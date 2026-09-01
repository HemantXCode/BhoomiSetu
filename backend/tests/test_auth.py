def test_valid_login(client):
    response = client.post("/api/v1/auth/login", json={
        "email": "field.demo@example.com",
        "password": "Demo@12345"
    })
    assert response.status_code == 200
    json_data = response.json()
    assert json_data["success"] is True
    assert "access_token" in json_data["data"]
    assert json_data["data"]["user"]["role"] == "FIELD_OFFICER"

def test_invalid_login(client):
    response = client.post("/api/v1/auth/login", json={
        "email": "field.demo@example.com",
        "password": "WrongPassword123"
    })
    assert response.status_code == 401
    json_data = response.json()
    assert json_data["success"] is False

def test_get_me(client):
    login_res = client.post("/api/v1/auth/login", json={
        "email": "central.demo@example.com",
        "password": "Demo@12345"
    })
    token = login_res.json()["data"]["access_token"]

    response = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    data = response.json()["data"]
    assert data["email"] == "central.demo@example.com"
    assert data["role"] == "CENTRAL_MINISTRY"
