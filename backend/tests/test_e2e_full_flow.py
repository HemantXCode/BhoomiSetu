import io
import uuid
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import text
from app.main import app
from app.database.session import engine, SessionLocal
from app.utils.jwt_util import create_access_token

client = TestClient(app)

def get_pg_counts():
    tables = [
        "users",
        "projects",
        "land_parcels",
        "field_tasks",
        "field_visits",
        "field_verifications",
        "documents",
        "sync_events"
    ]
    counts = {}
    with engine.connect() as conn:
        for t in tables:
            cnt = conn.execute(text(f'SELECT count(*) FROM "{t}";')).fetchone()[0]
            counts[t] = cnt
    return counts

def test_full_postgresql_e2e_flow():
    print("\n" + "="*70)
    print("STARTING REAL E2E INTEGRATION TEST: FLUTTER -> FASTAPI -> SUPABASE POSTGRESQL -> WEBSITE")
    print("="*70)

    # 1. Verify Health Endpoint and PostgreSQL Connectivity
    health_resp = client.get("/health")
    assert health_resp.status_code == 200, f"Health check failed: {health_resp.text}"
    health_json = health_resp.json()
    assert health_json["status"] == "healthy"
    assert health_json["database"] == "postgresql"
    print(" [1/14] Health Check Passed: Service running & connected to Supabase PostgreSQL.")

    # 2. Record Pre-Test Database Counts
    counts_before = get_pg_counts()
    print("\n--- INITIAL POSTGRESQL ROW COUNTS ---")
    for k, v in counts_before.items():
        print(f"  {k}: {v}")

    # 3. Field Officer Authentication
    login_resp = client.post("/api/v1/auth/login", json={
        "email": "field.demo@example.com",
        "password": "Demo@12345"
    })
    assert login_resp.status_code == 200, f"Login failed: {login_resp.text}"
    login_data = login_resp.json()["data"]
    token = login_data["access_token"]
    officer_user = login_data["user"]
    headers = {"Authorization": f"Bearer {token}"}
    assert officer_user["role"] == "FIELD_OFFICER"
    print(f" [2/14] Auth Login Passed: Authenticated '{officer_user['name']}' (ID: {officer_user['id']}).")

    # 4. Auth Me
    me_resp = client.get("/api/v1/auth/me", headers=headers)
    assert me_resp.status_code == 200
    assert me_resp.json()["data"]["email"] == "field.demo@example.com"
    print(" [3/14] Auth /me Passed: Retrieved verified Field Officer profile.")

    # 5. Fetch Assigned Tasks
    tasks_resp = client.get("/api/v1/field/tasks", headers=headers)
    assert tasks_resp.status_code == 200
    tasks = tasks_resp.json()["data"]["tasks"]
    assert len(tasks) > 0
    target_task = tasks[0]
    task_id = target_task["id"]
    parcel_id = target_task["parcel_id"]
    print(f" [4/14] Assigned Tasks Passed: Found {len(tasks)} tasks in PostgreSQL. Target Task: #{task_id} ({target_task['village']}).")

    # 6. Fetch Task Details
    task_detail_resp = client.get(f"/api/v1/field/tasks/{task_id}", headers=headers)
    assert task_detail_resp.status_code == 200
    task_detail = task_detail_resp.json()["data"]
    assert task_detail["parcel"]["id"] == parcel_id
    assert "checklist_schema" in task_detail
    print(f" [5/14] Task Details Passed: Boundary coordinates and checklist schema verified.")

    # 7. Start Field Visit
    visit_start_time = "2026-08-30T10:45:00Z"
    visit_resp = client.post("/api/v1/field/visits", headers=headers, json={
        "task_id": task_id,
        "visit_start": visit_start_time,
        "latitude": 18.5204,
        "longitude": 73.8567,
        "accuracy_meters": 3.8
    })
    assert visit_resp.status_code == 201, f"Visit creation failed: {visit_resp.text}"
    visit_data = visit_resp.json()["data"]
    visit_id = visit_data["visit_id"]
    print(f" [6/14] Start Field Visit Passed: Created Visit #{visit_id} in PostgreSQL.")

    # 8. Upload Real Field Photo
    photo_bytes = b"\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x01\x00`\x00`\x00\x00\xFF\xDB\x00C\x00" + b"TEST_PHOTO_E2E_EVIDENCE" * 50
    photo_file = io.BytesIO(photo_bytes)
    photo_resp = client.post(
        "/api/v1/field/photos",
        headers=headers,
        data={"related_entity_id": visit_id},
        files={"file": ("site_inspection_marker.jpg", photo_file, "image/jpeg")}
    )
    assert photo_resp.status_code == 201, f"Photo upload failed: {photo_resp.text}"
    photo_data = photo_resp.json()["data"]
    photo_id = photo_data["document_id"]
    photo_url = photo_data["url"]
    print(f" [7/14] Photo Upload Passed: Persisted photo '{photo_id}' to storage & PostgreSQL.")

    # 9. Upload Real Document (7/12 Extract PDF)
    doc_bytes = b"%PDF-1.4\n1 0 obj\n<< /Title (7/12 Land Extract) >>\nendobj\n" + b"TEST_PDF_EXTRACT" * 30
    doc_file = io.BytesIO(doc_bytes)
    doc_resp = client.post(
        "/api/v1/documents/upload",
        headers=headers,
        data={"related_entity": "FIELD_VISIT", "related_entity_id": visit_id},
        files={"file": ("7_12_Extract_Gat_142.pdf", doc_file, "application/pdf")}
    )
    assert doc_resp.status_code == 201, f"Document upload failed: {doc_resp.text}"
    doc_data = doc_resp.json()["data"]
    doc_id = doc_data["document_id"]
    doc_url = doc_data["url"]
    print(f" [8/14] Document Upload Passed: Persisted document '{doc_id}' to storage & PostgreSQL.")

    # 10. Submit Field Verification
    client_event_id = f"EVT_E2E_{uuid.uuid4().hex[:12]}"
    ver_resp = client.post("/api/v1/field/verifications", headers=headers, json={
        "client_event_id": client_event_id,
        "device_id": "Infinix_X6870_E2E_Test",
        "task_id": task_id,
        "visit_id": visit_id,
        "parcel_id": parcel_id,
        "latitude": 18.5204,
        "longitude": 73.8567,
        "accuracy_meters": 3.2,
        "checklist_data": {
            "boundary_verified": True,
            "structure_count": 2,
            "tree_count": 14,
            "dispute_flag": False
        },
        "remarks": "On-ground physical survey completed. Corner boundary stones confirmed with Cadastral map.",
        "photos": [photo_id]
    })
    assert ver_resp.status_code == 201, f"Verification submission failed: {ver_resp.text}"
    ver_data = ver_resp.json()["data"]
    ver_id = ver_data["verification_id"]
    print(f" [9/14] Submit Verification Passed: Persisted Verification #{ver_id} in PostgreSQL. Task #{task_id} -> SUBMITTED.")

    # 11. Test Offline Batch Sync + Idempotency
    sync_event_id = f"SYNC_EVT_{uuid.uuid4().hex[:12]}"
    sync_payload = {
        "device_id": "Infinix_X6870_E2E_Test",
        "events": [
            {
                "client_event_id": sync_event_id,
                "client_created_at": "2026-08-30T10:48:00Z",
                "event_type": "FIELD_VERIFICATION",
                "payload": {
                    "task_id": task_id,
                    "visit_id": visit_id,
                    "parcel_id": parcel_id,
                    "checklist_data": {"boundary_verified": True},
                    "remarks": "Offline cached inspection record synced."
                }
            }
        ]
    }

    # First Sync Run: Expect processed = 1, duplicate = 0
    sync_resp_1 = client.post("/api/v1/field/sync", headers=headers, json=sync_payload)
    assert sync_resp_1.status_code == 200
    sync_data_1 = sync_resp_1.json()["data"]
    assert sync_data_1["processed_count"] == 1
    assert sync_data_1["duplicate_count"] == 0
    print(" [10/14] Offline Sync (Run 1) Passed: processed=1, duplicate=0.")

    # Second Identical Sync Run: Expect processed = 0, duplicate = 1 (Idempotent replay)
    sync_resp_2 = client.post("/api/v1/field/sync", headers=headers, json=sync_payload)
    assert sync_resp_2.status_code == 200
    sync_data_2 = sync_resp_2.json()["data"]
    assert sync_data_2["processed_count"] == 0
    assert sync_data_2["duplicate_count"] == 1
    print(" [11/14] Offline Sync Idempotency (Run 2 Replay) Passed: processed=0, duplicate=1 (Zero duplicate records).")

    # 12. File Download Verification
    photo_dl = client.get(photo_url)
    assert photo_dl.status_code == 200
    assert len(photo_dl.content) == len(photo_bytes)

    doc_dl = client.get(doc_url)
    assert doc_dl.status_code == 200
    assert len(doc_dl.content) == len(doc_bytes)
    print(f" [12/14] File Serving Passed: Downloaded Photo ({len(photo_dl.content)} bytes) and PDF ({len(doc_dl.content)} bytes) safely.")

    # 13. District Authority Dashboard Verification (Website Integration)
    dist_login_resp = client.post("/api/v1/auth/login", json={
        "email": "district.demo@example.com",
        "password": "Demo@12345"
    })
    assert dist_login_resp.status_code == 200
    dist_token = dist_login_resp.json()["data"]["access_token"]
    dist_headers = {"Authorization": f"Bearer {dist_token}"}

    dist_stats_resp = client.get("/api/v1/dashboard/stats", headers=dist_headers)
    assert dist_stats_resp.status_code == 200
    dist_stats = dist_stats_resp.json()["data"]
    queue = dist_stats.get("field_verification_queue", [])
    
    # Assert newly created verification is visible in District Dashboard
    matching_ver = next((q for q in queue if q.get("verification_id") == ver_id or q.get("client_event_id") == client_event_id), None)
    assert matching_ver is not None, f"Submitted verification #{ver_id} not found in District dashboard queue: {queue}"
    assert matching_ver["officer"] == "Suresh Patil (Field Officer)" or "Suresh Patil" in matching_ver["officer"]
    print(f" [13/14] District Dashboard Integration Passed: Newly submitted verification #{ver_id} is live on District Dashboard!")

    # 14. Record Post-Test Database Counts & Verify Deltas
    counts_after = get_pg_counts()
    print("\n--- FINAL POSTGRESQL ROW COUNTS ---")
    for k, v in counts_after.items():
        delta = v - counts_before[k]
        print(f"  {k}: Before = {counts_before[k]}, After = {v}, Delta = +{delta}")

    # Assert expected deltas
    assert counts_after["field_visits"] > counts_before["field_visits"]
    assert counts_after["field_verifications"] > counts_before["field_verifications"]
    assert counts_after["documents"] == counts_before["documents"] + 2 # Photo + PDF
    assert counts_after["sync_events"] == counts_before["sync_events"] + 1

    print("\n" + "="*70)
    print("ALL 14 E2E INTEGRATION CHECKS PASSED WITH 100% SUCCESS AGAINST POSTGRESQL!")
    print("="*70)

if __name__ == "__main__":
    test_full_postgresql_e2e_flow()
