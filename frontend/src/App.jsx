import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import ProtectedRoute from './components/layout/ProtectedRoute';

// Pages
import LoginPage from './pages/auth/LoginPage';
import AccessDenied from './pages/auth/AccessDenied';
import CentralDashboard from './pages/central/CentralDashboard';
import StateDashboard from './pages/state/StateDashboard';
import DistrictDashboard from './pages/district/DistrictDashboard';
import AgencyDashboard from './pages/agency/AgencyDashboard';
import FieldDashboard from './pages/field/FieldDashboard';
import ProjectsList from './pages/projects/ProjectsList';

function RootRedirect() {
  const { isAuthenticated, user, getDashboardRouteForRole, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-50">
        <div className="w-8 h-8 border-3 border-orange-500 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  if (isAuthenticated && user) {
    return <Navigate to={getDashboardRouteForRole(user.role)} replace />;
  }

  return <Navigate to="/login" replace />;
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Public Routes */}
          <Route path="/login" element={<LoginPage />} />
          <Route path="/access-denied" element={<AccessDenied />} />

          {/* Root Redirect based on Role */}
          <Route path="/" element={<RootRedirect />} />

          {/* 1. Central Ministry Dashboard */}
          <Route
            path="/central/dashboard"
            element={
              <ProtectedRoute allowedRoles={['CENTRAL_MINISTRY']}>
                <CentralDashboard />
              </ProtectedRoute>
            }
          />

          {/* 2. State Government Dashboard */}
          <Route
            path="/state/dashboard"
            element={
              <ProtectedRoute allowedRoles={['STATE_GOVERNMENT']}>
                <StateDashboard />
              </ProtectedRoute>
            }
          />

          {/* 3. District Authority Dashboard */}
          <Route
            path="/district/dashboard"
            element={
              <ProtectedRoute allowedRoles={['DISTRICT_AUTHORITY']}>
                <DistrictDashboard />
              </ProtectedRoute>
            }
          />

          {/* 4. Project Agency Dashboard */}
          <Route
            path="/agency/dashboard"
            element={
              <ProtectedRoute allowedRoles={['PROJECT_AGENCY']}>
                <AgencyDashboard />
              </ProtectedRoute>
            }
          />

          {/* 5. Field Officer Dashboard */}
          <Route
            path="/field/dashboard"
            element={
              <ProtectedRoute allowedRoles={['FIELD_OFFICER']}>
                <FieldDashboard />
              </ProtectedRoute>
            }
          />

          {/* Common Projects Directory (Scope Enforced) */}
          <Route
            path="/projects"
            element={
              <ProtectedRoute>
                <ProjectsList />
              </ProtectedRoute>
            }
          />

          {/* Catch-all */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
