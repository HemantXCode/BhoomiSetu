const projectService = require('../services/projectService');
const { successResponse } = require('../utils/response');

async function listProjects(req, res, next) {
  try {
    const { status, state_id, search } = req.query;
    const projects = await projectService.getScopedProjects(req.user, { status, state_id, search });
    return successResponse(res, projects, 'Projects retrieved successfully.');
  } catch (err) {
    next(err);
  }
}

async function getProject(req, res, next) {
  try {
    const projectId = parseInt(req.params.id, 10);
    const project = await projectService.getProjectById(projectId, req.user);
    return successResponse(res, project, 'Project details retrieved successfully.');
  } catch (err) {
    next(err);
  }
}

async function createProject(req, res, next) {
  try {
    const project = await projectService.createProject(req.user, req.body);
    return successResponse(res, project, 'Project proposal created successfully.', 201);
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listProjects,
  getProject,
  createProject
};
