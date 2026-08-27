const db = require('../config/db');

async function findScoped(scope, filters = {}) {
  let sql = `
    SELECT 
      p.id, p.project_name, p.description, p.agency_id, p.state_id, p.district_id,
      p.proposed_area, p.status, p.start_date, p.expected_end_date, p.created_by,
      p.created_at, p.updated_at,
      s.name as state_name, s.code as state_code,
      d.name as district_name, d.code as district_code,
      a.name as agency_name, a.type as agency_type,
      u.name as creator_name
    FROM projects p
    LEFT JOIN states s ON p.state_id = s.id
    LEFT JOIN districts d ON p.district_id = d.id
    LEFT JOIN agencies a ON p.agency_id = a.id
    LEFT JOIN users u ON p.created_by = u.id
    WHERE 1=1
  `;
  const params = [];
  let paramIndex = 1;

  // Apply Role Data Scopes
  if (scope.role === 'STATE_GOVERNMENT' && scope.state_id) {
    sql += ` AND p.state_id = $${paramIndex++}`;
    params.push(scope.state_id);
  } else if (scope.role === 'DISTRICT_AUTHORITY' && scope.district_id) {
    sql += ` AND p.district_id = $${paramIndex++}`;
    params.push(scope.district_id);
  } else if (scope.role === 'PROJECT_AGENCY' && scope.agency_id) {
    sql += ` AND p.agency_id = $${paramIndex++}`;
    params.push(scope.agency_id);
  } else if (scope.role === 'FIELD_OFFICER') {
    if (scope.district_id) {
      sql += ` AND p.district_id = $${paramIndex++}`;
      params.push(scope.district_id);
    }
  }

  // Additional dynamic filters
  if (filters.status) {
    sql += ` AND p.status = $${paramIndex++}`;
    params.push(filters.status);
  }

  if (filters.state_id && scope.role === 'CENTRAL_MINISTRY') {
    sql += ` AND p.state_id = $${paramIndex++}`;
    params.push(filters.state_id);
  }

  if (filters.search) {
    sql += ` AND (p.project_name ILIKE $${paramIndex} OR p.description ILIKE $${paramIndex})`;
    params.push(`%${filters.search}%`);
    paramIndex++;
  }

  sql += ` ORDER BY p.id ASC`;

  const result = await db.query(sql, params);
  return result.rows;
}

async function findById(id) {
  const sql = `
    SELECT 
      p.id, p.project_name, p.description, p.agency_id, p.state_id, p.district_id,
      p.proposed_area, p.status, p.start_date, p.expected_end_date, p.created_by,
      p.created_at, p.updated_at,
      s.name as state_name, s.code as state_code,
      d.name as district_name, d.code as district_code,
      a.name as agency_name, a.type as agency_type,
      u.name as creator_name
    FROM projects p
    LEFT JOIN states s ON p.state_id = s.id
    LEFT JOIN districts d ON p.district_id = d.id
    LEFT JOIN agencies a ON p.agency_id = a.id
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.id = $1
  `;
  const result = await db.query(sql, [id]);
  return result.rows[0] || null;
}

async function create(data) {
  const sql = `
    INSERT INTO projects (
      project_name, description, agency_id, state_id, district_id,
      proposed_area, status, start_date, expected_end_date, created_by
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    RETURNING *
  `;
  const params = [
    data.project_name,
    data.description || null,
    data.agency_id,
    data.state_id,
    data.district_id,
    data.proposed_area,
    data.status || 'PROPOSED',
    data.start_date || null,
    data.expected_end_date || null,
    data.created_by || null
  ];

  const result = await db.query(sql, params);
  return result.rows[0];
}

module.exports = {
  findScoped,
  findById,
  create
};
