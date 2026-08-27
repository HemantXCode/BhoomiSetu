const projectModel = require('../models/projectModel');

async function getScopedProjects(user, filters = {}) {
  return projectModel.findScoped(user, filters);
}

async function getProjectById(projectId, user) {
  const project = await projectModel.findById(projectId);
  if (!project) {
    const err = new Error(`Project #${projectId} not found.`);
    err.statusCode = 404;
    throw err;
  }

  // Enforce Data Scope Restrictions
  if (user.role === 'STATE_GOVERNMENT' && project.state_id !== user.state_id) {
    const err = new Error('Access denied. You are only authorized to view projects within your assigned state.');
    err.statusCode = 403;
    throw err;
  }

  if (user.role === 'DISTRICT_AUTHORITY' && project.district_id !== user.district_id) {
    const err = new Error('Access denied. You are only authorized to view projects within your assigned district.');
    err.statusCode = 403;
    throw err;
  }

  if (user.role === 'PROJECT_AGENCY' && project.agency_id !== user.agency_id) {
    const err = new Error('Access denied. You are only authorized to view projects belonging to your agency.');
    err.statusCode = 403;
    throw err;
  }

  if (user.role === 'FIELD_OFFICER' && project.district_id !== user.district_id) {
    const err = new Error('Access denied. You are not assigned to this project or district.');
    err.statusCode = 403;
    throw err;
  }

  return project;
}

async function createProject(user, projectData) {
  if (!projectData.project_name || !projectData.proposed_area || !projectData.state_id || !projectData.district_id) {
    const err = new Error('Missing required fields: project_name, proposed_area, state_id, district_id are required.');
    err.statusCode = 400;
    throw err;
  }

  // Force agency_id to user's assigned agency if user is PROJECT_AGENCY
  let agencyId = projectData.agency_id;
  if (user.role === 'PROJECT_AGENCY') {
    agencyId = user.agency_id;
  }

  if (!agencyId) {
    const err = new Error('Agency ID is required for creating a project proposal.');
    err.statusCode = 400;
    throw err;
  }

  const payload = {
    ...projectData,
    agency_id: agencyId,
    created_by: user.id,
    status: projectData.status || 'PROPOSED'
  };

  return projectModel.create(payload);
}

module.exports = {
  getScopedProjects,
  getProjectById,
  createProject
};
