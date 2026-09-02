import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { LanguageProvider } from './context/LanguageContext';
import ProtectedRoute from './components/layout/ProtectedRoute';

// Pages
import LoginPage from './pages/auth/LoginPage';
import AccessDenied from './pages/auth/AccessDenied';
import ExecutiveDashboardPage from './pages/dashboard/ExecutiveDashboardPage';
import CentralDashboard from './pages/central/CentralDashboard';
import StateDashboard from './pages/state/StateDashboard';
import DistrictDashboard from './pages/district/DistrictDashboard';
import AgencyDashboard from './pages/agency/AgencyDashboard';
import FieldOfficerDashboard from './pages/field/FieldOfficerDashboard';
import MobileInspectionPage from './pages/mobile/MobileInspectionPage';
import ProjectsList from './pages/projects/ProjectsList';
import GISCommandCenterPage from './pages/gis/GISCommandCenterPage';

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
    <LanguageProvider>
      <AuthProvider>
        <BrowserRouter>
          <Routes>
            {/* Public Routes */}
            <Route path="/login" element={<LoginPage />} />
            <Route path="/access-denied" element={<AccessDenied />} />

            {/* Root Redirect based on Role */}
            <Route path="/" element={<RootRedirect />} />

            {/* Unified Executive Dashboard (Role-Adaptive) */}
            <Route
              path="/dashboard"
              element={
                <ProtectedRoute>
                  <ExecutiveDashboardPage />
                </ProtectedRoute>
              }
            />

            {/* Dedicated Ground Inspection & Mobile Evidence Hub */}
            <Route
              path="/mobile-inspection"
              element={
                <ProtectedRoute>
                  <MobileInspectionPage />
                </ProtectedRoute>
              }
            />

            {/* Legacy / Direct Role Dashboard Routes */}
            <Route
              path="/central/dashboard"
              element={
                <ProtectedRoute allowedRoles={['CENTRAL_MINISTRY']}>
                  <CentralDashboard />
                </ProtectedRoute>
              }
            />
            <Route
              path="/state/dashboard"
              element={
                <ProtectedRoute allowedRoles={['STATE_GOVERNMENT']}>
                  <StateDashboard />
                </ProtectedRoute>
              }
            />
            <Route
              path="/district/dashboard"
              element={
                <ProtectedRoute allowedRoles={['DISTRICT_AUTHORITY']}>
                  <DistrictDashboard />
                </ProtectedRoute>
              }
            />
            <Route
              path="/agency/dashboard"
              element={
                <ProtectedRoute allowedRoles={['PROJECT_AGENCY']}>
                  <AgencyDashboard />
                </ProtectedRoute>
              }
            />
            <Route
              path="/field/dashboard"
              element={
                <ProtectedRoute allowedRoles={['FIELD_OFFICER']}>
                  <FieldOfficerDashboard />
                </ProtectedRoute>
              }
            />
            <Route
              path="/field/mobile-inspection"
              element={<Navigate to="/mobile-inspection" replace />}
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

            {/* Advanced GIS Command Center */}
            <Route
              path="/gis"
              element={
                <ProtectedRoute>
                  <GISCommandCenterPage />
                </ProtectedRoute>
              }
            />
            <Route
              path="/gis-command-center"
              element={<Navigate to="/gis" replace />}
            />

            {/* Catch-all */}
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </LanguageProvider>
  );
}
