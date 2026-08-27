# BhoomiSetu REST API Specification

## Base URL
`/api`

## Authentication Header
Protected endpoints require:
`Authorization: Bearer <JWT_TOKEN>`

---

## 1. Authentication Endpoints

### `POST /api/auth/login`
- **Description**: Authenticates user via email and password, generates JWT.
- **Request Body**:
  ```json
  {
    "email": "central.demo@example.com",
    "password": "Demo@12345"
  }
  ```
- **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Authentication successful",
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
      "user": {
        "id": 1,
        "name": "Dr. Rajesh Verma (Joint Secretary)",
        "email": "central.demo@example.com",
        "role": "CENTRAL_MINISTRY",
        "state_id": null,
        "state_name": null,
        "district_id": null,
        "district_name": null,
        "agency_id": null,
        "agency_name": null
      }
    }
  }
  ```

### `GET /api/auth/me`
- **Description**: Returns authenticated user profile and data scope.
- **Headers**: `Authorization: Bearer <token>`
- **Success Response (200 OK)**: User profile object.

---

## 2. Dashboard Endpoints

### `GET /api/dashboard/stats`
- **Description**: Returns dynamically computed KPI cards, breakdown tables, delayed projects, and status counts tailored to the user's role and data scope.
- **Headers**: `Authorization: Bearer <token>`
- **Response Structure**:
  - `CENTRAL_MINISTRY`: National aggregated hectares, compensation figures, state-wise table, delayed projects list.
  - `STATE_GOVERNMENT`: State-scoped metrics, district-wise progress table, pending state approvals.
  - `DISTRICT_AUTHORITY`: District-scoped metrics, field verification backlog, notification & award stages.
  - `PROJECT_AGENCY`: Agency-scoped metrics, milestone tracker, pending clearances.
  - `FIELD_OFFICER`: Field task queue, verification progress, GPS inspection items.

---

## 3. Projects Endpoints

### `GET /api/projects`
- **Description**: Lists all projects accessible under the caller's role scope. Supports query filtering: `?status=...&state_id=...&search=...`.
- **Headers**: `Authorization: Bearer <token>`

### `GET /api/projects/:id`
- **Description**: Retrieves single project details if within the user's authorized data scope (returns 403 otherwise).
- **Headers**: `Authorization: Bearer <token>`

### `POST /api/projects`
- **Description**: Submits a new project proposal (Authorized for `PROJECT_AGENCY` and `CENTRAL_MINISTRY`).
- **Headers**: `Authorization: Bearer <token>`
- **Request Body**:
  ```json
  {
    "project_name": "New Expressway Bypass",
    "description": "Greenfield route alignment",
    "agency_id": 1,
    "state_id": 1,
    "district_id": 1,
    "proposed_area": 250.00,
    "status": "PROPOSED",
    "start_date": "2026-09-01",
    "expected_end_date": "2028-03-31"
  }
  ```

---

## 4. Geographic & Metadata Endpoints

### `GET /api/geo/states`
- **Description**: Returns list of all states.

### `GET /api/geo/districts?state_id=:id`
- **Description**: Returns list of districts (optionally filtered by state).

### `GET /api/geo/agencies`
- **Description**: Returns list of implementing agencies.
