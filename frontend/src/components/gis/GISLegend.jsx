import React, { useState } from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { ChevronDown, ChevronUp, Layers, Info } from 'lucide-react';

export default function GISLegend() {
  const { t } = useLanguage();
  const [isCollapsed, setIsCollapsed] = useState(false);

  return (
    <div className="bg-white/95 backdrop-blur-sm border border-slate-300 shadow-md rounded text-xs p-2.5 min-w-[220px] z-[1000] transition-all">
      {/* Legend Header */}
      <div 
        onClick={() => setIsCollapsed(!isCollapsed)}
        className="flex items-center justify-between font-bold text-slate-800 uppercase tracking-wider text-[11px] cursor-pointer pb-1 select-none"
      >
        <span className="flex items-center gap-1.5">
          <Layers className="w-3.5 h-3.5 text-orange-600" />
          {t('gis.legend')}
        </span>
        <button className="p-0.5 text-slate-500 hover:text-slate-800 cursor-pointer">
          {isCollapsed ? <ChevronUp className="w-3.5 h-3.5" /> : <ChevronDown className="w-3.5 h-3.5" />}
        </button>
      </div>

      {/* Legend Body */}
      {!isCollapsed && (
        <div className="mt-2 space-y-2 border-t border-slate-200 pt-2 text-slate-700">
          {/* Highway Road Line Key */}
          <div className="flex items-center gap-2 pb-1 border-b border-slate-100">
            <div className="w-6 h-2 bg-orange-600 border border-slate-900 rounded-sm flex-shrink-0" />
            <span className="font-bold text-[11px] text-slate-900">{t('gis.highwayCorridorKey')}</span>
          </div>

          {/* Right-of-Way Buffer Key */}
          <div className="flex items-center gap-2 pb-1 border-b border-slate-100">
            <div className="w-6 h-3 bg-orange-400/30 border border-dashed border-orange-600 rounded-sm flex-shrink-0" />
            <span className="font-medium text-[11px] text-slate-800">{t('gis.rowBufferKey')}</span>
          </div>

          {/* Parcel Status Keys */}
          <div className="flex items-center gap-2">
            <span className="w-3.5 h-3.5 rounded bg-emerald-500 border border-emerald-700 flex-shrink-0" />
            <span className="font-medium text-[11px]">{t('gis.acquiredParcelKey')}</span>
          </div>
          <div className="flex items-center gap-2">
            <span className="w-3.5 h-3.5 rounded bg-amber-500 border border-amber-700 flex-shrink-0" />
            <span className="font-medium text-[11px]">{t('gis.inProgressParcelKey')}</span>
          </div>
          <div className="flex items-center gap-2">
            <span className="w-3.5 h-3.5 rounded bg-rose-500 border border-dashed border-rose-700 flex-shrink-0" />
            <span className="font-medium text-[11px]">{t('gis.pendingParcelKey')}</span>
          </div>

          {/* ULPIN Badge Key */}
          <div className="flex items-center gap-2 pt-1 border-t border-slate-100">
            <div className="bg-slate-900 text-white font-mono text-[9px] px-1 py-0.5 rounded border border-orange-500 flex-shrink-0">
              P-101 • 3.25Ha
            </div>
            <span className="text-[10px] text-slate-600 font-medium">{t('gis.ulpinBadgeKey')}</span>
          </div>

          {/* Prototype Badge */}
          <div className="pt-1.5 mt-1 border-t border-slate-200 flex items-center gap-1 text-[9px] text-amber-800 bg-amber-50 p-1.5 rounded border border-amber-200 font-medium">
            <Info className="w-3 h-3 text-amber-600 shrink-0" />
            <span>{t('common.prototypeBadge')}</span>
          </div>
        </div>
      )}
    </div>
  );
}
