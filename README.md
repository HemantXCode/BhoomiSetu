# BhoomiSetu (भूमिसेतु)

## Digital National Land Acquisition & Management Platform
*Connecting Land, People & Infrastructure Governance • Prototype Platform*

---

## 📌 1. Project Introduction

**BhoomiSetu** is a proposed **National Land Acquisition & Management System** designed to digitally connect infrastructure project planning, land parcel identification, GIS-based corridor analysis, field verification, evidence collection, document management, acquisition progress monitoring, and administrative oversight.

Developed as an advanced prototype, BhoomiSetu bridges the critical operational gap between apex infrastructure planning authorities and ground-level revenue field officers. It unifies project corridors with cadastral land records under a single geospatial and operational workflow.

> [!NOTE]
> **Prototype Demonstration Notice**: BhoomiSetu is an innovative prototype developed for demonstration and hackathon evaluation purposes. It is not an officially deployed Government of India system. External government database integrations (such as live state land registries) are represented via standardized API models and realistic demonstration datasets.

---

## 🎯 2. Core Problem Statement

Infrastructure development across India (highways, expressways, dedicated freight corridors, high-speed rail, and metro networks) routinely faces severe execution bottlenecks due to fragmented land acquisition processes:

1. **Fragmented Land Information**: Project alignments and land records reside in disconnected silos across different departments and formats.
2. **Manual & Paper-Heavy Field Verification**: Joint Measurement Surveys (JMS) and physical parcel verifications rely on manual registers, creating inspection delays.
3. **Disconnection Between GIS & Acquisition Records**: Geospatial corridor alignment maps often lack direct linkage to individual cadastral plot boundaries and legal titleholders.
4. **Lack of Unified Acquisition Visibility**: Central and state authorities struggle to obtain real-time visibility into parcel-by-parcel acquisition milestones.
5. **Connectivity Gaps in Rural & Remote Areas**: Field officers operating along linear greenfield alignments frequently lose internet access, hindering real-time reporting.
6. **Weak Traceability & Audit Trails**: Dispersed photographic evidence and documents make dispute resolution and judicial scrutiny challenging.

---

## 💡 3. Why BhoomiSetu is Needed & How It Solves the Problem

BhoomiSetu provides a **unified, closed-loop digital workflow** where an infrastructure corridor is computationally overlaid on cadastral land parcels, dynamically calculating Right-of-Way (RoW) impacts, auto-generating field inspection tasks, enabling offline-capable mobile field verification with GPS and geotagged photographs, and instantly streaming verified field data back to central and district administrative dashboards.

---

## 👥 4. User Roles & Administrative Tiers

BhoomiSetu implements strict **Role-Based Access Control (RBAC)** and **Geographic Data Scoping** across five administrative tiers:

| Role | Administrative Scope | Key Capabilities & Implemented Permissions |
| :--- | :--- | :--- |
| **1. Central Ministry (National PMU)** | **National (All-India)** | Consolidated national acquisition KPIs, inter-state corridor comparisons, delay radar, high-level project oversight. |
| **2. State Government (Revenue Dept.)** | **Assigned State** | State-level project monitoring, district-wise progress tracking, Section 19 gazette declaration tracking. |
| **3. District Authority (Collector / CALA)** | **Assigned District** | Competent Authority for Land Acquisition (CALA) operations, field task dispatch, parcel verification queue, dispute tracking. |
| **4. Project Implementing Agency (NHAI, DFCCIL, Rail)** | **Assigned Agency** | Linear corridor proposal management, Right-of-Way (RoW) acquisition tracking, milestone timeline monitoring. |
| **5. Sub-Divisional Field Officer** | **Assigned Division / Tehsil** | Mobile-first ground inspection, GPS coordinate capture, discrepancy reporting, photo evidence capture, offline sync. |

---

## 🔄 5. Key System Workflow

The diagram below illustrates the end-to-end operational flow from project proposal to field verification and executive reporting:

