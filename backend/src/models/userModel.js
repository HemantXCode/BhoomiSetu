const db = require('../config/db');

async function findByEmail(email) {
  const sql = `
    SELECT 
      u.id, u.name, u.email, u.password_hash, u.role, 
      u.state_id, u.district_id, u.agency_id, u.is_active, u.created_at,
      s.name as state_name, s.code as state_code,
      d.name as district_name, d.code as district_code,
      a.name as agency_name, a.type as agency_type
    FROM users u
    LEFT JOIN states s ON u.state_id = s.id
    LEFT JOIN districts d ON u.district_id = d.id
    LEFT JOIN agencies a ON u.agency_id = a.id
    WHERE u.email = $1
  `;
  const result = await db.query(sql, [email]);
  return result.rows[0] || null;
}

async function findById(id) {
  const sql = `
    SELECT 
      u.id, u.name, u.email, u.role, 
      u.state_id, u.district_id, u.agency_id, u.is_active, u.created_at,
      s.name as state_name, s.code as state_code,
      d.name as district_name, d.code as district_code,
      a.name as agency_name, a.type as agency_type
    FROM users u
    LEFT JOIN states s ON u.state_id = s.id
    LEFT JOIN districts d ON u.district_id = d.id
    LEFT JOIN agencies a ON u.agency_id = a.id
    WHERE u.id = $1
  `;
  const result = await db.query(sql, [id]);
  return result.rows[0] || null;
}

module.exports = {
  findByEmail,
  findById
};
