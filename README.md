# BhoomiSetu

## Real-Time National Land Acquisition & Management System
*Connecting Land, People & Governance • Digital Land Lifecycle Platform*

---

## 📌 Project Overview
**BhoomiSetu** is a Smart India Hackathon (SIH) prototype designed to digitize, monitor, and coordinate the complete land acquisition lifecycle in India—from initial project proposal formulation and Joint Measurement Surveys (JMS) to Section 4/11 gazette notifications, award determination (Section 23), Direct Benefit Transfer (DBT) compensation disbursement, and final possession handover.

The platform coordinates five administrative tiers with strict Role-Based Access Control (RBAC) and geographical data scoping:
1. **Central Ministry (National PMU)** — Apex nationwide oversight, inter-ministerial clearances, state progress comparison.
2. **State Government (Revenue Department)** — State jurisdiction monitoring, district-wise progress, Section 19 declarations, grant sanctions.
3. **District Authority (Collector / CALA)** — Field verification queue, gazette notifications, award determination, and escrow disbursements.
4. **Project Implementing Agency (NHAI, DFCCIL, Metro Rail)** — Linear project proposals, RoW acquisition tracking, statutory milestone timeline.
5. **Field Officer (Sub-Divisional Revenue Officer)** — Mobile-first ground inspection, GPS boundary geotagging, on-site structure enumeration, evidence upload.

---

## 🚀 Current Phase
**Phase 1 — Foundation, Authentication, RBAC and Five Role Dashboards**

---

## ✨ Current Features
- **Traditional Indian Government Portal UI**: Official header, Lion Capital of Ashoka emblem, bilingual layout (`भारत सरकार` / `GOVERNMENT OF INDIA`), orange and white color palette, and high-contrast tables.
- **Five User Roles**: Central Ministry, State Government, District Authority, Project Implementing Agency, and Field Officer.
- **Role-Based Login**: Dedicated secure login with role identification and automatic dashboard routing.
- **JWT Authentication**: Secure stateless token issuance with expiration handling.
- **Role-Based Access Control (RBAC)**: Backend-enforced route guards and 403 Forbidden protection.
- **Data-Scoped Authorization**: Automatic SQL-level filtering restricting records to caller's state, district, or agency.
- **Five Role-Specific Dashboards**: Tailored views with dynamic metrics for each administrative tier.
- **Project Management Foundation**: Scoped project directory with filtering, detail view, and proposal creation.
- **Dashboard Statistics Foundation**: Real-time KPI calculations derived from the database.
- **Responsive Interface**: Mobile-first field inspection layout with large touch targets.
- **PostgreSQL Database Foundation**: Relational DDL schema with foreign keys, indexes, and PostGIS compatibility.
- **REST API Foundation**: Structured Express.js endpoints with centralized error handling.

---

## 👥 User Roles

| Role | Administrative Scope | Key Capabilities |
| :--- | :--- | :--- |
| **1. Central Ministry** | **All India** | Nationwide KPI consolidation, state-wise tables, delay bottlenecks radar |
| **2. State Government** | **Assigned State** | State jurisdiction oversight, district-wise breakdown, Section 19 approvals |
| **3. District Authority** | **Assigned District** | CALA operational queue, field verification backlog, awards & DBT tracking |
| **4. Project Agency** | **Assigned Agency** | Linear project proposals, milestone timeline, RoW possession tracking |
| **5. Field Officer** | **Assigned Division** | Mobile-first ground inspection, GPS geotagging, site photo upload |

---

## 💻 Technology Stack

### Frontend
- **React.js 18** with **Vite**
- **Tailwind CSS** (Government design tokens)
- **React Router v6** (Role-protected route guards)
- **Axios** (JWT interceptors & 401 handling)
- **Lucide React** (Official icons)

### Backend
- **Node.js** & **Express.js** (REST API)
- **PostgreSQL** (with `pg` connection pooling)
- **JWT (`jsonwebtoken`)** (Session tokens)
- **bcryptjs** (Salt rounds = 10)
- **dotenv** & **cors**

---

## 📂 Project Structure

