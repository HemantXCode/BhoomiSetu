-- BhoomiSetu: Phase 1 Seed Data
-- States, Districts, Agencies, Demo Users, and Realistic Projects

-- 1. SEED STATES
INSERT INTO states (id, name, code) VALUES
(1, 'Maharashtra', 'MH'),
(2, 'Gujarat', 'GJ'),
(3, 'Karnataka', 'KA'),
(4, 'Rajasthan', 'RJ'),
(5, 'Uttar Pradesh', 'UP'),
(6, 'Tamil Nadu', 'TN')
ON CONFLICT (id) DO NOTHING;

-- 2. SEED DISTRICTS
INSERT INTO districts (id, state_id, name, code) VALUES
-- Maharashtra
(1, 1, 'Pune', 'PUN'),
(2, 1, 'Nagpur', 'NGP'),
(3, 1, 'Thane', 'THN'),
(4, 1, 'Nashik', 'NSK'),
-- Gujarat
(5, 2, 'Ahmedabad', 'AMD'),
(6, 2, 'Surat', 'SRT'),
(7, 2, 'Vadodara', 'BRD'),
-- Karnataka
(8, 3, 'Bengaluru Urban', 'BLR'),
(9, 3, 'Mysuru', 'MYS'),
(10, 3, 'Belagavi', 'BLG'),
-- Rajasthan
(11, 4, 'Jaipur', 'JPR'),
(12, 4, 'Jodhpur', 'JDH'),
(13, 4, 'Kota', 'KTA'),
-- Uttar Pradesh
(14, 5, 'Lucknow', 'LKO'),
(15, 5, 'Varanasi', 'VNS'),
(16, 5, 'Kanpur Nagar', 'KNP'),
-- Tamil Nadu
(17, 6, 'Chennai', 'CHN'),
(18, 6, 'Coimbatore', 'CBE'),
(19, 6, 'Madurai', 'MDU')
ON CONFLICT (id) DO NOTHING;

-- 3. SEED AGENCIES
INSERT INTO agencies (id, name, type, state_id) VALUES
(1, 'National Highways Authority of India (NHAI)', 'CENTRAL_PSU', NULL),
(2, 'Dedicated Freight Corridor Corporation of India (DFCCIL)', 'CENTRAL_PSU', NULL),
(3, 'Maharashtra State Road Development Corporation (MSRDC)', 'STATE_PSU', 1),
(4, 'Gujarat Industrial Development Corporation (GIDC)', 'STATE_PSU', 2),
(5, 'Bangalore Metro Rail Corporation Limited (BMRCL)', 'STATE_JOINT_PSU', 3),
(6, 'Uttar Pradesh Expressways Industrial Development Authority (UPEIDA)', 'STATE_PSU', 5)
ON CONFLICT (id) DO NOTHING;

-- 4. SEED DEMO USERS (Password: Demo@12345, bcrypt hash with salt rounds 10)
-- Hash: $2a$10$w09ZlWvLfZv9rQG7gqY4v.P8o9uYl1xWc6Hj2lP9k7d4c.xR/6y8K or generated via seed script
INSERT INTO users (id, name, email, password_hash, role, state_id, district_id, agency_id, is_active) VALUES
(1, 'Dr. Rajesh Verma (Joint Secretary)', 'central.demo@example.com', '$2a$10$y6m49F8U5p4l7oX8gE674O2s0eCffB1c8gQh5Vz0o9A2fV4Fz12iO', 'CENTRAL_MINISTRY', NULL, NULL, NULL, TRUE),
(2, 'Shri Anand Kulkarni (Principal Secretary, Revenue)', 'state.demo@example.com', '$2a$10$y6m49F8U5p4l7oX8gE674O2s0eCffB1c8gQh5Vz0o9A2fV4Fz12iO', 'STATE_GOVERNMENT', 1, NULL, NULL, TRUE),
(3, 'Smt. Sujata Deshmukh (District Collector & LAO)', 'district.demo@example.com', '$2a$10$y6m49F8U5p4l7oX8gE674O2s0eCffB1c8gQh5Vz0o9A2fV4Fz12iO', 'DISTRICT_AUTHORITY', 1, 1, NULL, TRUE),
(4, 'Er. Vikram Malhotra (Chief Project Manager, NHAI)', 'agency.demo@example.com', '$2a$10$y6m49F8U5p4l7oX8gE674O2s0eCffB1c8gQh5Vz0o9A2fV4Fz12iO', 'PROJECT_AGENCY', NULL, NULL, 1, TRUE),
(5, 'Suresh Patil (Sub-Divisional Field Officer)', 'field.demo@example.com', '$2a$10$y6m49F8U5p4l7oX8gE674O2s0eCffB1c8gQh5Vz0o9A2fV4Fz12iO', 'FIELD_OFFICER', 1, 1, 1, TRUE)
ON CONFLICT (id) DO NOTHING;

