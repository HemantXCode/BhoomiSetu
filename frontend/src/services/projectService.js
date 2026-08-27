import api from './api';

export const projectService = {
  async getProjects(params = {}) {
    const response = await api.get('/projects', { params });
    return response.data;
  },

  async getProjectById(id) {
    const response = await api.get(`/projects/${id}`);
    return response.data;
  },

  async createProject(projectData) {
    const response = await api.post('/projects', projectData);
    return response.data;
  },

  async getStates() {
    const response = await api.get('/geo/states');
    return response.data;
  },

  async getDistricts(stateId = null) {
    const response = await api.get('/geo/districts', { params: { state_id: stateId } });
    return response.data;
  },

  async getAgencies(stateId = null) {
    const response = await api.get('/geo/agencies', { params: { state_id: stateId } });
    return response.data;
  }
};