```text
BhoomiSetu/
├── backend/
│   ├── src/
│   │   ├── config/          # db.js (PostgreSQL pool), env.js, seed.js
│   │   ├── controllers/     # authController, projectController, dashboardController, geoController
│   │   ├── middleware/      # authMiddleware, rbacMiddleware, errorHandler
│   │   ├── models/          # userModel, projectModel, geoModel
│   │   ├── routes/          # authRoutes, projectRoutes, dashboardRoutes, geoRoutes
│   │   ├── services/        # authService, projectService, dashboardService
│   │   ├── utils/           # jwt.js, hash.js, response.js
│   │   ├── app.js           # Express application setup
│   │   └── server.js        # Server listener
│   ├── tests/               # run_tests.js (Automated test suite)
│   └── package.json
│
├── frontend/
│   ├── src/
│   │   ├── assets/          # Official emblem and images
│   │   ├── components/
│   │   │   ├── common/      # GovHeader, GovNavbar, GovFooter, GovEmblem, StatCard, DataTable, StatusBadge, Breadcrumbs
│   │   │   ├── layout/      # DashboardLayout, ProtectedRoute
│   │   │   └── forms/       # ProposalModal
│   │   ├── context/         # AuthContext.jsx
│   │   ├── pages/
│   │   │   ├── auth/        # LoginPage.jsx, AccessDenied.jsx
│   │   │   ├── central/     # CentralDashboard.jsx
│   │   │   ├── state/       # StateDashboard.jsx
│   │   │   ├── district/    # DistrictDashboard.jsx
│   │   │   ├── agency/      # AgencyDashboard.jsx
│   │   │   ├── field/       # FieldDashboard.jsx
│   │   │   └── projects/    # ProjectsList.jsx
│   │   ├── services/        # api.js, authService.js, projectService.js, dashboardService.js
│   │   ├── App.jsx          # Route definitions & Role guards
│   │   ├── main.jsx
│   │   └── index.css        # Government styling
│   ├── package.json
│   ├── vite.config.js
│   └── tailwind.config.js
│
├── database/
│   ├── migrations/          # 001_initial_schema.sql (PostgreSQL DDL)
│   └── seeds/               # 001_demo_data.sql (States, Districts, Agencies, Demo Users, Projects)
│
├── docs/
│   ├── architecture.md      # Architecture specification & schema
│   ├── api_spec.md          # REST API endpoints & payload specifications
│   └── PHASE1_PROGRESS.md   # Phase 1 technical completion report
│
├── .env.example
├── .gitignore
└── README.md
```

---

## 🛠️ Setup Instructions

### 1. Prerequisites
- **Node.js** (v18+ LTS recommended)
- **PostgreSQL** (Configured in `.env` or automatic fallback for rapid local testing)

### 2. Environment Setup
Copy the example environment file:
```bash
cp .env.example .env
```

Configure your `.env`:
```env
PORT=5000
NODE_ENV=development
FRONTEND_URL=http://localhost:5173
DATABASE_URL=postgres://postgres:postgres@localhost:5432/bhoomisetu
JWT_SECRET=your_secure_jwt_secret_key
JWT_EXPIRES_IN=24h
```

### 3. Backend Setup
```bash
cd backend
npm install
npm test       # Run automated unit & integration tests
npm start      # Starts backend on http://localhost:5000
```

### 4. Frontend Setup
```bash
cd frontend
npm install
npm run dev    # Starts Vite dev server on http://localhost:5173
```

Visit **http://localhost:5173** to access the portal.

---

## 🔑 Demo Accounts (Development & Review)

All demo accounts use the common development password: **`Demo@12345`**

| Role | Email / User ID | Jurisdiction / Scope | Access Level |
| :--- | :--- | :--- | :--- |
| **Central Ministry** | `central.demo@example.com` | **All India** | National PMU Overview |
| **State Government** | `state.demo@example.com` | **Maharashtra** (`state_id = 1`) | State Revenue Oversight |
| **District Authority** | `district.demo@example.com` | **Pune District** (`district_id = 1`) | CALA Operational Office |
| **Project Agency** | `agency.demo@example.com` | **NHAI** (`agency_id = 1`) | Executing Agency Portfolio |
| **Field Officer** | `field.demo@example.com` | **Pune Field Division** | Ground Inspection Unit |

---

## 🔮 Future Development Roadmap

### Group 1: Land Acquisition + Project Workflow
- Project proposal review, verification, and multi-tier approval workflow
- Statutory RFCTLARR gazette stages (Section 4 preliminary, Section 11, Section 19 declaration, Section 23 award)
- Joint Measurement Survey (JMS) scheduling and milestone tracking

### Group 2: GIS + Compensation + R&R
- PostGIS spatial layers, cadastral parcel mapping, and polygon boundary visualization
- Direct Benefit Transfer (DBT) escrow calculation and payment disbursement tracking
- Rehabilitation & Resettlement (R&R) family entitlement tracking and resettlement package allocation

### Group 3: MIS + Analytics + AI + Integration
- National, State, and District MIS reporting engine with PDF/Excel export
- Delay prediction, bottleneck risk scoring, and spatial trend analysis
- Secure API integration with State Land Records (Bhulekh / Mahabhulekh) and cadastral map databases
