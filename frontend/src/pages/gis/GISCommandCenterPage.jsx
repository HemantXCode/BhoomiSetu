import React from 'react';
import GovHeader from '../../components/common/GovHeader';
import GovNavbar from '../../components/common/GovNavbar';
import GeographicFilters from '../../components/gis/GeographicFilters';
import ULPINSearch from '../../components/gis/ULPINSearch';
import GISStatsPanel from '../../components/gis/GISStatsPanel';
import GISMap from '../../components/gis/GISMap';
import ParcelInfoPanel from '../../components/gis/ParcelInfoPanel';
import ProjectInfoPanel from '../../components/gis/ProjectInfoPanel';
import { useGISData } from '../../hooks/useGISData';
import { useLanguage } from '../../context/LanguageContext';
import { Map, AlertCircle, RefreshCw, Layers } from 'lucide-react';

export default function GISCommandCenterPage() {
  const { t } = useLanguage();
  const {
    loading,
    error,
    states,
    selectedStateId,
    setSelectedStateId,
    districts,
    selectedDistrictId,
    setSelectedDistrictId,
    projects,
    selectedProjectId,
    setSelectedProjectId,
    corridorsGeoJSON,
    parcels,
    fieldOfficers,
    selectedParcel,
    setSelectedParcel,
    selectedCorridorSegment,
    setSelectedCorridorSegment,
    activeLayers,
    toggleLayer,
    stats,
    searchQuery,
    searchResults,
    isSearching,
    handleSearchULPIN,
    handleSelectSearchedParcel,
    handleSelectParcel,
    handleSelectCorridorSegment,
    handleResetMap,
    mapFocusTarget,
    refreshData
  } = useGISData();

  return (
    <div className="min-h-screen bg-slate-100 flex flex-col font-sans">
      {/* 1. Official Government Header */}
      <GovHeader />

      {/* 2. Official Saffron Government Navigation */}
      <GovNavbar />

      {/* 3. GIS Command Center Title & Action Ribbon */}
      <div className="bg-[#0B2545] text-white border-b border-slate-700 py-2.5 px-4 sm:px-8">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2">
          <div className="flex items-center gap-2.5">
            <div className="p-1.5 bg-orange-600 rounded">
              <Map className="w-4 h-4 text-white" />
            </div>
            <div>
              <h1 className="text-base sm:text-lg font-bold tracking-tight text-white flex flex-wrap items-center gap-2">
                {t('gis.commandCenter')}
                <span className="text-[10px] font-semibold bg-emerald-700 text-emerald-100 px-2 py-0.5 rounded uppercase">
                  {t('gis.geoPortalV1')}
                </span>
                <span className="text-[10px] font-semibold bg-amber-600 text-amber-50 px-2 py-0.5 rounded uppercase font-mono border border-amber-500">
                  {t('common.prototypeBadge')}
                </span>
              </h1>
              <p className="text-[11px] text-slate-300">
                {t('gis.tagline')}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <span className="text-[11px] text-slate-300 font-mono hidden md:inline">
              {t('gis.coordSystem')}
            </span>
            <button
              onClick={refreshData}
              className="px-2.5 py-1 text-xs bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-600 rounded flex items-center gap-1 cursor-pointer transition-colors"
              title="Refresh GIS Layers"
            >
              <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
              <span>{t('gis.syncLayers')}</span>
            </button>
          </div>
        </div>
      </div>

      {/* 4. Main Workspace */}
      <main className="flex-1 max-w-7xl w-full mx-auto p-3 sm:p-4 flex flex-col gap-3">
        {/* Error Alert with Retry */}
        {error && (
          <div className="p-3 bg-red-50 border border-red-200 text-red-800 rounded text-xs flex items-center justify-between">
            <div className="flex items-center gap-2">
              <AlertCircle className="w-4 h-4 text-red-600 flex-shrink-0" />
              <span>{error}</span>
            </div>
            <button
              onClick={refreshData}
              className="text-red-700 font-bold underline hover:text-red-900 cursor-pointer"
            >
              Retry
            </button>
          </div>
        )}

        {/* Top Control Ribbon: Geographic Cascading Filters & ULPIN Search */}
        <div className="flex flex-col lg:flex-row items-stretch lg:items-center justify-between gap-3">
          <div className="flex-1">
            <GeographicFilters
              states={states}
              selectedStateId={selectedStateId}
              onStateChange={setSelectedStateId}
              districts={districts}
              selectedDistrictId={selectedDistrictId}
              onDistrictChange={setSelectedDistrictId}
              projects={projects}
              selectedProjectId={selectedProjectId}
              onProjectChange={setSelectedProjectId}
              onReset={handleResetMap}
            />
          </div>
          <div className="flex-shrink-0">
            <ULPINSearch
              searchQuery={searchQuery}
              searchResults={searchResults}
              isSearching={isSearching}
              onSearchChange={handleSearchULPIN}
              onSelectParcel={handleSelectSearchedParcel}
              onClear={handleResetMap}
            />
          </div>
        </div>

        {/* Dynamic KPI Statistics Panel */}
        <GISStatsPanel stats={stats} />

        {/* Interactive GIS Map Canvas + Contextual Right Panel */}
        <div className="relative flex-1 min-h-[580px] h-[640px] bg-white border border-slate-300 shadow-sm flex flex-col lg:flex-row overflow-hidden">
          {/* Map Area */}
          <div className="flex-1 h-full min-h-[580px] relative">
            <GISMap
              corridorsGeoJSON={corridorsGeoJSON}
              parcels={parcels}
              fieldOfficers={fieldOfficers}
              activeLayers={activeLayers}
              selectedParcel={selectedParcel}
              selectedCorridorSegment={selectedCorridorSegment}
              onSelectParcel={handleSelectParcel}
              onSelectCorridorSegment={handleSelectCorridorSegment}
              onToggleLayer={toggleLayer}
              mapFocusTarget={mapFocusTarget}
              onRecenter={handleResetMap}
            />
          </div>

          {/* Contextual Side Panel: Parcel Info or Project Corridor Info */}
          {selectedParcel && (
            <div className="lg:w-[420px] w-full flex-shrink-0 h-full border-t lg:border-t-0 lg:border-l border-slate-300 bg-white">
              <ParcelInfoPanel
                parcel={selectedParcel}
                onClose={() => setSelectedParcel(null)}
              />
            </div>
          )}

          {selectedCorridorSegment && !selectedParcel && (
            <div className="lg:w-[380px] w-full flex-shrink-0 h-full border-t lg:border-t-0 lg:border-l border-slate-300 bg-white">
              <ProjectInfoPanel
                segment={selectedCorridorSegment}
                onClose={() => setSelectedCorridorSegment(null)}
                onViewParcels={(projId) => {
                  setSelectedProjectId(projId);
                  setSelectedCorridorSegment(null);
                }}
              />
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
