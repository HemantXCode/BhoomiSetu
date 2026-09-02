import React from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { MapPin, Building2, Layers, RotateCcw } from 'lucide-react';

export default function GeographicFilters({
  states,
  selectedStateId,
  onStateChange,
  districts,
  selectedDistrictId,
  onDistrictChange,
  projects,
  selectedProjectId,
  onProjectChange,
  onReset
}) {
  const { t } = useLanguage();

  return (
    <div className="bg-white border border-slate-200 shadow-sm p-3 rounded-none flex flex-wrap items-center justify-between gap-3 text-xs">
      {/* Cascading Filter Controls */}
      <div className="flex flex-wrap items-center gap-3">
        {/* 1. State Filter */}
        <div className="flex items-center gap-1.5 min-w-[150px]">
          <span className="font-semibold text-slate-700 flex items-center gap-1">
            <Building2 className="w-3.5 h-3.5 text-orange-600" />
            {t('gis.state')}:
          </span>
          <select
            value={selectedStateId || ''}
            onChange={(e) => onStateChange(e.target.value ? Number(e.target.value) : null)}
            className="border border-slate-300 rounded px-2.5 py-1.5 bg-slate-50 text-slate-800 font-medium focus:outline-none focus:ring-1 focus:ring-orange-500 min-h-[38px] text-xs cursor-pointer"
          >
            {states.map((s) => (
              <option key={s.id} value={s.id}>
                {s.name} ({s.code})
              </option>
            ))}
          </select>
        </div>

        {/* 2. District Filter */}
        <div className="flex items-center gap-1.5 min-w-[150px]">
          <span className="font-semibold text-slate-700 flex items-center gap-1">
            <MapPin className="w-3.5 h-3.5 text-orange-600" />
            {t('gis.district')}:
          </span>
          <select
            value={selectedDistrictId || ''}
            onChange={(e) => onDistrictChange(e.target.value ? Number(e.target.value) : null)}
            className="border border-slate-300 rounded px-2.5 py-1.5 bg-slate-50 text-slate-800 font-medium focus:outline-none focus:ring-1 focus:ring-orange-500 min-h-[38px] text-xs cursor-pointer"
          >
            <option value="">{t('gis.allDistricts')}</option>
            {districts.map((d) => (
              <option key={d.id} value={d.id}>
                {d.name}
              </option>
            ))}
          </select>
        </div>

        {/* 3. Project Filter */}
        <div className="flex items-center gap-1.5 min-w-[240px]">
          <span className="font-semibold text-slate-700 flex items-center gap-1">
            <Layers className="w-3.5 h-3.5 text-orange-600" />
            {t('gis.projectCorridor')}:
          </span>
          <select
            value={selectedProjectId || ''}
            onChange={(e) => onProjectChange(e.target.value ? Number(e.target.value) : null)}
            className="border border-slate-300 rounded px-2.5 py-1.5 bg-orange-50/50 text-slate-900 font-semibold focus:outline-none focus:ring-1 focus:ring-orange-500 min-h-[38px] text-xs max-w-[280px] truncate cursor-pointer"
          >
            <option value="">{t('gis.allProjects')}</option>
            {projects.map((p) => (
              <option key={p.id} value={p.id}>
                {p.project_name}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Action: Reset All */}
      <button
        onClick={onReset}
        title="Reset map view & filters"
        className="text-slate-600 hover:text-slate-900 font-medium flex items-center gap-1 px-3 py-1.5 border border-slate-300 rounded hover:bg-slate-100 transition-colors cursor-pointer min-h-[38px]"
      >
        <RotateCcw className="w-3.5 h-3.5 text-slate-500" />
        <span>{t('common.reset')}</span>
      </button>
    </div>
  );
}
