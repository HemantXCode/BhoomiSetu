const authService = require('../services/authService');
const { successResponse, errorResponse } = require('../utils/response');

async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    const authData = await authService.loginUser(email, password);
    return successResponse(res, authData, 'Authentication successful.', 200);
  } catch (err) {
    next(err);
  }
}

async function getMe(req, res, next) {
  try {
    const user = await authService.getAuthenticatedUserProfile(req.user.id);
    return successResponse(res, user, 'User profile retrieved.', 200);
  } catch (err) {
    next(err);
  }
}

module.exports = {
  login,
  getMe
};
