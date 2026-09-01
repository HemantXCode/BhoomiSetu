def test_jurisdiction_scoping_state_user(client):
    login_res = client.post("/api/v1/auth/login", json={
        "email": "state.demo@example.com",
        "password": "Demo@12345"
    })
    token = login_res.json()["data"]["access_token"]

    # State 1 user requests projects
    projects_res = client.get("/api/v1/projects", headers={"Authorization": f"Bearer {token}"})
    assert projects_res.status_code == 200
    projects = projects_res.json()["data"]
    for p in projects:
        assert p["state_id"] == 1
