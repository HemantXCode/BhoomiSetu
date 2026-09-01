import api from './api';

export const documentService = {
  async getDocuments(relatedEntity = null, relatedEntityId = null) {
    const params = {};
    if (relatedEntity) params.related_entity = relatedEntity;
    if (relatedEntityId) params.related_entity_id = relatedEntityId;
    const response = await api.get('/documents', { params });
    return response.data;
  },

  async getDocumentById(documentId) {
    const response = await api.get(`/documents/${documentId}`);
    return response.data;
  },

  async uploadDocument(formData) {
    const response = await api.post('/documents/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  getDocumentDownloadUrl(documentId) {
    return `/api/v1/documents/${documentId}/download`;
  },
};
