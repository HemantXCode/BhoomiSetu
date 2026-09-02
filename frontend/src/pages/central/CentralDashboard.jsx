import React, { useState, useEffect } from 'react';
import { dashboardService } from '../../services/dashboardService';
import { useLanguage } from '../../context/LanguageContext';
import DashboardLayout from '../../components/layout/DashboardLayout';
import Breadcrumbs from '../../components/common/Breadcrumbs';
import StatCard from '../../components/common/StatCard';
import StatusBadge from '../../components/common/StatusBadge';
import DataTable from '../../components/common/DataTable';
import { 
  Building2, 
  MapPin, 
  Coins, 
  Users, 
  AlertTriangle, 
  Clock, 
  TrendingUp, 
  RefreshCw,
  BellRing,
  Activity,
  CheckCircle,
  FileSpreadsheet
} from 'lucide-react';

export default function CentralDashboard() {
  const { t } = useLanguage();
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
      console.error('Failed to load central ministry stats:', err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  const summary = data?.summary || {};
  const stateWise = data?.state_wise_progress || [];
  const delayedProjects = data?.delayed_projects_list || [];
  const alerts = data?.alerts || [];
  const recentActivities = data?.recent_activities || [];
  const statusCounts = data?.status_counts || {};

  const stateColumns = [
    {
      header: 'State / UT',
      accessor: 'state_name',
      render: (row) => (
        <div>
          <span className="font-bold text-slate-900">{row.state_name}</span>
          <span className="text-xs text-slate-500 ml-1.5 font-mono">({row.state_code})</span>
        </div>
      )
    },
    {
      header: t('dashboard.totalProjects'),
      accessor: 'projects_count',
      className: 'text-center',
      render: (row) => (
        <span className="font-semibold text-slate-800 bg-slate-100 px-2 py-0.5 rounded text-xs">
          {row.projects_count}
        </span>
      )
    },
    {
      header: `${t('dashboard.landProposed')} (Ha)`,
      accessor: 'land_proposed',
      className: 'text-right font-mono',
      render: (row) => `${row.land_proposed} Ha`
    },
    {
      header: `${t('dashboard.landAcquired')} (Ha)`,
      accessor: 'land_acquired',
      className: 'text-right font-mono text-emerald-800 font-semibold',
      render: (row) => `${row.land_acquired} Ha`
    },
    {
      header: t('dashboard.acquisitionProgress'),
      accessor: 'acquisition_percentage',
      className: 'text-center',
      render: (row) => (
        <div className="w-full max-w-[140px] mx-auto">
          <div className="flex justify-between text-[11px] font-semibold mb-0.5">
            <span>{row.acquisition_percentage}%</span>
          </div>
          <div className="w-full bg-slate-200 h-2 rounded-full overflow-hidden">
            <div 
              className="bg-[#FF6B00] h-full rounded-full" 
              style={{ width: `${Math.min(100, parseFloat(row.acquisition_percentage))}%` }}
            ></div>
          </div>
        </div>
      )
    },
    {
      header: 'Delayed / Flagged',
      accessor: 'delayed_count',
      className: 'text-center',
      render: (row) => (
        row.delayed_count > 0 ? (
          <span className="bg-rose-100 text-rose-800 text-xs px-2 py-0.5 rounded font-bold border border-rose-200">
            {row.delayed_count} Delayed
          </span>
        ) : (
          <span className="text-emerald-700 text-xs font-semibold">On Schedule</span>
        )
      )
    }
  ];

  const delayedColumns = [
    {
      header: 'Project Name',
      accessor: 'project_name',
      render: (row) => (
        <div>
          <span className="font-bold text-slate-900 block">{row.project_name}</span>
          <span className="text-xs text-slate-500">{row.agency_name}</span>
        </div>
      )
    },
    {
      header: 'Location',
      render: (row) => `${row.district_name || 'District'}, ${row.state_name || 'State'}`
    },
    {
      header: 'Proposed Area',
      render: (row) => `${row.proposed_area} Ha`
    },
    {
      header: 'Delayed Stage',
      render: (row) => <StatusBadge status={row.status} />
    },
    {
      header: 'Bottleneck Reason',
      accessor: 'delay_reason',
      render: (row) => <span className="text-xs text-rose-700 font-medium">{row.delay_reason || 'Pending State Approval'}</span>
    }
  ];

  return (
    <DashboardLayout>
      <Breadcrumbs items={[{ label: t('nav.dashboard') }, { label: t('roles.CENTRAL_MINISTRY') }]} />

      {/* Official Government Header Banner */}
      <div className="bg-white border border-slate-200 p-5 rounded mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <div className="flex items-center gap-2">
            <span className="bg-[#FF6B00] text-white text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider">
              {t('dashboard.executiveScope')}
            </span>
            <span className="text-xs text-slate-500">• MoRTH / MoRD National PMU</span>
          </div>
          <h2 className="text-xl sm:text-2xl font-bold text-slate-900 mt-1">
            {t('dashboard.title')}
          </h2>
          <p className="text-xs text-slate-600">
            {t('dashboard.subtitle')}
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={fetchStats}
            disabled={refreshing}
            className="gov-btn-secondary text-xs cursor-pointer"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${refreshing ? 'animate-spin text-orange-600' : ''}`} />
            <span>{refreshing ? t('common.refreshing') : t('common.liveRefresh')}</span>
          </button>
        </div>
      </div>

      {loading ? (
        <div className="py-20 text-center">
          <div className="w-8 h-8 border-3 border-orange-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="mt-3 text-xs font-semibold text-slate-600">{t('dashboard.aggregatingStats')}</p>
        </div>
      ) : (
        <>
          {/* Top 12-Card Executive Matrix */}
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-3.5 mb-6">
            <StatCard
              title={t('dashboard.totalProjects')}
              value={summary.total_projects || 0}
              subtitle={t('dashboard.activeCorridors')}
              icon={Building2}
              colorScheme="blue"
            />
            <StatCard
              title={t('dashboard.landProposed')}
              value={summary.total_land_proposed || '0.00'}
              unit="Ha"
              subtitle="Total RoW Required"
              icon={MapPin}
              colorScheme="orange"
            />
            <StatCard
              title={t('dashboard.landAcquired')}
              value={summary.total_land_acquired || '0.00'}
              unit="Ha"
              subtitle="Possession in Progress"
              icon={CheckCircle}
              colorScheme="green"
            />
            <StatCard
              title={t('dashboard.acquisitionProgress')}
              value={`${summary.acquisition_percentage || '0.0'}%`}
              subtitle="National Average"
              icon={TrendingUp}
              colorScheme="orange"
              trend="Target: 80%"
            />
            <StatCard
              title={t('dashboard.compAssessed')}
              value={`₹${summary.compensation_assessed_cr || '0.00'}`}
              unit="Cr"
              subtitle="Estimated Award"
              icon={Coins}
              colorScheme="blue"
            />
            <StatCard
              title={t('dashboard.compDisbursed')}
              value={`₹${summary.compensation_paid_cr || '0.00'}`}
              unit="Cr"
              subtitle="Direct DBT to Escrow"
              icon={Coins}
              colorScheme="green"
            />
            <StatCard
              title={t('dashboard.affectedFamilies')}
              value={summary.affected_families?.toLocaleString('en-IN') || 0}
              subtitle="Titleholders Mapped"
              icon={Users}
              colorScheme="blue"
            />
            <StatCard
              title={t('dashboard.displacedFamilies')}
              value={summary.displaced_families?.toLocaleString('en-IN') || 0}
              subtitle="R&R Required"
              icon={Users}
              colorScheme="amber"
            />
            <StatCard
              title="R&R Progress"
              value={`${summary.rr_progress_pct || 0}%`}
              subtitle="Resettlement Pace"
              icon={TrendingUp}
              colorScheme="green"
            />
            <StatCard
              title="Delayed Projects"
              value={summary.delayed_projects || 0}
              subtitle="Clearance Bottlenecks"
              icon={AlertTriangle}
              colorScheme="red"
              trend="Action Req."
            />
            <StatCard
              title="Average Delay"
              value={`${summary.average_delay_months || 0}`}
              unit="Mos"
              subtitle="Statutory Drift"
              icon={Clock}
              colorScheme="amber"
            />
            <StatCard
              title="Active States"
              value={stateWise.length}
              subtitle="States with Corridors"
              icon={Building2}
              colorScheme="blue"
            />
          </div>

          {/* National Overview: State-Wise Table & Alerts */}
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 mb-6">
            
            {/* Left: State-wise Land Acquisition Progress Table */}
            <div className="lg:col-span-8 space-y-6">
              <DataTable
                title="State-wise Land Acquisition Progress (National Overview)"
                columns={stateColumns}
                data={stateWise}
                itemsPerPage={8}
                searchPlaceholder="Search state..."
              />

              {/* Delayed Projects Radar */}
              <div className="gov-card p-4">
                <div className="gov-card-header -mx-4 -mt-4 mb-4 bg-rose-50/70 text-rose-900 border-rose-200">
                  <div className="flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4 text-rose-600" />
                    <span className="font-bold uppercase tracking-wide text-xs">
                      Delayed & High-Priority Project Bottlenecks ({delayedProjects.length})
                    </span>
                  </div>
                </div>

                {delayedProjects.length > 0 ? (
                  <DataTable
                    columns={delayedColumns}
                    data={delayedProjects}
                    searchable={false}
                    pagination={false}
                  />
                ) : (
                  <div className="text-center py-6 text-emerald-700 text-xs font-semibold">
                    ✅ No projects currently flagged with critical statutory delay.
                  </div>
                )}
              </div>
            </div>

            {/* Right: Important Alerts & Activity Feed */}
            <div className="lg:col-span-4 space-y-6">
              
              {/* Important Alerts */}
              <div className="gov-card p-4">
                <div className="gov-card-header -mx-4 -mt-4 mb-4 text-[#D9531E]">
                  <div className="flex items-center gap-2">
                    <BellRing className="w-4 h-4 text-orange-600" />
                    <span className="font-bold uppercase tracking-wide text-xs">
                      Important System Alerts
                    </span>
                  </div>
                </div>

                <div className="space-y-3">
                  {alerts.map((alert) => (
                    <div 
                      key={alert.id} 
                      className={`p-3 rounded border text-xs ${
                        alert.severity === 'HIGH' 
                          ? 'bg-rose-50 border-rose-200 text-rose-900' 
                          : alert.severity === 'MEDIUM' 
                          ? 'bg-amber-50 border-amber-200 text-amber-900' 
                          : 'bg-slate-50 border-slate-200 text-slate-800'
                      }`}
                    >
                      <div className="flex justify-between items-center mb-1">
                        <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded ${
                          alert.severity === 'HIGH' ? 'bg-rose-200 text-rose-900' : 'bg-amber-200 text-amber-900'
                        }`}>
                          {alert.severity} PRIORITY
                        </span>
                        <span className="text-[10px] text-slate-500">{alert.time}</span>
                      </div>
                      <p className="leading-snug">{alert.message}</p>
                    </div>
                  ))}
                </div>
              </div>

              {/* Status Breakdown Radar */}
              <div className="gov-card p-4">
                <div className="gov-card-header -mx-4 -mt-4 mb-4">
                  <span className="font-bold uppercase tracking-wide text-xs">
                    Lifecycle Status Distribution
                  </span>
                </div>

                <div className="space-y-2 text-xs">
                  {Object.entries(statusCounts).map(([status, count]) => (
                    <div key={status} className="flex items-center justify-between py-1 border-b border-slate-100 last:border-0">
                      <StatusBadge status={status} />
                      <span className="font-bold font-mono text-slate-800">{count}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Recent National Activities */}
              <div className="gov-card p-4">
                <div className="gov-card-header -mx-4 -mt-4 mb-4">
                  <div className="flex items-center gap-2">
                    <Activity className="w-4 h-4 text-slate-600" />
                    <span className="font-bold uppercase tracking-wide text-xs">
                      Recent Field & Gazette Updates
                    </span>
                  </div>
                </div>

                <div className="space-y-3 text-xs">
                  {recentActivities.map((act) => (
                    <div key={act.id} className="border-l-2 border-orange-500 pl-3 py-0.5">
                      <p className="text-slate-800 font-medium leading-snug">{act.message}</p>
                      <div className="flex justify-between text-[10px] text-slate-500 mt-1">
                        <span>By {act.user}</span>
                        <span>{act.timestamp}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

            </div>

          </div>
        </>
      )}
    </DashboardLayout>
  );
}
