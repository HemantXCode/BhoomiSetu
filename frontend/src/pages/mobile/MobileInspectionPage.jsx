import React, { useState, useEffect, useRef } from 'react';
import { dashboardService } from '../../services/dashboardService';
import { fieldService } from '../../services/fieldService';
import { documentService } from '../../services/documentService';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';
import DashboardLayout from '../../components/layout/DashboardLayout';
import Breadcrumbs from '../../components/common/Breadcrumbs';
import StatCard from '../../components/common/StatCard';
import { 
  Camera, 
  MapPin, 
  Upload, 
  CheckCircle2, 
  Clock, 
  Smartphone, 
  RefreshCw, 
  AlertCircle, 
  FileCheck, 
  Navigation, 
  FileText, 
  ShieldCheck, 
  AlertTriangle,
  ExternalLink,
  Eye,
  Download,
  Image as ImageIcon,
  Check,
  X,
  Plus
} from 'lucide-react';

export default function MobileInspectionPage() {
  const { user } = useAuth();
  const { t } = useLanguage();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [activeTab, setActiveTab] = useState('uploads'); // 'uploads', 'tasks', 'visits', 'verifications', 'audit'
  const [selectedImage, setSelectedImage] = useState(null);
  const [selectedTask, setSelectedTask] = useState(null);
  const [remarks, setRemarks] = useState('');
  const [actionSuccess, setActionSuccess] = useState(null);
  const [actionError, setActionError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  const photoInputRef = useRef(null);
  const docInputRef = useRef(null);

  const isVerified = user?.identity_status === 'VERIFIED';

  const fetchStats = async (isBackground = false) => {
    try {
      if (!isBackground) setRefreshing(true);
      const res = await dashboardService.getDashboardStats();
      if (res.success && res.data) {
        setData(res.data);
        if (res.data.field_tasks?.length > 0 && !selectedTask) {
          setSelectedTask(res.data.field_tasks[0]);
        }
      }
    } catch (err) {
      console.error('Failed to load field officer stats:', err);
    } finally {
      if (!isBackground) {
        setLoading(false);
        setRefreshing(false);
      }
    }
  };

  useEffect(() => {
    fetchStats();
    // Live background polling every 6 seconds to capture real-time phone uploads
    const interval = setInterval(() => {
      fetchStats(true);
    }, 6000);
    return () => clearInterval(interval);
  }, []);

  const handlePhotoUpload = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!isVerified) {
      setActionError('❌ IDENTITY_VERIFICATION_REQUIRED: Official personnel identity verification is pending with District Authority.');
      return;
    }

    try {
      const formData = new FormData();
      formData.append('file', file);
      if (selectedTask?.task_id) {
        formData.append('related_entity_id', selectedTask.task_id);
      }

      const res = await fieldService.uploadPhoto(formData);
      if (res.success) {
        setActionSuccess(`📸 Photo '${file.name}' successfully uploaded and indexed in PostgreSQL.`);
        await fetchStats();
      }
    } catch (err) {
      console.error('Failed to upload photo:', err);
      setActionError('❌ Failed to upload photo.');
    } finally {
      setTimeout(() => { setActionSuccess(null); setActionError(null); }, 5000);
    }
  };

  const handleDocumentUpload = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    try {
      const formData = new FormData();
      formData.append('file', file);
      formData.append('related_entity', 'FIELD_TASK');
      if (selectedTask?.task_id) {
        formData.append('related_entity_id', selectedTask.task_id);
      }

      const res = await documentService.uploadDocument(formData);
      if (res.success) {
        setActionSuccess(`📄 Land Record document '${file.name}' successfully uploaded.`);
        await fetchStats();
      }
    } catch (err) {
      console.error('Failed to upload document:', err);
      setActionError('❌ Failed to upload document.');
    } finally {
      setTimeout(() => { setActionSuccess(null); setActionError(null); }, 5000);
    }
  };

  const handleVerifyTask = async (task) => {
    if (!task) return;
    try {
      setSubmitting(true);
      const res = await fieldService.submitVerification({
        task_id: task.task_id,
        verification_status: 'VERIFIED',
        remarks: remarks || `Boundary demarcated & verified on ground for ${task.survey_number}`
      });

      if (res.success) {
        setActionSuccess(`✅ Task ${task.task_id} successfully verified & forwarded to CALA.`);
        setRemarks('');
        await fetchStats();
      }
    } catch (err) {
      console.error('Failed to submit verification:', err);
      setActionError('❌ Verification submission failed.');
    } finally {
      setSubmitting(false);
      setTimeout(() => { setActionSuccess(null); setActionError(null); }, 5000);
    }
  };

  const summary = data?.summary || {};
  const tasks = data?.field_tasks || [];
  const fieldVisits = data?.field_visits || [];
  const fieldVerifications = data?.field_verifications || [];
  const mobileUploads = data?.uploaded_photos || [];
  const recentActivities = data?.recent_activities || [];
  const districtName = data?.district_name || user?.district_name || 'Pune Division';

  return (
    <DashboardLayout>
      <Breadcrumbs items={[{ label: t('nav.fieldOperations') }, { label: t('nav.mobileInspection') }]} />

      {/* Hidden file inputs */}
      <input 
        type="file" 
        ref={photoInputRef} 
        onChange={handlePhotoUpload} 
        accept="image/*" 
        className="hidden" 
      />
      <input 
        type="file" 
        ref={docInputRef} 
        onChange={handleDocumentUpload} 
        accept=".pdf,.png,.jpg,.jpeg" 
        className="hidden" 
      />

      {/* Header Banner */}
      <div className="bg-white border border-slate-200 p-4 rounded mb-5 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
        <div>
          <div className="flex items-center gap-2">
            <span className="bg-[#FF6B00] text-white text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider flex items-center gap-1">
              <Smartphone className="w-3 h-3" />
              {t('field.mobileTerminal')}
            </span>
            <span className={`text-[10px] font-bold px-2 py-0.5 rounded flex items-center gap-1 ${
              isVerified 
                ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' 
                : 'bg-amber-100 text-amber-800 border border-amber-300'
            }`}>
              {isVerified ? <ShieldCheck className="w-3 h-3 text-emerald-600" /> : <AlertTriangle className="w-3 h-3 text-amber-600" />}
              {t('common.status')}: {user?.identity_status || 'VERIFIED'}
            </span>
            {user?.official_id_masked && (
              <span className="text-[10px] font-mono bg-slate-100 text-slate-700 px-2 py-0.5 rounded border border-slate-200">
                Official ID: {user.official_id_masked}
              </span>
            )}
          </div>
          <h2 className="text-lg sm:text-xl font-bold text-slate-900 mt-1">
            {t('field.hubTitle')}
          </h2>
          <p className="text-xs text-slate-600">
            {t('field.officer')} <span className="font-bold text-slate-800">{user?.name}</span> • {user?.department || 'Department of Land Revenue'}
          </p>
        </div>

        <div className="flex items-center gap-2 w-full sm:w-auto">
          <button
            onClick={() => fetchStats(false)}
            disabled={refreshing}
            className="gov-btn-secondary text-xs flex items-center gap-1.5 cursor-pointer"
            title="Refresh latest records"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${refreshing ? 'animate-spin text-orange-600' : ''}`} />
            <span>{refreshing ? t('common.syncing') : t('common.sync')}</span>
          </button>
        </div>
      </div>

      {actionSuccess && (
        <div className="mb-4 p-3 bg-emerald-50 border border-emerald-300 text-emerald-900 rounded text-xs flex items-center gap-2 font-medium">
          <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
          <span>{actionSuccess}</span>
        </div>
      )}

      {actionError && (
        <div className="mb-4 p-3 bg-rose-50 border border-rose-300 text-rose-900 rounded text-xs flex items-center gap-2 font-medium">
          <AlertCircle className="w-4 h-4 text-rose-600 shrink-0" />
          <span>{actionError}</span>
        </div>
      )}

      {loading ? (
        <div className="py-16 text-center">
          <div className="w-8 h-8 border-3 border-orange-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="mt-3 text-xs font-semibold text-slate-600">{t('common.loading')}</p>
        </div>
      ) : (
        <>
          {/* KPI Summary Cards */}
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-2.5 mb-5">
            <StatCard
              title={t('field.todaysTasks')}
              value={summary.todays_tasks ?? tasks.length}
              subtitle="Assigned in PG"
              icon={Clock}
              colorScheme="orange"
            />
            <StatCard
              title={t('field.pendingVerification')}
              value={summary.pending_verification ?? 0}
              subtitle="On-Site Queue"
              icon={AlertCircle}
              colorScheme="amber"
            />
            <StatCard
              title={t('field.submittedVerifications')}
              value={summary.completed_verification ?? 0}
              subtitle="Sent to CALA"
              icon={CheckCircle2}
              colorScheme="green"
            />
            <StatCard
              title={t('field.mobilePhotos')}
              value={summary.uploaded_photos_count ?? 0}
              subtitle="JPEG Evidence"
              icon={Camera}
              colorScheme="blue"
            />
            <StatCard
              title={t('field.landRecords')}
              value={summary.uploaded_documents_count ?? 0}
              subtitle="7/12 Extracts"
              icon={FileText}
              colorScheme="indigo"
            />
            <StatCard
              title={t('field.fieldVisits')}
              value={summary.total_field_visits ?? 0}
              subtitle="GNSS Sessions"
              icon={MapPin}
              colorScheme="slate"
            />
          </div>

          {/* Navigation Tabs */}
          <div className="flex border-b border-slate-200 mb-5 overflow-x-auto">
            <button
              onClick={() => setActiveTab('uploads')}
              className={`pb-2.5 px-4 text-xs font-bold whitespace-nowrap transition-colors flex items-center gap-1.5 cursor-pointer ${
                activeTab === 'uploads'
                  ? 'text-orange-600 border-b-2 border-orange-600'
                  : 'text-slate-500 hover:text-slate-800'
              }`}
            >
              <Smartphone className="w-3.5 h-3.5" />
              {t('field.mobileUploadsTab')} ({mobileUploads.length})
            </button>
            <button
              onClick={() => setActiveTab('tasks')}
              className={`pb-2.5 px-4 text-xs font-bold whitespace-nowrap transition-colors flex items-center gap-1.5 cursor-pointer ${
                activeTab === 'tasks'
                  ? 'text-orange-600 border-b-2 border-orange-600'
                  : 'text-slate-500 hover:text-slate-800'
              }`}
            >
              <FileCheck className="w-3.5 h-3.5" />
              {t('field.assignedTasksTab')} ({tasks.length})
            </button>
            <button
              onClick={() => setActiveTab('visits')}
              className={`pb-2.5 px-4 text-xs font-bold whitespace-nowrap transition-colors flex items-center gap-1.5 cursor-pointer ${
                activeTab === 'visits'
                  ? 'text-orange-600 border-b-2 border-orange-600'
                  : 'text-slate-500 hover:text-slate-800'
              }`}
            >
              <Navigation className="w-3.5 h-3.5" />
              {t('field.fieldVisitsTab')} ({fieldVisits.length})
            </button>
            <button
              onClick={() => setActiveTab('verifications')}
              className={`pb-2.5 px-4 text-xs font-bold whitespace-nowrap transition-colors flex items-center gap-1.5 cursor-pointer ${
                activeTab === 'verifications'
                  ? 'text-orange-600 border-b-2 border-orange-600'
                  : 'text-slate-500 hover:text-slate-800'
              }`}
            >
              <CheckCircle2 className="w-3.5 h-3.5" />
              {t('field.submittedTab')} ({fieldVerifications.length})
            </button>
            <button
              onClick={() => setActiveTab('audit')}
              className={`pb-2.5 px-4 text-xs font-bold whitespace-nowrap transition-colors flex items-center gap-1.5 cursor-pointer ${
                activeTab === 'audit'
                  ? 'text-orange-600 border-b-2 border-orange-600'
                  : 'text-slate-500 hover:text-slate-800'
              }`}
            >
              <Clock className="w-3.5 h-3.5" />
              {t('field.auditTrailTab')} ({recentActivities.length})
            </button>
          </div>

          {/* TAB 1: RECENT MOBILE UPLOADS & EVIDENCE */}
          {activeTab === 'uploads' && (
            <div className="gov-card p-4">
              <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2 mb-4 pb-3 border-b border-slate-200">
                <div>
                  <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wide flex items-center gap-2">
                    <Camera className="w-4 h-4 text-orange-600" />
                    {t('field.recentMobileUploads')}
                  </h3>
                  <p className="text-xs text-slate-500 mt-0.5">
                    Live media files uploaded from the physical phone or web terminal and indexed in Supabase PostgreSQL.
                  </p>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => photoInputRef.current?.click()}
                    className="gov-btn-secondary text-xs flex items-center gap-1 cursor-pointer"
                  >
                    <Upload className="w-3 h-3" />
                    <span>{t('field.uploadPhoto')}</span>
                  </button>
                  <button
                    onClick={() => docInputRef.current?.click()}
                    className="gov-btn-secondary text-xs flex items-center gap-1 cursor-pointer"
                  >
                    <FileText className="w-3 h-3" />
                    <span>{t('field.uploadDoc')}</span>
                  </button>
                </div>
              </div>

              {mobileUploads.length > 0 ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3.5">
                  {mobileUploads.map((item) => (
                    <div 
                      key={item.id} 
                      className="border border-slate-200 rounded p-3 bg-slate-50 hover:bg-white hover:border-orange-300 transition-all flex flex-col justify-between"
                    >
                      <div>
                        <div className="flex items-center justify-between mb-2">
                          <span className={`text-[10px] font-bold px-2 py-0.5 rounded flex items-center gap-1 ${
                            item.upload_type === 'PHOTO'
                              ? 'bg-blue-100 text-blue-800 border border-blue-200'
                              : 'bg-indigo-100 text-indigo-800 border border-indigo-200'
                          }`}>
                            {item.upload_type === 'PHOTO' ? <ImageIcon className="w-3 h-3" /> : <FileText className="w-3 h-3" />}
                            {item.upload_type}
                          </span>
                          <span className="text-[10px] font-mono text-slate-500 bg-white px-1.5 py-0.5 rounded border border-slate-200">
                            {item.document_id}
                          </span>
                        </div>

                        {item.upload_type === 'PHOTO' ? (
                          <div className="mb-2 h-32 w-full bg-slate-200 rounded overflow-hidden relative group cursor-pointer" onClick={() => setSelectedImage(item.url)}>
                            <img 
                              src={item.url} 
                              alt={item.file_name}
                              className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                              onError={(e) => { e.target.src = 'https://placehold.co/400x300?text=Uploaded+Evidence'; }}
                            />
                            <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center text-white text-xs font-semibold gap-1">
                              <Eye className="w-4 h-4" /> View Full Image
                            </div>
                          </div>
                        ) : (
                          <div className="mb-2 h-32 w-full bg-indigo-50 border border-indigo-100 rounded flex flex-col items-center justify-center p-3 text-center">
                            <FileText className="w-8 h-8 text-indigo-600 mb-1" />
                            <span className="text-xs font-bold text-slate-800 line-clamp-1">{item.file_name}</span>
                            <span className="text-[10px] text-slate-500 mt-0.5">{item.file_size ? `${(item.file_size / 1024).toFixed(1)} KB` : 'PDF Extract'}</span>
                          </div>
                        )}

                        <div className="space-y-1 text-xs">
                          <div className="font-semibold text-slate-800 truncate" title={item.file_name}>
                            {item.file_name}
                          </div>
                          <div className="text-[11px] text-slate-500 flex items-center justify-between">
                            <span>Uploaded By:</span>
                            <span className="font-medium text-slate-700">{item.uploaded_by_name}</span>
                          </div>
                          <div className="text-[11px] text-slate-500 flex items-center justify-between">
                            <span>Timestamp:</span>
                            <span className="font-mono text-slate-600">{item.created_at}</span>
                          </div>
                        </div>
                      </div>

                      <div className="mt-3 pt-2.5 border-t border-slate-200 flex items-center justify-between">
                        <span className="text-[10px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200 flex items-center gap-1">
                          <Check className="w-2.5 h-2.5" /> PERSISTED
                        </span>
                        <a
                          href={item.url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="text-xs text-orange-600 hover:text-orange-700 font-semibold flex items-center gap-1 hover:underline"
                        >
                          <ExternalLink className="w-3 h-3" /> Open File
                        </a>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="py-12 text-center bg-slate-50 border border-dashed border-slate-200 rounded">
                  <Smartphone className="w-8 h-8 text-slate-400 mx-auto mb-2" />
                  <h4 className="text-xs font-bold text-slate-700">No Mobile Uploads Recorded Yet</h4>
                  <p className="text-[11px] text-slate-500 mt-1 max-w-sm mx-auto">
                    Evidence captured from the physical mobile app or uploaded via this terminal will appear here in real time.
                  </p>
                </div>
              )}
            </div>
          )}

          {/* TAB 2: ASSIGNED TASKS */}
          {activeTab === 'tasks' && (
            <div className="gov-card p-4">
              <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wide mb-3 flex items-center gap-2">
                <FileCheck className="w-4 h-4 text-orange-600" />
                Assigned Operational Field Tasks
              </h3>
              {tasks.length > 0 ? (
                <div className="overflow-x-auto">
                  <table className="gov-table">
                    <thead>
                      <tr>
                        <th>Task ID</th>
                        <th>Task Type</th>
                        <th>Project / Corridor</th>
                        <th>Village & ULPIN</th>
                        <th>Priority</th>
                        <th>Status</th>
                        <th>Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {tasks.map((t) => (
                        <tr key={t.id || t.task_id}>
                          <td className="font-mono font-bold text-orange-600">{t.id}</td>
                          <td className="font-medium text-slate-800">{t.task_type}</td>
                          <td className="text-slate-600">{t.project_name}</td>
                          <td className="text-slate-700">{t.village}</td>
                          <td>
                            <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${
                              t.priority === 'HIGH' ? 'bg-red-100 text-red-800' : 'bg-blue-100 text-blue-800'
                            }`}>
                              {t.priority || 'NORMAL'}
                            </span>
                          </td>
                          <td>
                            <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${
                              t.status === 'SUBMITTED' 
                                ? 'bg-emerald-100 text-emerald-800' 
                                : 'bg-amber-100 text-amber-800'
                            }`}>
                              {t.status}
                            </span>
                          </td>
                          <td>
                            <button
                              onClick={() => {
                                setSelectedTask(t);
                                setActiveTab('uploads');
                              }}
                              className="text-xs text-orange-600 hover:text-orange-800 font-semibold underline cursor-pointer"
                            >
                              Attach Evidence
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <div className="py-8 text-center text-xs text-slate-500">
                  No assigned tasks in database.
                </div>
              )}
            </div>
          )}

          {/* TAB 3: FIELD VISITS & GPS LOGS */}
          {activeTab === 'visits' && (
            <div className="gov-card p-4">
              <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wide mb-3 flex items-center gap-2">
                <Navigation className="w-4 h-4 text-orange-600" />
                Field Visit Sessions & GNSS Calibration
              </h3>
              {fieldVisits.length > 0 ? (
                <div className="overflow-x-auto">
                  <table className="gov-table">
                    <thead>
                      <tr>
                        <th>Visit ID</th>
                        <th>Task #</th>
                        <th>Task Description</th>
                        <th>GNSS Coordinates</th>
                        <th>Start Timestamp</th>
                        <th>Status</th>
                      </tr>
                    </thead>
                    <tbody>
                      {fieldVisits.map((v) => (
                        <tr key={v.id || v.visit_id}>
                          <td className="font-mono font-bold text-slate-900">#{v.visit_id || v.id}</td>
                          <td className="font-mono text-orange-600">#{v.task_id}</td>
                          <td className="text-slate-800 font-medium">{v.task_type}</td>
                          <td className="font-mono text-xs text-slate-700">
                            {v.gps_display}
                          </td>
                          <td className="text-xs text-slate-600">{v.visit_start}</td>
                          <td>
                            <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-emerald-100 text-emerald-800">
                              {v.status}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <div className="py-8 text-center text-xs text-slate-500">
                  No field visits initiated yet.
                </div>
              )}
            </div>
          )}

          {/* TAB 4: SUBMITTED VERIFICATIONS */}
          {activeTab === 'verifications' && (
            <div className="gov-card p-4">
              <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wide mb-3 flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-orange-600" />
                Submitted Field Verifications (Forwarded to CALA)
              </h3>
              {fieldVerifications.length > 0 ? (
                <div className="space-y-3">
                  {fieldVerifications.map((vf) => (
                    <div key={vf.id || vf.verification_id} className="p-3.5 border border-slate-200 rounded bg-slate-50">
                      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2 mb-2">
                        <div className="flex items-center gap-2">
                          <span className="bg-emerald-600 text-white text-xs font-bold px-2 py-0.5 rounded">
                            Verification #{vf.verification_id || vf.id}
                          </span>
                          <span className="font-mono text-xs font-semibold text-slate-800">
                            Task #{vf.task_id} • Visit #{vf.visit_id}{vf.ulpin ? ` • ${vf.ulpin}` : ''}
                          </span>
                        </div>
                        <span className="text-xs text-slate-500 font-mono">
                          Submitted: {vf.verified_at}
                        </span>
                      </div>
                      <p className="text-xs text-slate-700 bg-white p-2.5 rounded border border-slate-200 mt-2">
                        <span className="font-semibold text-slate-900">Survey Remarks:</span> {vf.remarks || 'Ground survey verified with boundary demarcation.'}
                      </p>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="py-8 text-center text-xs text-slate-500">
                  No submitted field verifications recorded yet.
                </div>
              )}
            </div>
          )}

          {/* TAB 5: LIVE AUDIT TRAIL */}
          {activeTab === 'audit' && (
            <div className="gov-card p-4">
              <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wide mb-3 flex items-center gap-2">
                <Clock className="w-4 h-4 text-orange-600" />
                Live PostgreSQL Audit Log Activity Feed
              </h3>
              {recentActivities.length > 0 ? (
                <div className="space-y-2">
                  {recentActivities.map((act) => (
                    <div key={act.id} className="p-2.5 border border-slate-200 rounded bg-slate-50 flex items-center justify-between text-xs">
                      <div className="flex items-center gap-2">
                        <span className="w-2 h-2 rounded-full bg-emerald-500 shrink-0"></span>
                        <span className="font-bold text-slate-800">{act.action}</span>
                        <span className="text-slate-600 hidden sm:inline">{act.message}</span>
                      </div>
                      <div className="flex items-center gap-3">
                        <span className="text-[11px] text-slate-500">{act.user}</span>
                        <span className="font-mono text-[11px] text-slate-400">{act.timestamp}</span>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="py-8 text-center text-xs text-slate-500">
                  No audit activity recorded.
                </div>
              )}
            </div>
          )}
        </>
      )}

      {/* Image Modal Preview */}
      {selectedImage && (
        <div className="fixed inset-0 z-50 bg-black/80 flex items-center justify-center p-4" onClick={() => setSelectedImage(null)}>
          <div className="bg-white rounded max-w-2xl w-full p-3 relative" onClick={(e) => e.stopPropagation()}>
            <button 
              onClick={() => setSelectedImage(null)}
              className="absolute top-2 right-2 p-1 bg-slate-200 hover:bg-slate-300 rounded text-slate-700 cursor-pointer"
            >
              <X className="w-4 h-4" />
            </button>
            <h4 className="text-xs font-bold text-slate-800 mb-2">Ground Evidence Photo Preview</h4>
            <div className="max-h-[70vh] overflow-hidden rounded bg-slate-900 flex items-center justify-center">
              <img src={selectedImage} alt="Preview" className="max-h-[70vh] object-contain" />
            </div>
            <div className="mt-2 text-right">
              <a 
                href={selectedImage} 
                target="_blank" 
                rel="noopener noreferrer" 
                className="gov-btn-secondary text-xs inline-flex items-center gap-1 cursor-pointer"
              >
                <Download className="w-3.5 h-3.5" /> Download Full Resolution
              </a>
            </div>
          </div>
        </div>
      )}
    </DashboardLayout>
  );
}
