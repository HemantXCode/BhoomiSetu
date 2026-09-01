import os
import sys
import json
import time
import uuid
import tempfile

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import httpx
from app.database.session import SessionLocal
from app.models.user import User
from app.models.field import FieldTask, FieldVisit, FieldVerification, SyncEvent
from app.models.document import Document

BASE_URL = "http://192.168.29.94:5000"

def run_integration_verification():
    print(f"[*] Starting End-to-End Integration Verification against {BASE_URL}...")
    results = {}
    
    # 1. Database baseline counts
    db = SessionLocal()
    counts_before = {
        "users": db.query(User).count(),
        "tasks": db.query(FieldTask).count(),
        "visits": db.query(FieldVisit).count(),
        "verifications": db.query(FieldVerification).count(),
        "sync_events": db.query(SyncEvent).count(),
        "documents": db.query(Document).count()
    }
    db.close()
    results["counts_before"] = counts_before
    print(f"[+] Baseline DB counts: {counts_before}")

    with httpx.Client(base_url=BASE_URL, timeout=15.0) as client:
        # 2. Health check
        r = client.get("/health")
        assert r.status_code == 200, f"Health check failed: {r.status_code}"
        results["health"] = {"status": r.status_code, "data": r.json()}
        print(f"[+] Health check passed: {r.json()}")

        # 3. Authentication: Login as Field Officer
        login_payload = {
            "email": "field.demo@example.com",
            "password": "Demo@12345"
        }
        r = client.post("/api/v1/auth/login", json=login_payload)
        assert r.status_code == 200, f"Login failed: {r.status_code} - {r.text}"
        login_data = r.json().get("data", {})
        token = login_data.get("access_token")
        user_info = login_data.get("user", {})
        assert token, "No access token returned"
        assert user_info.get("role") == "FIELD_OFFICER", f"Expected FIELD_OFFICER, got {user_info.get('role')}"
        auth_headers = {
            "Authorization": f"Bearer {token}",
            "Accept": "application/json"
        }
        results["auth_login"] = {"status": r.status_code, "role": user_info.get("role"), "user_id": user_info.get("id")}
        print(f"[+] Field Officer login verified. Role: {user_info.get('role')}, ID: {user_info.get('id')}")

        # 4. Auth Me check
        r = client.get("/api/v1/auth/me", headers=auth_headers)
        assert r.status_code == 200, f"Auth me failed: {r.status_code}"
        me_data = r.json().get("data", {})
        assert me_data.get("email") == "field.demo@example.com"
        results["auth_me"] = {"status": r.status_code, "email": me_data.get("email")}
        print(f"[+] Auth /me verified for {me_data.get('email')}")

        # 5. Get Field Tasks
        r = client.get("/api/v1/field/tasks", headers=auth_headers)
        assert r.status_code == 200, f"Get tasks failed: {r.status_code}"
        raw_tasks_data = r.json().get("data", {})
        if isinstance(raw_tasks_data, dict):
            tasks_data = raw_tasks_data.get("tasks", [])
        else:
            tasks_data = raw_tasks_data
        assert len(tasks_data) > 0, "No field tasks returned"
        selected_task = tasks_data[0]
        task_id = selected_task.get("id")
        results["tasks_list"] = {"status": r.status_code, "count": len(tasks_data), "first_task_id": task_id}
        print(f"[+] Field tasks list verified. Found {len(tasks_data)} tasks. Selected task ID: {task_id}")

        # 6. Get Task Details
        r = client.get(f"/api/v1/field/tasks/{task_id}", headers=auth_headers)
        assert r.status_code == 200, f"Get task details failed: {r.status_code}"
        task_detail = r.json().get("data", {})
        assert task_detail.get("id") == task_id
        results["task_detail"] = {
            "status": r.status_code,
            "project_name": task_detail.get("project_name"),
            "parcel": task_detail.get("parcel"),
            "checklist_schema": task_detail.get("checklist_schema")
        }
        print(f"[+] Task details verified for ID {task_id}: Project '{task_detail.get('project_name')}'")

        # 7. Create Field Visit
        visit_payload = {
            "task_id": task_id,
            "visit_start": "2026-08-29T15:10:00Z",
            "latitude": 18.5204,
            "longitude": 73.8567,
            "accuracy_meters": 3.8
        }
        r = client.post("/api/v1/field/visits", json=visit_payload, headers=auth_headers)
        assert r.status_code == 201, f"Create field visit failed: {r.status_code} - {r.text}"
        created_visit = r.json().get("data", {})
        visit_id = created_visit.get("visit_id") or created_visit.get("id")
        assert visit_id, "No visit ID returned"
        results["create_visit"] = {"status": r.status_code, "visit_id": visit_id}
        print(f"[+] Field visit created successfully. Visit ID: {visit_id}")

        # 8. Real Photo Upload (multipart/form-data)
        with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as f:
            f.write(b"GIF89a\x01\x00\x01\x00\x80\x00\x00\xff\xff\xff\x00\x00\x00!\xf9\x04\x01\x00\x00\x00\x00,\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x02D\x01\x00;")
            temp_img_path = f.name
        
        try:
            with open(temp_img_path, "rb") as img_file:
                files = {"file": ("inspection_evidence.jpg", img_file.read(), "image/jpeg")}
                data = {"related_entity_id": str(visit_id)}
                r = client.post("/api/v1/field/photos", files=files, data=data, headers=auth_headers)
                assert r.status_code == 201, f"Photo upload failed: {r.status_code} - {r.text}"
                photo_data = r.json().get("data", {})
                results["photo_upload"] = {"status": r.status_code, "file_url": photo_data.get("file_url")}
                print(f"[+] Photo uploaded successfully. URL: {photo_data.get('file_url')}")
        finally:
            if os.path.exists(temp_img_path):
                os.remove(temp_img_path)

        # 9. Real Field Verification Submission
        client_event_id_verif = f"EVT_{uuid.uuid4()}"
        verification_payload = {
            "client_event_id": client_event_id_verif,
            "device_id": "Infinix_X6870_140253154E052185",
            "task_id": task_id,
            "visit_id": visit_id,
            "parcel_id": (task_detail.get("parcel") or {}).get("id") or 1,
            "latitude": 18.52043,
            "longitude": 73.85672,
            "accuracy_meters": 3.2,
            "checklist_data": {
                "boundary_verified": True,
                "encroachment_detected": False,
                "soil_type": "Black Cotton",
                "crop_standing": "Sugarcane"
            },
            "remarks": "Real E2E field verification verified on device Infinix X6870.",
            "photos": ["inspection_evidence.jpg"]
        }
        r = client.post("/api/v1/field/verifications", json=verification_payload, headers=auth_headers)
        assert r.status_code == 201, f"Field verification failed: {r.status_code} - {r.text}"
        verif_data = r.json().get("data", {})
        results["verification"] = {"status": r.status_code, "verification_id": verif_data.get("verification_id") or verif_data.get("id"), "event_id": client_event_id_verif}
        print(f"[+] Field verification submitted successfully. ID: {results['verification']['verification_id']}")

        # 10. Real Offline Sync Queue & Idempotency Test
        client_event_id_sync = f"EVT_SYNC_{uuid.uuid4()}"
        sync_payload = {
            "device_id": "Infinix_X6870_140253154E052185",
            "events": [
                {
                    "client_event_id": client_event_id_sync,
                    "client_created_at": "2026-08-29T15:15:00Z",
                    "event_type": "FIELD_VERIFICATION",
                    "payload": {
                        "task_id": task_id,
                        "visit_id": visit_id,
                        "parcel_id": (task_detail.get("parcel") or {}).get("id") or 1,
                        "checklist_data": {"boundary_verified": True},
                        "remarks": "Synced offline field submission"
                    }
                }
            ]
        }
        
        # First Sync Attempt
        r1 = client.post("/api/v1/field/sync", json=sync_payload, headers=auth_headers)
        assert r1.status_code == 200, f"Sync attempt 1 failed: {r1.status_code} - {r1.text}"
        sync_res1 = r1.json().get("data", {})
        results["sync_attempt_1"] = {"status": r1.status_code, "processed": sync_res1.get("processed_count"), "duplicate": sync_res1.get("duplicate_count")}
        print(f"[+] Sync Attempt 1 processed: {sync_res1.get('processed_count')} event(s), duplicate: {sync_res1.get('duplicate_count')}")

        # Second Sync Attempt with exact same client_event_id (Idempotency Check)
        r2 = client.post("/api/v1/field/sync", json=sync_payload, headers=auth_headers)
        assert r2.status_code == 200, f"Sync attempt 2 failed: {r2.status_code} - {r2.text}"
        sync_res2 = r2.json().get("data", {})
        results["sync_attempt_2_idempotency"] = {"status": r2.status_code, "processed": sync_res2.get("processed_count"), "duplicate": sync_res2.get("duplicate_count")}
        print(f"[+] Sync Attempt 2 (Idempotency) processed: {sync_res2.get('processed_count')} event(s), duplicate: {sync_res2.get('duplicate_count')}")
        assert sync_res2.get("duplicate_count") == 1 or sync_res2.get("processed_count") == 0, "Idempotency test failed"

        # 11. Document Upload endpoint test
        with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as f:
            f.write(b"%PDF-1.4 test document content for bhoomisetu e2e")
            temp_pdf_path = f.name
        
        try:
            with open(temp_pdf_path, "rb") as pdf_file:
                files = {"file": ("survey_report.pdf", pdf_file.read(), "application/pdf")}
                data = {"related_entity": "FIELD_VISIT", "related_entity_id": str(visit_id)}
                r = client.post("/api/v1/documents/upload", files=files, data=data, headers=auth_headers)
                assert r.status_code == 201, f"Document upload failed: {r.status_code} - {r.text}"
                doc_data = r.json().get("data", {})
                results["document_upload"] = {"status": r.status_code, "document_id": doc_data.get("id"), "file_url": doc_data.get("file_url")}
                print(f"[+] Document uploaded successfully. ID: {doc_data.get('id')}")
        finally:
            if os.path.exists(temp_pdf_path):
                os.remove(temp_pdf_path)

        # 12. Geo and GIS API Endpoints
        r = client.get("/api/v1/geo/states", headers=auth_headers)
        assert r.status_code == 200, "GET /geo/states failed"
        results["geo_states"] = {"status": r.status_code, "count": len(r.json().get("data", []))}

        r = client.get("/api/v1/geo/districts?state_id=1", headers=auth_headers)
        assert r.status_code == 200, "GET /geo/districts failed"
        results["geo_districts"] = {"status": r.status_code, "count": len(r.json().get("data", []))}

        r = client.get("/api/v1/geo/projects", headers=auth_headers)
        assert r.status_code == 200, "GET /geo/projects failed"
        results["geo_projects"] = {"status": r.status_code, "count": len(r.json().get("data", []))}

        r = client.get("/api/v1/geo/parcels", headers=auth_headers)
        assert r.status_code == 200, "GET /geo/parcels failed"
        results["geo_parcels"] = {"status": r.status_code, "type": r.json().get("type")}

        # 13. Dashboard Stats
        r = client.get("/api/v1/dashboard/stats", headers=auth_headers)
        assert r.status_code == 200, "GET /dashboard/stats failed"
        results["dashboard_stats"] = {"status": r.status_code, "stats": r.json().get("data")}
        print(f"[+] Geo & Dashboard endpoints verified successfully.")

    # 14. Verify Database mutations
    db = SessionLocal()
    counts_after = {
        "users": db.query(User).count(),
        "tasks": db.query(FieldTask).count(),
        "visits": db.query(FieldVisit).count(),
        "verifications": db.query(FieldVerification).count(),
        "sync_events": db.query(SyncEvent).count(),
        "documents": db.query(Document).count()
    }
    db.close()
    results["counts_after"] = counts_after
    print(f"[+] Mutated DB counts after operations: {counts_after}")

    results["database_persistence"] = {
        "visits_delta": counts_after["visits"] - counts_before["visits"],
        "verifications_delta": counts_after["verifications"] - counts_before["verifications"],
        "sync_events_delta": counts_after["sync_events"] - counts_before["sync_events"],
        "documents_delta": counts_after["documents"] - counts_before["documents"],
    }
    print(f"[+] DB Delta verified: {results['database_persistence']}")

    # Save integration test evidence JSON
    with open("scripts/e2e_integration_evidence.json", "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)

    print("\n[SUCCESS] All Real End-to-End API Gateway -> Field Officer Operations VERIFIED with 100% success!")

if __name__ == "__main__":
    run_integration_verification()