```mermaid
flowchart TD
    A[Infrastructure Project Proposal] --> B[Digital Corridor Alignment Formulation]
    B --> C[GIS Corridor & 70m RoW Buffer Generation]
    C --> D[Spatial Intersection with Cadastral Parcels]
    D --> E[Unique Parcel Identification via ULPIN]
    E --> F[Acquisition Status Assessment: Acquired / In-Progress / Pending]
    F --> G[Automated Field Task Dispatch to Field Officer]
    G --> H[Flutter Mobile Field Inspection]
    H --> I[Physical GPS Coordinate Capture & Cadastral Comparison]
    I --> J[On-Site Verification & Structure/Tree Enumeration]
    J --> K[Geotagged Photographic Evidence & Document Upload]
    K --> L[Offline SQLite Queue & Cryptographic Sync]
    L --> M[FastAPI Backend Processing & PostGIS Ingestion]
    M --> N[Real-Time Authority Dashboards & Forensic Audit Trail]
```

---

## 🏛️ 6. System Architecture

BhoomiSetu employs a modular, high-performance architecture comprising a React web portal, a FastAPI geospatial backend, a PostgreSQL/PostGIS database, and a Flutter field application with offline SQLite synchronization.

```mermaid
graph TB
    subgraph Client Layer
        WebPortal["Web Portal (React 18 + Vite + TailwindCSS)"]
        MobileApp["Field Officer App (Flutter + SQLite)"]
    end

    subgraph API & Gateway Layer
        FastAPI["FastAPI REST & WebSocket Server"]
        AuthMiddleware["JWT Authentication & RBAC Engine"]
        GeoEngine["Spatial Analysis & GeoJSON Engine"]
        SyncManager["Idempotent Offline Sync Manager"]
    end

    subgraph Data & Storage Layer
        PostgreSQL[("PostgreSQL 16 + PostGIS")]
        FileStorage[("Secure File Storage: Evidence / Documents")]
        LocalSQLite[("Mobile Local SQLite Engine")]
    end

    WebPortal -->|REST / HTTPS| FastAPI
    MobileApp -->|REST / HTTPS| FastAPI
    MobileApp <-->|Local Cache & Queue| LocalSQLite

    FastAPI --> AuthMiddleware
    FastAPI --> GeoEngine
    FastAPI --> SyncManager

    GeoEngine -->|GeoAlchemy2 / Spatial Queries| PostgreSQL
    SyncManager -->|Transactional Ingestion| PostgreSQL
    FastAPI -->|Binary Upload / Stream| FileStorage
```

---

## 🌐 7. Web Portal Capabilities

The BhoomiSetu Web Portal provides an enterprise-grade administrative command interface:

- **Bilingual Interface**: Seamless instant toggling between **English** and **Hindi (हिन्दी)** with context-wide translation coverage.
- **Official Government Design System**: Clean typography, high-contrast accessible color palettes, official iconography, and responsive layouts.
- **Five Dedicated Role Dashboards**: Custom-tailored analytical views for Central, State, District, Agency, and Field tiers.
- **Projects Directory**: Interactive filterable registry of infrastructure projects with financial, physical, and acquisition metrics.
- **Field Operations Monitoring**: Centralized oversight of field verification visits, assigned tasks, and inspection logs.
- **Audit & Governance Explorer**: Traceable record of administrative actions, status updates, and user modifications.

---

## 🗺️ 8. Advanced GIS Command Center

The Web and Mobile GIS Command Centers demonstrate advanced spatial decision support capabilities:

### Geospatial Engine & Visualization Stack
1. **Interactive Base Layer**: OpenStreetMap vector tile rendering with smooth pan/zoom and responsive touch navigation.
2. **Multi-Layer Infrastructure Corridor**: Visualized with dark outer road casing, white lane dividers, and status-colored centerline segments.
3. **Right-of-Way (RoW) Buffer Band**: Translucent statutory 70m buffer visualization highlighting land subject to acquisition.
4. **Cadastral Parcel Polygons**: Precise multi-point polygon boundaries geometrically bisected and intersected by the project corridor.
5. **Acquisition Status Thematic Colors**:
   - 🟢 **Green (Acquired)**: Land acquired, compensation awarded/disbursed.
   - 🟠 **Orange / Saffron (In Progress)**: JMS complete, verification underway, Section 19 stage.
   - 🔴 **Red (Pending)**: Initial identification, pending joint measurement or notice issuance.
