const { errorResponse } = require('../utils/response');

/**
 * Role-Based Access Control Middleware
 * @param  {...string} allowedRoles Allowed role identifiers
 */
function authorizeRoles(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return errorResponse(res, 'Authentication required before authorization check.', 401);
    }

    if (!allowedRoles.includes(req.user.role)) {
      return errorResponse(
        res,
        `Access denied. Role '${req.user.role}' is not authorized to access this resource.`,
        403
      );
    }

    next();
  };
}

/**
 * Data Scope Enforcer for SQL queries
 * Attaches structured scope parameters to req.dataScope
 */
function applyDataScope(req, res, next) {
  if (!req.user) {
    return errorResponse(res, 'Authentication required.', 401);
  }

  const { role, state_id, district_id, agency_id } = req.user;

  const scope = {
    role,
    isNational: role === 'CENTRAL_MINISTRY',
    stateId: role === 'STATE_GOVERNMENT' ? state_id : null,
    districtId: role === 'DISTRICT_AUTHORITY' ? district_id : null,
    agencyId: role === 'PROJECT_AGENCY' ? agency_id : null,
    fieldOfficerScope: role === 'FIELD_OFFICER' ? { state_id, district_id, agency_id } : null
  };

  req.dataScope = scope;
  next();
}

module.exports = {
  authorizeRoles,
  applyDataScope
};
