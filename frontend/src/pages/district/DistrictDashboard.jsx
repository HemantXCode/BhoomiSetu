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
  CheckCircle, 
  FileCheck2, 
  ClipboardList, 
  RefreshCw,
  Clock,
  Send,
  AlertCircle
} from 'lucide-react';

export default function DistrictDashboard() {
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
      console.error('Failed to load district authority stats:', err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  const summary = data?.summary || {};
  const districtName = data?.district_name || 'District Collectorate';
  const stateName = data?.state_name || 'State';
  const projects = data?.projects_list || [];
  const fieldQueue = data?.field_verification_queue || [];

  const projectColumns = [
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
      header: 'Proposed Area (Ha)',
      accessor: 'proposed_area',
      className: 'text-right font-mono',
      render: (row) => `${row.proposed_area} Ha`
    },
    {
      header: 'Target Possession',
      accessor: 'expected_end_date',
      className: 'text-center text-xs font-mono',
      render: (row) => row.expected_end_date || 'TBD'
    },
    {
      header: 'Stage / Status',
      accessor: 'status',
      render: (row) => <StatusBadge status={row.status} />
    }
  ];

  const fieldQueueColumns = [
    {
      header: 'Task ID / Parcel',
      accessor: 'id',
      render: (row) => (
        <div>
          <span className="font-bold font-mono text-slate-900 block">{row.id}</span>
          <span className="text-xs text-slate-600">{row.parcel_no}</span>
        </div>
      )
    },
    {
      header: 'Village / Taluka',
      accessor: 'village',
      render: (row) => <span className="font-medium text-slate-800">{row.village}</span>
    },
    {
      header: 'Project Corridor',
      accessor: 'project_name',
      render: (row) => <span className="text-xs text-slate-700">{row.project_name}</span>
    },
    {
      header: 'Assigned Officer',
      accessor: 'officer',
      render: (row) => <span className="text-xs font-semibold text-slate-700">{row.officer}</span>
    },
    {
      header: 'Verification Status',
      accessor: 'status',
      render: (row) => (
        <span className="bg-amber-100 text-amber-900 border border-amber-300 text-[11px] font-bold px-2 py-0.5 rounded">
          {row.status}
        </span>
      )
    }
  ];

  return (
    <DashboardLayout>
      <Breadcrumbs items={[{ label: 'District Authority', path: '/district/dashboard' }, { label: `${districtName} District Portal` }]} />

      {/* District Header Banner */}
      <div className="bg-white border border-slate-200 p-5 rounded mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <div className="flex items-center gap-2">
            <span className="bg-[#FF6B00] text-white text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider">
              District Competent Authority (CALA)
            </span>
            <span className="text-xs text-slate-500 font-medium">• {districtName} District, {stateName}</span>
          </div>
          <h2 className="text-xl sm:text-2xl font-bold text-slate-900 mt-1">
            {districtName} District Land Acquisition & Award Office
          </h2>
          <p className="text-xs text-slate-600">
            Operational dashboard for gazette notifications (Section 4/11), award declarations (Section 23), and direct benefit transfer (DBT).
          </p>
        </div>

        <button
          onClick={fetchStats}
          disabled={refreshing}
          className="gov-btn-secondary text-xs"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${refreshing ? 'animate-spin text-orange-600' : ''}`} />
          <span>{refreshing ? 'Refreshing...' : 'Refresh District Stats'}</span>
        </button>
      </div>

      {loading ? (
        <div className="py-16 text-center">
          <div className="w-8 h-8 border-3 border-orange-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="mt-3 text-xs font-semibold text-slate-600">Loading {districtName} Operational Records...</p>
        </div>
      ) : (
        <>
          {/* Operational KPI Cards */}
          <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-8 gap-3 mb-6">
            <StatCard
              title="District Projects"
              value={summary.district_projects || 0}
              icon={Building2}
              colorScheme="blue"
            />
            <StatCard
              title="Land Proposed"
              value={summary.land_proposed || '0.00'}
              unit="Ha"
              icon={MapPin}
              colorScheme="orange"
            />
            <StatCard
              title="Land Acquired"
              value={summary.land_acquired || '0.00'}
              unit="Ha"
              icon={CheckCircle}
              colorScheme="green"
            />
            <StatCard
              title="Pending Verification"
              value={summary.pending_verification || 0}
              subtitle="Parcels in Queue"
              icon={ClipboardList}
              colorScheme="amber"
            />
            <StatCard
              title="Pending Sec-4/11"
              value={summary.pending_notifications || 0}
              subtitle="Gazette Ready"
              icon={FileCheck2}
              colorScheme="blue"
            />
            <StatCard
              title="Pending Awards"
              value={summary.pending_awards || 0}
              subtitle="Draft Awards"
              icon={Clock}
              colorScheme="amber"
            />
            <StatCard
              title="DBT Disbursed"
              value={`${summary.compensation_disbursed_pct || 0}%`}
              subtitle="Direct to Escrow"
              icon={Coins}
              colorScheme="green"
            />
            <StatCard
              title="R&R Status"
              value={summary.rr_status || 'Active'}
              subtitle="Family Rehabilitation"
              icon={Users}
              colorScheme="blue"
            />
          </div>

          {/* Operational Tables: Field Queue & District Projects */}
          <div className="space-y-6">
            
            {/* Field Verification Task Queue */}
            <DataTable
              title={`Field Verification & Joint Measurement Queue (${districtName})`}
              columns={fieldQueueColumns}
              data={fieldQueue}
              itemsPerPage={5}
              searchPlaceholder="Search parcel or village..."
            />

            {/* District Projects Listing */}
            <DataTable
              title={`Jurisdictional Projects in ${districtName} District`}
              columns={projectColumns}
              data={projects}
              itemsPerPage={5}
              searchPlaceholder="Search project..."
            />

          </div>
        </>
      )}
    </DashboardLayout>
  );
}
