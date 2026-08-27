const { errorResponse } = require('../utils/response');

function errorHandler(err, req, res, next) {
  console.error('Unhandled Application Error:', err);

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error. Please try again later.';

  return errorResponse(res, message, statusCode);
}

function notFoundHandler(req, res) {
  return errorResponse(res, `API route '${req.originalUrl}' not found.`, 404);
}

module.exports = {
  errorHandler,
  notFoundHandler
};
