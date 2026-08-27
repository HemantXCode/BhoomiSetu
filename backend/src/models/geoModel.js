const db = require('../config/db');

async function getStates() {
  const sql = 'SELECT id, name, code FROM states ORDER BY name ASC';
  const result = await db.query(sql);
  return result.rows;
}

async function getDistricts(stateId = null) {
  let sql = 'SELECT id, state_id, name, code FROM districts';
  const params = [];
  if (stateId) {
    sql += ' WHERE state_id = $1';
    params.push(stateId);
  }
  sql += ' ORDER BY name ASC';
  const result = await db.query(sql, params);
  return result.rows;
}

async function getAgencies(stateId = null) {
  let sql = 'SELECT id, name, type, state_id FROM agencies';
  const params = [];
  if (stateId) {
    sql += ' WHERE state_id = $1 OR state_id IS NULL';
    params.push(stateId);
  }
  sql += ' ORDER BY name ASC';
  const result = await db.query(sql, params);
  return result.rows;
}

module.exports = {
  getStates,
  getDistricts,
  getAgencies
};