6. **Centroid Badges & Terminal Markers**: ULPIN markers positioned on parcel centroids, alongside major project terminus badges (e.g., Urse, Hadapsar).
7. **Granular Layer Controls**: Toggle Corridor/RoW, Cadastral Boundaries, Affected Only, Status Colors, and Centroid Badges.
8. **Geographic Filtering**: Filter by State, District, and specific project corridors.

---

## 🏷️ 9. ULPIN-Centric Land Identity & 360° View

### ULPIN Architecture
BhoomiSetu treats the **Unique Land Parcel Identification Number (ULPIN)** as the universal business identifier across Web, GIS, Mobile, and API layers:

```text
land_parcels
├── id (UUID / Integer)    ──> Internal Database Primary Key
└── ulpin (String)         ──> User-Facing Unique 14-Digit Land Identity (e.g., ULPIN-MH-PUN-1024)
```

### ULPIN 360° Parcel Lifecycle View
Selecting any parcel on the GIS map or mobile app displays a comprehensive lifecycle dossier:
- **Identifier**: ULPIN & Survey / Gat Number.
- **Administrative Location**: Village, Taluka, District, State.
- **Spatial Metrics**: Land Area in Hectares and Square Meters, Centroid GPS coordinates.
- **Ownership & Classification**: Primary Titleholder, Land Classification (Agricultural / Non-Agricultural / Commercial).
- **Corridor Relationship**: Project Name, RoW Impact Status (`PROJECT-AFFECTED LAND: YES`, `Corridor Intersects This Parcel`).
- **Operational Status**: Verification Status, Assigned Field Task, and direct inspection triggers.

---

## 📱 10. Flutter Field Officer Mobile Application

The **BhoomiSetu Field Officer App** is a dedicated Flutter application engineered for harsh, low-connectivity field environments:

```text
Tasks List ──> Start Field Visit ──> GPS Coordinate Capture ──> Parcel Verification
     │
     └──> Inspection Checklist ──> Evidence Capture ──> Document Upload ──> Review & Submit ──> Offline Sync
```

### Key Mobile Capabilities
1. **Mobile GIS Command Center**: Full 5-layer interactive GIS engine matching the Web GIS datasets and geometries.
2. **Hardware GPS Geotagging**: Captures real-time device latitude, longitude, altitude, and accuracy (in meters), automatically computing proximity and deviation from the registered cadastral centroid.
3. **Structured Inspection Checklist**: Fast field evaluation of land use, structure counts, tree counts, irrigation status, and on-ground occupancy.
4. **Multi-Angle Photographic Evidence**: Built-in camera capture with timestamp and GPS coordinate watermarking.
5. **Document Verification**: Field upload and classification of Aadhaar, 7/12 Extract, Sale Deed, and Mutation records.
6. **Offline-First Resilience**: Local SQLite database with a persistent synchronization queue. Field inspections completed without internet access are assigned a unique `clientEventId` for idempotent replay upon reconnection.

---

## ⚙️ 11. Backend API Architecture (FastAPI)

The backend provides high-performance, asynchronous REST endpoints with centralized error handling and OpenAPI documentation (`/docs`):

### Implemented API Routers

