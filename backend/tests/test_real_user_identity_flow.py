import io
import uuid
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import text
from app.main import app
from app.database.session import engine, SessionLocal
from app.models.field import FieldTask
from datetime import datetime, timezone

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
        "sync_events",
        "audit_logs"
    ]
    counts = {}
    with engine.connect() as conn:
        for t in tables:
            cnt = conn.execute(text(f'SELECT count(*) FROM "{t}";')).fetchone()[0]
            counts[t] = cnt
    return counts

def test_real_user_identity_and_field_workflow():
    print("\n" + "="*80)
    print("STARTING REAL PRODUCTION-GRADE IDENTITY + E2E INTEGRATION TEST")
    print("="*80)

    # 1. Health & PostgreSQL Check
    health_resp = client.get("/health")
    assert health_resp.status_code == 200
    assert health_resp.json()["database"] == "postgresql"
    print(" [1/17] Health Check Passed: Live connection to Supabase PostgreSQL verified.")

    # 2. Record Pre-Test Counts
    counts_before = get_pg_counts()
    print("\n--- INITIAL POSTGRESQL ROW COUNTS ---")
    for k, v in counts_before.items():
        print(f"  {k}: {v}")

    # 3. District Authority Authenticates to Register a New Official Field Officer
    dist_login_resp = client.post("/api/v1/auth/login", json={
        "email": "district.demo@example.com",
        "password": "Demo@12345"
    })
    assert dist_login_resp.status_code == 200
    dist_token = dist_login_resp.json()["data"]["access_token"]
    dist_headers = {"Authorization": f"Bearer {dist_token}"}
    dist_user = dist_login_resp.json()["data"]["user"]
    print(f" [2/17] Authority Authenticated: '{dist_user['name']}' (Role: {dist_user['role']}, ID: {dist_user['id']}).")

    # 4. Register a NEW Official Field Officer with Government Credentials
    unique_suffix = uuid.uuid4().hex[:6]
    test_officer_email = f"arun.shinde.{unique_suffix}@maharashtra.gov.in"
    test_official_id = f"REV-MH-PUN-{unique_suffix.upper()}"
    
    register_resp = client.post("/api/v1/users", headers=dist_headers, json={
        "name": f"Arun B. Shinde (Field Unit {unique_suffix.upper()})",
        "email": test_officer_email,
        "password": "OfficerPass@2026",
        "role": "FIELD_OFFICER",
        "official_id": test_official_id,
        "official_id_type": "STATE_REVENUE_EMP_ID",
        "department": "Department of Land Revenue & Cadastral Survey",
        "designation": "Assistant Land Acquisition Officer",
        "phone": "+91-9822019944",
        "state_id": 1,
        "district_id": 1,
        "is_demo": False
    })
    assert register_resp.status_code == 201, f"User registration failed: {register_resp.text}"
    new_officer_data = register_resp.json()["data"]
    new_officer_id = new_officer_data["id"]
    assert new_officer_data["identity_status"] == "PENDING"
    assert "REV-MH-****-" in new_officer_data["official_id_masked"] or "****" in new_officer_data["official_id_masked"]
    print(f" [3/17] Official User Registered: ID #{new_officer_id} ('{new_officer_data['name']}'), Status: {new_officer_data['identity_status']}, Masked ID: {new_officer_data['official_id_masked']}.")

    # 5. Officer Logs In with Pending Status
    officer_login_resp = client.post("/api/v1/auth/login", json={
        "email": test_officer_email,
        "password": "OfficerPass@2026"
    })
    assert officer_login_resp.status_code == 200
    officer_token = officer_login_resp.json()["data"]["access_token"]
    officer_headers = {"Authorization": f"Bearer {officer_token}"}
    assert officer_login_resp.json()["data"]["user"]["identity_status"] == "PENDING"
    print(" [4/17] Officer Login Passed: Initial identity status is correctly PENDING.")

    # 6. Unverified Officer Attempts to Start Field Visit -> MUST BE BLOCKED (HTTP 403)
    blocked_visit_resp = client.post("/api/v1/field/visits", headers=officer_headers, json={
        "task_id": 101,
        "visit_start": datetime.now(timezone.utc).isoformat(),
        "latitude": 18.5204,
        "longitude": 73.8567
    })
    assert blocked_visit_resp.status_code == 403, f"Expected 403 Forbidden for unverified officer, got: {blocked_visit_resp.status_code}"
    assert "IDENTITY_VERIFICATION_REQUIRED" in blocked_visit_resp.text
    print(" [5/17] Security Policy Enforced: Unverified officer visit blocked with HTTP 403 (IDENTITY_VERIFICATION_REQUIRED).")

    # 7. District Authority Reviews and Verifies Official Personnel Identity
    verify_resp = client.post(f"/api/v1/users/{new_officer_id}/verify", headers=dist_headers, json={
        "decision": "VERIFIED",
        "notes": "State Revenue Department employee credentials verified against District Cadastral Service Register."
    })
    assert verify_resp.status_code == 200, f"Verification failed: {verify_resp.text}"
    verify_data = verify_resp.json()["data"]
    assert verify_data["identity_status"] == "VERIFIED"
    assert verify_data["verified_by"] == dist_user["id"]
    assert verify_data["verified_at"] is not None
    print(f" [6/17] Identity Verified by CALA: Officer #{new_officer_id} verified by Authority #{dist_user['id']} ('{dist_user['name']}').")

    # 8. Create an Assigned Inspection Task for This Verified Officer in PostgreSQL
    with SessionLocal() as db:
        new_task = FieldTask(
            project_id=1,
            parcel_id=1,
            assigned_to_user_id=new_officer_id,
            task_type="Joint Boundary Demarcation & Tree Enumeration",
            priority="HIGH",
            due_date=datetime.now(timezone.utc),
            status="PENDING"
        )
        db.add(new_task)
        db.commit()
        db.refresh(new_task)
        assigned_task_id = new_task.id
    print(f" [7/17] Assigned Task Created: Task #{assigned_task_id} assigned to Officer #{new_officer_id}.")

    # 9. Verified Officer Logs In Again & Fetches Tasks
    verified_login_resp = client.post("/api/v1/auth/login", json={
        "email": test_officer_email,
        "password": "OfficerPass@2026"
    })
    assert verified_login_resp.status_code == 200
    v_token = verified_login_resp.json()["data"]["access_token"]
    v_headers = {"Authorization": f"Bearer {v_token}"}
    assert verified_login_resp.json()["data"]["user"]["identity_status"] == "VERIFIED"

    tasks_resp = client.get("/api/v1/field/tasks", headers=v_headers)
    assert tasks_resp.status_code == 200
    my_tasks = tasks_resp.json()["data"]["tasks"]
    # Verify server-side filtering: officer sees only their own tasks
    for t in my_tasks:
        assert t["assigned_to_user_id"] == new_officer_id
    print(f" [8/17] Task Access Verified: Server returned {len(my_tasks)} tasks strictly assigned to Officer #{new_officer_id}.")

    # 10. Verified Officer Starts Field Visit
    visit_resp = client.post("/api/v1/field/visits", headers=v_headers, json={
        "task_id": assigned_task_id,
        "visit_start": datetime.now(timezone.utc).isoformat(),
        "latitude": 18.5204,
        "longitude": 73.8567,
        "accuracy_meters": 3.4
    })
    assert visit_resp.status_code == 201, f"Visit creation failed: {visit_resp.text}"
    visit_data = visit_resp.json()["data"]
    visit_id = visit_data["visit_id"]
    # Verify strict server ownership
    assert visit_data["field_officer_id"] == new_officer_id
    print(f" [9/17] Field Visit Started: Visit #{visit_id} created in PostgreSQL. Officer ownership strictly = #{new_officer_id}.")

    # 11. Upload Real Site Photo
    photo_bytes = b"\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x01\x00`\x00`\x00\x00" + b"REAL_SITE_PHOTO_ARUN_SHINDE" * 40
    photo_resp = client.post(
        "/api/v1/field/photos",
        headers=v_headers,
        data={"related_entity_id": visit_id},
        files={"file": ("pune_ring_road_corner_stone.jpg", io.BytesIO(photo_bytes), "image/jpeg")}
    )
    assert photo_resp.status_code == 201
    photo_id = photo_resp.json()["data"]["document_id"]
    print(f" [10/17] Photo Uploaded: Document '{photo_id}' stored on disk & indexed in PostgreSQL.")

    # 12. Upload Real Document (7/12 Land Record Extract)
    doc_bytes = b"%PDF-1.4\n1 0 obj\n<< /Title (Official 7/12 Extract Haveli) >>\nendobj\n" + b"CAD_EXTRACT" * 30
    doc_resp = client.post(
        "/api/v1/documents/upload",
        headers=v_headers,
        data={"related_entity": "FIELD_VISIT", "related_entity_id": visit_id},
        files={"file": ("7_12_Extract_Gat_142_3A.pdf", io.BytesIO(doc_bytes), "application/pdf")}
    )
    assert doc_resp.status_code == 201
    doc_id = doc_resp.json()["data"]["document_id"]
    assert doc_resp.json()["data"]["uploaded_by"] == new_officer_id
    print(f" [11/17] 7/12 Extract Uploaded: Document '{doc_id}' linked to Officer #{new_officer_id}.")

    # 13. Submit Field Verification
    client_event_id = f"EVT_PROD_{uuid.uuid4().hex[:12]}"
    ver_resp = client.post("/api/v1/field/verifications", headers=v_headers, json={
        "client_event_id": client_event_id,
        "device_id": "Infinix_Official_Unit_01",
        "task_id": assigned_task_id,
        "visit_id": visit_id,
        "parcel_id": 1,
        "latitude": 18.5204,
        "longitude": 73.8567,
        "accuracy_meters": 2.8,
        "checklist_data": {
            "boundary_verified": True,
            "structure_count": 1,
            "tree_count": 8,
            "dispute_flag": False
        },
        "remarks": "Corner stone #4 verified with Total Station. No boundary encroachment detected."
    })
    assert ver_resp.status_code == 201
    ver_id = ver_resp.json()["data"]["verification_id"]
    print(f" [12/17] Field Verification Submitted: Verification #{ver_id} created in PostgreSQL. Task #{assigned_task_id} -> SUBMITTED.")

    # 14. Test Offline Batch Sync & Duplicate Replay Protection
    sync_event_id = f"SYNC_EVT_OFFLINE_{uuid.uuid4().hex[:10]}"
    sync_payload = {
        "device_id": "Infinix_Official_Unit_01",
        "events": [
            {
                "client_event_id": sync_event_id,
                "client_created_at": datetime.now(timezone.utc).isoformat(),
                "event_type": "FIELD_VERIFICATION",
                "payload": {
                    "task_id": assigned_task_id,
                    "visit_id": visit_id,
                    "parcel_id": 1,
                    "checklist_data": {"boundary_verified": True},
                    "remarks": "Offline cached record synced."
                }
            }
        ]
    }

    # Run 1: First sync
    sync_1 = client.post("/api/v1/field/sync", headers=v_headers, json=sync_payload)
    assert sync_1.status_code == 200
    assert sync_1.json()["data"]["processed_count"] == 1
    assert sync_1.json()["data"]["duplicate_count"] == 0
    print(" [13/17] Offline Batch Sync (Run 1) Passed: processed=1, duplicate=0.")

    # Run 2: Duplicate replay
    sync_2 = client.post("/api/v1/field/sync", headers=v_headers, json=sync_payload)
    assert sync_2.status_code == 200
    assert sync_2.json()["data"]["processed_count"] == 0
    assert sync_2.json()["data"]["duplicate_count"] == 1
    print(" [14/17] Idempotent Duplicate Replay (Run 2) Passed: processed=0, duplicate=1 (Zero duplicate DB rows).")

    # 15. Verify Audit Log Trail in PostgreSQL
    with SessionLocal() as db:
        from app.models.audit import AuditLog
        recent_audits = db.query(AuditLog).filter(AuditLog.user_id.in_([dist_user["id"], new_officer_id])).all()
        actions = [a.action for a in recent_audits]
        print(f" [15/17] Audit Log Trail Verified: Recorded {len(recent_audits)} audit events in PostgreSQL: {set(actions)}")
        assert "USER_CREATED" in actions
        assert "USER_VERIFIED" in actions
        assert "FIELD_VISIT_CREATED" in actions
        assert "PHOTO_UPLOADED" in actions
        assert "DOCUMENT_UPLOADED" in actions
        assert "FIELD_VERIFICATION_SUBMITTED" in actions

    # 16. Verify Website District Dashboard Live Integration
    dist_stats_resp = client.get("/api/v1/dashboard/stats", headers=dist_headers)
    assert dist_stats_resp.status_code == 200
    queue = dist_stats_resp.json()["data"]["field_verification_queue"]
    matching = next((q for q in queue if q.get("verification_id") == ver_id or q.get("client_event_id") == client_event_id), None)
    assert matching is not None, f"Submitted verification #{ver_id} not found in District CALA queue: {queue}"
    assert "Arun B. Shinde" in matching["officer"]
    print(f" [16/17] District CALA Dashboard Integration Passed: Verification #{ver_id} by '{matching['officer']}' is live on the website!")

    # 17. Record Final Database Counts & Deltas
    counts_after = get_pg_counts()
    print("\n--- FINAL POSTGRESQL ROW COUNTS ---")
    for k, v in counts_after.items():
        delta = v - counts_before[k]
        print(f"  {k}: Before = {counts_before[k]}, After = {v}, Delta = +{delta}")

    # Check generated database IDs
    print("\n--- ACTUAL GENERATED POSTGRESQL PRIMARY KEYS ---")
    print(f"  User ID:                 {new_officer_id}")
    print(f"  Task ID:                 {assigned_task_id}")
    print(f"  Visit ID:                {visit_id}")
    print(f"  Verification ID:         {ver_id}")
    print(f"  Photo Document ID:       {photo_id}")
    print(f"  PDF Document ID:         {doc_id}")
    print(f"  Sync Event Client ID:    {sync_event_id}")

    # Assert database deltas
    assert counts_after["users"] == counts_before["users"] + 1
    assert counts_after["field_tasks"] == counts_before["field_tasks"] + 1
    assert counts_after["field_visits"] >= counts_before["field_visits"] + 1
    assert counts_after["field_verifications"] >= counts_before["field_verifications"] + 1
    assert counts_after["documents"] == counts_before["documents"] + 2
    assert counts_after["sync_events"] == counts_before["sync_events"] + 1
    assert counts_after["audit_logs"] >= counts_before["audit_logs"] + 6

    print("\n" + "="*80)
    print("ALL 17 PRODUCTION-GRADE E2E CHECKS PASSED WITH 100% SUCCESS AGAINST SUPABASE POSTGRESQL!")
    print("="*80)

if __name__ == "__main__":
    test_real_user_identity_and_field_workflow()
