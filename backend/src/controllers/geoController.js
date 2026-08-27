const geoModel = require('../models/geoModel');
const { successResponse } = require('../utils/response');

async function getStates(req, res, next) {
  try {
    const states = await geoModel.getStates();
    return successResponse(res, states, 'States retrieved successfully.');
  } catch (err) {
    next(err);
  }
}

async function getDistricts(req, res, next) {
  try {
    const stateId = req.query.state_id ? parseInt(req.query.state_id, 10) : null;
    const districts = await geoModel.getDistricts(stateId);
    return successResponse(res, districts, 'Districts retrieved successfully.');
  } catch (err) {
    next(err);
  }
}

async function getAgencies(req, res, next) {
  try {
    const stateId = req.query.state_id ? parseInt(req.query.state_id, 10) : null;
    const agencies = await geoModel.getAgencies(stateId);
    return successResponse(res, agencies, 'Agencies retrieved successfully.');
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getStates,
  getDistricts,
  getAgencies
};
