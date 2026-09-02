import React, { useState, useEffect } from 'react';
import { projectService } from '../../services/projectService';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';
import DashboardLayout from '../../components/layout/DashboardLayout';
import Breadcrumbs from '../../components/common/Breadcrumbs';
import StatusBadge from '../../components/common/StatusBadge';
import DataTable from '../../components/common/DataTable';
import ProposalModal from '../../components/forms/ProposalModal';
import { PlusCircle, RefreshCw, FolderKanban, Filter } from 'lucide-react';

export default function ProjectsList() {
  const { user } = useAuth();
  const { t } = useLanguage();
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [statusFilter, setStatusFilter] = useState('');

  const fetchProjects = async () => {
    try {
      setRefreshing(true);
      const res = await projectService.getProjects({ status: statusFilter || undefined });
      if (res.success && res.data) {
        setProjects(res.data);
      }
    } catch (err) {
      console.error('Failed to load projects:', err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchProjects();
  }, [statusFilter]);

  const canCreateProposal = user?.role === 'PROJECT_AGENCY' || user?.role === 'CENTRAL_MINISTRY';

  const columns = [
    {
      header: 'ID',
      accessor: 'id',
      className: 'font-mono text-center font-bold text-slate-700 w-16',
      render: (row) => `#${row.id}`
    },
    {
      header: t('projects.projectName'),
      accessor: 'project_name',
      render: (row) => (
        <div>
          <span className="font-bold text-slate-900 block">{row.project_name}</span>
          <span className="text-xs text-slate-500 leading-tight">
            {row.description ? row.description.slice(0, 90) + '...' : 'No description provided.'}
          </span>
        </div>
      )
    },
    {
      header: t('projects.agency'),
      accessor: 'agency_name',
      render: (row) => <span className="text-xs font-semibold text-slate-800">{row.agency_name}</span>
    },
    {
      header: t('projects.stateDistrict'),
      render: (row) => (
        <div className="text-xs">
          <span className="font-medium text-slate-800">{row.district_name || 'District'}</span>,{' '}
          <span className="text-slate-600 font-mono">({row.state_code || row.state_name})</span>
        </div>
      )
    },
    {
      header: t('projects.landRequiredHa'),
      accessor: 'proposed_area',
      className: 'text-right font-mono font-semibold',
      render: (row) => `${row.proposed_area} Ha`
    },
    {
      header: t('common.status'),
      accessor: 'status',
      render: (row) => <StatusBadge status={row.status} />
    }
  ];

  return (
    <DashboardLayout>
      <Breadcrumbs items={[{ label: t('projects.title') }]} />

      {/* Page Header */}
      <div className="bg-white border border-slate-200 p-5 rounded mb-6 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <div className="flex items-center gap-2">
            <span className="bg-[#FF6B00] text-white text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider flex items-center gap-1">
              <FolderKanban className="w-3 h-3" />
              {t('projects.title')}
            </span>
          </div>
          <h2 className="text-xl sm:text-2xl font-bold text-slate-900 mt-1">
            {t('projects.title')}
          </h2>
          <p className="text-xs text-slate-600">
            {t('projects.subtitle')}
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          {/* Status Filter */}
          <div className="flex items-center gap-1 bg-slate-100 px-2 py-1 rounded border border-slate-300 text-xs">
            <Filter className="w-3.5 h-3.5 text-slate-500" />
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="bg-transparent text-slate-800 font-medium outline-none cursor-pointer"
            >
              <option value="">{t('projects.allStatuses')}</option>
              <option value="PROPOSED">Proposed</option>
              <option value="SURVEY_IN_PROGRESS">Survey Active</option>
              <option value="NOTIFICATION_IN_PROGRESS">Notification Sec-4/11</option>
              <option value="AWARD_IN_PROGRESS">Award Determination</option>
              <option value="COMPENSATION_IN_PROGRESS">Compensation</option>
              <option value="POSSESSION_IN_PROGRESS">Possession Active</option>
            </select>
          </div>

          <button
            onClick={fetchProjects}
            disabled={refreshing}
            className="gov-btn-secondary text-xs cursor-pointer"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${refreshing ? 'animate-spin text-orange-600' : ''}`} />
            <span>{refreshing ? t('common.refreshing') : t('common.sync')}</span>
          </button>
        </div>
      </div>

      {/* Projects Table */}
      <div className="gov-card p-4 rounded">
        <DataTable
          columns={columns}
          data={projects}
          loading={loading}
          emptyMessage={t('projects.noProjects')}
        />
      </div>

      {/* Proposal Modal */}
      {isModalOpen && (
        <ProposalModal
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          onSuccess={() => {
            setIsModalOpen(false);
            fetchProjects();
          }}
        />
      )}
    </DashboardLayout>
  );
}
