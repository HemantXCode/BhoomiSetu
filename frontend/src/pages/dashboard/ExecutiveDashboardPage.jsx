import React from 'react';
import { useAuth } from '../../context/AuthContext';
import CentralDashboard from '../central/CentralDashboard';
import StateDashboard from '../state/StateDashboard';
import DistrictDashboard from '../district/DistrictDashboard';
import AgencyDashboard from '../agency/AgencyDashboard';
import FieldOfficerDashboard from '../field/FieldOfficerDashboard';

export default function ExecutiveDashboardPage() {
  const { user } = useAuth();

  if (!user) return null;

  switch (user.role) {
    case 'CENTRAL_MINISTRY':
      return <CentralDashboard />;
    case 'STATE_GOVERNMENT':
      return <StateDashboard />;
    case 'DISTRICT_AUTHORITY':
      return <DistrictDashboard />;
    case 'PROJECT_AGENCY':
      return <AgencyDashboard />;
    case 'FIELD_OFFICER':
      return <FieldOfficerDashboard />;
    default:
      return <CentralDashboard />;
  }
}