| Module | Route Prefix | Key Endpoints & Capabilities |
| :--- | :--- | :--- |
| **Authentication** | `/api/v1/auth` | `POST /login`, `POST /refresh`, `POST /logout`, `GET /me` (JWT verification) |
| **Users** | `/api/v1/users` | `GET /`, `GET /{id}`, `POST /`, `GET /profile` |
| **Projects** | `/api/v1/projects` | `GET /`, `GET /{id}`, `POST /`, `GET /{id}/parcels`, `GET /{id}/timeline` |
| **Land Parcels** | `/api/v1/parcels` | `GET /`, `GET /{id}`, `GET /ulpin/{ulpin}`, `GET /{id}/history` |
| **Geospatial (GIS)** | `/api/v1/geo` | `GET /corridors`, `GET /corridors/{id}/geojson`, `GET /parcels`, `GET /parcels/spatial-query` |
| **Field Operations**| `/api/v1/field` | `GET /tasks`, `POST /visits`, `POST /verify`, `GET /inspections/{id}` |
| **Documents** | `/api/v1/documents` | `POST /upload`, `GET /{id}`, `GET /parcel/{ulpin}`, `GET /download/{id}` |
| **Dashboard** | `/api/v1/dashboard` | `GET /stats`, `GET /kpi/central`, `GET /kpi/state`, `GET /kpi/district` |
| **Compensation** | `/api/v1/compensation` | `GET /summary`, `POST /calculate`, `GET /disbursements` |
| **R&R Management** | `/api/v1/rr` | `GET /plans`, `GET /entitlements` |
| **Audit Trail** | `/api/v1/audit` | `GET /logs`, `GET /entity/{entity_type}/{entity_id}` |
| **Notifications** | `/api/v1/notifications` | `GET /`, `POST /read/{id}` |
| **Analytics** | `/api/v1/analytics` | `GET /trends`, `GET /bottlenecks` |
| **System Health** | `/health`, `/api/v1/health` | `GET /health` (PostgreSQL / system liveness check) |
| **WebSocket** | `/ws/{client_id}` | Real-time notification and sync event dispatch |

---

## 🗄️ 12. Database Architecture

### PostgreSQL 16 + PostGIS
- **Relational Tables**: `users`, `projects`, `land_parcels`, `field_tasks`, `field_visits`, `inspection_records`, `evidence_files`, `document_records`, `audit_logs`, `compensation_records`.
- **Spatial Extensions**: PostGIS geometry types (`GEOMETRY(LineString, 4326)`, `GEOMETRY(Polygon, 4326)`, `GEOMETRY(Point, 4326)`), spatial indexing via GIST indexes.
- **Binary File Storage**: Uploaded photographic evidence and document binaries are stored securely on the backend filesystem storage volume with verified cryptographic checksums and metadata recorded in PostgreSQL.

### Mobile Local Database (SQLite)
- Local embedded SQLite tables mirror key inspection models, caching parcel geometry, task assignments, and pending sync queue items.

---

## 💻 13. Technology Stack

| Layer | Technology | Purpose / Implemented Usage |
| :--- | :--- | :--- |
| **Web Frontend** | React.js 18 + Vite | Single-page administrative dashboard portal |
| **Styling** | Tailwind CSS | Government design tokens, responsive layouts, color systems |
| **Web Mapping** | Leaflet / React-Leaflet | 5-layer interactive GIS visualization & parcel selection |
| **Backend Framework** | FastAPI (Python 3.11+) | High-throughput async REST API with auto-generated OpenAPI |
| **ORM & Spatial** | SQLAlchemy 2.0 + GeoAlchemy2 + Shapely | Relational modeling & spatial polygon/corridor queries |
| **Database** | PostgreSQL 16 + PostGIS 3.4 | Authoritative spatial & transactional data store |
| **Mobile Frontend** | Flutter (Dart 3.x) | Cross-platform mobile field inspection application |
| **Mobile Mapping** | `flutter_map` (v7.0.2) + `latlong2` | Mobile GIS engine with polygons, polylines & markers |
| **Mobile Local DB** | SQLite (`sqflite`) | Offline-first parcel caching & resilient sync queue |
| **State Management** | Riverpod / Provider | Declarative reactive state management |
| **Authentication** | JWT (JSON Web Tokens) + `passlib` (bcrypt) | Stateless secure authentication & RBAC |
| **Testing** | `pytest` + `flutter_test` | Automated backend & mobile test verification suites |

---

## 📂 14. Project Structure

