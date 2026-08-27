-- BhoomiSetu: Phase 1 Initial Database Schema
-- Compatible with PostgreSQL (and prepared for PostGIS extensions in Phase 4)

-- 1. STATES
CREATE TABLE IF NOT EXISTS states (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(10) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. DISTRICTS
CREATE TABLE IF NOT EXISTS districts (
    id SERIAL PRIMARY KEY,
    state_id INTEGER NOT NULL REFERENCES states(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(10) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_state_district_code UNIQUE (state_id, code)
);

CREATE INDEX IF NOT EXISTS idx_districts_state_id ON districts(state_id);

-- 3. AGENCIES
CREATE TABLE IF NOT EXISTS agencies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    state_id INTEGER REFERENCES states(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_agencies_state_id ON agencies(state_id);

-- 4. USERS
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN (
        'CENTRAL_MINISTRY',
        'STATE_GOVERNMENT',
        'DISTRICT_AUTHORITY',
        'PROJECT_AGENCY',
        'FIELD_OFFICER'
    )),
    state_id INTEGER REFERENCES states(id) ON DELETE SET NULL,
    district_id INTEGER REFERENCES districts(id) ON DELETE SET NULL,
    agency_id INTEGER REFERENCES agencies(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_scope ON users(state_id, district_id, agency_id);

-- 5. PROJECTS
CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    description TEXT,
    agency_id INTEGER NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
    state_id INTEGER NOT NULL REFERENCES states(id) ON DELETE RESTRICT,
    district_id INTEGER NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    proposed_area NUMERIC(12, 2) NOT NULL, -- in hectares
    status VARCHAR(50) NOT NULL DEFAULT 'PROPOSED' CHECK (status IN (
        'PROPOSED',
        'SURVEY_IN_PROGRESS',
        'NOTIFICATION_IN_PROGRESS',
        'AWARD_IN_PROGRESS',
        'COMPENSATION_IN_PROGRESS',
        'POSSESSION_IN_PROGRESS',
        'POSSESSION_HANDED_OVER',
        'DELAYED'
    )),
    start_date DATE,
    expected_end_date DATE,
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_projects_agency_id ON projects(agency_id);
CREATE INDEX IF NOT EXISTS idx_projects_state_id ON projects(state_id);
CREATE INDEX IF NOT EXISTS idx_projects_district_id ON projects(district_id);
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
