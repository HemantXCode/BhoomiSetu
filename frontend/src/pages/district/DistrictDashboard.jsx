import React, { useState, useEffect } from 'react';
import { dashboardService } from '../../services/dashboardService';
import { userService } from '../../services/userService';
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
  ExternalLink,
  Camera,
  FileText,
  X,
  Navigation,
  CheckCircle2,
  ShieldCheck,
  UserCheck,
  AlertTriangle,
  History
} from 'lucide-react';

export default function DistrictDashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [activeTab, setActiveTab] = useState('queue'); // 'queue', 'personnel', 'projects', 'audit'
  const [selectedVerification, setSelectedVerification] = useState(null);
  
  // Personnel state
  const [officers, setOfficers] = useState([]);
  const [officersLoading, setOfficersLoading] = useState(false);
  const [actionMessage, setActionMessage] = useState(null);

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

  const fetchPersonnel = async () => {
    try {
      setOfficersLoading(true);
      const res = await userService.getUsers({ role: 'FIELD_OFFICER' });
      if (res.success && res.data) {
        setOfficers(res.data);
      }
    } catch (err) {
      console.error('Failed to load personnel:', err);
    } finally {
      setOfficersLoading(false);
    }
  };

  useEffect(() => {
    fetchStats();
    fetchPersonnel();
  }, []);

  const handleVerifyOfficer = async (userId, decision) => {
    try {
      const res = await userService.verifyUser(userId, {
        decision,
        notes: `Identity credentials reviewed and ${decision.toLowerCase()} by District Competent Authority (CALA).`
      });
      if (res.success) {
        setActionMessage(`✅ Officer identity successfully marked as ${decision}!`);
        await fetchPersonnel();
        await fetchStats();
      }
    } catch (err) {
      console.error('Failed to verify officer:', err);
      setActionMessage('❌ Failed to update officer identity status.');
    } finally {
      setTimeout(() => setActionMessage(null), 5000);
    }
  };

  const summary = data?.summary || {};
  const districtName = data?.district_name || 'Pune District Collectorate';
  const stateName = data?.state_name || 'Maharashtra';
  const projects = data?.projects_list || [];
  const fieldQueue = data?.field_verification_queue || [];
  const activities = data?.recent_activities || [];

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
      header: 'Verification ID / Parcel',
      accessor: 'id',
      render: (row) => (
        <div>
          <span className="font-bold font-mono text-orange-700 block">{row.id}</span>
          <span className="text-xs text-slate-800 font-semibold">{row.parcel_no}</span>
        </div>
      )
    },
    {
      header: 'Village / Tehsil',
      accessor: 'village',
      render: (row) => <span className="font-medium text-slate-800">{row.village}</span>
    },
    {
      header: 'Project Corridor',
      accessor: 'project_name',
      render: (row) => <span className="text-xs text-slate-700">{row.project_name}</span>
    },
    {
      header: 'Assigned Field Officer',
      accessor: 'officer',
      render: (row) => <span className="text-xs font-semibold text-slate-800">{row.officer}</span>
    },
    {
      header: 'Submission Status',
      accessor: 'status',
      render: (row) => (
        <span className="bg-emerald-100 text-emerald-800 border border-emerald-300 text-[11px] font-bold px-2 py-0.5 rounded flex items-center gap-1 w-max">
          <CheckCircle2 className="w-3 h-3 text-emerald-600" />
          {row.status}
        </span>
      )
    },
    {
      header: 'Inspection Details',
      accessor: 'action',
      render: (row) => (
        <button
          onClick={() => setSelectedVerification(row)}
          className="text-xs text-[#FF6B00] hover:text-orange-700 font-semibold underline flex items-center gap-1 cursor-pointer"
        >
          <span>View Findings</span>
          <ExternalLink className="w-3 h-3" />
        </button>
      )
    }
  ];

  return (
    <DashboardLayout>
      <Breadcrumbs items={[{ label: 'District Authority', path: '/district/dashboard' }, { label: `${districtName} Portal` }]} />

      {/* District Header Banner */}
      <div className="bg-white border border-slate-200 p-5 rounded mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <div className="flex items-center gap-2">
            <span className="bg-[#FF6B00] text-white text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider">
              District Competent Authority (CALA)
            </span>
            <span className="text-xs text-slate-500 font-medium">• {districtName}, {stateName}</span>
          </div>
          <h2 className="text-xl sm:text-2xl font-bold text-slate-900 mt-1">
            {districtName} Land Acquisition & Monitoring Portal
          </h2>
          <p className="text-xs text-slate-600">
            Real-time synchronization with Supabase PostgreSQL • Official Identity Lifecycle & On-ground Joint Measurement Verifications.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => { fetchStats(); fetchPersonnel(); }}
            disabled={refreshing}
            className="gov-btn-secondary text-xs"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${refreshing ? 'animate-spin text-orange-600' : ''}`} />
            <span>{refreshing ? 'Refreshing...' : 'Refresh Live DB'}</span>
          </button>
        </div>
      </div>

      {actionMessage && (
        <div className="mb-4 p-3 bg-emerald-50 border border-emerald-300 text-emerald-900 rounded text-xs font-semibold flex items-center gap-2">
          <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
          <span>{actionMessage}</span>
        </div>
      )}

      {loading ? (
        <div className="py-16 text-center">
          <div className="w-8 h-8 border-3 border-orange-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="mt-3 text-xs font-semibold text-slate-600">Loading {districtName} Operational Records from Supabase PostgreSQL...</p>
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
              title="Verified Submissions"
              value={summary.submitted_verification || summary.total_verifications || 0}
              subtitle="Officer Submitted"
              icon={FileCheck2}
              colorScheme="green"
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

          {/* Tab Navigation */}
          <div className="flex border-b border-slate-200 mb-5 text-xs font-bold gap-2">
            <button
              onClick={() => setActiveTab('queue')}
              className={`pb-2.5 px-3 border-b-2 transition-colors cursor-pointer flex items-center gap-1.5 ${
                activeTab === 'queue'
                  ? 'border-[#FF6B00] text-[#FF6B00]'
                  : 'border-transparent text-slate-600 hover:text-slate-900'
              }`}
            >
              <ClipboardList className="w-4 h-4" />
              <span>Field Verification Queue ({fieldQueue.length})</span>
            </button>

            <button
              onClick={() => setActiveTab('personnel')}
              className={`pb-2.5 px-3 border-b-2 transition-colors cursor-pointer flex items-center gap-1.5 ${
                activeTab === 'personnel'
                  ? 'border-[#FF6B00] text-[#FF6B00]'
                  : 'border-transparent text-slate-600 hover:text-slate-900'
              }`}
            >
              <ShieldCheck className="w-4 h-4" />
              <span>Field Personnel & Identity Verification ({officers.length})</span>
            </button>

            <button
              onClick={() => setActiveTab('projects')}
              className={`pb-2.5 px-3 border-b-2 transition-colors cursor-pointer flex items-center gap-1.5 ${
                activeTab === 'projects'
                  ? 'border-[#FF6B00] text-[#FF6B00]'
                  : 'border-transparent text-slate-600 hover:text-slate-900'
              }`}
            >
              <Building2 className="w-4 h-4" />
              <span>Jurisdictional Projects ({projects.length})</span>
            </button>

            <button
              onClick={() => setActiveTab('audit')}
              className={`pb-2.5 px-3 border-b-2 transition-colors cursor-pointer flex items-center gap-1.5 ${
                activeTab === 'audit'
                  ? 'border-[#FF6B00] text-[#FF6B00]'
                  : 'border-transparent text-slate-600 hover:text-slate-900'
              }`}
            >
              <History className="w-4 h-4" />
              <span>Audit Trail Feed ({activities.length})</span>
            </button>
          </div>

          {/* TAB 1: FIELD QUEUE */}
          {activeTab === 'queue' && (
            <DataTable
              title={`Live Field Officer Submissions & Joint Measurement Queue (${districtName})`}
              columns={fieldQueueColumns}
              data={fieldQueue}
              itemsPerPage={5}
              searchPlaceholder="Search parcel or village..."
            />
          )}

          {/* TAB 2: FIELD PERSONNEL & IDENTITY VERIFICATION */}
          {activeTab === 'personnel' && (
            <div className="gov-card p-4 sm:p-5">
              <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center pb-3 mb-4 border-b border-slate-200 gap-2">
                <div>
                  <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                    <UserCheck className="w-4 h-4 text-orange-600" />
                    Government Field Personnel Identity Lifecycle & Verification
                  </h3>
                  <p className="text-xs text-slate-500">
                    District Competent Authority (CALA) official authorization required before field officers can conduct on-ground inspections.
                  </p>
                </div>

                <span className="text-[11px] bg-slate-100 text-slate-700 px-2 py-1 rounded font-mono">
                  Total Officers: {officers.length}
                </span>
              </div>

              {officersLoading ? (
                <div className="py-8 text-center text-xs text-slate-500">Loading personnel records...</div>
              ) : officers.length === 0 ? (
                <div className="py-8 text-center text-xs text-slate-500">No field personnel registered in this district.</div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full text-xs text-left border-collapse">
                    <thead>
                      <tr className="bg-slate-100 border-b border-slate-200 text-slate-700 font-bold uppercase text-[10px]">
                        <th className="p-2.5">Officer Name & ID</th>
                        <th className="p-2.5">Department / Designation</th>
                        <th className="p-2.5">Official ID (Masked)</th>
                        <th className="p-2.5">Identity Status</th>
                        <th className="p-2.5 text-right">CALA Authorization Action</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-200">
                      {officers.map((off) => {
                        const isPending = off.identity_status === 'PENDING' || off.identity_status === 'UNDER_REVIEW';
                        const isVerified = off.identity_status === 'VERIFIED';
                        return (
                          <tr key={off.id} className="hover:bg-slate-50">
                            <td className="p-2.5">
                              <span className="font-bold text-slate-900 block">{off.name}</span>
                              <span className="text-[11px] text-slate-500">{off.email}</span>
                            </td>
                            <td className="p-2.5">
                              <span className="font-medium text-slate-800 block">{off.department || 'Department of Revenue'}</span>
                              <span className="text-[10px] text-slate-500">{off.designation || 'Field Officer'}</span>
                            </td>
                            <td className="p-2.5 font-mono text-slate-800 font-semibold">
                              {off.official_id_masked || 'TEST-OFFICER-001'}
                            </td>
                            <td className="p-2.5">
                              <span className={`text-[10px] font-bold px-2 py-0.5 rounded inline-flex items-center gap-1 ${
                                isVerified 
                                  ? 'bg-emerald-100 text-emerald-800 border border-emerald-300'
                                  : isPending
                                  ? 'bg-amber-100 text-amber-800 border border-amber-300'
                                  : 'bg-rose-100 text-rose-800 border border-rose-300'
                              }`}>
                                {isVerified ? <CheckCircle2 className="w-3 h-3 text-emerald-600" /> : <AlertTriangle className="w-3 h-3 text-amber-600" />}
                                {off.identity_status}
                              </span>
                            </td>
                            <td className="p-2.5 text-right space-x-1.5">
                              {isPending ? (
                                <>
                                  <button
                                    onClick={() => handleVerifyOfficer(off.id, 'VERIFIED')}
                                    className="bg-emerald-600 hover:bg-emerald-700 text-white px-2.5 py-1 rounded text-[11px] font-bold cursor-pointer"
                                  >
                                    Verify Identity
                                  </button>
                                  <button
                                    onClick={() => handleVerifyOfficer(off.id, 'REJECTED')}
                                    className="bg-rose-600 hover:bg-rose-700 text-white px-2.5 py-1 rounded text-[11px] font-bold cursor-pointer"
                                  >
                                    Reject
                                  </button>
                                </>
                              ) : isVerified ? (
                                <button
                                  onClick={() => handleVerifyOfficer(off.id, 'SUSPENDED')}
                                  className="bg-slate-200 hover:bg-rose-100 hover:text-rose-800 text-slate-700 px-2 py-1 rounded text-[10px] font-semibold cursor-pointer"
                                >
                                  Suspend Access
                                </button>
                              ) : (
                                <button
                                  onClick={() => handleVerifyOfficer(off.id, 'VERIFIED')}
                                  className="bg-emerald-600 hover:bg-emerald-700 text-white px-2 py-1 rounded text-[10px] font-bold cursor-pointer"
                                >
                                  Re-Authorize
                                </button>
                              )}
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )}

          {/* TAB 3: JURISDICTIONAL PROJECTS */}
          {activeTab === 'projects' && (
            <DataTable
              title={`Jurisdictional Projects in ${districtName} District`}
              columns={projectColumns}
              data={projects}
              itemsPerPage={5}
              searchPlaceholder="Search project..."
            />
          )}

          {/* TAB 4: AUDIT TRAIL FEED */}
          {activeTab === 'audit' && (
            <div className="gov-card p-4 sm:p-5">
              <h3 className="text-sm font-bold text-slate-900 mb-3 pb-2 border-b border-slate-200 flex items-center gap-2">
                <History className="w-4 h-4 text-orange-600" />
                Immutable PostgreSQL Audit Trail Log
              </h3>
              {activities.length === 0 ? (
                <div className="py-8 text-center text-xs text-slate-500">No audit activity recorded yet.</div>
              ) : (
                <div className="space-y-2.5 text-xs">
                  {activities.map((act) => (
                    <div key={act.id} className="p-3 bg-slate-50 border border-slate-200 rounded flex justify-between items-center">
                      <div>
                        <span className="font-bold text-slate-900 block">{act.message}</span>
                        <span className="text-[10px] text-slate-500">Actor: {act.user}</span>
                      </div>
                      <span className="text-[10px] text-slate-400 font-mono shrink-0">{act.timestamp}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

        </>
      )}

      {/* Field Inspection Detail Modal */}
      {selectedVerification && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto border border-slate-300 shadow-2xl p-6">
            <div className="flex justify-between items-start pb-3 border-b border-slate-200">
              <div>
                <span className="text-[10px] font-bold bg-orange-100 text-orange-800 px-2 py-0.5 rounded uppercase">
                  Field Inspection Submission Details
                </span>
                <h3 className="text-lg font-bold text-slate-900 mt-1">
                  {selectedVerification.parcel_no} • {selectedVerification.village}
                </h3>
                <p className="text-xs text-slate-600">{selectedVerification.project_name}</p>
              </div>
              <button 
                onClick={() => setSelectedVerification(null)}
                className="p-1 text-slate-400 hover:text-slate-700 rounded cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="mt-4 space-y-4 text-xs">
              {/* Field Officer & GPS */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 bg-slate-50 p-3 rounded border border-slate-200">
                <div>
                  <span className="text-slate-500 block text-[10px] uppercase font-bold">Field Officer</span>
                  <span className="font-semibold text-slate-900">{selectedVerification.officer}</span>
                </div>
                <div>
                  <span className="text-slate-500 block text-[10px] uppercase font-bold">Geo Coordinates</span>
                  <span className="font-mono text-slate-800 flex items-center gap-1 font-semibold">
                    <Navigation className="w-3 h-3 text-orange-600" />
                    {selectedVerification.latitude}° N, {selectedVerification.longitude}° E
                  </span>
                </div>
                <div>
                  <span className="text-slate-500 block text-[10px] uppercase font-bold">Verified At</span>
                  <span className="text-slate-700">{selectedVerification.verified_at || 'Just now'}</span>
                </div>
                <div>
                  <span className="text-slate-500 block text-[10px] uppercase font-bold">Client Event ID</span>
                  <span className="font-mono text-[10px] text-slate-600">{selectedVerification.client_event_id || 'N/A'}</span>
                </div>
              </div>

              {/* Checklist results */}
              <div>
                <span className="font-bold text-slate-800 uppercase block mb-1.5">Statutory Checklist Results</span>
                <div className="bg-slate-50 p-3 rounded border border-slate-200 space-y-1.5">
                  {selectedVerification.checklist_data ? (
                    Object.entries(selectedVerification.checklist_data).map(([k, v]) => (
                      <div key={k} className="flex justify-between items-center py-1 border-b border-slate-200/60 last:border-0">
                        <span className="text-slate-700 capitalize">{k.replace(/_/g, ' ')}:</span>
                        <span className="font-bold text-slate-900 font-mono">{String(v)}</span>
                      </div>
                    ))
                  ) : (
                    <div className="text-slate-500 italic">Standard statutory boundary verification confirmed.</div>
                  )}
                </div>
              </div>

              {/* Remarks */}
              <div>
                <span className="font-bold text-slate-800 uppercase block mb-1">Field Inspection Remarks</span>
                <div className="p-3 bg-amber-50/50 border border-amber-200 rounded text-slate-800 italic">
                  "{selectedVerification.remarks || 'Boundaries physically identified and verified on ground without any dispute.'}"
                </div>
              </div>

              {/* Attached Photos / Evidence */}
              {selectedVerification.photos && selectedVerification.photos.length > 0 && (
                <div>
                  <span className="font-bold text-slate-800 uppercase block mb-1.5 flex items-center gap-1">
                    <Camera className="w-3.5 h-3.5 text-orange-600" />
                    Attached Site Photos & Evidence ({selectedVerification.photos.length})
                  </span>
                  <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                    {selectedVerification.photos.map((ph, idx) => (
                      <a
                        key={idx}
                        href={ph.url}
                        target="_blank"
                        rel="noreferrer"
                        className="p-2 border border-slate-200 rounded bg-slate-50 hover:bg-orange-50 flex items-center gap-2 group transition-colors"
                      >
                        <FileText className="w-4 h-4 text-orange-600 shrink-0" />
                        <div className="overflow-hidden">
                          <span className="font-semibold text-slate-800 truncate block text-[11px] group-hover:text-orange-700">
                            {ph.name || `Photo #${idx + 1}`}
                          </span>
                          <span className="text-[9px] text-slate-500">Download Evidence</span>
                        </div>
                      </a>
                    ))}
                  </div>
                </div>
              )}
            </div>

            <div className="mt-5 pt-3 border-t border-slate-200 flex justify-end">
              <button
                onClick={() => setSelectedVerification(null)}
                className="gov-btn-secondary text-xs"
              >
                Close Details
              </button>
            </div>
          </div>
        </div>
      )}
    </DashboardLayout>
  );
}
