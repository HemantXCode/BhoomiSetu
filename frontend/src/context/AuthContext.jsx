import React, { createContext, useContext, useState, useEffect } from 'react';
import { authService } from '../services/authService';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(() => {
    const savedUser = localStorage.getItem('bhoomisetu_user');
    return savedUser ? JSON.parse(savedUser) : null;
  });
  const [token, setToken] = useState(() => localStorage.getItem('bhoomisetu_token'));
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function verifySession() {
      const savedToken = localStorage.getItem('bhoomisetu_token');
      if (savedToken && savedToken !== 'undefined' && savedToken !== 'null') {
        try {
          const res = await authService.getMe();
          if (res.success && res.data) {
            setUser(res.data);
            localStorage.setItem('bhoomisetu_user', JSON.stringify(res.data));
          }
        } catch (err) {
          console.warn('Session verification failed:', err.message);
          logout();
        }
      } else {
        // Purge corrupted token strings if present
        localStorage.removeItem('bhoomisetu_token');
        localStorage.removeItem('bhoomisetu_user');
      }
      setLoading(false);
    }

    verifySession();
  }, []);

  const login = async (email, password) => {
    const response = await authService.login(email, password);
    if (response.success && response.data) {
      const jwtToken = response.data.access_token || response.data.token;
      const userData = response.data.user;
      setToken(jwtToken);
      setUser(userData);
      localStorage.setItem('bhoomisetu_token', jwtToken);
      localStorage.setItem('bhoomisetu_user', JSON.stringify(userData));
      return userData;
    }
    throw new Error(response.message || 'Login failed');
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('bhoomisetu_token');
    localStorage.removeItem('bhoomisetu_user');
    window.location.href = '/login';
  };

  const getDashboardRouteForRole = (role) => {
    if (!role) return '/login';
    return '/dashboard';
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        loading,
        login,
        logout,
        isAuthenticated: !!token && !!user,
        getDashboardRouteForRole
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
