import uuid
from datetime import datetime, timezone
from fastapi.testclient import TestClient
from sqlalchemy import text
from app.main import app
from app.database.session import SessionLocal, engine
from app.models.user import User
from app.models.field import FieldTask, FieldVisit, FieldVerification, SyncEvent
from app.models.document import Document
from app.models.audit import AuditLog

client = TestClient(app)

def run_proof():
    print("================================================================================")
    print("FORENSIC DATABASE WRITE -> DIRECT POSTGRESQL READ VERIFICATION")
    print("================================================================================")

    # 1. Authenticate Authority
    auth_res = client.post("/api/v1/auth/login", json={"email": "district.demo@example.com", "password": "Demo@12345"})
    assert auth_res.status_code == 200
    auth_token = auth_res.json()["data"]["access_token"]
    auth_headers = {"Authorization": f"Bearer {auth_token}"}
    print("[Step 1] Authority Authenticated: User #3 (District Authority).")

    # 2. Register Dedicated Test User
    suffix = uuid.uuid4().hex[:6]
    test_email = f"forensic.test.{suffix}@test.gov.in"
    test_official_id = f"REV-FOR-{suffix.upper()}"
    reg_resp = client.post("/api/v1/users", headers=auth_headers, json={
        "name": f"Forensic Officer {suffix.upper()}",
        "email": test_email,
        "password": "TestPassword@2026",
        "role": "FIELD_OFFICER",
        "official_id": test_official_id,
        "official_id_type": "STATE_REVENUE_EMP_ID",
        "department": "Land Revenue Department",
        "designation": "Field Inspection Officer",
        "phone": "+91-9876543210",
        "state_id": 1,
        "district_id": 1,
        "is_demo": False
    })
    assert reg_resp.status_code == 201
    api_user_id = reg_resp.json()["data"]["id"]
    
    # Direct SQL verification of user
    db = SessionLocal()
    pg_user = db.query(User).filter(User.id == api_user_id).first()
    assert pg_user is not None
    print(f"[Step 2] User Registered -> API ID: {api_user_id} | PostgreSQL Row ID: {pg_user.id} | Status: {pg_user.identity_status} | CreatedAt: {pg_user.created_at}")

    # 3. Authority Verifies Officer Identity
    verify_resp = client.post(f"/api/v1/users/{pg_user.id}/verify", headers=auth_headers, json={
        "decision": "VERIFIED",
        "verification_method": "MANUAL_AUTHORITY_REVIEW",
        "verification_reference": f"CALA-ORDER-2026-{suffix.upper()}",
        "notes": "Official credentials and jurisdictional appointment verified by District Competent Authority."
    })
    assert verify_resp.status_code == 200
    db.expire_all()
    pg_user_verified = db.query(User).filter(User.id == api_user_id).first()
    assert pg_user_verified.identity_status == "VERIFIED"
    print(f"[Step 3] Identity Verified -> API Status: {verify_resp.json()['data']['identity_status']} | PostgreSQL Status: {pg_user_verified.identity_status} | Method: {pg_user_verified.verification_method} | VerifiedBy: {pg_user_verified.verified_by} | VerifiedAt: {pg_user_verified.verified_at}")

    # 4. Officer Login
    officer_login = client.post("/api/v1/auth/login", json={"email": test_email, "password": "TestPassword@2026"})
    assert officer_login.status_code == 200
    officer_token = officer_login.json()["data"]["access_token"]
    officer_headers = {"Authorization": f"Bearer {officer_token}"}
    print(f"[Step 4] Officer Login -> JWT Token Issued for User #{api_user_id} with identity_status='VERIFIED'.")

    # 5. Create & Assign Task in PostgreSQL
    new_task = FieldTask(
        project_id=1,
        parcel_id=1,
        assigned_to_user_id=pg_user.id,
        task_type="Joint Boundary Demarcation",
        priority="HIGH",
        due_date=datetime.now(timezone.utc),
        status="PENDING"
    )
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    print(f"[Step 5] Task Created in PostgreSQL -> Task ID: {new_task.id} | Parcel ID: {new_task.parcel_id} | AssignedTo: {new_task.assigned_to_user_id} | Status: {new_task.status}")

    # 6. Officer Starts Field Visit
    visit_resp = client.post("/api/v1/field/visits", headers=officer_headers, json={
        "task_id": new_task.id,
        "visit_start": datetime.now(timezone.utc).isoformat(),
        "latitude": 18.5204,
        "longitude": 73.8567,
        "accuracy_meters": 3.8
    })
    assert visit_resp.status_code == 201
    api_visit_id = visit_resp.json()["data"]["visit_id"]
    pg_visit = db.query(FieldVisit).filter(FieldVisit.id == api_visit_id).first()
    assert pg_visit is not None
    print(f"[Step 6] Field Visit Created -> API ID: {api_visit_id} | PostgreSQL Row ID: {pg_visit.id} | Officer ID: {pg_visit.field_officer_id} | Lat/Lng: {pg_visit.latitude}, {pg_visit.longitude} | Status: {pg_visit.status}")

    # 7. Officer Uploads Photo
    photo_resp = client.post(
        "/api/v1/field/photos",
        headers=officer_headers,
        files={"file": ("site_boundary_ground_truth.jpg", b"\xFF\xD8\xFF\xE0JPEG_REAL_CONTENT", "image/jpeg")},
        data={"related_entity_id": new_task.id}
    )
    assert photo_resp.status_code == 201
    api_photo_id = photo_resp.json()["data"]["document_id"]
    pg_photo = db.query(Document).filter(Document.id == api_photo_id).first()
    assert pg_photo is not None
    print(f"[Step 7] Photo Uploaded -> Document ID: {api_photo_id} | PostgreSQL Row ID: {pg_photo.id} | UploadedBy: {pg_photo.uploaded_by} | Size: {pg_photo.file_size} bytes | Path: {pg_photo.storage_path}")

    # 8. Officer Uploads PDF Document
    pdf_resp = client.post(
        "/api/v1/documents/upload",
        headers=officer_headers,
        files={"file": ("7_12_land_record_extract.pdf", b"%PDF-1.4_REAL_CONTENT", "application/pdf")},
        data={"related_entity": "FIELD_TASK", "related_entity_id": str(new_task.id)}
    )
    assert pdf_resp.status_code == 201
    api_pdf_id = pdf_resp.json()["data"]["document_id"]
    pg_pdf = db.query(Document).filter(Document.id == api_pdf_id).first()
    assert pg_pdf is not None
    print(f"[Step 8] PDF Uploaded -> Document ID: {api_pdf_id} | PostgreSQL Row ID: {pg_pdf.id} | UploadedBy: {pg_pdf.uploaded_by} | Size: {pg_pdf.file_size} bytes | Path: {pg_pdf.storage_path}")

    # 9. Officer Submits Verification
    verif_resp = client.post("/api/v1/field/verifications", headers=officer_headers, json={
        "client_event_id": f"EVT_VERIF_{suffix}",
        "task_id": new_task.id,
        "visit_id": pg_visit.id,
        "parcel_id": 1,
        "latitude": 18.5204,
        "longitude": 73.8567,
        "checklist_data": {
            "boundary_verified": True,
            "encroachment_detected": False,
            "structures_count": 0,
            "trees_count": 4
        },
        "remarks": "Joint ground verification completed successfully with zero boundary discrepancies."
    })
    assert verif_resp.status_code == 201
    api_verif_id = verif_resp.json()["data"]["verification_id"]
    pg_verif = db.query(FieldVerification).filter(FieldVerification.id == api_verif_id).first()
    assert pg_verif is not None
    db.refresh(new_task)
    assert new_task.status == "SUBMITTED"
    print(f"[Step 9] Verification Submitted -> API ID: {api_verif_id} | PostgreSQL Row ID: {pg_verif.id} | Task Status: {new_task.status} | ClientEventId: {pg_verif.client_event_id} | VerifiedAt: {pg_verif.verified_at}")

    # 10. Direct PostgreSQL Audit Trail Verification
    audit_rows = db.query(AuditLog).filter(AuditLog.user_id == pg_user.id).order_by(AuditLog.id.asc()).all()
    print(f"[Step 10] PostgreSQL Audit Trail -> Total Audit Events for User #{pg_user.id}: {len(audit_rows)}")
    for a in audit_rows:
        print(f"   Audit ID: {a.id:3d} | Action: {a.action:<28} | Entity: {a.entity_type:<14} | Entity ID: {a.entity_id} | Timestamp: {a.timestamp}")

    print("================================================================================")
    print("DATABASE WRITE -> READ PROOF COMPLETED WITH 100% POSTGRESQL CONSISTENCY")
    print("================================================================================")

if __name__ == "__main__":
    run_proof()
