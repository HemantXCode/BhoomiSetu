import urllib.request
import json
import uuid

BASE_URL = "http://192.168.29.94:5000"

def log_step(name, success, details=""):
    status = "PASSED" if success else "FAILED"
    print(f"[{status}] {name} - {details}")

def run_integration_test():
    print("==========================================================")
    print(f"Starting Real End-to-End LAN Integration Test on {BASE_URL}")
    print("==========================================================")

    # Step 1: Health Check
    try:
        res = urllib.request.urlopen(f"{BASE_URL}/health")
        health_data = json.loads(res.read().decode())
        log_step("1. GET /health", health_data.get("status") == "healthy", f"Response: {health_data}")
    except Exception as e:
        log_step("1. GET /health", False, str(e))
        return

    # Step 2: Login
    token = ""
    try:
        login_req = urllib.request.Request(
            f"{BASE_URL}/api/v1/auth/login",
            data=json.dumps({"email": "field.demo@example.com", "password": "Demo@12345"}).encode('utf-8'),
            headers={"Content-Type": "application/json"}
        )
        res = urllib.request.urlopen(login_req)
        login_data = json.loads(res.read().decode())
        token = login_data["data"]["access_token"]
        user_name = login_data["data"]["user"]["name"]
        log_step("2. POST /api/v1/auth/login", True, f"Logged in user: '{user_name}' Token len: {len(token)}")
    except Exception as e:
        log_step("2. POST /api/v1/auth/login", False, str(e))
        return

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    # Step 3: GET /auth/me
    try:
        req = urllib.request.Request(f"{BASE_URL}/api/v1/auth/me", headers=headers)
        res = urllib.request.urlopen(req)
        me_data = json.loads(res.read().decode())
        log_step("3. GET /api/v1/auth/me", me_data["success"], f"User role: {me_data['data']['role']}")
    except Exception as e:
        log_step("3. GET /api/v1/auth/me", False, str(e))

    # Step 4: GET /field/tasks
    try:
        req = urllib.request.Request(f"{BASE_URL}/api/v1/field/tasks", headers=headers)
        res = urllib.request.urlopen(req)
        tasks_data = json.loads(res.read().decode())
        task_count = tasks_data["data"]["total"]
        log_step("4. GET /api/v1/field/tasks", tasks_data["success"], f"Retrieved {task_count} assigned tasks.")
    except Exception as e:
        log_step("4. GET /api/v1/field/tasks", False, str(e))

    # Step 5: GET /field/tasks/101
    try:
        req = urllib.request.Request(f"{BASE_URL}/api/v1/field/tasks/101", headers=headers)
        res = urllib.request.urlopen(req)
        detail_data = json.loads(res.read().decode())
        parcel_num = detail_data["data"]["parcel"]["parcel_number"]
        log_step("5. GET /api/v1/field/tasks/101", detail_data["success"], f"Parcel Number: {parcel_num}")
    except Exception as e:
        log_step("5. GET /api/v1/field/tasks/101", False, str(e))

    # Step 6: POST /field/visits
    visit_id = 50
    try:
        visit_payload = {
            "task_id": 101,
            "visit_start": "2026-08-29T10:30:00Z",
            "latitude": 18.5204,
            "longitude": 73.8567,
            "accuracy_meters": 4.5
        }
        req = urllib.request.Request(f"{BASE_URL}/api/v1/field/visits", data=json.dumps(visit_payload).encode('utf-8'), headers=headers)
        res = urllib.request.urlopen(req)
        visit_data = json.loads(res.read().decode())
        visit_id = visit_data["data"]["visit_id"]
        log_step("6. POST /api/v1/field/visits", visit_data["success"], f"Initiated visit #{visit_id}")
    except Exception as e:
        log_step("6. POST /api/v1/field/visits", False, str(e))

    # Step 7: POST /field/photos (Multipart upload)
    try:
        import io
        photo_bytes = b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15c4\x00\x00\x00\rIDATx\x9cc\xf8\xff\xff?\x00\x05\xfe\x02\xfe\xa76u\xfa\x00\x00\x00\x00IEND\xaeB`\x82"
        files = {'file': ('evidence_boundary_01.png', photo_bytes, 'image/png')}
        data = {'related_entity_id': '101'}
        import httpx
        r_photo = httpx.post(
            f"{BASE_URL}/api/v1/field/photos",
            headers={"Authorization": f"Bearer {token}"},
            files=files,
            data=data
        )
        photo_res = r_photo.json()
        log_step("7. POST /api/v1/field/photos", photo_res.get("success", False), f"Uploaded file: {photo_res.get('data', {}).get('file_name', 'N/A')}")
    except Exception as e:
        log_step("7. POST /api/v1/field/photos", False, str(e))

    # Step 8: POST /field/verifications
    client_event_id = str(uuid.uuid4())
    try:
        verif_payload = {
            "client_event_id": client_event_id,
            "device_id": "android-test-device-99",
            "task_id": 101,
            "visit_id": visit_id,
            "parcel_id": 1,
            "latitude": 18.5204,
            "longitude": 73.8567,
            "accuracy_meters": 3.8,
            "checklist_data": {
                "boundary_verified": True,
                "structure_count": 2,
                "tree_count": 14
            },
            "remarks": "Land boundary verified live during LAN test.",
            "photos": ["evidence_boundary_01.png"]
        }
        req = urllib.request.Request(f"{BASE_URL}/api/v1/field/verifications", data=json.dumps(verif_payload).encode('utf-8'), headers=headers)
        res = urllib.request.urlopen(req)
        verif_data = json.loads(res.read().decode())
        log_step("8. POST /api/v1/field/verifications", verif_data["success"], f"Verification status: {verif_data['data']['status']}")
    except Exception as e:
        log_step("8. POST /api/v1/field/verifications", False, str(e))

    # Step 9: POST /field/sync (Idempotent offline batch sync)
    try:
        sync_event_id = str(uuid.uuid4())
        sync_payload = {
            "device_id": "android-test-device-99",
            "sync_timestamp": "2026-08-29T11:00:00Z",
            "events": [
                {
                    "client_event_id": sync_event_id,
                    "client_created_at": "2026-08-29T10:45:00Z",
                    "event_type": "FIELD_VERIFICATION",
                    "payload": {
                        "task_id": 101,
                        "visit_id": visit_id,
                        "parcel_id": 1,
                        "remarks": "Offline verification sync test"
                    }
                }
            ]
        }
        req = urllib.request.Request(f"{BASE_URL}/api/v1/field/sync", data=json.dumps(sync_payload).encode('utf-8'), headers=headers)
        res = urllib.request.urlopen(req)
        sync_data = json.loads(res.read().decode())
        processed = sync_data["data"]["processed_count"]
        log_step("9. POST /api/v1/field/sync (Initial Batch)", sync_data["success"], f"Processed items: {processed}")

        # Test duplicate idempotency resend
        req2 = urllib.request.Request(f"{BASE_URL}/api/v1/field/sync", data=json.dumps(sync_payload).encode('utf-8'), headers=headers)
        res2 = urllib.request.urlopen(req2)
        sync_data2 = json.loads(res2.read().decode())
        duplicates = sync_data2["data"]["duplicate_count"]
        log_step("10. POST /api/v1/field/sync (Idempotency Resend)", sync_data2["success"], f"Duplicate items skipped: {duplicates}")

    except Exception as e:
        log_step("9. POST /api/v1/field/sync", False, str(e))

if __name__ == "__main__":
    run_integration_test()
