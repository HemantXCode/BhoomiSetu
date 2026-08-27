import React, { useState, useEffect } from 'react';
import { projectService } from '../../services/projectService';
import { X, PlusCircle, AlertCircle } from 'lucide-react';

export default function ProposalModal({ isOpen, onClose, onProjectCreated, user }) {
  const [states, setStates] = useState([]);
  const [districts, setDistricts] = useState([]);
  const [agencies, setAgencies] = useState([]);

  const [formData, setFormData] = useState({
    project_name: '',
    description: '',
    agency_id: user?.agency_id || '',
    state_id: user?.state_id || '',
    district_id: user?.district_id || '',
    proposed_area: '',
    start_date: new Date().toISOString().split('T')[0],
    expected_end_date: ''
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (isOpen) {
      loadGeoData();
    }
  }, [isOpen]);

  useEffect(() => {
    if (formData.state_id) {
      loadDistricts(formData.state_id);
    }
  }, [formData.state_id]);

  const loadGeoData = async () => {
    try {
      const [statesRes, agenciesRes] = await Promise.all([
        projectService.getStates(),
        projectService.getAgencies()
      ]);
      if (statesRes.success) setStates(statesRes.data);
      if (agenciesRes.success) setAgencies(agenciesRes.data);

      if (user?.state_id) {
        setFormData(prev => ({ ...prev, state_id: user.state_id }));
        loadDistricts(user.state_id);
      }
      if (user?.agency_id) {
        setFormData(prev => ({ ...prev, agency_id: user.agency_id }));
      }
    } catch (err) {
      console.error('Failed to load geographic metadata:', err);
    }
  };

  const loadDistricts = async (stateId) => {
    try {
      const res = await projectService.getDistricts(stateId);
      if (res.success) setDistricts(res.data);
    } catch (err) {
      console.error('Failed to load districts:', err);
    }
  };

  if (!isOpen) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const payload = {
        ...formData,
        proposed_area: parseFloat(formData.proposed_area),
        state_id: parseInt(formData.state_id, 10),
        district_id: parseInt(formData.district_id, 10),
        agency_id: user.agency_id ? user.agency_id : parseInt(formData.agency_id, 10)
      };

      const res = await projectService.createProject(payload);
      if (res.success) {
        onProjectCreated(res.data);
        onClose();
      }
    } catch (err) {
      setError(err.response?.data?.message || err.message || 'Failed to submit proposal.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 overflow-y-auto">
      <div className="bg-white border border-slate-300 shadow-xl max-w-2xl w-full rounded overflow-hidden">
        {/* Modal Header */}
        <div className="bg-[#0B2545] text-white px-5 py-3.5 flex items-center justify-between border-b border-slate-700">
          <div className="flex items-center gap-2">
            <PlusCircle className="w-5 h-5 text-orange-400" />
            <h3 className="font-bold text-sm uppercase tracking-wide">
              Submit New Land Acquisition Project Proposal
            </h3>
          </div>
          <button 
            onClick={onClose} 
            className="text-slate-300 hover:text-white p-1 rounded"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Body */}
        <form onSubmit={handleSubmit} className="p-5 space-y-4">
          {error && (
            <div className="p-3 bg-red-50 border border-red-200 text-red-800 text-xs rounded flex items-center gap-2">
              <AlertCircle className="w-4 h-4 text-red-600 shrink-0" />
              <span>{error}</span>
            </div>
          )}

          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase mb-1">
              Project Title / Name <span className="text-red-500">*</span>
            </label>
            <input
              type="text"
              required
              value={formData.project_name}
              onChange={(e) => setFormData({ ...formData, project_name: e.target.value })}
              placeholder="e.g. Pune-Solapur Multi-Modal Logistics Expressway"
              className="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-300 rounded focus:bg-white focus:ring-1 focus:ring-orange-500 outline-none"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase mb-1">
              Project Description & Alignment Scope
            </label>
            <textarea
              rows="2"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              placeholder="Details of the alignment, required Right-of-Way (RoW), talukas affected..."
              className="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-300 rounded focus:bg-white focus:ring-1 focus:ring-orange-500 outline-none"
            ></textarea>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {/* Implementing Agency */}
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">
                Implementing Agency <span className="text-red-500">*</span>
              </label>
              <select
                disabled={!!user?.agency_id}
                required
                value={formData.agency_id}
                onChange={(e) => setFormData({ ...formData, agency_id: e.target.value })}
                className="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-300 rounded focus:bg-white outline-none disabled:bg-slate-200"
              >
                <option value="">-- Select Implementing Agency --</option>
                {agencies.map(a => (
                  <option key={a.id} value={a.id}>{a.name}</option>
                ))}
              </select>
            </div>

            {/* Proposed Area */}
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">
                Proposed Land Area (in Hectares) <span className="text-red-500">*</span>
              </label>
              <input
                type="number"
                step="0.01"
                required
                min="0.1"
                value={formData.proposed_area}
                onChange={(e) => setFormData({ ...formData, proposed_area: e.target.value })}
                placeholder="e.g. 245.50"
                className="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-300 rounded focus:bg-white focus:ring-1 focus:ring-orange-500 outline-none"
              />
            </div>

            {/* State Selection */}
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">
                State <span className="text-red-500">*</span>
              </label>
              <select
                required
                value={formData.state_id}
                onChange={(e) => setFormData({ ...formData, state_id: e.target.value, district_id: '' })}
                className="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-300 rounded focus:bg-white outline-none"
              >
                <option value="">-- Select State --</option>
                {states.map(s => (
                  <option key={s.id} value={s.id}>{s.name} ({s.code})</option>
                ))}
              </select>
            </div>

            {/* District Selection */}
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">
                District <span className="text-red-500">*</span>
              </label>
              <select
                required
                disabled={!formData.state_id}
                value={formData.district_id}
                onChange={(e) => setFormData({ ...formData, district_id: e.target.value })}
                className="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-300 rounded focus:bg-white outline-none disabled:bg-slate-200"
              >
                <option value="">-- Select District --</option>
                {districts.map(d => (
                  <option key={d.id} value={d.id}>{d.name} ({d.code})</option>
                ))}
              </select>
            </div>

            {/* Start Date */}
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">
                Tentative Start Date
              </label>
              <input
                type="date"
                value={formData.start_date}
                onChange={(e) => setFormData({ ...formData, start_date: e.target.value })}
                className="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-300 rounded focus:bg-white outline-none"
              />
            </div>

            {/* Expected End Date */}
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">
                Target Possession Date
              </label>
              <input
                type="date"
                value={formData.expected_end_date}
                onChange={(e) => setFormData({ ...formData, expected_end_date: e.target.value })}
                className="w-full px-3 py-2 text-xs bg-slate-50 border border-slate-300 rounded focus:bg-white outline-none"
              />
            </div>
          </div>

          {/* Modal Actions */}
          <div className="pt-4 border-t border-slate-200 flex justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
              className="gov-btn-secondary text-xs"
            >
              Cancel
            </button>

            <button
              type="submit"
              disabled={loading}
              className="gov-btn-primary text-xs"
            >
              {loading ? 'Registering Proposal...' : 'Submit Official Proposal'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
