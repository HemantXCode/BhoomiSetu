const dashboardService = require('../services/dashboardService');
const { successResponse } = require('../utils/response');

async function getStats(req, res, next) {
  try {
    const stats = await dashboardService.getDashboardStats(req.user);
    return successResponse(res, stats, 'Dashboard statistics retrieved successfully.');
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getStats
};
