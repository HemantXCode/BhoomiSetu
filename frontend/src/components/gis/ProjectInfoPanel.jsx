import React from 'react';
import { useNavigate } from 'react-router-dom';
import { X, Layers, Route, LandPlot, ExternalLink, ArrowRight } from 'lucide-react';

export default function ProjectInfoPanel({ segment, onClose, onViewParcels }) {
  const navigate = useNavigate();

  if (!segment) return null;

  return (
    <div className="bg-white border-l border-slate-300 shadow-2xl w-full max-w-md h-full flex flex-col z-20 text-xs overflow-hidden">
      {/* Header */}
      <div className="p-3.5 bg-[#0B2545] text-white flex items-start justify-between border-b border-slate-700 flex-shrink-0">
        <div className="flex items-start gap-2">
          <div className="p-2 bg-blue-600 rounded mt-0.5">
            <Route className="w-4 h-4 text-white" />
          </div>
          <div>
            <span className="text-[10px] font-bold uppercase tracking-wider text-blue-300 bg-blue-950/60 px-1.5 py-0.5 rounded">
              Project Corridor Segment
            </span>
            <h3 className="text-sm font-bold tracking-tight mt-1 text-white">
              {segment.segment_name}
            </h3>
            <p className="text-[11px] text-slate-300 font-medium">
              {segment.project_name}
            </p>
          </div>
        </div>
        <button
          onClick={onClose}
          className="p-1 text-slate-400 hover:text-white rounded hover:bg-slate-800 transition-colors cursor-pointer"
          title="Close panel"
        >
          <X className="w-5 h-5" />
        </button>
      </div>

      {/* Segment Metrics */}
      <div className="p-4 flex-1 overflow-y-auto space-y-3.5">
        <div className="gov-card p-3 space-y-2">
          <h4 className="font-bold text-slate-800 text-xs border-b border-slate-200 pb-1 flex items-center gap-1.5">
            <Layers className="w-3.5 h-3.5 text-orange-600" />
            Corridor Specifications
          </h4>
          <div className="grid grid-cols-2 gap-3 text-[11px]">
            <div>
              <span className="text-slate-500 block">Acquisition Status</span>
              <span className={`inline-block mt-0.5 text-[10px] font-bold px-2 py-0.5 rounded ${
                segment.status === 'ACQUIRED' ? 'bg-emerald-100 text-emerald-800' :
                segment.status === 'IN_PROGRESS' ? 'bg-amber-100 text-amber-800' :
                'bg-rose-100 text-rose-800'
              }`}>
                {segment.status}
              </span>
            </div>
            <div>
              <span className="text-slate-500 block">Segment Length</span>
              <span className="font-mono font-bold text-slate-800">{segment.length_km} km</span>
            </div>
            <div>
              <span className="text-slate-500 block">Land Required</span>
              <span className="font-mono font-bold text-slate-800">{segment.land_area_ha} Ha</span>
            </div>
            <div>
              <span className="text-slate-500 block">Segment Code</span>
              <span className="font-mono font-semibold text-slate-800">{segment.segment_id}</span>
            </div>
          </div>
        </div>

        <div className="gov-card p-3 space-y-2">
          <h4 className="font-bold text-slate-800 text-xs border-b border-slate-200 pb-1">
            Corridor Operations
          </h4>
          <p className="text-[11px] text-slate-600">
            Click <strong>VIEW PARCELS</strong> to filter and highlight all individual land parcels aligned along this corridor sector on the GIS canvas.
          </p>
          <button
            onClick={() => onViewParcels(segment.project_id)}
            className="w-full mt-2 gov-btn-secondary text-xs py-2 px-3 rounded flex items-center justify-center gap-1.5 border-orange-300 text-orange-700 hover:bg-orange-50"
          >
            <LandPlot className="w-4 h-4 text-orange-600" />
            <span>FILTER PARCELS FOR THIS CORRIDOR</span>
          </button>
        </div>
      </div>

      {/* Action Footer */}
      <div className="p-3 bg-slate-50 border-t border-slate-200 flex items-center justify-between flex-shrink-0">
        <button
          onClick={() => navigate('/projects')}
          className="gov-btn-primary text-xs py-1.5 px-3 rounded shadow-sm w-full flex items-center justify-center gap-1.5"
        >
          <span>VIEW FULL PROJECT DETAILS</span>
          <ExternalLink className="w-3.5 h-3.5" />
        </button>
      </div>
    </div>
  );
}
