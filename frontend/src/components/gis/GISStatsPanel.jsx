import React from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { Layers, CheckCircle2, Clock, AlertTriangle, TrendingUp, LandPlot } from 'lucide-react';

export default function GISStatsPanel({ stats }) {
  const { t } = useLanguage();
  const progressNum = parseFloat(stats.progressPercent || '0');

  return (
    <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-2 sm:gap-3">
      {/* 1. Total Land Required */}
      <div className="bg-white border border-slate-200 p-2.5 sm:p-3 shadow-sm">
        <div className="flex items-center justify-between">
          <span className="text-[10px] sm:text-xs font-semibold uppercase tracking-wider text-slate-500">
            {t('gis.totalLandRequired')}
          </span>
          <Layers className="w-3.5 h-3.5 text-slate-400" />
        </div>
        <div className="mt-1 flex items-baseline gap-1">
          <span className="text-base sm:text-lg font-bold text-slate-900 font-mono">
            {stats.totalLand}
          </span>
          <span className="text-[10px] text-slate-500 font-medium">Ha</span>
        </div>
      </div>

      {/* 2. Acquired Land */}
      <div className="bg-white border border-emerald-200 p-2.5 sm:p-3 shadow-sm bg-emerald-50/20">
        <div className="flex items-center justify-between">
          <span className="text-[10px] sm:text-xs font-semibold uppercase tracking-wider text-emerald-800">
            {t('gis.acquiredLand')}
          </span>
          <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
        </div>
        <div className="mt-1 flex items-baseline gap-1">
          <span className="text-base sm:text-lg font-bold text-emerald-700 font-mono">
            {stats.acquiredLand}
          </span>
          <span className="text-[10px] text-emerald-600 font-medium">Ha</span>
        </div>
      </div>

      {/* 3. In Progress Land */}
      <div className="bg-white border border-amber-200 p-2.5 sm:p-3 shadow-sm bg-amber-50/20">
        <div className="flex items-center justify-between">
          <span className="text-[10px] sm:text-xs font-semibold uppercase tracking-wider text-amber-800">
            {t('gis.inProgressLand')}
          </span>
          <Clock className="w-3.5 h-3.5 text-amber-600" />
        </div>
        <div className="mt-1 flex items-baseline gap-1">
          <span className="text-base sm:text-lg font-bold text-amber-700 font-mono">
            {stats.inProgressLand}
          </span>
          <span className="text-[10px] text-amber-600 font-medium">Ha</span>
        </div>
      </div>

      {/* 4. Pending Land */}
      <div className="bg-white border border-rose-200 p-2.5 sm:p-3 shadow-sm bg-rose-50/20">
        <div className="flex items-center justify-between">
          <span className="text-[10px] sm:text-xs font-semibold uppercase tracking-wider text-rose-800">
            {t('gis.pendingLand')}
          </span>
          <AlertTriangle className="w-3.5 h-3.5 text-rose-600" />
        </div>
        <div className="mt-1 flex items-baseline gap-1">
          <span className="text-base sm:text-lg font-bold text-rose-700 font-mono">
            {stats.pendingLand}
          </span>
          <span className="text-[10px] text-rose-600 font-medium">Ha</span>
        </div>
      </div>

      {/* 5. Acquisition Progress % (Dynamically Calculated) */}
      <div className="bg-white border border-slate-200 p-2.5 sm:p-3 shadow-sm">
        <div className="flex items-center justify-between">
          <span className="text-[10px] sm:text-xs font-semibold uppercase tracking-wider text-slate-500">
            {t('dashboard.acquisitionProgress')}
          </span>
          <TrendingUp className="w-3.5 h-3.5 text-orange-500" />
        </div>
        <div className="mt-1 flex items-baseline gap-1">
          <span className="text-base sm:text-lg font-bold text-slate-900 font-mono">
            {stats.progressPercent}%
          </span>
        </div>
        <div className="w-full bg-slate-100 h-1.5 rounded-full mt-1.5 overflow-hidden">
          <div
            className="bg-[#FF6B00] h-full rounded-full transition-all duration-500"
            style={{ width: `${Math.min(progressNum, 100)}%` }}
          />
        </div>
      </div>

      {/* 6. Project-Affected Parcels */}
      <div className="bg-white border border-orange-200 p-2.5 sm:p-3 shadow-sm bg-orange-50/20">
        <div className="flex items-center justify-between">
          <span className="text-[10px] sm:text-xs font-semibold uppercase tracking-wider text-orange-800">
            {t('gis.affectedParcels')}
          </span>
          <LandPlot className="w-3.5 h-3.5 text-orange-600" />
        </div>
        <div className="mt-1 flex items-baseline gap-1">
          <span className="text-base sm:text-lg font-bold text-orange-700 font-mono">
            {stats.totalParcels}
          </span>
          <span className="text-[10px] text-orange-600 font-medium">{t('gis.mapped')}</span>
        </div>
      </div>
    </div>
  );
}
