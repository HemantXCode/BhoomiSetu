const jwt = require('jsonwebtoken');
const config = require('../config/env');

function generateToken(user) {
  const payload = {
    id: user.id,
    email: user.email,
    role: user.role,
    state_id: user.state_id,
    district_id: user.district_id,
    agency_id: user.agency_id
  };

  return jwt.sign(payload, config.JWT_SECRET, {
    expiresIn: config.JWT_EXPIRES_IN
  });
}

function verifyToken(token) {
  return jwt.verify(token, config.JWT_SECRET);
}

module.exports = {
  generateToken,
  verifyToken
};