```text
BhoomiSetu/
├── backend/                         # FastAPI & Node.js Backend Engine
│   ├── app/                         # FastAPI Python Application
│   │   ├── auth/                    # JWT & Password Hashing Utilities
│   │   ├── config/                  # Settings & Pydantic Environment Config
│   │   ├── database/                # SQLAlchemy Session & PostGIS Connectors
│   │   ├── models/                  # Declarative SQLAlchemy ORM Models
│   │   ├── routers/                 # 13 Dedicated REST API Routers
│   │   ├── schemas/                 # Pydantic Request/Response DTO Schemas
│   │   ├── services/                # Business Logic & Spatial Analysis Services
│   │   ├── storage/                 # Evidence & Document File Storage Handlers
│   │   ├── websocket/               # Real-time WebSocket Connection Manager
│   │   └── main.py                  # FastAPI Application Entrypoint & Middleware
│   ├── tests/                       # Pytest Automated Test Suite
│   ├── requirements.txt             # Python Dependencies
│   └── Dockerfile                   # Backend Container Definition
│
├── frontend/                        # React Web Administrative Portal
│   ├── src/
│   │   ├── assets/                  # National Emblem, Icons, Logos
│   │   ├── components/              # Reusable UI & GIS Components
│   │   │   ├── common/              # GovHeader, GovNavbar, GovFooter, StatCard, StatusBadge
│   │   │   ├── gis/                 # GISMap, GISLayerControl, GISLegend, ParcelInfoPanel, ULPINSearch
│   │   │   └── layout/              # DashboardLayout, ProtectedRoute
│   │   ├── context/                 # AuthContext.jsx, LanguageContext.jsx (Bilingual i18n)
│   │   ├── hooks/                   # useGISData.js, useAuth.js
│   │   ├── i18n/                    # translations.js (English / Hindi dictionary)
│   │   ├── pages/                   # Role Dashboards (Central, State, District, Agency, Field, GIS)
│   │   ├── services/                # api.js, authService.js, gisService.js, projectService.js
│   │   ├── App.jsx                  # React Router Route Tree & Role Guards
│   │   └── main.jsx                 # Application Bootstrap
│   ├── package.json                 # Frontend Dependencies & Scripts
│   ├── vite.config.js               # Vite Build Configuration
│   └── tailwind.config.js           # Tailwind Configuration
│
├── field-officer-app/               # Flutter Field Officer Mobile Application
│   ├── lib/
│   │   ├── core/                    # App Colors, Themes, Constants, Providers, SQLite Helper
│   │   ├── data/                    # Models, Repositories, Mock & API Datasources
│   │   ├── features/                # Feature Modules
│   │   │   ├── auth/                # Login Screen & Authentication
│   │   │   ├── dashboard/           # Field Officer Summary Dashboard
│   │   │   ├── field_visit/         # 9-Step Verification & Inspection Workflow
│   │   │   ├── map/                 # 5-Layer Mobile GIS Command Center & Widgets
│   │   │   ├── tasks/               # Assigned Field Tasks & Details
│   │   │   ├── evidence/            # Photo Evidence Capture with GPS Watermarking
│   │   │   ├── documents/           # Document Upload & Classification
│   │   │   └── sync/                # Offline Synchronization Center
│   │   └── main.dart                # Flutter Application Entrypoint
│   ├── test/                        # Flutter Unit & Widget Test Suite (20 Tests)
│   └── pubspec.yaml                 # Flutter Dependencies & Assets
│
├── database/                        # Database Schema & Migrations
│   ├── migrations/                  # 001_initial_schema.sql, 002_ulpin_migration.sql
│   └── seeds/                       # Seed Datasets for Corridors, Parcels, and Demo Users
│
├── docs/                            # Architecture & API Specifications
│   └── API_CONTRACT.md              # Detailed API Contract Documentation
│
├── .env.example                     # Environment Variables Template
└── README.md                        # Project Documentation
```

---

## 🧪 15. Testing & Verification

The codebase is validated across all tiers through automated test suites and real hardware testing:

