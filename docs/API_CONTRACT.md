# BhoomiSetu REST API & Integration Specification
## API Version: `v1`
## Base URL: `/api/v1`

---

## 1. Global Specifications

### Authentication & Authorization Header
All protected API endpoints require an HTTP `Authorization` header containing a valid JSON Web Token (JWT) issued via `/api/v1/auth/login`:
```http
Authorization: Bearer <JWT_ACCESS_TOKEN>
```

### Standard Response Formats

#### Success Response Structure
```json
{
  "success": true,
  "message": "Operation completed successfully.",
  "data": { ... }
}
```

#### Error Response Structure
```json
{
  "success": false,
  "message": "Detailed error message",
  "error_code": "FORBIDDEN",
  "errors": [
    {
      "field": "latitude",
      "message": "Latitude must be a valid float between -90 and 90"
    }
  ]
}
```

---

## 2. Authentication Endpoints

### 2.1 User Login
- **Endpoint**: `POST /api/v1/auth/login`
- **Authentication**: Public
- **Request Body**:
```json
{
  "email": "field.demo@example.com",
  "password": "Demo@12345"
}
```
- **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Authentication successful.",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
    "token_type": "bearer",
    "user": {
      "id": 5,
      "name": "Suresh Patil (Sub-Divisional Field Officer)",
      "email": "field.demo@example.com",
      "role": "FIELD_OFFICER",
      "state_id": 1,
      "state_name": "Maharashtra",
      "state_code": "MH",
      "district_id": 1,
      "district_name": "Pune",
      "district_code": "PUN",
      "agency_id": 1,
      "agency_name": "National Highways Authority of India (NHAI)",
      "agency_type": "CENTRAL_PSU"
    }
  }
}
```

### 2.2 Get Authenticated User Profile
- **Endpoint**: `GET /api/v1/auth/me`
- **Authentication**: Bearer Token required
- **Success Response (`200 OK`)**: Same `user` object as in login response.

---

## 3. Field Officer APIs (Flutter Mobile App Contract)

### 3.1 Get Assigned Field Tasks
- **Endpoint**: `GET /api/v1/field/tasks`
- **Authentication**: Bearer Token required
- **Allowed Roles**: `FIELD_OFFICER`, `DISTRICT_AUTHORITY`
- **Jurisdiction**: Filtered to officer's assigned district/agency/tasks
- **Query Parameters**:
  - `status` (optional): `PENDING`, `IN_PROGRESS`, `SUBMITTED`, `COMPLETED`
  - `page` (optional): Default `1`
  - `limit` (optional): Default `20`
- **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Field tasks retrieved successfully.",
  "data": {
    "total": 3,
    "page": 1,
    "limit": 20,
    "tasks": [
      {
        "id": 101,
        "project_id": 1,
        "project_name": "Pune Ring Road Express Corridor (Phase-I)",
        "ulpin": "ULPIN-MH-PUN-001",
        "parcel_id": 1,
        "survey_number": "Gat No. 142/3A",
        "village": "Haveli",
        "task_type": "Ground Boundary Delineation",
        "priority": "HIGH",
        "due_date": "2026-08-29T17:00:00Z",
        "status": "PENDING",
        "target_latitude": 18.5204,
        "target_longitude": 73.8567
      }
    ]
  }
}
```

