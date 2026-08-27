# BhoomiSetu Architecture Specification

## 1. Overview
**BhoomiSetu** is a Real-Time National Land Acquisition & Management System designed to digitize and monitor the complete land acquisition lifecycle across India.

## 2. System Architecture Layers

```text
┌─────────────────────────────────────────────────────────────┐
│                    Client Browser (React)                   │
│  - Traditional Indian Government Portal UI (Orange/White)   │
│  - 5 Role-Specific Dashboards (Central, State, Dist, Agency, Field) │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTPS / REST (JWT Auth)
┌──────────────────────────────▼──────────────────────────────┐
│                    Node.js / Express Backend                │
│  - Authentication Layer (JWT + bcrypt)                      │
│  - RBAC & Data Scope Middleware                             │
│  - Domain Controllers (Auth, Projects, Dashboard)           │
│  - Database Access Layer (pg Pool + Parameterized SQL)      │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                     PostgreSQL Database                     │
│  - Tables: states, districts, agencies, users, projects     │
│  - PostGIS Prepared Architecture (Phase 4 ready)            │
└─────────────────────────────────────────────────────────────┘
```

## 3. Role-Based Access Control (RBAC) & Scope Matrix

| Role | Geographical Scope | Accessible Data | Key Capabilities |
| :--- | :--- | :--- | :--- |
| `CENTRAL_MINISTRY` | **All India** | All states, all districts, all agencies, all projects | National KPI analysis, state comparison, delay monitoring |
| `STATE_GOVERNMENT` | **Assigned State** | Only projects located within the assigned state | State KPI monitoring, district progress, state approvals |
| `DISTRICT_AUTHORITY`| **Assigned District** | Only projects located within the assigned district | Field queue management, notification/award tracking, local possession |
| `PROJECT_AGENCY` | **Assigned Agency** | Only projects belonging to the executing agency | Project proposal submission, timeline & milestone tracking |
| `FIELD_OFFICER` | **Assigned District / Projects** | Projects assigned for field-level inspection | Mobile-first inspection, evidence/photo logging, verification submission |

## 4. Database Schema Relationships

```text
[states] (1) ──< (N) [districts]
   │                       │
   │ (1)                   │ (1)
   └───< (N) [agencies]    │
   │           │ (1)       │
   │ (1)       └───< (N) [projects] >─── (1) [districts]
   │                       │ (N)
   └───< (N) [users] >─────┘ (created_by)
```
