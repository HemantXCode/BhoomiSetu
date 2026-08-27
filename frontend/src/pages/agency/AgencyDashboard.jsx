import React, { useState, useEffect } from 'react';
import { dashboardService } from '../../services/dashboardService';
import { useAuth } from '../../context/AuthContext';
import DashboardLayout from '../../components/layout/DashboardLayout';
import Breadcrumbs from '../../components/common/Breadcrumbs';
import StatCard from '../../components/common/StatCard';
import StatusBadge from '../../components/common/StatusBadge';
import DataTable from '../../components/common/DataTable';
import ProposalModal from '../../components/forms/ProposalModal';
import { 
  Building2, 
  MapPin, 
  CheckCircle, 
  AlertTriangle, 
  TrendingUp, 
  PlusCircle, 
  RefreshCw,
  FolderKanban,
  Flag,
  Activity
} from 'lucide-react';

export default function AgencyDashboard() {
  const { user } = useAuth();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const fetchStats = async () => {
    try {
      setRefreshing(true);
      const res = await dashboardService.getDashboardStats();
      if (res.success && res.data) {
        setData(res.data);
      }
    } catch (err) {
      console.error('Failed to load agency stats:', err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  const handleProjectCreated = (newProject) => {
    fetchStats();
  };

  const summary = data?.summary || {};
  const agencyName = data?.agency_name || user?.agency_name || 'Executing Project Agency';
  const projects = data?.projects_list || [];
  const milestones = data?.milestones || [];
  const recentActivities = data?.recent_activities || [];

  const projectColumns = [
    {
      header: 'Project Title',
      accessor: 'project_name',
      render: (row) => (
        <div>
          <span className="font-bold text-slate-900 block">{row.project_name}</span>
          <span className="text-xs text-slate-500">{row.description ? row.description.slice(0, 70) + '...' : ''}</span>
        </div>
      )
    },
    {
      header: 'State / District',
      render: (row) => `${row.district_name || 'District'}, ${row.state_name || 'State'}`
    },
    {
      header: 'Land Required',
      accessor: 'proposed_area',
      className: 'text-right font-mono',
      render: (row) => `${row.proposed_area} Ha`
    },
    {
      header: 'Current Status',
      accessor: 'status',
      render: (row) => <StatusBadge status={row.status} />
    }
  ];

  return (
    <DashboardLayout>
      <Breadcrumbs items={[{ label: 'Project Agency', path: '/agency/dashboard' }, { label: `${agencyName} Portal` }]} />

      {/* Agency Header Banner with Submit Proposal Button */}
      <div className="bg-white border border-slate-200 p-5 rounded mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <div className="flex items-center gap-2">
            <span className="bg-[#FF6B00] text-white text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider">
              Project Implementing Agency (PIA)
            </span>
            <span className="text-xs text-slate-500 font-medium">• {agencyName}</span>
          </div>
          <h2 className="text-xl sm:text-2xl font-bold text-slate-900 mt-1">
            {agencyName} Project & Acquisition Portfolio
          </h2>
          <p className="text-xs text-slate-600">
            Submit new land acquisition proposals, monitor Joint Measurement Surveys, and track Right-of-Way (RoW) handovers.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={fetchStats}
            disabled={refreshing}
            className="gov-btn-secondary text-xs"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${refreshing ? 'animate-spin text-orange-600' : ''}`} />
            <span>Refresh</span>
          </button>

          {/* Submit New Proposal Button */}
          <button
            onClick={() => setIsModalOpen(true)}
            className="gov-btn-primary text-xs shadow-sm"
          >
            <PlusCircle className="w-4 h-4" />
            <span>+ Submit New Project Proposal</span>
          </button>
        </div>
      </div>

      {loading ? (
        <div className="py-16 text-center">
          <div className="w-8 h-8 border-3 border-orange-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="mt-3 text-xs font-semibold text-slate-600">Loading {agencyName} Portfolio Data...</p>
        </div>
      ) : (
        <>
          {/* Agency KPI Summary Cards */}
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3.5 mb-6">
            <StatCard
              title="My Projects"
              value={summary.my_projects || 0}
              subtitle="Agency Portfolio"
              icon={FolderKanban}
              colorScheme="blue"
            />
            <StatCard
              title="Land Required"
              value={summary.land_required || '0.00'}
              unit="Ha"
              subtitle="Total RoW"
              icon={MapPin}
              colorScheme="orange"
            />
            <StatCard
              title="Land Acquired"
              value={summary.land_acquired || '0.00'}
              unit="Ha"
              subtitle="Handed Over"
              icon={CheckCircle}
              colorScheme="green"
            />
            <StatCard
              title="Acquisition %"
              value={`${summary.acquisition_percentage || '0.0'}%`}
              subtitle="RoW Possession"
              icon={TrendingUp}
              colorScheme="orange"
            />
            <StatCard
              title="Projects On Track"
              value={summary.projects_on_track || 0}
              subtitle="Adhering to Timeline"
              icon={CheckCircle}
              colorScheme="green"
            />
            <StatCard
              title="Delayed Projects"
              value={summary.delayed_projects || 0}
              subtitle="Bottlenecks"
              icon={AlertTriangle}
              colorScheme="red"
            />
          </div>

          {/* Agency Projects & Milestone Tracking */}
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
            
            {/* Left: Agency Projects Table */}
            <div className="lg:col-span-8 space-y-6">
              <DataTable
                title={`Executing Projects Managed by ${agencyName}`}
                columns={projectColumns}
                data={projects}
                itemsPerPage={6}
                searchPlaceholder="Search agency project..."
              />
            </div>

            {/* Right: Milestone Timeline & Status */}
            <div className="lg:col-span-4 space-y-6">
              
              {/* Milestone Progress Tracker */}
              <div className="gov-card p-4">
                <div className="gov-card-header -mx-4 -mt-4 mb-4 text-[#D9531E]">
                  <div className="flex items-center gap-2">
                    <Flag className="w-4 h-4 text-orange-600" />
                    <span className="font-bold uppercase tracking-wide text-xs">
                      Key Statutory Milestones
                    </span>
                  </div>
                </div>

                <div className="space-y-4">
                  {milestones.map((ms, idx) => (
                    <div key={idx} className="space-y-1 text-xs">
                      <div className="flex justify-between items-center">
                        <span className="font-semibold text-slate-800">{ms.milestone}</span>
                        <span className="text-[11px] font-mono font-bold text-slate-700">{ms.progress}%</span>
                      </div>
                      <div className="w-full bg-slate-200 h-2 rounded-full overflow-hidden">
                        <div 
                          className={`h-full rounded-full ${
                            ms.progress === 100 ? 'bg-emerald-600' : 'bg-[#FF6B00]'
                          }`}
                          style={{ width: `${ms.progress}%` }}
                        ></div>
                      </div>
                      <div className="text-[10px] text-slate-500">{ms.name}</div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Recent Updates */}
              <div className="gov-card p-4">
                <div className="gov-card-header -mx-4 -mt-4 mb-4">
                  <div className="flex items-center gap-2">
                    <Activity className="w-4 h-4 text-slate-600" />
                    <span className="font-bold uppercase tracking-wide text-xs">
                      Recent Agency Activities
                    </span>
                  </div>
                </div>

                <div className="space-y-3 text-xs">
                  {recentActivities.map((act) => (
                    <div key={act.id} className="border-l-2 border-orange-500 pl-3 py-0.5">
                      <p className="text-slate-800 font-medium leading-snug">{act.message}</p>
                      <div className="text-[10px] text-slate-500 mt-0.5">{act.timestamp}</div>
                    </div>
                  ))}
                </div>
              </div>

            </div>

          </div>
        </>
      )}

      {/* Proposal Submission Modal */}
      <ProposalModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onProjectCreated={handleProjectCreated}
        user={user}
      />
    </DashboardLayout>
  );
}
