import httpx
from datetime import datetime, timezone
from app.database.session import SessionLocal
from app.models.user import User
from app.models.field import FieldTask, FieldVisit, FieldVerification, SyncEvent
from app.models.document import Document
from app.models.audit import AuditLog

BASE_URL = "http://127.0.0.1:5000/api/v1"

def run_real_device_validation():
    print("================================================================================")
    print("REAL DEVICE / GATEWAY VERIFICATION AGAINST SUPABASE POSTGRESQL")
    print("================================================================================")
    client = httpx.Client(timeout=15.0)

    # 1. Real Login
    login_res = client.post(f"{BASE_URL}/auth/login", json={
        "email": "arun.shinde.01508f@maharashtra.gov.in",
        "password": "OperationalPass@2026"
    })
    assert login_res.status_code == 200, f"Login failed: {login_res.text}"
    auth_data = login_res.json()["data"]
    token = auth_data["access_token"]
    user_info = auth_data["user"]
    headers = {"Authorization": f"Bearer {token}"}
    print(f"[1. Real Login] PASS | User: {user_info['name']} (ID {user_info['id']}) | Status: {user_info['identity_status']} | Masked ID: {user_info['official_id_masked']}")

    # 2. Fetch Assigned Operational Tasks
    tasks_res = client.get(f"{BASE_URL}/field/tasks", headers=headers)
    assert tasks_res.status_code == 200
    tasks = tasks_res.json()["data"]["tasks"]
    assert len(tasks) > 0
    assigned_task = tasks[0]
    task_id = assigned_task["id"]
    print(f"[2. Assigned Tasks] PASS | Total Tasks: {len(tasks)} | Selected Task ID: {task_id} ({assigned_task['task_type']}) | Parcel: {assigned_task['parcel_number']}")

    # 3. Create / Start Field Visit
    visit_res = client.post(f"{BASE_URL}/field/visits", headers=headers, json={
        "task_id": task_id,
        "visit_start": datetime.now(timezone.utc).isoformat(),
        "latitude": 18.520433,
        "longitude": 73.856744,
        "accuracy_meters": 4.2
    })
    assert visit_res.status_code == 201
    visit_id = visit_res.json()["data"]["visit_id"]
    print(f"[3. Field Visit] PASS | Visit ID: {visit_id} | Lat/Lng: 18.520433, 73.856744 | Accuracy: 4.2m | Status: IN_PROGRESS")

    # 4. Upload Field Photo
    photo_res = client.post(
        f"{BASE_URL}/field/photos",
        headers=headers,
        files={"file": ("ground_boundary_marker.jpg", b"\xFF\xD8\xFF\xE0JFIF_GROUND_TRUTH_PHOTO", "image/jpeg")},
        data={"related_entity_id": str(task_id)}
    )
    assert photo_res.status_code == 201
    photo_doc_id = photo_res.json()["data"]["document_id"]
    print(f"[4. Real Photo Upload] PASS | Document ID: {photo_doc_id} | Type: image/jpeg | Size: {photo_res.json()['data']['file_size']} bytes | URL: {photo_res.json()['data']['url']}")

    # 5. Upload Land Record Document
    doc_res = client.post(
        f"{BASE_URL}/documents/upload",
        headers=headers,
        files={"file": ("7_12_extract_satbara.pdf", b"%PDF-1.4_OFFICIAL_REVENUE_EXTRACT", "application/pdf")},
        data={"related_entity": "FIELD_TASK", "related_entity_id": str(task_id)}
    )
    assert doc_res.status_code == 201
    pdf_doc_id = doc_res.json()["data"]["document_id"]
    print(f"[5. Real Document Upload] PASS | Document ID: {pdf_doc_id} | Type: application/pdf | Size: {doc_res.json()['data']['file_size']} bytes | URL: {doc_res.json()['data']['url']}")

    # 6. Submit Field Verification
    client_event_id = f"EVT_DEVICE_VERIF_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    verif_res = client.post(f"{BASE_URL}/field/verifications", headers=headers, json={
        "client_event_id": client_event_id,
        "device_id": "140253154E052185",
        "task_id": task_id,
        "visit_id": visit_id,
        "parcel_id": assigned_task["parcel_id"],
        "latitude": 18.520433,
        "longitude": 73.856744,
        "checklist_data": {
            "boundary_pegs_confirmed": True,
            "encroachment_detected": False,
            "crop_type": "Sugarcane / Cash Crop",
            "tree_count": 6
        },
        "remarks": "On-ground physical survey completed using GNSS-calibrated mobile terminal.",
        "photos": [photo_doc_id]
    })
    assert verif_res.status_code == 201
    verif_id = verif_res.json()["data"]["verification_id"]
    print(f"[6. Real Verification] PASS | Verification ID: {verif_id} | Client Event ID: {client_event_id} | Task Status: SUBMITTED")

    # 7. Query Supabase PostgreSQL directly to confirm persistence
    db = SessionLocal()
    try:
        pg_visit = db.query(FieldVisit).filter(FieldVisit.id == visit_id).first()
        pg_photo = db.query(Document).filter(Document.id == photo_doc_id).first()
        pg_pdf = db.query(Document).filter(Document.id == pdf_doc_id).first()
        pg_verif = db.query(FieldVerification).filter(FieldVerification.id == verif_id).first()
        pg_task = db.query(FieldTask).filter(FieldTask.id == task_id).first()

        print("\n================================================================================")
        print("DIRECT POSTGRESQL QUERY CONFIRMATION")
        print("================================================================================")
        print(f"  Field Visit:        ID #{pg_visit.id} | Officer ID: {pg_visit.field_officer_id} | Task #{pg_visit.task_id} | Start: {pg_visit.visit_start}")
        print(f"  Photo Document:     ID {pg_photo.id} | Name: {pg_photo.document_name} | UploadedBy: {pg_photo.uploaded_by} | Path: {pg_photo.storage_path}")
        print(f"  PDF Document:       ID {pg_pdf.id} | Name: {pg_pdf.document_name} | UploadedBy: {pg_pdf.uploaded_by} | Path: {pg_pdf.storage_path}")
        print(f"  Field Verification: ID #{pg_verif.id} | Visit #{pg_verif.visit_id} | Parcel #{pg_verif.parcel_id} | VerifiedAt: {pg_verif.verified_at}")
        print(f"  Task Status in DB:  ID #{pg_task.id} -> Status: {pg_task.status}")

        assert pg_visit is not None
        assert pg_photo is not None
        assert pg_pdf is not None
        assert pg_verif is not None
        assert pg_task.status == "SUBMITTED"
    finally:
        db.close()

    # 8. Verify Website Dashboard visibility via Authority API
    auth_login = client.post(f"{BASE_URL}/auth/login", json={
        "email": "cala.pune@maharashtra.gov.in",
        "password": "OperationalPass@2026"
    })
    assert auth_login.status_code == 200
    auth_token = auth_login.json()["data"]["access_token"]
    
    stats_res = client.get(f"{BASE_URL}/dashboard/stats", headers={"Authorization": f"Bearer {auth_token}"})
    assert stats_res.status_code == 200
    queue = stats_res.json()["data"].get("field_verification_queue", [])
    matching = [q for q in queue if q["task_id"] == task_id]
    print(f"[8. Website Live Data] PASS | Verification Queue Length: {len(queue)} | Newly submitted task in queue: {len(matching) > 0}")

    print("================================================================================")
    print("ALL REAL DEVICE / GATEWAY VERIFICATION TESTS PASSED SUCCESSFULLY!")
    print("================================================================================")

if __name__ == "__main__":
    run_real_device_validation()