- **Flutter Test Suite**: `20 / 20 tests passing (100%)` across authentication, domain models, GPS calculations, project corridor parsing, sync queues, and UI widgets.
- **Flutter Analyzer**: `0 errors` (`flutter analyze`).
- **Backend Test Suite**: Automated `pytest` suite validating JWT auth, data scoping, RBAC guards, spatial queries, and sync idempotency.
- **Physical Device Deployment**: Validated via dynamic ADB device deployment on physical Android hardware (`1220x2712` resolution), confirming real GPS coordinate acquisition, offline caching, and responsive touch GIS interaction.

---

## 📊 16. Current Implementation Status

| Feature / Module | Implementation Status | Description |
| :--- | :--- | :--- |
| **FastAPI Backend Core** | ✅ **Completed** | 13 REST routers, OpenAPI docs, centralized error handling |
| **Authentication & RBAC** | ✅ **Completed** | JWT issuance, password hashing, role & data-scoping guards |
| **PostgreSQL / PostGIS Schema** | ✅ **Completed** | Relational tables, spatial indexes, DDL migrations |
| **Web Administrative Portal** | ✅ **Completed** | 5 role-tailored dashboards, projects registry, field logs |
| **Bilingual Support (EN / HI)** | ✅ **Completed** | Instant UI language switching with comprehensive dictionary |
| **Advanced Web GIS** | ✅ **Completed** | 5-layer Leaflet map, corridor RoW, parcel polygons, ULPIN search |
| **Mobile GIS Command Center** | ✅ **Completed** | 5-layer `flutter_map` stack, RoW buffer, parcel sheets |
| **Mobile Field Visit Workflow** | ✅ **Completed** | 9-step inspection flow, GPS capture, photo evidence, documents |
| **Offline SQLite Sync** | ✅ **Completed** | Local caching, pending queue, idempotent replay keys |
| **ULPIN 360° View** | ✅ **Completed** | Full parcel attributes, ownership, RoW status, classification |
| **Audit Logging** | ✅ **Completed** | Structured administrative action tracking with timestamps |
| **Award & Compensation (DBT)** | 🟡 **In Progress / Prototype** | Calculation engine implemented; live bank gateway planned |
| **R&R Rehabilitation Tracking** | 🟡 **In Progress / Prototype** | Schema & basic endpoints implemented; workflow expansion planned |
| **Live State Registry APIs** | ⚪ **Planned / Future** | Standardized connectors ready; live state registry integration planned |
| **Satellite Change Detection** | ⚪ **Planned / Future** | Planned future enhancement using remote sensing imagery |

---

## 🌟 17. Key Differentiators

1. **GIS + Operational Workflow Fusion**: BhoomiSetu is not merely a static viewing map; spatial parcel selections directly trigger field tasks, verification visits, and executive decisions.
2. **True ULPIN-Centric Identity**: A single, uniform 14-digit land identity ties together geospatial polygons, ownership records, field inspection photos, and legal documents.
3. **Corridor-to-Parcel Geometric Alignment**: Highway and rail corridors visibly pass through and bisect affected cadastral plots, visually identifying impacted plots.
4. **Field-to-Authority Digital Thread**: On-ground GPS coordinates and geotagged photographic evidence captured on mobile immediately reflect on central executive dashboards.
5. **Resilient Offline Architecture**: Field revenue officers can execute complete inspections in remote valleys and forests without connectivity, seamlessly syncing once back in network range.

---

## 🎬 18. Prototype Demonstration Flow

To experience the full end-to-end BhoomiSetu workflow during a demonstration:

