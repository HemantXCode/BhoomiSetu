import React, { useState, useEffect } from 'react';
import { dashboardService } from '../../services/dashboardService';
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
  TrendingUp, 
  RefreshCw,
  FileCheck2,
  Map as MapIcon,
  CheckCircle,
  Clock
} from 'lucide-react';

export default function StateDashboard() {
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
      console.error('Failed to load state stats:', err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  const summary = data?.summary || {};
  const districtWise = data?.district_wise_progress || [];
  const pendingApprovals = data?.pending_approvals || [];
  const delayedProjects = data?.delayed_projects_list || [];
  const stateName = data?.state_name || 'State Revenue Department';

  const districtColumns = [
    {
      header: 'District Name',
      accessor: 'district_name',
      render: (row) => (
        <div>
          <span className="font-bold text-slate-900">{row.district_name}</span>
          <span className="text-xs text-slate-500 ml-1.5 font-mono">({row.district_code})</span>
        </div>
      )
    },
    {
      header: 'Active Projects',
      accessor: 'projects_count',
      className: 'text-center font-bold text-slate-800',
      render: (row) => row.projects_count
    },
    {
      header: 'Land Proposed (Ha)',
      accessor: 'land_proposed',
      className: 'text-right font-mono',
      render: (row) => `${row.land_proposed} Ha`
    },
    {
      header: 'Land Acquired (Ha)',
      accessor: 'land_acquired',
      className: 'text-right font-mono text-emerald-800 font-semibold',
      render: (row) => `${row.land_acquired} Ha`
    },
    {
      header: 'Acquisition %',
      accessor: 'acquisition_percentage',
      className: 'text-center',
      render: (row) => (
        <div className="w-full max-w-[130px] mx-auto">
          <div className="text-[11px] font-semibold mb-0.5">{row.acquisition_percentage}%</div>
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
      header: 'Status',
      accessor: 'delayed_count',
      className: 'text-center',
      render: (row) => (
        row.delayed_count > 0 ? (
          <span className="bg-rose-100 text-rose-800 text-xs px-2 py-0.5 rounded font-bold">
            {row.delayed_count} Delayed
          </span>
        ) : (
          <span className="text-emerald-700 text-xs font-semibold">On Track</span>
        )
      )
    }
  ];

  return (
    <DashboardLayout>
      <Breadcrumbs items={[{ label: 'State Government', path: '/state/dashboard' }, { label: `${stateName} State Dashboard` }]} />

      {/* State Header Banner */}
      <div className="bg-white border border-slate-200 p-5 rounded mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <div className="flex items-center gap-2">
            <span className="bg-[#D9531E] text-white text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider">
              State Government Authority
            </span>
            <span className="text-xs text-slate-500 font-medium">• {stateName} State Jurisdiction</span>
          </div>
          <h2 className="text-xl sm:text-2xl font-bold text-slate-900 mt-1">
            {stateName} Land Acquisition & Revenue Oversight
          </h2>
          <p className="text-xs text-slate-600">
            Monitoring district-level joint measurement surveys, Section 19 declarations, and compensation sanction orders.
          </p>
        </div>

        <button
          onClick={fetchStats}
          disabled={refreshing}
          className="gov-btn-secondary text-xs"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${refreshing ? 'animate-spin text-orange-600' : ''}`} />
          <span>{refreshing ? 'Refreshing...' : 'Refresh State Stats'}</span>
        </button>
      </div>

      {loading ? (
        <div className="py-16 text-center">
          <div className="w-8 h-8 border-3 border-orange-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="mt-3 text-xs font-semibold text-slate-600">Loading {stateName} Acquisition Records...</p>
        </div>
      ) : (
        <>
          {/* State Summary KPI Cards */}
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3.5 mb-6">
            <StatCard
              title="State Projects"
              value={summary.state_projects || 0}
              subtitle="Active in State"
              icon={Building2}
              colorScheme="blue"
            />
            <StatCard
              title="Land Proposed"
              value={summary.land_proposed || '0.00'}
              unit="Ha"
              subtitle="Total Area"
              icon={MapPin}
              colorScheme="orange"
            />
            <StatCard
              title="Land Acquired"
              value={summary.land_acquired || '0.00'}
              unit="Ha"
              subtitle="Possession Recorded"
              icon={CheckCircle}
              colorScheme="green"
            />
            <StatCard
              title="State Progress"
              value={`${summary.acquisition_percentage || '0.0'}%`}
              subtitle="Acquisition Pace"
              icon={TrendingUp}
              colorScheme="orange"
            />
            <StatCard
              title="Comp. Assessed"
              value={`₹${summary.compensation_assessed_cr || '0.00'}`}
              unit="Cr"
              subtitle="State Total Estimate"
              icon={Coins}
              colorScheme="blue"
            />
            <StatCard
              title="Comp. Disbursed"
              value={`₹${summary.compensation_paid_cr || '0.00'}`}
              unit="Cr"
              subtitle="Paid to Landowners"
              icon={Coins}
              colorScheme="green"
            />
            <StatCard
              title="Affected Families"
              value={summary.affected_families?.toLocaleString('en-IN') || 0}
              subtitle="State Registry"
              icon={Users}
              colorScheme="blue"
            />
            <StatCard
              title="Displaced Families"
              value={summary.displaced_families?.toLocaleString('en-IN') || 0}
              subtitle="R&R Eligible"
              icon={Users}
              colorScheme="amber"
            />
            <StatCard
              title="R&R Progress"
              value={`${summary.rr_progress_pct || 0}%`}
              subtitle="Rehabilitation Stage"
              icon={TrendingUp}
              colorScheme="green"
            />
            <StatCard
              title="Delayed Projects"
              value={summary.delayed_projects || 0}
              subtitle="State Flagged"
              icon={AlertTriangle}
              colorScheme="red"
            />
          </div>

          {/* District-wise Table & State Actions */}
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
            
            {/* Left: District Progress Table */}
            <div className="lg:col-span-8 space-y-6">
              <DataTable
                title={`District-wise Land Acquisition Breakdown (${stateName})`}
                columns={districtColumns}
                data={districtWise}
                itemsPerPage={6}
                searchPlaceholder="Search district..."
              />

              {/* State Delayed Projects */}
              {delayedProjects.length > 0 && (
                <div className="gov-card p-4 border-l-4 border-l-rose-600">
                  <h3 className="font-bold text-sm text-slate-800 uppercase tracking-wide mb-3 flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4 text-rose-600" />
                    Delayed Projects in {stateName} ({delayedProjects.length})
                  </h3>
                  <div className="space-y-2 text-xs">
                    {delayedProjects.map(p => (
                      <div key={p.id} className="p-2.5 bg-rose-50/50 border border-rose-200 rounded flex justify-between items-center">
                        <div>
                          <div className="font-bold text-slate-900">{p.project_name}</div>
                          <div className="text-slate-600 text-[11px]">{p.district_name} District • {p.agency_name} • {p.proposed_area} Ha</div>
                        </div>
                        <StatusBadge status={p.status} />
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Right: Pending State Approvals & Future GIS Placeholder */}
            <div className="lg:col-span-4 space-y-6">
              
              {/* Pending State Approvals */}
              <div className="gov-card p-4">
                <div className="gov-card-header -mx-4 -mt-4 mb-4 text-[#D9531E]">
                  <div className="flex items-center gap-2">
                    <FileCheck2 className="w-4 h-4 text-orange-600" />
                    <span className="font-bold uppercase tracking-wide text-xs">
                      Pending State Clearances & Sanctions
                    </span>
                  </div>
                </div>

                <div className="space-y-3">
                  {pendingApprovals.map(appr => (
                    <div key={appr.id} className="p-3 bg-amber-50/60 border border-amber-200 rounded text-xs">
                      <div className="flex justify-between items-center mb-1">
                        <span className="font-mono font-bold text-slate-900">{appr.id}</span>
                        <span className="text-[10px] bg-amber-200 text-amber-900 font-bold px-1.5 py-0.5 rounded flex items-center gap-1">
                          <Clock className="w-3 h-3" />
                          {appr.days_pending} days pending
                        </span>
                      </div>
                      <div className="font-semibold text-slate-800">{appr.item}</div>
                      <div className="text-[11px] text-slate-600 mt-1">{appr.project}</div>
                    </div>
                  ))}
                </div>
              </div>

              {/* State GIS Map Placeholder (Phase 4 Ready) */}
              <div className="gov-card p-4 border border-dashed border-slate-300 bg-slate-50 text-center">
                <div className="w-10 h-10 bg-orange-100 text-[#FF6B00] rounded-full flex items-center justify-center mx-auto mb-2">
                  <MapIcon className="w-5 h-5" />
                </div>
                <h4 className="font-bold text-xs uppercase text-slate-800 mb-1">
                  State GIS Cadastral Layer
                </h4>
                <p className="text-[11px] text-slate-500 mb-3">
                  PostGIS polygon boundary rendering and spatial status overlays are architecturally prepared for Phase 4.
                </p>
                <span className="bg-slate-200 text-slate-700 text-[10px] font-semibold px-2 py-0.5 rounded uppercase">
                  Spatial Engine: Phase 4
                </span>
              </div>

            </div>

          </div>
        </>
      )}
    </DashboardLayout>
  );
}
