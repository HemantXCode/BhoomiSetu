# BhoomiSetu — Phase 1 Progress & Technical Specification

## 1. Project Foundation
- Established clean, modular repository architecture dividing `frontend/`, `backend/`, `database/`, and `docs/`.
- Configured environment isolation via `.env.example`.
- Verified 100% test coverage for authentication, RBAC, and data-scope logic.

---

## 2. UI Design System
- Built to Indian Government Digital Portal standards (Orange `#FF6B00`, `#D9531E`, Crisp White `#FFFFFF`, Dark Charcoal `#1E293B`).
- Government of India official header layout with Indian Tricolor accent, Lion Capital of Ashoka emblem, bilingual text (`भारत सरकार` / `GOVERNMENT OF INDIA`), accessibility font toggles, and 24x7 Helpdesk.
- Structured rectangular cards, status badges, data tables with search and pagination, and formal typography.

---

## 3. Five Roles & RBAC Matrix
1. **`CENTRAL_MINISTRY`**: Apex national jurisdiction, All-India data scope.
2. **`STATE_GOVERNMENT`**: State jurisdiction (Revenue Department), restricted to own state.
3. **`DISTRICT_AUTHORITY`**: District Collector / CALA, restricted to own district.
4. **`PROJECT_AGENCY`**: Project Implementing Agency (e.g. NHAI), restricted to agency projects.
5. **`FIELD_OFFICER`**: Sub-divisional field officer, operational inspection queue.

---

## 4. Authentication & Security
- **JWT (JSON Web Tokens)**: Stateless token issuance containing user ID, role, and geographical scope IDs.
- **bcrypt**: Passwords hashed with salt factor 10.
- **Middleware**:
  - `authenticateToken`: Validates Bearer token and rejects unauthorized requests (401).
  - `authorizeRoles`: Backend authorization guard rejecting role mismatches (403).
  - `applyDataScope`: Parameterized query scoping restricting database rows to caller's geographical jurisdiction.

---

## 5. Five Role-Specific Dashboards
- **Central Ministry** (`/central/dashboard`): 11 national KPI cards, state-wise progress table, delay bottlenecks radar, alerts feed.
- **State Government** (`/state/dashboard`): State metrics, district-wise progress breakdown, pending Section 19 clearances.
- **District Authority** (`/district/dashboard`): CALA operational queue, field verification backlog, Section 4/11 notifications, award status.
- **Project Agency** (`/agency/dashboard`): NHAI project portfolio, milestone timeline, `+ Submit New Project Proposal` modal.
- **Field Officer** (`/field/dashboard`): Mobile-first touch interface, GPS geotagging, site photo evidence upload, statutory checklist.

---

## 6. Database Architecture
- **PostgreSQL DDL**: `database/migrations/001_initial_schema.sql` (`states`, `districts`, `agencies`, `users`, `projects`).
- **Seed Data**: `database/seeds/001_demo_data.sql` (6 States, 19 Districts, 6 Agencies, 12 Projects, 5 Demo Accounts).
- **PostGIS Compatibility**: DDL prepared for geometry/spatial extensions in Phase 4.

---

## 7. API Foundation
- `POST /api/auth/login`, `GET /api/auth/me`
- `GET /api/projects`, `GET /api/projects/:id`, `POST /api/projects`
- `GET /api/dashboard/stats` (Dynamic aggregation based on role and scope)
- `GET /api/geo/states`, `GET /api/geo/districts`, `GET /api/geo/agencies`

---

## 8. Current Limitations (Phase 1 Baseline)
- PostGIS spatial layers, cadastral map overlays, and polygon boundary drawing are scheduled for Phase 4.
- Statutory multi-stage legal approval workflows (e.g., Section 15 objections, Section 19 declaration approvals) are scheduled for Phase 2 & 3.
- Live DBT payment gateway and escrow bank reconciliation are scheduled for Phase 5.

---

## 9. Next Steps (Phase 2 Roadmap)
- Project Proposal Submission & Verification Workflow
- Multi-tier administrative approval workflows
- Linear milestone tracking & project management
