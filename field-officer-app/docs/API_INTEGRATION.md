# BhoomiSetu - Field Officer App: API Integration Contract

**Document Purpose**: Defines the PROPOSED / AGREED REST and WebSocket contracts between the Flutter Field Officer Mobile Application and Aditya's BhoomiSetu API Gateway / Backend.

---

## 🏛️ Team Boundary & Architecture

- **Hemant (Mobile Scope)**: Flutter Field Officer App UI, GPS capture, Camera capture, 5-section Inspection checklists, Document manager, Local SQLite database, Offline Sync Queue, and Repository layer.
- **Aditya (Backend Scope)**: FastAPI Server, API Gateway, PostgreSQL/PostGIS databases, JWT generation/validation, RBAC, WebSocket backend, and Web Portal.
- **Data Mode Switch**:
  - `DATA_MODE = mock`: App uses `MockDataSource` and local SQLite persistence for standalone operation.
  - `DATA_MODE = api`: App routes requests to Aditya's live API Gateway (`/api/v1/...`).

---

## 🔐 1. Authentication Endpoints

### 1.1 Field Officer Login
- **Status**: `PROPOSED`
- **Method**: `POST`
- **Path**: `/api/v1/auth/login`
- **Request Body**:
```json
{
  "email": "field.demo@bhoomisetu.gov.in",
  "password": "secure_password"
}
```
- **Response `200 OK`**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsIn...",
  "token_type": "bearer",
  "expires_in": 86400,
  "user": {
    "id": "usr_01_rajesh",
    "email": "field.demo@bhoomisetu.gov.in",
    "name": "Rajesh Kumar",
    "officer_id": "FO-MH-PUN-0842",
    "designation": "Senior Field Survey Officer",
    "state": "Maharashtra",
    "district": "Pune",
    "phone": "+91 98230 45678",
    "role": "FIELD_OFFICER"
  }
}
```

---

## 📋 2. Task Management Endpoints

### 2.1 Fetch Assigned Field Tasks
- **Status**: `PROPOSED`
- **Method**: `GET`
- **Path**: `/api/v1/field/tasks`
- **Headers**: `Authorization: Bearer <token>`
- **Response `200 OK`**:
```json
[
  {
    "id": "TSK-1024",
    "parcel_id": "PUN-1024",
    "project": "Pune Ring Road Express Corridor",
    "village": "Bhugaon",
    "district": "Pune",
    "state": "Maharashtra",
    "survey_number": "48/2A",
    "land_area_sqm": 4250.0,
    "task_type": "Survey & Verification",
    "assigned_date": "2026-08-27",
    "due_date": "2026-09-02",
    "status": "PENDING",
    "latitude": 18.498214,
    "longitude": 73.746820,
    "instructions": "Verify western boundary alignment against proposed corridor centerline."
  }
]
```

---

## 📍 3. Field Visit & Verification Endpoints

### 3.1 Submit Completed Field Visit (Idempotent)
- **Status**: `PROPOSED`
- **Method**: `POST`
- **Path**: `/api/v1/field/visits/{visit_id}/submit`
- **Headers**:
  - `Authorization: Bearer <token>`
  - `X-Client-Event-ID: EVT_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d` (Idempotency Key)
- **Request Body**:
```json
{
  "visitId": "VST-1024",
  "taskId": "TSK-1024",
  "parcelId": "PUN-1024",
  "officerId": "FO-MH-PUN-0842",
  "startTime": "2026-08-29T10:00:00Z",
  "endTime": "2026-08-29T10:45:00Z",
  "latitude": 18.498214,
  "longitude": 73.746820,
  "gpsAccuracy": 4.2,
  "altitude": 580.0,
  "status": "PENDING_VERIFICATION",
  "remarks": "Boundaries identified and matched against survey sheet.",
  "isConfirmed": 1,
  "inspection": {
    "parcelMatchesRecord": "YES",
    "boundaryIdentified": "YES",
    "boundaryMarkersAvailable": "YES",
    "boundaryMatchesCadastral": "YES",
    "landUseVerified": "YES",
    "physicalConditionVerified": "YES",
    "encroachmentChecked": "YES",
    "ownershipChecked": "YES",
    "documentsReviewed": "YES",
    "objectionReceived": "NO",
    "disputeObserved": "NO",
    "encroachmentObserved": "NO",
    "otherIssues": "NO",
    "remarks": "On-site inspection completed.",
    "additionalObservations": "No physical obstacles observed."
  },
  "evidence": [
    {
      "photoId": "PHO-101",
      "category": "Parcel Boundary",
      "description": "Corner boundary stone marker #1",
      "timestamp": "2026-08-29T10:15:00Z",
      "latitude": 18.498214,
      "longitude": 73.746820,
      "gpsAccuracy": 3.8
    }
  ],
  "documents": [
    {
      "documentId": "DOC-201",
      "fileName": "7_12_Extract.pdf",
      "fileType": "PDF",
      "fileSizeBytes": 245000
    }
  ]
}
```
- **Response `200 OK`**:
```json
{
  "status": "SUCCESS",
  "message": "Field visit submitted and queued for CALA officer approval.",
  "visitId": "VST-1024",
  "submittedAt": "2026-08-29T10:45:00Z"
}
```

---

## 🔄 4. Batch Synchronization Endpoint

### 4.1 Sync Offline Operations
- **Status**: `PROPOSED`
- **Method**: `POST`
- **Path**: `/api/v1/sync`
- **Headers**: `Authorization: Bearer <token>`
- **Request Body**:
```json
{
  "operations": [
    {
      "clientEventId": "EVT_01",
      "entityType": "FIELD_VISIT",
      "entityId": "VST-1024",
      "operation": "SUBMIT",
      "payload": { ... },
      "createdAt": "2026-08-29T10:45:00Z"
    }
  ]
}
```

---

## 📡 5. WebSocket Real-Time Events (Abstraction)

- **Connection URL**: `wss://api.bhoomisetu.gov.in/ws/v1/field/events?token=<token>`
- **Event Types**:
  1. `FIELD_TASK_ASSIGNED`: Sent when a CALA officer assigns a new parcel to the field officer.
  2. `FIELD_TASK_UPDATED`: Sent when parcel boundaries or instructions are amended.
  3. `FIELD_VISIT_VERIFIED`: Sent when the field report is approved by the competent authority.
  4. `FIELD_VISIT_REJECTED`: Sent if the report is returned for re-survey.
  5. `NOTIFICATION_CREATED`: General administration announcements.

---

## 🛡️ 6. Error Codes & Handling Contract

| HTTP Status | App Handling |
| :--- | :--- |
| `401 Unauthorized` | Clears secure token storage, prompts officer to re-authenticate. |
| `403 Forbidden` | Displays permission denial dialog (e.g. out-of-jurisdiction parcel). |
| `400 / 422 Validation Error` | Surfaces specific invalid field messages to the officer. |
| `500+ Server Error` | Preserves payload in SQLite `sync_queue` and retries automatically. |
| `Network Timeout / Offline` | Retains state locally with `SYNC_PENDING` status. |
