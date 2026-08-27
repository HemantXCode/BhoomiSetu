const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
const config = require('./env');

let pool = null;
let isPgConnected = false;

// Internal in-memory storage fallback for seamless zero-setup testing if local Postgres service is not yet running
const memoryStore = {
  states: [],
  districts: [],
  agencies: [],
  users: [],
  projects: []
};

// Initialize PostgreSQL Pool
try {
  pool = new Pool({
    connectionString: config.DATABASE_URL,
    connectionTimeoutMillis: 3000,
    idleTimeoutMillis: 10000,
    max: 10
  });

  pool.on('error', (err) => {
    console.warn('⚠️  PostgreSQL pool background error:', err.message);
  });
} catch (err) {
  console.warn('⚠️  PostgreSQL connection initialization note:', err.message);
}

/**
 * Universal query runner with PostgreSQL support and local fallback
 */
async function query(text, params = []) {
  if (pool && isPgConnected) {
    try {
      const start = Date.now();
      const res = await pool.query(text, params);
      const duration = Date.now() - start;
      if (config.NODE_ENV === 'development') {
        // console.log('Executed query', { text: text.slice(0, 80), duration, rows: res.rowCount });
      }
      return res;
    } catch (err) {
      console.error('Database query error:', err.message, 'Query:', text);
      throw err;
    }
  }

  // Execute on local in-memory store if Postgres is offline
  return executeMemoryQuery(text, params);
}

/**
 * In-memory SQL engine for local test runs and offline demo
 */
