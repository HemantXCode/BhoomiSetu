import uuid

def test_field_tasks_retrieval(client):
    login_res = client.post("/api/v1/auth/login", json={
        "email": "field.demo@example.com",
        "password": "Demo@12345"
    })
    token = login_res.json()["data"]["access_token"]

    response = client.get("/api/v1/field/tasks", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    data = response.json()["data"]
    assert "tasks" in data
    assert data["total"] >= 1

def test_field_visit_lifecycle(client):
    login_res = client.post("/api/v1/auth/login", json={
        "email": "field.demo@example.com",
        "password": "Demo@12345"
    })
    token = login_res.json()["data"]["access_token"]

    # 1. Start Visit
    visit_res = client.post(
        "/api/v1/field/visits",
        json={
            "task_id": 101,
            "visit_start": "2026-08-29T10:00:00Z",
            "latitude": 18.5204,
            "longitude": 73.8567,
            "accuracy_meters": 4.2
        },
        headers={"Authorization": f"Bearer {token}"}
    )
    assert visit_res.status_code == 201
    visit_id = visit_res.json()["data"]["visit_id"]

    # 2. Submit Verification
    event_id = str(uuid.uuid4())
    ver_res = client.post(
        "/api/v1/field/verifications",
        json={
            "client_event_id": event_id,
            "device_id": "test-device-001",
            "task_id": 101,
            "visit_id": visit_id,
            "parcel_id": 1,
            "checklist_data": {"boundary_verified": True},
            "remarks": "Boundary markers verified"
        },
        headers={"Authorization": f"Bearer {token}"}
    )
    assert ver_res.status_code == 201
    assert ver_res.json()["data"]["client_event_id"] == event_id

    # 3. Idempotent Retry of same client_event_id
    retry_res = client.post(
        "/api/v1/field/verifications",
        json={
            "client_event_id": event_id,
            "device_id": "test-device-001",
            "task_id": 101,
            "visit_id": visit_id,
            "parcel_id": 1,
            "checklist_data": {"boundary_verified": True},
            "remarks": "Boundary markers verified"
        },
        headers={"Authorization": f"Bearer {token}"}
    )
    assert retry_res.status_code == 201
    assert "Idempotent" in retry_res.json()["data"]["note"]

def test_offline_batch_sync_idempotency(client):
    login_res = client.post("/api/v1/auth/login", json={
        "email": "field.demo@example.com",
        "password": "Demo@12345"
    })
    token = login_res.json()["data"]["access_token"]

    event_id = str(uuid.uuid4())
    sync_payload = {
        "device_id": "android-test-device",
        "sync_timestamp": "2026-08-29T11:00:00Z",
        "events": [
            {
                "client_event_id": event_id,
                "client_created_at": "2026-08-29T10:45:00Z",
                "event_type": "FIELD_VERIFICATION",
                "payload": {
                    "task_id": 102,
                    "visit_id": 50,
                    "parcel_id": 2,
                    "remarks": "Offline sync test"
                }
            }
        ]
    }

    # First sync run
    sync_1 = client.post("/api/v1/field/sync", json=sync_payload, headers={"Authorization": f"Bearer {token}"})
    assert sync_1.status_code == 200
    assert sync_1.json()["data"]["processed_count"] == 1
    assert sync_1.json()["data"]["duplicate_count"] == 0

    # Second sync run with duplicate client_event_id
    sync_2 = client.post("/api/v1/field/sync", json=sync_payload, headers={"Authorization": f"Bearer {token}"})
    assert sync_2.status_code == 200
    assert sync_2.json()["data"]["processed_count"] == 0
    assert sync_2.json()["data"]["duplicate_count"] == 1
    assert sync_2.json()["data"]["results"][0]["status"] == "ALREADY_PROCESSED"
