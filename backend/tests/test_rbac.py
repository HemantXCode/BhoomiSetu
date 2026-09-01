def test_field_officer_cannot_create_project(client):
    login_res = client.post("/api/v1/auth/login", json={
        "email": "field.demo@example.com",
        "password": "Demo@12345"
    })
    token = login_res.json()["data"]["access_token"]

    response = client.post(
        "/api/v1/projects",
        json={
            "project_name": "Unauthorized Project",
            "state_id": 1,
            "district_id": 1,
            "proposed_area": 50.0
        },
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 403

def test_agency_can_create_project(client):
    login_res = client.post("/api/v1/auth/login", json={
        "email": "agency.demo@example.com",
        "password": "Demo@12345"
    })
    token = login_res.json()["data"]["access_token"]

    response = client.post(
        "/api/v1/projects",
        json={
            "project_name": "NHAI Highway Expansion Phase-V",
            "state_id": 1,
            "district_id": 1,
            "proposed_area": 120.50
        },
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 201
    assert response.json()["success"] is True