function executeMemoryQuery(sql, params = []) {
  const trimmed = sql.trim().replace(/;/g, '');
  const upper = trimmed.toUpperCase();

  // Normalize parameters: replace $1, $2 with values
  const getParam = (idx) => params[idx - 1];

  // 1. SELECT queries
  if (upper.startsWith('SELECT')) {
    // USERS lookup by email
    if (upper.includes('FROM USERS') && (upper.includes('EMAIL = $1') || upper.includes('U.EMAIL = $1'))) {
      const email = params[0]?.toLowerCase().trim();
      const user = memoryStore.users.find(u => u.email.toLowerCase() === email);
      if (!user) return { rows: [], rowCount: 0 };
      
      const state = memoryStore.states.find(s => s.id === user.state_id);
      const district = memoryStore.districts.find(d => d.id === user.district_id);
      const agency = memoryStore.agencies.find(a => a.id === user.agency_id);

      return {
        rows: [{
          id: user.id,
          name: user.name,
          email: user.email,
          password_hash: user.password_hash,
          role: user.role,
          state_id: user.state_id,
          district_id: user.district_id,
          agency_id: user.agency_id,
          is_active: user.is_active,
          created_at: user.created_at,
          state_name: state ? state.name : null,
          state_code: state ? state.code : null,
          district_name: district ? district.name : null,
          district_code: district ? district.code : null,
          agency_name: agency ? agency.name : null,
          agency_type: agency ? agency.type : null
        }],
        rowCount: 1
      };
    }

    // USERS lookup by ID
    if (upper.includes('FROM USERS') && (upper.includes('ID = $1') || upper.includes('U.ID = $1'))) {
      const id = parseInt(params[0], 10);
      const user = memoryStore.users.find(u => u.id === id);
      if (!user) return { rows: [], rowCount: 0 };
      
      const state = memoryStore.states.find(s => s.id === user.state_id);
      const district = memoryStore.districts.find(d => d.id === user.district_id);
      const agency = memoryStore.agencies.find(a => a.id === user.agency_id);

      return {
        rows: [{
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          state_id: user.state_id,
          district_id: user.district_id,
          agency_id: user.agency_id,
          is_active: user.is_active,
          created_at: user.created_at,
          state_name: state ? state.name : null,
          state_code: state ? state.code : null,
          district_name: district ? district.name : null,
          district_code: district ? district.code : null,
          agency_name: agency ? agency.name : null,
          agency_type: agency ? agency.type : null
        }],
        rowCount: 1
      };
    }

    // STATES list
    if (upper.includes('FROM STATES')) {
      return { rows: [...memoryStore.states].sort((a, b) => a.name.localeCompare(b.name)), rowCount: memoryStore.states.length };
    }

    // DISTRICTS list
    if (upper.includes('FROM DISTRICTS')) {
      let filtered = [...memoryStore.districts];
      if (upper.includes('WHERE STATE_ID = $1')) {
        const stateId = parseInt(params[0], 10);
        filtered = filtered.filter(d => d.state_id === stateId);
      }
      return { rows: filtered.sort((a, b) => a.name.localeCompare(b.name)), rowCount: filtered.length };
    }

    // AGENCIES list
    if (upper.includes('FROM AGENCIES')) {
      let filtered = [...memoryStore.agencies];
      if (upper.includes('WHERE STATE_ID = $1 OR STATE_ID IS NULL')) {
        const stateId = parseInt(params[0], 10);
        filtered = filtered.filter(a => a.state_id === stateId || a.state_id === null);
      }
      return { rows: filtered.sort((a, b) => a.name.localeCompare(b.name)), rowCount: filtered.length };
    }

    // PROJECTS queries
    if (upper.includes('FROM PROJECTS')) {
      let result = memoryStore.projects.map(p => {
        const state = memoryStore.states.find(s => s.id === p.state_id);
        const district = memoryStore.districts.find(d => d.id === p.district_id);
        const agency = memoryStore.agencies.find(a => a.id === p.agency_id);
        const user = memoryStore.users.find(u => u.id === p.created_by);
        return {
          ...p,
          state_name: state ? state.name : null,
          district_name: district ? district.name : null,
          agency_name: agency ? agency.name : null,
          creator_name: user ? user.name : null
        };
      });

      // Filter by ID
      if (upper.includes('WHERE P.ID = $1') || upper.includes('WHERE ID = $1')) {
        const id = parseInt(params[0], 10);
        result = result.filter(p => p.id === id);
      }

      // Filter by State
      if (upper.includes('STATE_ID = $') || upper.includes('P.STATE_ID = $')) {
        const match = upper.match(/STATE_ID\s*=\s*\$(\d+)/);
        if (match) {
          const pIndex = parseInt(match[1], 10) - 1;
          const sId = parseInt(params[pIndex], 10);
          if (sId) result = result.filter(p => p.state_id === sId);
        }
      }

      // Filter by District
      if (upper.includes('DISTRICT_ID = $') || upper.includes('P.DISTRICT_ID = $')) {
        const match = upper.match(/DISTRICT_ID\s*=\s*\$(\d+)/);
        if (match) {
          const pIndex = parseInt(match[1], 10) - 1;
          const dId = parseInt(params[pIndex], 10);
          if (dId) result = result.filter(p => p.district_id === dId);
        }
      }

      // Filter by Agency
      if (upper.includes('AGENCY_ID = $') || upper.includes('P.AGENCY_ID = $')) {
        const match = upper.match(/AGENCY_ID\s*=\s*\$(\d+)/);
        if (match) {
          const pIndex = parseInt(match[1], 10) - 1;
          const aId = parseInt(params[pIndex], 10);
          if (aId) result = result.filter(p => p.agency_id === aId);
        }
      }

      // Filter by Status
      if (upper.includes('STATUS = $') || upper.includes('P.STATUS = $')) {
        const match = upper.match(/STATUS\s*=\s*\$(\d+)/);
        if (match) {
          const pIndex = parseInt(match[1], 10) - 1;
          const st = params[pIndex];
          if (st) result = result.filter(p => p.status === st);
        }
      }

      return { rows: result, rowCount: result.length };
    }
  }

  // 2. INSERT queries
  if (upper.startsWith('INSERT INTO PROJECTS')) {
    const id = memoryStore.projects.length > 0 ? Math.max(...memoryStore.projects.map(p => p.id)) + 1 : 1;
    const newProject = {
      id,
      project_name: params[0],
      description: params[1],
      agency_id: parseInt(params[2], 10),
      state_id: parseInt(params[3], 10),
      district_id: parseInt(params[4], 10),
      proposed_area: parseFloat(params[5]),
      status: params[6] || 'PROPOSED',
      start_date: params[7] || null,
      expected_end_date: params[8] || null,
      created_by: params[9] ? parseInt(params[9], 10) : null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    memoryStore.projects.push(newProject);
    return { rows: [newProject], rowCount: 1 };
  }

  return { rows: [], rowCount: 0 };
}

/**
 * Initialize database connection and run schema/seeds
 */
async function initDb() {
  console.log('🔄 Initializing BhoomiSetu Database...');
  
  if (pool) {
    try {
      const client = await pool.connect();
      console.log('✅ Connected to PostgreSQL Server successfully!');
      isPgConnected = true;

      // Run initial migrations
      const migrationFile = path.resolve(__dirname, '../../../database/migrations/001_initial_schema.sql');
      if (fs.existsSync(migrationFile)) {
        const migrationSql = fs.readFileSync(migrationFile, 'utf8');
        await client.query(migrationSql);
        console.log('✅ PostgreSQL migrations applied successfully.');
      }

      // Check if users exist, otherwise seed
      const userCountRes = await client.query('SELECT COUNT(*) FROM users');
      if (parseInt(userCountRes.rows[0].count, 10) === 0) {
        const seedFile = path.resolve(__dirname, '../../../database/seeds/001_demo_data.sql');
        if (fs.existsSync(seedFile)) {
          const seedSql = fs.readFileSync(seedFile, 'utf8');
          await client.query(seedSql);
          console.log('✅ PostgreSQL demo seeds applied successfully.');
        }
      }

      client.release();
      return true;
    } catch (err) {
      console.warn('⚠️  PostgreSQL connection failed:', err.message);
      console.log('ℹ️  Activating high-performance built-in memory storage for seamless execution.');
      isPgConnected = false;
    }
  }

  // Load seeds into in-memory store
  await seedMemoryStore();
  return true;
}

async function seedMemoryStore() {
  const bcrypt = require('bcryptjs');
  const demoPasswordHash = await bcrypt.hash('Demo@12345', 10);

  memoryStore.states = [
    { id: 1, name: 'Maharashtra', code: 'MH', created_at: new Date().toISOString() },
    { id: 2, name: 'Gujarat', code: 'GJ', created_at: new Date().toISOString() },
    { id: 3, name: 'Karnataka', code: 'KA', created_at: new Date().toISOString() },
    { id: 4, name: 'Rajasthan', code: 'RJ', created_at: new Date().toISOString() },
    { id: 5, name: 'Uttar Pradesh', code: 'UP', created_at: new Date().toISOString() },
    { id: 6, name: 'Tamil Nadu', code: 'TN', created_at: new Date().toISOString() }
  ];

  memoryStore.districts = [
    { id: 1, state_id: 1, name: 'Pune', code: 'PUN', created_at: new Date().toISOString() },
    { id: 2, state_id: 1, name: 'Nagpur', code: 'NGP', created_at: new Date().toISOString() },
    { id: 3, state_id: 1, name: 'Thane', code: 'THN', created_at: new Date().toISOString() },
    { id: 4, state_id: 1, name: 'Nashik', code: 'NSK', created_at: new Date().toISOString() },
    { id: 5, state_id: 2, name: 'Ahmedabad', code: 'AMD', created_at: new Date().toISOString() },
    { id: 6, state_id: 2, name: 'Surat', code: 'SRT', created_at: new Date().toISOString() },
    { id: 7, state_id: 2, name: 'Vadodara', code: 'BRD', created_at: new Date().toISOString() },
    { id: 8, state_id: 3, name: 'Bengaluru Urban', code: 'BLR', created_at: new Date().toISOString() },
    { id: 9, state_id: 3, name: 'Mysuru', code: 'MYS', created_at: new Date().toISOString() },
    { id: 10, state_id: 3, name: 'Belagavi', code: 'BLG', created_at: new Date().toISOString() },
    { id: 11, state_id: 4, name: 'Jaipur', code: 'JPR', created_at: new Date().toISOString() },
    { id: 12, state_id: 4, name: 'Jodhpur', code: 'JDH', created_at: new Date().toISOString() },
    { id: 13, state_id: 4, name: 'Kota', code: 'KTA', created_at: new Date().toISOString() },
    { id: 14, state_id: 5, name: 'Lucknow', code: 'LKO', created_at: new Date().toISOString() },
    { id: 15, state_id: 5, name: 'Varanasi', code: 'VNS', created_at: new Date().toISOString() },
    { id: 16, state_id: 5, name: 'Kanpur Nagar', code: 'KNP', created_at: new Date().toISOString() },
    { id: 17, state_id: 6, name: 'Chennai', code: 'CHN', created_at: new Date().toISOString() },
    { id: 18, state_id: 6, name: 'Coimbatore', code: 'CBE', created_at: new Date().toISOString() },
    { id: 19, state_id: 6, name: 'Madurai', code: 'MDU', created_at: new Date().toISOString() }
  ];

  memoryStore.agencies = [
    { id: 1, name: 'National Highways Authority of India (NHAI)', type: 'CENTRAL_PSU', state_id: null, created_at: new Date().toISOString() },
    { id: 2, name: 'Dedicated Freight Corridor Corporation of India (DFCCIL)', type: 'CENTRAL_PSU', state_id: null, created_at: new Date().toISOString() },
    { id: 3, name: 'Maharashtra State Road Development Corporation (MSRDC)', type: 'STATE_PSU', state_id: 1, created_at: new Date().toISOString() },
    { id: 4, name: 'Gujarat Industrial Development Corporation (GIDC)', type: 'STATE_PSU', state_id: 2, created_at: new Date().toISOString() },
    { id: 5, name: 'Bangalore Metro Rail Corporation Limited (BMRCL)', type: 'STATE_JOINT_PSU', state_id: 3, created_at: new Date().toISOString() },
    { id: 6, name: 'Uttar Pradesh Expressways Industrial Development Authority (UPEIDA)', type: 'STATE_PSU', state_id: 5, created_at: new Date().toISOString() }
  ];

  memoryStore.users = [
    {
      id: 1,
      name: 'Dr. Rajesh Verma (Joint Secretary)',
      email: 'central.demo@example.com',
      password_hash: demoPasswordHash,
      role: 'CENTRAL_MINISTRY',
      state_id: null,
      district_id: null,
      agency_id: null,
      is_active: true,
      created_at: new Date().toISOString()
    },
    {
      id: 2,
      name: 'Shri Anand Kulkarni (Principal Secretary, Revenue)',
      email: 'state.demo@example.com',
      password_hash: demoPasswordHash,
      role: 'STATE_GOVERNMENT',
      state_id: 1,
      district_id: null,
      agency_id: null,
      is_active: true,
      created_at: new Date().toISOString()
    },
    {
      id: 3,
      name: 'Smt. Sujata Deshmukh (District Collector & LAO)',
      email: 'district.demo@example.com',
      password_hash: demoPasswordHash,
      role: 'DISTRICT_AUTHORITY',
      state_id: 1,
      district_id: 1,
      agency_id: null,
      is_active: true,
      created_at: new Date().toISOString()
    },
    {
      id: 4,
      name: 'Er. Vikram Malhotra (Chief Project Manager, NHAI)',
      email: 'agency.demo@example.com',
      password_hash: demoPasswordHash,
      role: 'PROJECT_AGENCY',
      state_id: null,
      district_id: null,
      agency_id: 1,
      is_active: true,
      created_at: new Date().toISOString()
    },
    {
      id: 5,
      name: 'Suresh Patil (Sub-Divisional Field Officer)',
      email: 'field.demo@example.com',
      password_hash: demoPasswordHash,
      role: 'FIELD_OFFICER',
      state_id: 1,
      district_id: 1,
      agency_id: 1,
      is_active: true,
      created_at: new Date().toISOString()
    }
  ];

  memoryStore.projects = [
    {
      id: 1,
      project_name: 'Pune Ring Road Express Corridor (Phase-I)',
      description: 'Acquisition of bypass land corridor spanning Haveli and Mulshi talukas to ease national transit congestion.',
      agency_id: 1,
      state_id: 1,
      district_id: 1,
      proposed_area: 485.50,
      status: 'COMPENSATION_IN_PROGRESS',
      start_date: '2025-01-15',
      expected_end_date: '2026-12-31',
      created_by: 4,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 2,
      project_name: 'Pune-Nashik Semi High-Speed Rail Corridor',
      description: 'Linear greenfield land acquisition across 12 villages for multi-modal logistics corridor.',
      agency_id: 3,
      state_id: 1,
      district_id: 1,
      proposed_area: 310.20,
      status: 'NOTIFICATION_IN_PROGRESS',
      start_date: '2025-03-01',
      expected_end_date: '2027-06-30',
      created_by: 4,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 3,
      project_name: 'Nagpur Metro Rail Phase-II Extension',
      description: 'Urban and peri-urban land parcels required for terminal yard expansion and viaduct pillars.',
      agency_id: 1,
      state_id: 1,
      district_id: 2,
      proposed_area: 142.80,
      status: 'SURVEY_IN_PROGRESS',
      start_date: '2025-02-10',
      expected_end_date: '2026-10-15',
      created_by: 4,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 4,
      project_name: 'Thane-Borivali Twin Tunnel Approach Expressway',
      description: 'Forest and revenue land acquisition for western bypass approach interchange.',
      agency_id: 3,
      state_id: 1,
      district_id: 3,
      proposed_area: 95.40,
      status: 'DELAYED',
      start_date: '2024-08-01',
      expected_end_date: '2026-03-31',
      created_by: 4,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 5,
      project_name: 'Ahmedabad-Dholera Special Investment Region Expressway',
      description: 'Greenfield expressway connectivity to Dholera Industrial Hub.',
      agency_id: 1,
      state_id: 2,
      district_id: 5,
      proposed_area: 620.00,
      status: 'POSSESSION_IN_PROGRESS',
      start_date: '2024-11-01',
      expected_end_date: '2026-08-30',
      created_by: 4,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 6,
      project_name: 'Western Dedicated Freight Corridor (Surat Section)',
      description: 'Double line electrified freight corridor right-of-way land parcels.',
      agency_id: 2,
      state_id: 2,
      district_id: 6,
      proposed_area: 280.75,
      status: 'POSSESSION_HANDED_OVER',
      start_date: '2024-05-15',
      expected_end_date: '2025-11-30',
      created_by: 4,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 7,
      project_name: 'Bengaluru Peripheral Ring Road (Northern Segment)',
      description: 'Access-controlled 8-lane expressway corridor surrounding Bengaluru urban perimeter.',
      agency_id: 5,
      state_id: 3,
      district_id: 8,
      proposed_area: 540.30,
      status: 'AWARD_IN_PROGRESS',
      start_date: '2025-01-10',
      expected_end_date: '2027-04-30',
      created_by: 4,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 8,
      project_name: 'Mysuru Industrial Growth Center Expansion',
      description: 'Contiguous agricultural land conversion for green electronics manufacturing cluster.',
      agency_id: 1,
      state_id: 3,
      district_id: 9,
      proposed_area: 215.60,
      status: 'SURVEY_IN_PROGRESS',
      start_date: '2025-04-01',
      expected_end_date: '2026-12-15',
      created_by: 4,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 9,
      project_name: 'Ganga Expressway Phase-II (Lucknow Spur)',
      description: 'Six-lane expandable greenfield expressway link connecting central UP districts.',
      agency_id: 6,
      state_id: 5,
      district_id: 14,
      proposed_area: 780.00,
      status: 'COMPENSATION_IN_PROGRESS',
      start_date: '2024-09-01',
      expected_end_date: '2026-12-31',
      created_by: 4,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 10,
      project_name: 'Varanasi Multi-Modal Freight Logistics Hub',
      description: 'Riverfront port and rail freight terminal land integration.',
      agency_id: 2,
      state_id: 5,
      district_id: 15,
      proposed_area: 165.90,
      status: 'PROPOSED',
      start_date: '2025-06-01',
      expected_end_date: '2027-08-31',
      created_by: 4,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 11,
      project_name: 'Jaipur-Kishangarh Economic Feeder Corridor',
      description: 'Highway widening and service lane right-of-way acquisition.',
      agency_id: 1,
      state_id: 4,
      district_id: 11,
      proposed_area: 190.40,
      status: 'AWARD_IN_PROGRESS',
      start_date: '2025-02-20',
      expected_end_date: '2026-11-30',
      created_by: 4,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 12,
      project_name: 'Chennai Outer Orbital Expressway (Poonamallee-Minjur)',
      description: 'Strategic orbital freight bypass connecting industrial ports.',
      agency_id: 1,
      state_id: 6,
      district_id: 17,
      proposed_area: 345.80,
      status: 'NOTIFICATION_IN_PROGRESS',
      start_date: '2025-01-05',
      expected_end_date: '2027-02-28',
      created_by: 4,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }
  ];

  console.log('✅ Local seed database initialized with 6 States, 19 Districts, 6 Agencies, 5 Demo Users, 12 Projects.');
}

module.exports = {
  query,
  pool,
  initDb,
  getIsPgConnected: () => isPgConnected
};