-- 5. SEED PROJECTS
INSERT INTO projects (id, project_name, description, agency_id, state_id, district_id, proposed_area, status, start_date, expected_end_date, created_by) VALUES
-- Maharashtra Projects
(1, 'Pune Ring Road Express Corridor (Phase-I)', 'Acquisition of bypass land corridor spanning Haveli and Mulshi talukas to ease national transit congestion.', 1, 1, 1, 485.50, 'COMPENSATION_IN_PROGRESS', '2025-01-15', '2026-12-31', 4),
(2, 'Pune-Nashik Semi High-Speed Rail Corridor', 'Linear greenfield land acquisition across 12 villages for multi-modal logistics corridor.', 3, 1, 1, 310.20, 'NOTIFICATION_IN_PROGRESS', '2025-03-01', '2027-06-30', 4),
(3, 'Nagpur Metro Rail Phase-II Extension', 'Urban and peri-urban land parcels required for terminal yard expansion and viaduct pillars.', 1, 1, 2, 142.80, 'SURVEY_IN_PROGRESS', '2025-02-10', '2026-10-15', 4),
(4, 'Thane-Borivali Twin Tunnel Approach Expressway', 'Forest and revenue land acquisition for western bypass approach interchange.', 3, 1, 3, 95.40, 'DELAYED', '2024-08-01', '2026-03-31', 4),

-- Gujarat Projects
(5, 'Ahmedabad-Dholera Special Investment Region Expressway', 'Greenfield expressway connectivity to Dholera Industrial Hub.', 1, 2, 5, 620.00, 'POSSESSION_IN_PROGRESS', '2024-11-01', '2026-08-30', 4),
(6, 'Western Dedicated Freight Corridor (Surat Section)', 'Double line electrified freight corridor right-of-way land parcels.', 2, 2, 6, 280.75, 'POSSESSION_HANDED_OVER', '2024-05-15', '2025-11-30', 4),

-- Karnataka Projects
(7, 'Bengaluru Peripheral Ring Road (Northern Segment)', 'Access-controlled 8-lane expressway corridor surrounding Bengaluru urban perimeter.', 5, 3, 8, 540.30, 'AWARD_IN_PROGRESS', '2025-01-10', '2027-04-30', 4),
(8, 'Mysuru Industrial Growth Center Expansion', 'Contiguous agricultural land conversion for green electronics manufacturing cluster.', 1, 3, 9, 215.60, 'SURVEY_IN_PROGRESS', '2025-04-01', '2026-12-15', 4),

-- Uttar Pradesh Projects
(9, 'Ganga Expressway Phase-II (Lucknow Spur)', 'Six-lane expandable greenfield expressway link connecting central UP districts.', 6, 5, 14, 780.00, 'COMPENSATION_IN_PROGRESS', '2024-09-01', '2026-12-31', 4),
(10, 'Varanasi Multi-Modal Freight Logistics Hub', 'Riverfront port and rail freight terminal land integration.', 2, 5, 15, 165.90, 'PROPOSED', '2025-06-01', '2027-08-31', 4),

-- Rajasthan Projects
(11, 'Jaipur-Kishangarh Economic Feeder Corridor', 'Highway widening and service lane right-of-way acquisition.', 1, 4, 11, 190.40, 'AWARD_IN_PROGRESS', '2025-02-20', '2026-11-30', 4),

-- Tamil Nadu Projects
(12, 'Chennai Outer Orbital Expressway (Poonamallee-Minjur)', 'Strategic orbital freight bypass connecting industrial ports.', 1, 6, 17, 345.80, 'NOTIFICATION_IN_PROGRESS', '2025-01-05', '2027-02-28', 4)
ON CONFLICT (id) DO NOTHING;

-- Reset sequence counters for future inserts
SELECT setval(pg_get_serial_sequence('states', 'id'), coalesce(max(id),0) + 1, false) FROM states;
SELECT setval(pg_get_serial_sequence('districts', 'id'), coalesce(max(id),0) + 1, false) FROM districts;
SELECT setval(pg_get_serial_sequence('agencies', 'id'), coalesce(max(id),0) + 1, false) FROM agencies;
SELECT setval(pg_get_serial_sequence('users', 'id'), coalesce(max(id),0) + 1, false) FROM users;
SELECT setval(pg_get_serial_sequence('projects', 'id'), coalesce(max(id),0) + 1, false) FROM projects;
