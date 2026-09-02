import { useState, useEffect, useCallback, useMemo } from 'react';
import { gisService } from '../services/gisService';

export function useGISData() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Filter States
  const [states, setStates] = useState([]);
  const [selectedStateId, setSelectedStateId] = useState(1); // Default Maharashtra

  const [districts, setDistricts] = useState([]);
  const [selectedDistrictId, setSelectedDistrictId] = useState(null);

  const [projects, setProjects] = useState([]);
  const [selectedProjectId, setSelectedProjectId] = useState(null); // null = All Projects

  // Map Data
  const [corridorsGeoJSON, setCorridorsGeoJSON] = useState({ type: 'FeatureCollection', features: [] });
  const [parcels, setParcels] = useState([]);
  const [fieldOfficers, setFieldOfficers] = useState([]);

  // Selections
  const [selectedParcel, setSelectedParcel] = useState(null);
  const [selectedCorridorSegment, setSelectedCorridorSegment] = useState(null);

  // Active Map Layers
  const [activeLayers, setActiveLayers] = useState({
    corridors: true,
    parcels: true,
    affectedHighlight: true,
    ulpinLabels: true,
    acquisitionStatus: true,
    fieldOfficers: false,
    verificationPoints: false
  });

  // Search State
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);

  // Map Navigation Focus State
  const [mapFocusTarget, setMapFocusTarget] = useState({ center: [18.5750, 73.7400], zoom: 12 }); // { center: [lat, lng], zoom: number }

  // 1. Initial Load: States & Projects
  useEffect(() => {
    let isMounted = true;
    async function initData() {
      try {
        setLoading(true);
        setError(null);

        const [statesData, projsData, officersData] = await Promise.all([
          gisService.getStates(),
          gisService.getGISProjects(),
          gisService.getGISFieldOfficers()
        ]);

        if (isMounted) {
          setStates(statesData);
          setProjects(projsData);
          setFieldOfficers(officersData);
        }
      } catch (err) {
        if (isMounted) {
          setError('Failed to initialize GIS configuration.');
        }
      } finally {
        if (isMounted) setLoading(false);
      }
    }
    initData();
    return () => { isMounted = false; };
  }, []);

  // 2. Cascading: When State changes, fetch Districts
  useEffect(() => {
    let isMounted = true;
    async function loadDistricts() {
      if (!selectedStateId) return;
      try {
        const distsData = await gisService.getDistricts(selectedStateId);
        if (isMounted) {
          setDistricts(distsData);
        }
      } catch (err) {
        console.error('Failed to load districts', err);
      }
    }
    loadDistricts();
    return () => { isMounted = false; };
  }, [selectedStateId]);

  // 3. Load Corridors & Parcels whenever Project / District filter changes
  const loadMapLayers = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      const [corridors, parcelsList] = await Promise.all([
        gisService.getProjectCorridor(selectedProjectId),
        gisService.getGISParcels({
          projectId: selectedProjectId,
          districtId: selectedDistrictId
        })
      ]);

      setCorridorsGeoJSON(corridors);
      setParcels(parcelsList);

      // Adjust Map Focus
      if (Number(selectedProjectId) === 1) {
        setMapFocusTarget({ center: [18.5750, 73.7400], zoom: 12 });
      } else if (Number(selectedProjectId) === 2) {
        setMapFocusTarget({ center: [19.2500, 73.9500], zoom: 10 });
      } else {
        // National / Regional Center (Maharashtra / Pune)
        setMapFocusTarget({ center: [18.7500, 73.8500], zoom: 9 });
      }
    } catch (err) {
      setError('Unable to load project corridor or parcel geometry.');
    } finally {
      setLoading(false);
    }
  }, [selectedProjectId, selectedDistrictId]);

  useEffect(() => {
    loadMapLayers();
  }, [loadMapLayers]);

  // 4. Dynamic KPI Statistics Calculation
  const stats = useMemo(() => {
    let totalLand = 0;
    let acquiredLand = 0;
    let inProgressLand = 0;
    let pendingLand = 0;
    let totalParcels = 0;
    let acquiredParcels = 0;
    let inProgressParcels = 0;
    let pendingParcels = 0;

    if (selectedProjectId) {
      const proj = projects.find(p => p.id === Number(selectedProjectId));
      if (proj) {
        totalLand = proj.total_land_ha;
        acquiredLand = proj.acquired_land_ha;
        inProgressLand = proj.in_progress_land_ha;
        pendingLand = proj.pending_land_ha;
        totalParcels = proj.total_parcels;
        acquiredParcels = proj.acquired_parcels;
        inProgressParcels = proj.in_progress_parcels;
        pendingParcels = proj.pending_parcels;
      }
    } else {
      // Sum all available projects
      projects.forEach(p => {
        totalLand += p.total_land_ha;
        acquiredLand += p.acquired_land_ha;
        inProgressLand += p.in_progress_land_ha;
        pendingLand += p.pending_land_ha;
        totalParcels += p.total_parcels;
        acquiredParcels += p.acquired_parcels;
        inProgressParcels += p.in_progress_parcels;
        pendingParcels += p.pending_parcels;
      });
    }

    const progressPercent = totalLand > 0 
      ? ((acquiredLand / totalLand) * 100).toFixed(1)
      : '0.0';

    return {
      totalLand: totalLand.toFixed(2),
      acquiredLand: acquiredLand.toFixed(2),
      inProgressLand: inProgressLand.toFixed(2),
      pendingLand: pendingLand.toFixed(2),
      progressPercent,
      totalParcels,
      acquiredParcels,
      inProgressParcels,
      pendingParcels
    };
  }, [projects, selectedProjectId]);

  // 5. ULPIN Search Handler
  const handleSearchULPIN = useCallback(async (query) => {
    setSearchQuery(query);
    if (!query || !query.trim()) {
      setSearchResults([]);
      return;
    }
    setIsSearching(true);
    try {
      const results = await gisService.searchByULPIN(query);
      setSearchResults(results);
    } catch (err) {
      console.error('Search error', err);
    } finally {
      setIsSearching(false);
    }
  }, []);

  const handleSelectSearchedParcel = useCallback((parcel) => {
    setSelectedParcel(parcel);
    setSelectedCorridorSegment(null);
    setSearchResults([]);
    setSearchQuery(parcel.ulpin);

    if (parcel.polygon && parcel.polygon.length > 0) {
      setMapFocusTarget({
        center: parcel.polygon[0],
        zoom: 16
      });
    }
  }, []);

  const toggleLayer = useCallback((layerKey) => {
    setActiveLayers(prev => ({
      ...prev,
      [layerKey]: !prev[layerKey]
    }));
  }, []);

  const handleSelectCorridorSegment = useCallback((segmentProps) => {
    setSelectedCorridorSegment(segmentProps);
    setSelectedParcel(null);
  }, []);

  const handleSelectParcel = useCallback((parcel) => {
    setSelectedParcel(parcel);
    setSelectedCorridorSegment(null);
    if (parcel.polygon && parcel.polygon.length > 0) {
      setMapFocusTarget({
        center: parcel.polygon[0],
        zoom: 15
      });
    }
  }, []);

  const handleResetMap = useCallback(() => {
    setSelectedParcel(null);
    setSelectedCorridorSegment(null);
    setSearchQuery('');
    setSearchResults([]);
    setMapFocusTarget({ center: [18.7500, 73.8500], zoom: 9 });
  }, []);

  return {
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
    refreshData: loadMapLayers
  };
}
