import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { ShieldAlert, ArrowLeft, Home } from 'lucide-react';
import GovHeader from '../../components/common/GovHeader';
import GovFooter from '../../components/common/GovFooter';

export default function AccessDenied({ requiredRoles = [], currentRole = '' }) {
  const navigate = useNavigate();
  const { getDashboardRouteForRole } = useAuth();

  return (
    <div className="min-h-screen flex flex-col bg-[#F8FAFC]">
      <GovHeader />

      <main className="flex-1 max-w-3xl w-full mx-auto px-4 py-12 flex items-center justify-center">
        <div className="gov-card border-l-4 border-l-rose-600 p-6 sm:p-8 w-full text-center">
          <div className="w-16 h-16 bg-rose-50 text-rose-600 rounded-full flex items-center justify-center mx-auto mb-4 border border-rose-200">
            <ShieldAlert className="w-8 h-8" />
          </div>

          <span className="bg-rose-100 text-rose-800 text-xs font-bold px-2.5 py-0.5 rounded tracking-wide uppercase">
            HTTP 403 • FORBIDDEN
          </span>

          <h2 className="text-xl sm:text-2xl font-bold text-slate-900 mt-3 mb-2">
            Unauthorized Access / Role Restriction
          </h2>

          <p className="text-sm text-slate-600 max-w-lg mx-auto mb-6 leading-relaxed">
            You do not have the required administrative clearance to access this module. 
            BhoomiSetu strictly enforces national role-based access control (RBAC) and data scope isolation.
          </p>

          <div className="bg-slate-50 border border-slate-200 rounded p-4 text-xs text-left max-w-md mx-auto mb-6 space-y-1.5">
            <div><span className="font-semibold text-slate-700">Your Current Role:</span> <span className="text-rose-700 font-mono font-bold">{currentRole || 'Unknown'}</span></div>
            {requiredRoles.length > 0 && (
              <div><span className="font-semibold text-slate-700">Authorized Role(s):</span> <span className="text-slate-800 font-mono">{requiredRoles.join(', ')}</span></div>
            )}
            <div className="text-[11px] text-slate-500 pt-1 border-t border-slate-200">
              Event Logged • IP & Session Timestamp Recorded for Audit Trail
            </div>
          </div>

          <div className="flex flex-wrap justify-center gap-3">
            <button
              onClick={() => navigate(-1)}
              className="gov-btn-secondary text-xs"
            >
              <ArrowLeft className="w-4 h-4" />
              <span>Go Back</span>
            </button>

            <button
              onClick={() => navigate(getDashboardRouteForRole(currentRole))}
              className="gov-btn-primary text-xs"
            >
              <Home className="w-4 h-4" />
              <span>Return to My Dashboard</span>
            </button>
          </div>
        </div>
      </main>

      <GovFooter />
    </div>
  );
}
