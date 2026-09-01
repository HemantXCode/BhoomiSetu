import api from './api';

export const fieldService = {
  async getTasks(status = null) {
    const params = status ? { status } : {};
    const response = await api.get('/field/tasks', { params });
    return response.data;
  },

  async getTaskById(taskId) {
    const response = await api.get(`/field/tasks/${taskId}`);
    return response.data;
  },

  async getVisits(taskId = null) {
    const params = taskId ? { task_id: taskId } : {};
    const response = await api.get('/field/visits', { params });
    return response.data;
  },

  async getVisitById(visitId) {
    const response = await api.get(`/field/visits/${visitId}`);
    return response.data;
  },

  async startVisit(visitData) {
    const response = await api.post('/field/visits', visitData);
    return response.data;
  },

  async submitVerification(verificationData) {
    const response = await api.post('/field/verifications', verificationData);
    return response.data;
  },

  async getVerifications(taskId = null) {
    const params = taskId ? { task_id: taskId } : {};
    const response = await api.get('/field/verifications', { params });
    return response.data;
  },

  async getPhotos(relatedEntityId = null) {
    const params = relatedEntityId ? { related_entity_id: relatedEntityId } : {};
    const response = await api.get('/field/photos', { params });
    return response.data;
  },

  async uploadPhoto(formData) {
    const response = await api.post('/field/photos', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },
};
