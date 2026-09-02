import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../../context/LanguageContext';
import { 
  X, 
  LandPlot, 
  MapPin, 
  CheckCircle2, 
  FileText, 
  Camera, 
  Coins, 
  Users, 
  History, 
  ExternalLink,
  ShieldCheck,
  Building
} from 'lucide-react';

export default function ParcelInfoPanel({ parcel, onClose }) {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [activeTab, setActiveTab] = useState('land');

  if (!parcel) return null;

  const tabs = [
    { id: 'land', label: t('gis.ownershipRecord'), icon: LandPlot },
    { id: 'gis', label: t('gis.geospatialMeta'), icon: MapPin },
    { id: 'verification', label: t('gis.groundVerification'), icon: CheckCircle2 },
    { id: 'evidence', label: t('gis.evidenceMedia'), icon: Camera },
    { id: 'compensation', label: t('gis.awardCompensation'), icon: Coins },
    { id: 'rr', label: t('gis.rrStatus'), icon: Users },
    { id: 'audit', label: t('gis.auditHistory'), icon: History }
  ];

  return (
    <div className="bg-white border-l border-slate-300 shadow-2xl w-full max-w-md h-full flex flex-col z-20 text-xs overflow-hidden">
      {/* Header */}
      <div className="p-3.5 bg-[#0B2545] text-white flex items-start justify-between border-b border-slate-700 flex-shrink-0">
        <div className="flex items-start gap-2">
          <div className="p-2 bg-orange-600 rounded mt-0.5">
            <LandPlot className="w-4 h-4 text-white" />
          </div>
          <div>
            <span className="text-[10px] font-bold uppercase tracking-wider text-orange-400 bg-orange-950/60 px-1.5 py-0.5 rounded">
              {t('gis.landPlot')}
            </span>
            <h3 className="text-sm font-bold font-mono tracking-tight mt-1 text-white">
              {parcel.ulpin}
            </h3>
            <p className="text-[11px] text-slate-300 font-medium">
              {parcel.survey_number} • {parcel.village}, {parcel.district}
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

      {/* Status Bar */}
      <div className="px-3.5 py-2 bg-slate-100 border-b border-slate-200 flex items-center justify-between">
        <div className="flex items-center gap-1.5">
          <span className="text-slate-500 font-semibold">{t('common.status')}:</span>
          <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${
            parcel.status === 'ACQUIRED' ? 'bg-emerald-100 text-emerald-800' :
            parcel.status === 'IN_PROGRESS' ? 'bg-amber-100 text-amber-800' :
            'bg-rose-100 text-rose-800'
          }`}>
            {parcel.status}
          </span>
        </div>
        <div className="flex items-center gap-1">
          <span className="text-slate-500 font-semibold">{t('dashboard.landRequired')}:</span>
          <span className="font-bold text-slate-900 font-mono">
            {parcel.area_hectares} Ha
          </span>
        </div>
      </div>

      {/* ULPIN 360° Navigation Tabs */}
      <div className="flex items-center overflow-x-auto bg-slate-50 border-b border-slate-200 scrollbar-none flex-shrink-0">
        {tabs.map((tItem) => {
          const Icon = tItem.icon;
          const isActive = activeTab === tItem.id;
          return (
            <button
              key={tItem.id}
              onClick={() => setActiveTab(tItem.id)}
              className={`px-3 py-2 text-[11px] font-medium flex items-center gap-1 whitespace-nowrap border-b-2 transition-colors cursor-pointer ${
                isActive
                  ? 'border-orange-600 text-orange-700 bg-white font-bold'
                  : 'border-transparent text-slate-600 hover:text-slate-900 hover:bg-slate-100'
              }`}
            >
              <Icon className="w-3.5 h-3.5" />
              <span>{tItem.label}</span>
            </button>
          );
        })}
      </div>

      {/* Tab Content Body */}
      <div className="p-4 flex-1 overflow-y-auto space-y-3.5">
        {activeTab === 'land' && (
          <div className="space-y-3">
            <div className="gov-card p-3 space-y-2">
              <h4 className="font-bold text-slate-800 text-xs border-b border-slate-200 pb-1 flex items-center gap-1.5">
                <Building className="w-3.5 h-3.5 text-orange-600" />
                {t('gis.ownershipRecord')}
              </h4>
              <div className="grid grid-cols-2 gap-2 text-[11px]">
                <div>
                  <span className="text-slate-500 block">{t('gis.primaryTitleholder')}</span>
                  <span className="font-bold text-slate-900">{parcel.owner_name}</span>
                </div>
                <div>
                  <span className="text-slate-500 block">{t('gis.classification')}</span>
                  <span className="font-semibold text-slate-800">{parcel.classification}</span>
                </div>
                <div>
                  <span className="text-slate-500 block">{t('gis.surveyGatNo')}</span>
                  <span className="font-mono font-semibold text-slate-800">{parcel.survey_number}</span>
                </div>
                <div>
                  <span className="text-slate-500 block">{t('gis.areaSqM')}</span>
                  <span className="font-mono font-semibold text-slate-800">{(parcel.area_hectares * 10000).toLocaleString()} sq.m</span>
                </div>
              </div>
            </div>

            {/* Project Affected Banner */}
            <div className="bg-amber-50 border border-amber-300 rounded p-2.5 flex items-center justify-between">
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-amber-800 block">
                  {t('gis.rowStatusBanner')}
                </span>
                <span className="font-bold text-slate-900 text-xs">
                  {t('gis.projectAffectedYes')}
                </span>
              </div>
              <span className="bg-orange-600 text-white font-bold text-[10px] px-2 py-0.5 rounded shadow-xs">
                {t('gis.rowIntersected')}
              </span>
            </div>

            <div className="gov-card p-3 space-y-2">
              <h4 className="font-bold text-slate-800 text-xs border-b border-slate-200 pb-1">
                {t('gis.projectAssociation')}
              </h4>
              <div className="text-[11px] space-y-1">
                <span className="text-slate-500 block">{t('gis.projectCorridor')}:</span>
                <span className="font-bold text-slate-900 block">{parcel.project_name}</span>
                <span className="text-slate-500 block mt-2">{t('gis.rowDemarcationStatus')}:</span>
                <span className="text-emerald-700 font-bold block">{t('gis.corridorIntersects')}</span>
                <span className="text-slate-500 block mt-2">{t('gis.adminJurisdiction')}:</span>
                <span className="text-slate-800">{parcel.village} Village, {parcel.district} District, {parcel.state}</span>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'gis' && (
          <div className="space-y-3">
            <div className="gov-card p-3 space-y-2">
              <h4 className="font-bold text-slate-800 text-xs border-b border-slate-200 pb-1 flex items-center gap-1.5">
                <MapPin className="w-3.5 h-3.5 text-orange-600" />
                {t('gis.geospatialMeta')}
              </h4>
              <p className="text-[11px] text-slate-600">
                Cadastral polygon vertices mapped via RoR integration and High-Precision GNSS survey pins.
              </p>
              <div className="bg-slate-50 p-2.5 rounded border border-slate-200 font-mono text-[10px] space-y-1">
                <div className="text-slate-500">{t('gis.polygonVertices')}</div>
                {parcel.polygon && parcel.polygon.slice(0, 4).map((pt, i) => (
                  <div key={i} className="text-slate-700">
                    Vertex {i + 1}: {pt[0].toFixed(6)}° N, {pt[1].toFixed(6)}° E
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {activeTab === 'verification' && (
          <div className="space-y-3">
            <div className="gov-card p-3 space-y-2">
              <h4 className="font-bold text-slate-800 text-xs border-b border-slate-200 pb-1 flex items-center gap-1.5">
                <ShieldCheck className="w-3.5 h-3.5 text-emerald-600" />
                {t('gis.groundVerification')}
              </h4>
              <div className="text-[11px] space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-slate-500">{t('gis.verificationStatus')}:</span>
                  <span className="font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                    {parcel.verification_status || 'VERIFIED'}
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-slate-500">{t('gis.verifiedByOfficer')}:</span>
                  <span className="font-semibold text-slate-800">Suresh Patil (SDRO-Haveli)</span>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'evidence' && (
          <div className="space-y-3">
            <div className="gov-card p-3 space-y-2">
              <h4 className="font-bold text-slate-800 text-xs border-b border-slate-200 pb-1 flex items-center gap-1.5">
                <Camera className="w-3.5 h-3.5 text-orange-600" />
                {t('gis.evidenceMedia')}
              </h4>
              <p className="text-[11px] text-slate-600">
                Ground photographs and certified 7/12 Land Revenue extracts attached via Mobile Terminal.
              </p>
            </div>
          </div>
        )}

        {activeTab === 'compensation' && (
          <div className="space-y-3">
            <div className="gov-card p-3 space-y-2">
              <h4 className="font-bold text-slate-800 text-xs border-b border-slate-200 pb-1 flex items-center gap-1.5">
                <Coins className="w-3.5 h-3.5 text-green-600" />
                {t('gis.awardCompensation')}
              </h4>
              <div className="text-[11px] space-y-1.5">
                <div className="flex justify-between">
                  <span className="text-slate-500">Market Rate (Ready Reckoner):</span>
                  <span className="font-mono font-semibold">₹4,200 / sq.m</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Total Compensation Assessed:</span>
                  <span className="font-mono font-bold text-emerald-700">₹{(parcel.area_hectares * 1.85).toFixed(2)} Cr</span>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'rr' && (
          <div className="space-y-3">
            <div className="gov-card p-3 space-y-2">
              <h4 className="font-bold text-slate-800 text-xs border-b border-slate-200 pb-1 flex items-center gap-1.5">
                <Users className="w-3.5 h-3.5 text-blue-600" />
                {t('gis.rrStatus')}
              </h4>
              <p className="text-[11px] text-slate-600">
                Resettlement & Rehabilitation entitlements mapped under Schedule II of RFCTLARR Act, 2013.
              </p>
            </div>
          </div>
        )}

        {activeTab === 'audit' && (
          <div className="space-y-3">
            <div className="gov-card p-3 space-y-2">
              <h4 className="font-bold text-slate-800 text-xs border-b border-slate-200 pb-1 flex items-center gap-1.5">
                <History className="w-3.5 h-3.5 text-slate-600" />
                {t('gis.auditHistory')}
              </h4>
              <div className="space-y-1 text-[11px] font-mono">
                <div className="text-slate-700">• 2026-08-20: Joint Demarcation Completed</div>
                <div className="text-slate-700">• 2026-08-28: GeoJSON Coordinates Certified</div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
