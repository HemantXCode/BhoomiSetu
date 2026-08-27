const userModel = require('../models/userModel');
const { comparePassword } = require('../utils/hash');
const { generateToken } = require('../utils/jwt');

async function loginUser(email, password) {
  if (!email || !password) {
    const err = new Error('Please provide both email and password.');
    err.statusCode = 400;
    throw err;
  }

  const user = await userModel.findByEmail(email.trim().toLowerCase());

  if (!user) {
    const err = new Error('Invalid email or password.');
    err.statusCode = 401;
    throw err;
  }

  if (!user.is_active) {
    const err = new Error('Your account has been deactivated. Please contact your system administrator.');
    err.statusCode = 403;
    throw err;
  }

  const isMatch = await comparePassword(password, user.password_hash);
  if (!isMatch) {
    const err = new Error('Invalid email or password.');
    err.statusCode = 401;
    throw err;
  }

  const token = generateToken(user);

  // Return sanitized user
  const sanitizedUser = {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    state_id: user.state_id,
    state_name: user.state_name || null,
    state_code: user.state_code || null,
    district_id: user.district_id,
    district_name: user.district_name || null,
    district_code: user.district_code || null,
    agency_id: user.agency_id,
    agency_name: user.agency_name || null,
    agency_type: user.agency_type || null
  };

  return {
    token,
    user: sanitizedUser
  };
}

async function getAuthenticatedUserProfile(userId) {
  const user = await userModel.findById(userId);
  if (!user) {
    const err = new Error('User profile not found.');
    err.statusCode = 404;
    throw err;
  }

  return user;
}

module.exports = {
  loginUser,
  getAuthenticatedUserProfile
};