1. **Authority Login**: Log in to the Web Portal as District Authority (CALA) or Central Ministry.
2. **Explore GIS Command Center**: Open the GIS Command Center, select **Maharashtra → Pune**, and choose the **Pune Ring Road Express Corridor (Phase-I)**.
3. **Inspect RoW & Parcels**: Observe how the multi-layer highway corridor and 70m RoW buffer band pass directly through the affected parcel polygons in Urse, Hinjawadi, Lavale, and Bhugaon.
4. **Inspect ULPIN 360°**: Click parcel `PUN-PRR-14` (Bhugaon) to view its complete lifecycle attributes, titleholder, and `PROJECT-AFFECTED LAND: YES` status.
5. **Switch Projects**: Toggle to the **Pune-Nashik Semi-High Speed Rail Corridor** to review the 235 km alignment spanning 24 parcels across Hadapsar, Manchar, Sangamner, and Nashik.
6. **Open Field Officer App**: Launch the mobile app and navigate to the **Map** tab to view the identical GIS dataset on a mobile-optimized touch interface.
7. **Search & Select Parcel**: Tap Search, filter by `Lavale`, select parcel `1024`, and open the **Parcel Details Sheet**.
8. **Execute Field Visit**: Tap **START VISIT** to capture device GPS coordinates, complete the inspection checklist, capture photographic evidence, attach documents, and submit.
9. **Review Real-Time Sync**: Observe the updated verification status instantly reflecting across the authority dashboards and audit logs.

---

## 🚀 19. How to Run the Project

### Prerequisites
- **Node.js** (v18+ LTS)
- **Python** (v3.10+)
- **Flutter SDK** (v3.22+)
- **PostgreSQL 16** with **PostGIS** extension (or SQLite fallback for quick evaluation)
- **Android SDK / Connected Device** (for mobile application)

---

### Step 1: Clone the Repository
```bash
git clone https://github.com/HemantXCode/BhoomiSetu.git
cd BhoomiSetu
```

---

### Step 2: Backend Setup (FastAPI)
```bash
cd backend

# Create and activate virtual environment
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
# source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env

# Run FastAPI development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
- Interactive API Documentation: `http://localhost:8000/docs`
- Health Check: `http://localhost:8000/health`

---

### Step 3: Frontend Setup (React + Vite)
```bash
cd ../frontend

# Install dependencies
npm install

# Start Vite development server
npm run dev
```
- Access Web Portal: `http://localhost:5173`

---

### Step 4: Mobile App Setup (Flutter)
```bash
cd ../field-officer-app

# Get Flutter packages
flutter pub get

# Run test suite
flutter test

# Run analyzer
flutter analyze

# Detect connected Android device
adb devices

# Run on connected device or emulator
flutter run
```

---

## 🔐 20. Environment Variables Template

Create a `.env` file in the `backend/` directory with the following configuration keys:

```env
# Server Configuration
PROJECT_NAME="BhoomiSetu - National Land Acquisition System"
API_V1_STR="/api/v1"
PORT=8000
HOST="0.0.0.0"
ENVIRONMENT="development"

# CORS Configuration
ALLOWED_ORIGINS="http://localhost:5173,http://localhost:3000,http://127.0.0.1:5173"

# Database Configuration (PostgreSQL + PostGIS)
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/bhoomisetu"

# JWT Security
SECRET_KEY="your-secure-256-bit-secret-key-here"
ALGORITHM="HS256"
ACCESS_TOKEN_EXPIRE_MINUTES=1440

# File Storage Volume
UPLOAD_STORAGE_DIR="./storage/uploads"
MAX_UPLOAD_SIZE_MB=25
```

---

## 🗺️ 21. Future Roadmap

- [ ] **State Land Registry Integrations**: Secure standardized adapters for State Bhulekh / Bhoomi land record APIs.
- [ ] **Automated Award & DBT Gateway**: Direct integration with PFMS / e-Kuber for instant compensation disbursement.
- [ ] **AI-Assisted Title Deed Scrutiny**: Automated optical character recognition (OCR) and semantic validation of registered sale deeds.
- [ ] **Satellite Change Detection**: Automated alerts on unauthorized construction within the notified 70m Right-of-Way corridor using optical satellite feeds.
- [ ] **Grievance Redressal Portal**: Citizen-facing dispute tracking and compensation status verification.

---

## 📄 License & Attribution

Developed for the **Smart India Hackathon (SIH)**.  
Designed and maintained by the **BhoomiSetu Development Team**.
