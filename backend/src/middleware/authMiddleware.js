const { verifyToken } = require('../utils/jwt');
const { errorResponse } = require('../utils/response');

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.startsWith('Bearer ') ? authHeader.split(' ')[1] : null;

  if (!token) {
    return errorResponse(res, 'Access denied. Authentication token missing.', 401);
  }

  try {
    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (err) {
    return errorResponse(res, 'Invalid or expired authentication token. Please log in again.', 401);
  }
}

module.exports = {
  authenticateToken
};
