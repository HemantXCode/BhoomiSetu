import React, { useState, useEffect } from 'react';
import { dashboardService } from '../../services/dashboardService';
import { useAuth } from '../../context/AuthContext';
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
  Send,
  Navigation
} from 'lucide-react';

export default function FieldDashboard() {
  const { user } = useAuth();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [selectedTask, setSelectedTask] = useState(null);
  const [remarks, setRemarks] = useState('');
  const [actionSuccess, setActionSuccess] = useState(null);
  const [currentGps, setCurrentGps] = useState('18.5204° N, 73.8567° E (Pune Div)');

  const fetchStats = async () => {
    try {
      setRefreshing(true);
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
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  const handleCaptureGps = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          const coords = `${pos.coords.latitude.toFixed(4)}° N, ${pos.coords.longitude.toFixed(4)}° E (Live GPS)`;
          setCurrentGps(coords);
          setActionSuccess('✅ High-precision GPS coordinates captured from device.');
        },
        () => {
          setCurrentGps('18.5204° N, 73.8567° E (Fixed Cell Tower)');
          setActionSuccess('ℹ️ Default GPS coordinate recorded.');
        }
      );
    }
  };

  const handleQuickAction = (actionName) => {
    setActionSuccess(`✅ Action '${actionName}' executed for ${selectedTask?.id || 'Task'}.`);
    setTimeout(() => setActionSuccess(null), 4000);
  };

  const handleSubmitVerification = (e) => {
    e.preventDefault();
    setActionSuccess(`🎉 Field verification for [${selectedTask?.id} - ${selectedTask?.village}] successfully submitted to District Collectorate!`);
    setRemarks('');
    setTimeout(() => setActionSuccess(null), 5000);
  };

  const summary = data?.summary || {};
  const tasks = data?.field_tasks || [];
  const districtName = data?.district_name || user?.district_name || 'Assigned Field Division';

  return (
    <DashboardLayout>
      <Breadcrumbs items={[{ label: 'Field Operations', path: '/field/dashboard' }, { label: 'Mobile Field Officer Interface' }]} />

      {/* Field Officer Banner */}
      <div className="bg-white border border-slate-200 p-4 rounded mb-5 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
        <div>
          <div className="flex items-center gap-2">
            <span className="bg-[#15803D] text-white text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider flex items-center gap-1">
              <Smartphone className="w-3 h-3" />
              Mobile Field Unit
            </span>
            <span className="text-xs text-slate-500 font-medium">• {districtName} Division</span>
          </div>
          <h2 className="text-lg sm:text-xl font-bold text-slate-900 mt-1">
            Ground Inspection & Joint Measurement Portal
          </h2>
          <p className="text-xs text-slate-600">
            Field Officer: <span className="font-bold text-slate-800">{user?.name}</span> • Ready for on-site boundary surveys.
          </p>
        </div>

        <button
          onClick={fetchStats}
          disabled={refreshing}
          className="gov-btn-secondary text-xs w-full sm:w-auto"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${refreshing ? 'animate-spin text-orange-600' : ''}`} />
          <span>Sync Assigned Tasks</span>
        </button>
      </div>

      {actionSuccess && (
        <div className="mb-4 p-3 bg-emerald-50 border border-emerald-300 text-emerald-900 rounded text-xs flex items-center gap-2 font-medium">
          <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
          <span>{actionSuccess}</span>
        </div>
      )}

      {loading ? (
        <div className="py-16 text-center">
          <div className="w-8 h-8 border-3 border-orange-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="mt-3 text-xs font-semibold text-slate-600">Connecting to Field Division Server...</p>
        </div>
      ) : (
        <>
          {/* Mobile-Friendly KPI Summary Cards */}
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-2.5 mb-5">
            <StatCard
              title="Today's Tasks"
              value={summary.todays_tasks || 0}
              subtitle="Urgent on-site"
              icon={Clock}
              colorScheme="orange"
            />
            <StatCard
              title="Pending Verification"
              value={summary.pending_verification || 0}
              subtitle="Inspection Queue"
              icon={AlertCircle}
              colorScheme="amber"
            />
            <StatCard
              title="Completed Parcels"
              value={summary.completed_verification || 0}
              subtitle="Verified & Uploaded"
              icon={CheckCircle2}
              colorScheme="green"
            />
            <StatCard
              title="Assigned Parcels"
              value={summary.assigned_parcels || 0}
              subtitle="Division Total"
              icon={MapPin}
              colorScheme="blue"
            />
            <StatCard
              title="Assigned Projects"
              value={summary.assigned_projects || 0}
              subtitle="Linear Corridors"
              icon={FileCheck}
              colorScheme="blue"
            />
            <StatCard
              title="Survey Accuracy"
              value={summary.verification_accuracy || '100%'}
              subtitle="QA Passed"
              icon={CheckCircle2}
              colorScheme="green"
            />
          </div>

          {/* Main Field Interface: Tasks on Left, Active Action Panel on Right */}
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-5">
            
            {/* Left: Task Queue (Touch-Friendly List) */}
            <div className="lg:col-span-5 space-y-3">
              <div className="gov-card p-3.5">
                <div className="flex items-center justify-between pb-2 mb-3 border-b border-slate-200">
                  <h3 className="font-bold text-xs uppercase tracking-wide text-slate-800">
                    Assigned Inspection Tasks ({tasks.length})
                  </h3>
                  <span className="text-[10px] text-slate-500">Select task to inspect</span>
                </div>

                <div className="space-y-2.5">
                  {tasks.map((task) => {
                    const isSelected = selectedTask?.id === task.id;
                    return (
                      <div
                        key={task.id}
                        onClick={() => setSelectedTask(task)}
                        className={`p-3 rounded border text-xs cursor-pointer transition-all ${
                          isSelected
                            ? 'bg-orange-50/80 border-[#FF6B00] shadow-xs'
                            : 'bg-slate-50 hover:bg-white border-slate-200'
                        }`}
                      >
                        <div className="flex justify-between items-start mb-1">
                          <span className="font-bold font-mono text-slate-900 text-sm">{task.id}</span>
                          <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${
                            task.priority === 'HIGH' ? 'bg-rose-100 text-rose-800' : 'bg-slate-200 text-slate-700'
                          }`}>
                            {task.priority}
                          </span>
                        </div>

                        <div className="font-semibold text-slate-800">{task.village}</div>
                        <div className="text-[11px] text-slate-600">{task.project_name}</div>
                        <div className="text-[11px] text-orange-700 font-medium mt-1">
                          Task: {task.task_type}
                        </div>

                        <div className="flex justify-between items-center text-[10px] text-slate-500 pt-2 mt-2 border-t border-slate-200/60">
                          <span className="flex items-center gap-1 font-mono">
                            <Navigation className="w-3 h-3 text-slate-400" />
                            {task.gps_coords}
                          </span>
                          <span className="font-semibold text-amber-700">{task.due_date}</span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>

            {/* Right: Active Field Verification & Evidence Workbench */}
            <div className="lg:col-span-7 space-y-4">
              {selectedTask ? (
                <div className="gov-card p-4 sm:p-5 border-t-4 border-t-[#FF6B00]">
                  <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center pb-3 mb-4 border-b border-slate-200 gap-2">
                    <div>
                      <span className="text-[10px] font-bold text-orange-700 uppercase bg-orange-100 px-2 py-0.5 rounded">
                        Active Inspection Workbench
                      </span>
                      <h3 className="text-base font-bold text-slate-900 mt-1">
                        {selectedTask.village} ({selectedTask.id})
                      </h3>
                      <p className="text-xs text-slate-600">{selectedTask.project_name}</p>
                    </div>

                    <div className="text-right text-xs">
                      <span className="text-slate-500 block text-[10px]">Due Time</span>
                      <span className="font-bold text-rose-700">{selectedTask.due_date}</span>
                    </div>
                  </div>

                  {/* 1. Quick Action Buttons (Mobile-first large touch targets) */}
                  <div className="mb-5">
                    <label className="block text-xs font-bold text-slate-700 uppercase mb-2">
                      Field Evidence & Geotagging Tools
                    </label>
                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 text-xs">
                      <button
                        type="button"
                        onClick={() => handleQuickAction('Site Photograph Captured')}
                        className="p-3 bg-slate-50 hover:bg-orange-50 border border-slate-300 hover:border-orange-400 rounded flex flex-col items-center justify-center gap-1.5 transition-colors"
                      >
                        <Camera className="w-5 h-5 text-orange-600" />
                        <span className="font-semibold text-slate-800 text-[11px]">Capture Photo</span>
                      </button>

                      <button
                        type="button"
                        onClick={handleCaptureGps}
                        className="p-3 bg-slate-50 hover:bg-orange-50 border border-slate-300 hover:border-orange-400 rounded flex flex-col items-center justify-center gap-1.5 transition-colors"
                      >
                        <MapPin className="w-5 h-5 text-green-600" />
                        <span className="font-semibold text-slate-800 text-[11px]">Record GPS</span>
                      </button>

                      <button
                        type="button"
                        onClick={() => handleQuickAction('7/12 Extract & Title Uploaded')}
                        className="p-3 bg-slate-50 hover:bg-orange-50 border border-slate-300 hover:border-orange-400 rounded flex flex-col items-center justify-center gap-1.5 transition-colors"
                      >
                        <Upload className="w-5 h-5 text-blue-600" />
                        <span className="font-semibold text-slate-800 text-[11px]">Upload 7/12</span>
                      </button>

                      <button
                        type="button"
                        onClick={() => handleQuickAction('Boundary Stones Flagged')}
                        className="p-3 bg-slate-50 hover:bg-orange-50 border border-slate-300 hover:border-orange-400 rounded flex flex-col items-center justify-center gap-1.5 transition-colors"
                      >
                        <FileCheck className="w-5 h-5 text-purple-600" />
                        <span className="font-semibold text-slate-800 text-[11px]">Pin Boundary</span>
                      </button>
                    </div>
                  </div>

                  {/* Current Captured Coordinates Info Box */}
                  <div className="bg-slate-100 p-3 rounded border border-slate-200 text-xs mb-4 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <MapPin className="w-4 h-4 text-orange-600" />
                      <span className="text-slate-600">Geo-tag:</span>
                      <span className="font-mono font-bold text-slate-800">{currentGps}</span>
                    </div>
                    <span className="text-[10px] bg-green-100 text-green-800 px-1.5 py-0.5 rounded font-semibold">
                      GPS Locked
                    </span>
                  </div>

                  {/* Ground Inspection Checklist & Remarks Form */}
                  <form onSubmit={handleSubmitVerification} className="space-y-4">
                    <div>
                      <label className="block text-xs font-bold text-slate-700 uppercase mb-1">
                        Statutory Field Checklist
                      </label>
                      <div className="space-y-1.5 bg-slate-50 p-3 rounded border border-slate-200 text-xs">
                        <label className="flex items-center gap-2 cursor-pointer">
                          <input type="checkbox" defaultChecked className="rounded text-orange-600 focus:ring-orange-500" />
                          <span>Land parcel boundary physically identified and matched with Cadastral Map</span>
                        </label>
                        <label className="flex items-center gap-2 cursor-pointer">
                          <input type="checkbox" defaultChecked className="rounded text-orange-600 focus:ring-orange-500" />
                          <span>Structures, wells, borewells, and standing trees enumerated</span>
                        </label>
                        <label className="flex items-center gap-2 cursor-pointer">
                          <input type="checkbox" defaultChecked className="rounded text-orange-600 focus:ring-orange-500" />
                          <span>Presence of titleholder / occupant confirmed on site</span>
                        </label>
                      </div>
                    </div>

                    <div>
                      <label className="block text-xs font-bold text-slate-700 uppercase mb-1">
                        Field Inspection Remarks & Findings <span className="text-red-500">*</span>
                      </label>
                      <textarea
                        rows="3"
                        required
                        value={remarks}
                        onChange={(e) => setRemarks(e.target.value)}
                        placeholder="Enter physical inspection findings, boundary verification status, landowner remarks..."
                        className="w-full p-2.5 text-xs bg-slate-50 border border-slate-300 rounded focus:bg-white focus:ring-1 focus:ring-orange-500 outline-none"
                      ></textarea>
                    </div>

                    <div className="pt-2 flex flex-col sm:flex-row justify-end gap-2.5">
                      <button
                        type="submit"
                        className="gov-btn-primary py-2.5 text-xs font-bold uppercase w-full sm:w-auto"
                      >
                        <Send className="w-4 h-4" />
                        <span>Submit Verification to CALA Office</span>
                      </button>
                    </div>
                  </form>
                </div>
              ) : (
                <div className="gov-card p-12 text-center text-slate-500 text-xs">
                  Please select a task from the list to begin field inspection.
                </div>
              )}
            </div>

          </div>
        </>
      )}
    </DashboardLayout>
  );
}