### 3.2 Get Field Task Details
- **Endpoint**: `GET /api/v1/field/tasks/{task_id}`
- **Authentication**: Bearer Token required
- **Allowed Roles**: `FIELD_OFFICER`, `DISTRICT_AUTHORITY`
- **Jurisdiction**: Must belong to officer's assigned task ID and district. (Returns `403 Forbidden` if assigned to another officer).
- **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Task details retrieved.",
  "data": {
    "id": 101,
    "project_id": 1,
    "project_name": "Pune Ring Road Express Corridor (Phase-I)",
    "parcel": {
      "id": 1,
      "parcel_number": "PARCEL-MH-PUN-001",
      "survey_number": "Gat No. 142/3A",
      "village": "Haveli",
      "area_hectares": 12.50,
      "owner_name": "Ramesh Chandra Patil",
      "classification": "AGRICULTURAL",
      "boundary_coordinates": [
        [73.8567, 18.5204],
        [73.8575, 18.5210],
        [73.8580, 18.5200],
        [73.8567, 18.5204]
      ]
    },
    "task_type": "Ground Boundary Delineation",
    "checklist_schema": [
      { "id": "boundary_verified", "label": "Boundary Markers Verified", "type": "BOOLEAN" },
      { "id": "structure_count", "label": "Number of Structures Identified", "type": "NUMBER" },
      { "id": "tree_count", "label": "Number of Trees Enumerated", "type": "NUMBER" },
      { "id": "dispute_flag", "label": "Local Dispute / Objection Raised", "type": "BOOLEAN" }
    ],
    "priority": "HIGH",
    "due_date": "2026-08-29T17:00:00Z",
    "status": "PENDING"
  }
}
```

### 3.3 Start Field Visit
- **Endpoint**: `POST /api/v1/field/visits`
- **Authentication**: Bearer Token required
- **Allowed Roles**: `FIELD_OFFICER`
- **Request Body**:
```json
{
  "task_id": 101,
  "visit_start": "2026-08-29T10:30:00Z",
  "latitude": 18.5204,
  "longitude": 73.8567,
  "accuracy_meters": 4.5
}
```
- **Success Response (`201 Created`)**:
```json
{
  "success": true,
  "message": "Field visit initiated.",
  "data": {
    "visit_id": 50,
    "task_id": 101,
    "field_officer_id": 5,
    "status": "IN_PROGRESS",
    "visit_start": "2026-08-29T10:30:00Z"
  }
}
```

### 3.4 Submit Field Verification
- **Endpoint**: `POST /api/v1/field/verifications`
- **Authentication**: Bearer Token required
- **Allowed Roles**: `FIELD_OFFICER`
- **Workflow State**: Returns status `"SUBMITTED"` representing evidence submission pending District Authority review.
- **Request Body**:
```json
{
  "client_event_id": "c7a8b9e0-1234-4567-89ab-cdef01234567",
  "device_id": "android-device-xyz-987",
  "task_id": 101,
  "visit_id": 50,
  "ulpin": "ULPIN-MH-PUN-001",
  "parcel_id": 1,
  "latitude": 18.5204,
  "longitude": 73.8567,
  "accuracy_meters": 3.8,
  "checklist_data": {
    "boundary_verified": true,
    "structure_count": 2,
    "tree_count": 14,
    "dispute_flag": false
  },
  "remarks": "Land boundaries physically verified with GPS pins.",
  "photos": ["doc-uuid-101", "doc-uuid-102"]
}
```
- **Success Response (`201 Created`)**:
```json
{
  "success": true,
  "message": "Field verification submitted successfully.",
  "data": {
    "verification_id": 88,
    "client_event_id": "c7a8b9e0-1234-4567-89ab-cdef01234567",
    "status": "SUBMITTED",
    "verified_at": "2026-08-29T10:45:00Z"
  }
}
```

### 3.5 Offline Batch Synchronization (Idempotent Sync)
- **Endpoint**: `POST /api/v1/field/sync`
- **Authentication**: Bearer Token required
- **Allowed Roles**: `FIELD_OFFICER`
- **Idempotency Rule**: Server checks `client_event_id` against `sync_events`. Duplicate events return `"status": "ALREADY_PROCESSED"`.
- **Request Body**:
```json
{
  "device_id": "android-device-xyz-987",
  "sync_timestamp": "2026-08-29T11:00:00Z",
  "events": [
    {
      "client_event_id": "c7a8b9e0-1234-4567-89ab-cdef01234567",
      "client_created_at": "2026-08-29T10:45:00Z",
      "event_type": "FIELD_VERIFICATION",
      "payload": {
        "task_id": 101,
        "visit_id": 50,
        "ulpin": "ULPIN-MH-PUN-001",
        "parcel_id": 1,
        "latitude": 18.5204,
        "longitude": 73.8567,
        "accuracy_meters": 3.8,
        "checklist_data": { "boundary_verified": true },
        "remarks": "Land boundary verified offline"
      }
    }
  ]
}
```
- **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Synchronization completed.",
  "data": {
    "processed_count": 1,
    "duplicate_count": 0,
    "failed_count": 0,
    "results": [
      {
        "client_event_id": "c7a8b9e0-1234-4567-89ab-cdef01234567",
        "status": "PROCESSED",
        "server_entity_id": 88
      }
    ]
  }
}
```

---

## 4. Documents & Photo Upload

- **Endpoint**: `POST /api/v1/documents/upload` or `POST /api/v1/field/photos`
- **Authentication**: Bearer Token required
- **Content-Type**: `multipart/form-data`
- **Form Fields**: `file` (JPG/PNG/PDF), `related_entity_id`
- **Success Response (`201 Created`)**:
```json
{
  "success": true,
  "message": "Document uploaded successfully.",
  "data": {
    "document_id": "doc-a1b2c3d4e5f6",
    "file_name": "photo_site_1.jpg",
    "file_type": "image/jpeg",
    "file_size": 1845000,
    "url": "/api/v1/documents/doc-a1b2c3d4e5f6/download"
  }
}
```

---

## 5. PostGIS GIS APIs (GeoJSON Specification)

- **Coordinate Reference System (CRS)**: `EPSG:4326` (WGS 84).
- **GeoJSON Coordinate Order**: `[Longitude, Latitude]` (`[X, Y]`).
- **GeoJSON Polygon Format**: Closed ring where first and last coordinate points are identical: `[[[lon1, lat1], [lon2, lat2], [lon3, lat3], [lon1, lat1]]]`.

### Endpoints
- `GET /api/v1/geo/states`: List of states (JSON)
- `GET /api/v1/geo/districts?state_id=1`: List of districts under state (JSON)
- `GET /api/v1/geo/agencies?state_id=1`: List of agencies under state (JSON)
- `GET /api/v1/geo/projects`: GIS project layer (**GeoJSON FeatureCollection**)
- `GET /api/v1/geo/parcels?district_id=1`: Land parcel polygon boundaries (**GeoJSON FeatureCollection**)
