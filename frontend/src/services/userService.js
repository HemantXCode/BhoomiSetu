import api from './api';

export const userService = {
  getUsers: async (params = {}) => {
    try {
      const res = await api.get('/users', { params });
      return res.data;
    } catch (err) {
      console.error('Error fetching users:', err);
      throw err;
    }
  },

  getUserById: async (userId) => {
    try {
      const res = await api.get(`/users/${userId}`);
      return res.data;
    } catch (err) {
      console.error(`Error fetching user #${userId}:`, err);
      throw err;
    }
  },

  registerUser: async (payload) => {
    try {
      const res = await api.post('/users', payload);
      return res.data;
    } catch (err) {
      console.error('Error registering user:', err);
      throw err;
    }
  },

  verifyUser: async (userId, { decision, notes }) => {
    try {
      const res = await api.post(`/users/${userId}/verify`, { decision, notes });
      return res.data;
    } catch (err) {
      console.error(`Error verifying user #${userId}:`, err);
      throw err;
    }
  }
};
