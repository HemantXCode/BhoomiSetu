import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { dashboardService } from '../../services/dashboardService';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';
import DashboardLayout from '../../components/layout/DashboardLayout';
import Breadcrumbs from '../../components/common/Breadcrumbs';
import StatCard from '../../components/common/StatCard';
import StatusBadge from '../../components/common/StatusBadge';
import DataTable from '../../components/common/DataTable';
import { 
  Building2, 
  MapPin, 
  TrendingUp, 
  CheckCircle, 
  Clock, 
  AlertTriangle, 
  Smartphone, 
  Map as MapIcon, 
  ArrowRight,
  RefreshCw,
  FileCheck2,
  Activity,
  Layers,
  ShieldCheck
} from 'lucide-react';

export default function FieldOfficerDashboard() {
  const { user } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const fetchStats = async () => {
    try {
      setRefreshing(true);
      const res = await dashboardService.getDashboardStats();
      if (res.success && res.data) {
        setData(res.data);
      }
    } catch (err) {
      console.error('Failed to load field officer executive stats:', err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  const summary = data?.summary || {};
  const tasks = data?.field_tasks || [];
  const fieldVisits = data?.field_visits || [];
  const fieldVerifications = data?.field_verifications || [];
  const recentActivities = data?.recent_activities || [];
  const districtName = data?.district_name || user?.district_name || 'Pune Division';

  // Calculate executive KPI metrics from assigned field data
  const totalTasksCount = tasks.length || summary.assigned_tasks || 6;
  const verifiedCount = fieldVerifications.length || summary.completed_verifications || 3;
  const pendingCount = Math.max(0, totalTasksCount - verifiedCount);
  const progressPct = totalTasksCount > 0 ? Math.round((verifiedCount / totalTasksCount) * 100) : 50;

  // Project progress breakdown for officer's assigned jurisdiction
  const assignedProjects = [
    {
      id: 1,
      project_name: 'Pune Ring Road Express Corridor (Phase-I)',
      project_type: 'Expressway',
      state: 'Maharashtra',
      district: 'Pune',
      land_required_ha: 485.50,
      land_acquired_ha: 289.28,
      land_in_progress_ha: 96.20,
      land_pending_ha: 100.02,
      progress_pct: 60,
      status: 'SURVEY_IN_PROGRESS',
      assigned_parcels: 18,
      verified_parcels: 10
    },
    {
      id: 2,
      project_name: 'Pune-Nashik Semi-High Speed Rail Corridor',
      project_type: 'Railway',
      state: 'Maharashtra',
      district: 'Pune',
      land_required_ha: 720.00,
      land_acquired_ha: 430.00,
      land_in_progress_ha: 140.00,
      land_pending_ha: 150.00,
      progress_pct: 59,
      status: 'NOTIFICATION_IN_PROGRESS',
      assigned_parcels: 24,
      verified_parcels: 14
    }
  ];

  const projectColumns = [
    {
      header: t('dashboard.corridorName'),
      accessor: 'project_name',
      render: (row) => (
        <div>
          <span className="font-bold text-slate-900 block">{row.project_name}</span>
          <span className="text-xs text-slate-500 font-mono">{row.project_type} • {row.district}, {row.state}</span>
        </div>
      )
    },
    {
      header: t('dashboard.landRequired'),
      accessor: 'land_required_ha',
      className: 'text-right font-mono',
      render: (row) => `${row.land_required_ha} Ha`
    },
    {
      header: t('dashboard.landAcquired'),
      accessor: 'land_acquired_ha',
      className: 'text-right font-mono text-emerald-800 font-semibold',
      render: (row) => `${row.land_acquired_ha} Ha`
    },
    {
      header: t('dashboard.landInProgress'),
      accessor: 'land_in_progress_ha',
      className: 'text-right font-mono text-amber-700',
      render: (row) => `${row.land_in_progress_ha} Ha`
    },
    {
      header: t('dashboard.landPending'),
      accessor: 'land_pending_ha',
      className: 'text-right font-mono text-rose-700',
      render: (row) => `${row.land_pending_ha} Ha`
    },
    {
      header: t('dashboard.progressPct'),
      accessor: 'progress_pct',
      className: 'text-center',
      render: (row) => (
        <div className="w-full max-w-[120px] mx-auto">
          <div className="flex justify-between text-[11px] font-semibold mb-0.5">
            <span>{row.progress_pct}%</span>
          </div>
          <div className="w-full bg-slate-200 h-2 rounded-full overflow-hidden">
            <div 
              className="bg-[#FF6B00] h-full rounded-full" 
              style={{ width: `${row.progress_pct}%` }}
            ></div>
          </div>
        </div>
      )
    },
    {
      header: t('common.status'),
      accessor: 'status',
      className: 'text-center',
      render: (row) => <StatusBadge status={row.status} />
    }
  ];

  return (
    <DashboardLayout>
      <Breadcrumbs items={[{ label: t('nav.fieldOperations') }, { label: t('roles.FIELD_OFFICER') }]} />

      {/* Header Banner */}
      <div className="bg-white border border-slate-200 p-5 rounded mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <div className="flex items-center gap-2">
            <span className="bg-[#15803D] text-white text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider flex items-center gap-1">
              <ShieldCheck className="w-3 h-3" />
              {t('dashboard.fieldScope')}
            </span>
            <span className="text-xs text-slate-500">• {districtName}</span>
            <span className="text-[10px] font-bold bg-slate-100 text-slate-700 px-2 py-0.5 rounded border border-slate-200">
              {t('roles.FIELD_OFFICER')}
            </span>
          </div>
          <h2 className="text-xl sm:text-2xl font-bold text-slate-900 mt-1">
            {t('dashboard.title')}
          </h2>
          <p className="text-xs text-slate-600">
            {t('dashboard.subtitle')} • {t('field.officer')} <span className="font-bold text-slate-800">{user?.name}</span> ({user?.email})
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          <button
            onClick={fetchStats}
            disabled={refreshing}
            className="gov-btn-secondary text-xs cursor-pointer"
            title="Refresh statistics"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${refreshing ? 'animate-spin text-orange-600' : ''}`} />
            <span>{refreshing ? t('common.refreshing') : t('common.liveRefresh')}</span>
          </button>
        </div>
      </div>

      {/* Prominent Operational Hub Banner */}
      <div className="bg-gradient-to-r from-orange-600 to-amber-600 text-white p-4 rounded-lg mb-6 shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="bg-white/20 p-2.5 rounded-full">
            <Smartphone className="w-6 h-6 text-white" />
          </div>
          <div>
            <h3 className="font-bold text-sm sm:text-base">{t('dashboard.groundOpsActive')}</h3>
            <p className="text-xs text-orange-100">
              {t('dashboard.groundOpsDesc')}
            </p>
          </div>
        </div>
        <Link
          to="/mobile-inspection"
          className="bg-white text-orange-700 hover:bg-orange-50 font-bold px-4 py-2 rounded text-xs transition-colors flex items-center gap-1.5 shadow-sm whitespace-nowrap cursor-pointer"
        >
          <span>{t('dashboard.openMobileHub')}</span>
          <ArrowRight className="w-3.5 h-3.5" />
        </Link>
      </div>

      {loading ? (
        <div className="py-16 text-center">
          <div className="w-8 h-8 border-3 border-orange-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="mt-3 text-xs font-semibold text-slate-600">{t('dashboard.aggregatingFieldStats')}</p>
        </div>
      ) : (
        <>
          {/* Executive KPI Cards */}
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-8 gap-3.5 mb-6">
            <StatCard
              title={t('dashboard.assignedProjects')}
              value={assignedProjects.length}
              subtitle={t('dashboard.activeCorridors')}
              icon={Building2}
              colorScheme="blue"
            />
            <StatCard
              title={t('dashboard.landRequired')}
              value="1,205.5"
              unit="Ha"
              subtitle={t('dashboard.fieldScope')}
              icon={MapPin}
              colorScheme="orange"
            />
            <StatCard
              title={t('dashboard.landAcquired')}
              value="719.3"
              unit="Ha"
              subtitle={t('dashboard.completed')}
              icon={CheckCircle}
              colorScheme="green"
            />
            <StatCard
              title={t('dashboard.landInProgress')}
              value="236.2"
              unit="Ha"
              subtitle={t('dashboard.inProgress')}
              icon={Clock}
              colorScheme="amber"
            />
            <StatCard
              title={t('dashboard.landPending')}
              value="250.0"
              unit="Ha"
              subtitle={t('dashboard.pending')}
              icon={AlertTriangle}
              colorScheme="red"
            />
            <StatCard
              title={t('dashboard.verificationProgress')}
              value={`${progressPct}%`}
              subtitle={t('dashboard.completed')}
              icon={TrendingUp}
              colorScheme="green"
            />
            <StatCard
              title={t('dashboard.totalLandParcels')}
              value={totalTasksCount}
              subtitle="ULPIN Records"
              icon={Layers}
              colorScheme="blue"
            />
            <StatCard
              title={t('dashboard.pendingTasks')}
              value={pendingCount}
              subtitle={t('dashboard.actionRequired')}
              icon={FileCheck2}
              colorScheme="orange"
            />
          </div>

          {/* Acquisition Lifecycle Pipeline */}
          <div className="gov-card p-4 rounded mb-6">
            <div className="flex items-center justify-between mb-3 border-b border-slate-200 pb-2">
              <h3 className="font-bold text-slate-800 text-sm flex items-center gap-2">
                <Layers className="w-4 h-4 text-orange-600" />
                <span>{t('dashboard.lifecyclePipeline')}</span>
              </h3>
              <span className="text-[11px] text-slate-500 font-medium">{t('dashboard.rfctlarrWorkflow')}</span>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-8 gap-2 text-center text-xs">
              <div className="p-2.5 rounded bg-slate-50 border border-slate-200">
                <div className="text-[10px] font-bold text-slate-500 uppercase">Stage 1</div>
                <div className="font-semibold text-slate-800 mt-0.5">{t('dashboard.stage1')}</div>
                <div className="text-emerald-700 font-bold text-xs mt-1">{t('dashboard.completed')}</div>
              </div>
              <div className="p-2.5 rounded bg-slate-50 border border-slate-200">
                <div className="text-[10px] font-bold text-slate-500 uppercase">Stage 2</div>
                <div className="font-semibold text-slate-800 mt-0.5">{t('dashboard.stage2')}</div>
                <div className="text-emerald-700 font-bold text-xs mt-1">{t('dashboard.completed')}</div>
              </div>
              <div className="p-2.5 rounded bg-slate-50 border border-slate-200">
                <div className="text-[10px] font-bold text-slate-500 uppercase">Stage 3</div>
                <div className="font-semibold text-slate-800 mt-0.5">{t('dashboard.stage3')}</div>
                <div className="text-emerald-700 font-bold text-xs mt-1">42 Parcels</div>
              </div>
              <div className="p-2.5 rounded bg-orange-50 border border-orange-300 shadow-xs">
                <div className="text-[10px] font-bold text-orange-700 uppercase">Stage 4 (Current)</div>
                <div className="font-bold text-orange-900 mt-0.5">{t('dashboard.stage4')}</div>
                <div className="text-orange-700 font-bold text-xs mt-1">{verifiedCount}/{totalTasksCount} {t('dashboard.completed')}</div>
              </div>
              <div className="p-2.5 rounded bg-slate-50 border border-slate-200">
                <div className="text-[10px] font-bold text-slate-500 uppercase">Stage 5</div>
                <div className="font-semibold text-slate-800 mt-0.5">{t('dashboard.stage5')}</div>
                <div className="text-slate-500 text-xs mt-1">{t('dashboard.pending')}</div>
              </div>
              <div className="p-2.5 rounded bg-slate-50 border border-slate-200">
                <div className="text-[10px] font-bold text-slate-500 uppercase">Stage 6</div>
                <div className="font-semibold text-slate-800 mt-0.5">{t('dashboard.stage6')}</div>
                <div className="text-slate-500 text-xs mt-1">{t('dashboard.pending')}</div>
              </div>
              <div className="p-2.5 rounded bg-slate-50 border border-slate-200">
                <div className="text-[10px] font-bold text-slate-500 uppercase">Stage 7</div>
                <div className="font-semibold text-slate-800 mt-0.5">{t('dashboard.stage7')}</div>
                <div className="text-slate-500 text-xs mt-1">{t('dashboard.pending')}</div>
              </div>
              <div className="p-2.5 rounded bg-slate-50 border border-slate-200">
                <div className="text-[10px] font-bold text-slate-500 uppercase">Stage 8</div>
                <div className="font-semibold text-slate-800 mt-0.5">{t('dashboard.stage8')}</div>
                <div className="text-slate-500 text-xs mt-1">{t('dashboard.pending')}</div>
              </div>
            </div>
          </div>

          {/* Project Overview Table & Priority Action Sidebar */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
            <div className="lg:col-span-2 gov-card p-4 rounded">
              <div className="flex items-center justify-between mb-3 border-b border-slate-200 pb-2">
                <h3 className="font-bold text-slate-800 text-sm flex items-center gap-2">
                  <Building2 className="w-4 h-4 text-orange-600" />
                  <span>{t('dashboard.projectCorridors')}</span>
                </h3>
                <span className="text-xs text-slate-500 font-mono">{assignedProjects.length} Active Projects</span>
              </div>
              <DataTable
                columns={projectColumns}
                data={assignedProjects}
                emptyMessage="No assigned projects in this district."
              />
            </div>

            {/* GIS Quick View Card & Priority Attention */}
            <div className="space-y-6">
              {/* GIS Command Center Entry Card */}
              <div className="gov-card p-4 rounded bg-gradient-to-br from-slate-900 to-slate-800 text-white shadow-sm">
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-1.5 text-xs font-bold text-orange-400 uppercase tracking-wider">
                    <MapIcon className="w-4 h-4 text-orange-400" />
                    <span>{t('nav.cadastralMap')}</span>
                  </div>
                  <span className="bg-emerald-500/20 text-emerald-300 text-[10px] font-bold px-2 py-0.5 rounded border border-emerald-500/30">
                    Live
                  </span>
                </div>
                <h4 className="font-bold text-base mb-1">{t('dashboard.cadastralMapTitle')}</h4>
                <p className="text-xs text-slate-300 mb-4">
                  {t('dashboard.cadastralMapDesc')}
                </p>
                <button
                  onClick={() => navigate('/gis')}
                  className="w-full bg-[#FF6B00] hover:bg-[#D9531E] text-white font-bold py-2 px-3 rounded text-xs transition-colors flex items-center justify-center gap-2 cursor-pointer"
                >
                  <span>{t('dashboard.openGis')}</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </button>
              </div>

              {/* Priority & Attention Panel */}
              <div className="gov-card p-4 rounded">
                <div className="flex items-center justify-between mb-3 border-b border-slate-200 pb-2">
                  <h3 className="font-bold text-slate-800 text-sm flex items-center gap-1.5">
                    <AlertTriangle className="w-4 h-4 text-rose-600" />
                    <span>{t('dashboard.priorityAttention')}</span>
                  </h3>
                  <span className="text-[10px] font-bold bg-rose-100 text-rose-800 px-1.5 py-0.5 rounded">
                    {pendingCount} {t('dashboard.pending')}
                  </span>
                </div>

                <div className="space-y-2.5 text-xs">
                  <div className="p-2.5 rounded bg-amber-50 border border-amber-200">
                    <div className="font-bold text-amber-900">{t('dashboard.pendingVerifications')} ({pendingCount})</div>
                    <div className="text-amber-700 text-[11px] mt-0.5">
                      Ground cadastral demarcation required for Urse & Hinjawadi survey numbers.
                    </div>
                  </div>
                  <div className="p-2.5 rounded bg-slate-50 border border-slate-200">
                    <div className="font-bold text-slate-800">{t('dashboard.pendingUploads')}</div>
                    <div className="text-slate-600 text-[11px] mt-0.5">
                      Ensure all certified land revenue extracts are attached before final CALA submission.
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Recent Verification Activity Log */}
          <div className="gov-card p-4 rounded">
            <div className="flex items-center justify-between mb-3 border-b border-slate-200 pb-2">
              <h3 className="font-bold text-slate-800 text-sm flex items-center gap-2">
                <Activity className="w-4 h-4 text-orange-600" />
                <span>{t('dashboard.recentActivities')}</span>
              </h3>
              <span className="text-xs text-slate-500 font-mono">{t('dashboard.auditTrail')}</span>
            </div>

            <div className="space-y-2 text-xs">
              {recentActivities.length > 0 ? (
                recentActivities.slice(0, 5).map((act, idx) => (
                  <div key={idx} className="p-2.5 rounded bg-slate-50 border border-slate-200 flex items-center justify-between">
                    <div>
                      <span className="font-bold text-slate-900">{act.action}</span>
                      <span className="text-slate-600 text-[11px] ml-2">{act.details || act.description}</span>
                    </div>
                    <span className="text-slate-400 font-mono text-[10px]">{act.timestamp || 'Today'}</span>
                  </div>
                ))
              ) : (
                <div className="text-slate-500 py-3 text-center">{t('dashboard.noActivities')}</div>
              )}
            </div>
          </div>
        </>
      )}
    </DashboardLayout>
  );
}
