import pytest
import uuid
from datetime import datetime, timezone, timedelta
from fastapi.testclient import TestClient
from app.main import app
from app.database.session import SessionLocal
from app.models.user import User
from app.models.field import FieldTask, FieldVisit, SyncEvent
from app.utils.jwt_util import create_access_token

client = TestClient(app)

@pytest.fixture(scope="module")
def authority_auth():
    resp = client.post("/api/v1/auth/login", json={
        "email": "district.demo@example.com",
        "password": "Demo@12345"
    })
    assert resp.status_code == 200
    token = resp.json()["data"]["access_token"]
    return {"Authorization": f"Bearer {token}"}

def test_01_unverified_user_blocked_from_visit(authority_auth):
    """1. Unverified user (PENDING) attempts visit -> 403 FORBIDDEN"""
    suffix = uuid.uuid4().hex[:6]
    email = f"audit.officer.{suffix}@test.gov.in"
    reg_resp = client.post("/api/v1/users", headers=authority_auth, json={
        "name": f"Test Officer {suffix}",
        "email": email,
        "password": "Password@123",
        "role": "FIELD_OFFICER",
        "official_id": f"TEST-ID-{suffix}",
        "official_id_type": "STATE_REVENUE_EMP_ID",
        "is_demo": False
    })
    assert reg_resp.status_code == 201
    
    # Login as new unverified officer
    login_resp = client.post("/api/v1/auth/login", json={
        "email": email,
        "password": "Password@123"
    })
    assert login_resp.status_code == 200
    token = login_resp.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Attempt to start field visit
    visit_resp = client.post("/api/v1/field/visits", headers=headers, json={
        "task_id": 101,
        "visit_start": datetime.now(timezone.utc).isoformat(),
        "latitude": 18.5204,
        "longitude": 73.8567
    })
    assert visit_resp.status_code == 403
    assert "IDENTITY_VERIFICATION_REQUIRED" in visit_resp.json().get("message", "")

def test_02_unverified_user_blocked_from_photo(authority_auth):
    """2. Unverified user attempts photo upload -> 403 FORBIDDEN"""
    suffix = uuid.uuid4().hex[:6]
    email = f"audit.officer.{suffix}@test.gov.in"
    reg_resp = client.post("/api/v1/users", headers=authority_auth, json={
        "name": f"Test Officer {suffix}",
        "email": email,
        "password": "Password@123",
        "role": "FIELD_OFFICER",
        "official_id": f"TEST-ID-{suffix}",
        "official_id_type": "STATE_REVENUE_EMP_ID",
        "is_demo": False
    })
    assert reg_resp.status_code == 201
    
    login_resp = client.post("/api/v1/auth/login", json={"email": email, "password": "Password@123"})
    token = login_resp.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    photo_resp = client.post(
        "/api/v1/field/photos",
        headers=headers,
        files={"file": ("test.jpg", b"fake_jpeg_content", "image/jpeg")},
        data={"related_entity_id": 101}
    )
    assert photo_resp.status_code == 403

def test_03_unverified_user_blocked_from_verification(authority_auth):
    """3. Unverified user attempts verification submission -> 403 FORBIDDEN"""
    suffix = uuid.uuid4().hex[:6]
    email = f"audit.officer.{suffix}@test.gov.in"
    client.post("/api/v1/users", headers=authority_auth, json={
        "name": f"Test Officer {suffix}",
        "email": email,
        "password": "Password@123",
        "role": "FIELD_OFFICER",
        "official_id": f"TEST-ID-{suffix}",
        "official_id_type": "STATE_REVENUE_EMP_ID",
        "is_demo": False
    })
    
    login_resp = client.post("/api/v1/auth/login", json={"email": email, "password": "Password@123"})
    token = login_resp.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    verif_resp = client.post("/api/v1/field/verifications", headers=headers, json={
        "task_id": 101,
        "visit_id": 1,
        "verification_status": "VERIFIED_MATCH",
        "boundary_gps_polygon": [[73.8567, 18.5204]],
        "is_confirmed": True
    })
    assert verif_resp.status_code == 403

def test_04_user_cannot_access_unassigned_task():
    """4. User tries another officer's task -> 403 FORBIDDEN"""
    # Login as User 5 (Suresh Patil)
    login_resp = client.post("/api/v1/auth/login", json={
        "email": "field.demo@example.com",
        "password": "Demo@12345"
    })
    token = login_resp.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Task 104 is assigned to User 6 (Arun Shinde)
    resp = client.get("/api/v1/field/tasks/104", headers=headers)
    assert resp.status_code == 403

def test_05_impersonation_prevented_jwt_ownership_enforced():
    """5. User sends another officer's ID -> server strictly uses JWT context"""
    login_resp = client.post("/api/v1/auth/login", json={
        "email": "field.demo@example.com",
        "password": "Demo@12345"
    })
    user_5_id = login_resp.json()["data"]["user"]["id"]
    token = login_resp.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # User 5 starts visit on their assigned task 101
    visit_resp = client.post("/api/v1/field/visits", headers=headers, json={
        "task_id": 101,
        "visit_start": datetime.now(timezone.utc).isoformat(),
        "field_officer_id": 999  # Attempt to spoof officer_id
    })
    assert visit_resp.status_code == 201
    visit_data = visit_resp.json()["data"]
    # Verify server assigned actual authenticated user ID, ignoring client spoof
    assert visit_data["field_officer_id"] == user_5_id

def test_06_duplicate_official_id_rejected(authority_auth):
    """6. Duplicate official ID -> 409 CONFLICT"""
    suffix = uuid.uuid4().hex[:6]
    official_id = f"REV-DUP-{suffix}"
    
    # First creation succeeds
    resp1 = client.post("/api/v1/users", headers=authority_auth, json={
        "name": "Officer One",
        "email": f"officer.one.{suffix}@test.gov.in",
        "password": "Password@123",
        "official_id": official_id,
        "role": "FIELD_OFFICER"
    })
    assert resp1.status_code == 201

    # Second creation with duplicate official_id fails
    resp2 = client.post("/api/v1/users", headers=authority_auth, json={
        "name": "Officer Two",
        "email": f"officer.two.{suffix}@test.gov.in",
        "password": "Password@123",
        "official_id": official_id,
        "role": "FIELD_OFFICER"
    })
    assert resp2.status_code == 409

def test_07_duplicate_email_rejected(authority_auth):
    """7. Duplicate email -> 409 CONFLICT"""
    suffix = uuid.uuid4().hex[:6]
    email = f"officer.dup.{suffix}@test.gov.in"
    
    resp1 = client.post("/api/v1/users", headers=authority_auth, json={
        "name": "Officer One",
        "email": email,
        "password": "Password@123",
        "official_id": f"OFF-1-{suffix}",
        "role": "FIELD_OFFICER"
    })
    assert resp1.status_code == 201

    resp2 = client.post("/api/v1/users", headers=authority_auth, json={
        "name": "Officer Two",
        "email": email,
        "password": "Password@123",
        "official_id": f"OFF-2-{suffix}",
        "role": "FIELD_OFFICER"
    })
    assert resp2.status_code == 409

def test_08_duplicate_sync_idempotency():
    """8. Duplicate sync event -> no duplicate PostgreSQL record"""
    login_resp = client.post("/api/v1/auth/login", json={
        "email": "field.demo@example.com",
        "password": "Demo@12345"
    })
    headers = {"Authorization": f"Bearer {login_resp.json()['data']['access_token']}"}
    client_event_id = f"EVT_TEST_IDEMPOTENT_{uuid.uuid4().hex[:8]}"

    sync_payload = {
        "client_event_id": client_event_id,
        "client_created_at": datetime.now(timezone.utc).isoformat(),
        "event_type": "FIELD_VISIT",
        "payload": {
            "task_id": 101,
            "visit_start": datetime.now(timezone.utc).isoformat(),
            "latitude": 18.5204,
            "longitude": 73.8567
        }
    }

    # First sync
    res1 = client.post("/api/v1/field/sync", headers=headers, json={"events": [sync_payload]})
    assert res1.status_code == 200
    assert res1.json()["data"]["processed"] == 1
    assert res1.json()["data"]["duplicate"] == 0

    # Replay second sync with same client_event_id
    res2 = client.post("/api/v1/field/sync", headers=headers, json={"events": [sync_payload]})
    assert res2.status_code == 200
    assert res2.json()["data"]["processed"] == 0
    assert res2.json()["data"]["duplicate"] == 1

def test_09_suspended_officer_blocked_from_operations(authority_auth):
    """9. Suspended officer attempts login/operations -> 403 FORBIDDEN"""
    suffix = uuid.uuid4().hex[:6]
    email = f"suspended.officer.{suffix}@test.gov.in"
    reg_resp = client.post("/api/v1/users", headers=authority_auth, json={
        "name": f"Suspended Officer {suffix}",
        "email": email,
        "password": "Password@123",
        "role": "FIELD_OFFICER",
        "official_id": f"SUSP-{suffix}"
    })
    user_id = reg_resp.json()["data"]["id"]

    # Authority verifies and then suspends user
    client.post(f"/api/v1/users/{user_id}/verify", headers=authority_auth, json={"decision": "VERIFIED"})
    client.post(f"/api/v1/users/{user_id}/verify", headers=authority_auth, json={
        "decision": "SUSPENDED",
        "notes": "Suspended pending administrative inquiry."
    })

    # Suspended officer attempt to login -> blocked at login with 403
    login_resp = client.post("/api/v1/auth/login", json={"email": email, "password": "Password@123"})
    assert login_resp.status_code == 403
    assert "suspended" in login_resp.json().get("message", "").lower()

def test_10_invalid_jwt_rejected():
    """10. Invalid JWT -> 401 UNAUTHORIZED"""
    resp = client.get("/api/v1/field/tasks", headers={"Authorization": "Bearer invalid_garbage_token_12345"})
    assert resp.status_code == 401

def test_11_expired_jwt_rejected():
    """11. Expired JWT -> 401 UNAUTHORIZED"""
    expired_token = create_access_token(
        data={"sub": 5, "email": "field.demo@example.com", "role": "FIELD_OFFICER"},
        expires_delta=timedelta(minutes=-10)  # Expired 10 minutes ago
    )
    resp = client.get("/api/v1/field/tasks", headers={"Authorization": f"Bearer {expired_token}"})
    assert resp.status_code == 401
