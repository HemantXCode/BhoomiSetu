import React, { useEffect } from 'react';
import 'leaflet/dist/leaflet.css';
import { 
  MapContainer, 
  TileLayer, 
  Polyline, 
  Polygon, 
  Popup, 
  Tooltip, 
  Marker, 
  useMap 
} from 'react-leaflet';
import L from 'leaflet';
import GISLegend from './GISLegend';
import GISLayerControl from './GISLayerControl';
import { Maximize2, User, LandPlot } from 'lucide-react';

// Fix Default Leaflet marker icons in Vite bundler
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: markerIcon2x,
  iconUrl: markerIcon,
  shadowUrl: markerShadow,
});

// Normalize coordinates between GeoJSON [lng, lat] and Leaflet [lat, lng]
function toLeafletLatLng(pt) {
  if (!pt || !Array.isArray(pt) || pt.length < 2) return [18.5204, 73.8567];
  // India bounds: Longitude ~68°E to 97°E, Latitude ~8°N to 37°N
  // If first number > 50, it represents longitude, so swap to [latitude, longitude]
  if (pt[0] > 50 && pt[1] < 40) {
    return [pt[1], pt[0]];
  }
  return [pt[0], pt[1]];
}

// Normalize Polygon array
function toLeafletPolygon(polygon) {
  if (!polygon || !Array.isArray(polygon)) return [];
  if (polygon.length > 0 && Array.isArray(polygon[0]) && Array.isArray(polygon[0][0])) {
    return polygon[0].map(toLeafletLatLng);
  }
  return polygon.map(toLeafletLatLng);
}

// Map Invalidator Hook to ensure proper tile rendering on mount & resize
function MapInvalidator() {
  const map = useMap();

  useEffect(() => {
    const handleResize = () => map.invalidateSize();

    // Trigger progressive invalidations as DOM layout tree settles
    const t1 = setTimeout(() => map.invalidateSize(), 100);
    const t2 = setTimeout(() => map.invalidateSize(), 400);
    const t3 = setTimeout(() => map.invalidateSize(), 1000);

    window.addEventListener('resize', handleResize);
    return () => {
      clearTimeout(t1);
      clearTimeout(t2);
      clearTimeout(t3);
      window.removeEventListener('resize', handleResize);
    };
  }, [map]);

  return null;
}

// Custom Map Controller Hook to update view smoothly
function MapViewController({ focusTarget }) {
  const map = useMap();

  useEffect(() => {
    if (focusTarget && focusTarget.center) {
      map.flyTo(focusTarget.center, focusTarget.zoom || 12, {
        duration: 1.2
      });
    }
  }, [focusTarget, map]);

  return null;
}

// Field Officer Custom Icon
const officerIcon = L.divIcon({
  className: 'custom-officer-icon',
  html: `<div style="background-color: #9333ea; color: white; padding: 4px; border-radius: 50%; border: 2px solid white; box-shadow: 0 2px 6px rgba(0,0,0,0.3); display: flex; align-items: center; justify-content: center; width: 28px; height: 28px;">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
  </div>`,
  iconSize: [28, 28],
  iconAnchor: [14, 14],
  popupAnchor: [0, -14]
});

// Helper to calculate centroid of polygon
function getPolygonCentroid(positions) {
  if (!positions || positions.length === 0) return [18.5204, 73.8567];
  let sumLat = 0;
  let sumLng = 0;
  positions.forEach(pt => {
    sumLat += pt[0];
    sumLng += pt[1];
  });
  return [sumLat / positions.length, sumLng / positions.length];
}

export default function GISMap({
  corridorsGeoJSON,
  parcels,
  fieldOfficers,
  activeLayers,
  selectedParcel,
  selectedCorridorSegment,
  onSelectParcel,
  onSelectCorridorSegment,
  onToggleLayer,
  mapFocusTarget,
  onRecenter
}) {
  // Color resolver for corridor segment status
  const getCorridorColor = (status) => {
    switch (status) {
      case 'ACQUIRED': return '#16A34A'; // Emerald Green
      case 'IN_PROGRESS': return '#EA580C'; // Vibrant Saffron / Amber
      case 'PENDING': return '#DC2626'; // Red
      default: return '#0284C7'; // Blue
    }
  };

  // Style resolver for parcel polygons
  const getParcelStyle = (parcel) => {
    const isSelected = selectedParcel && selectedParcel.id === parcel.id;
    let color = '#DC2626';
    let fillColor = '#EF4444';

    if (parcel.status === 'ACQUIRED') {
      color = '#15803D';
      fillColor = '#22C55E';
    } else if (parcel.status === 'IN_PROGRESS') {
      color = '#C2410C';
      fillColor = '#F97316';
    }

    const isHighlightAffected = activeLayers.affectedHighlight !== false;

    return {
      color: isSelected ? '#1E3A8A' : color,
      weight: isSelected ? 4 : (isHighlightAffected ? 2.5 : 1.5),
      fillColor: isSelected ? '#3B82F6' : fillColor,
      fillOpacity: isSelected ? 0.75 : (activeLayers.acquisitionStatus ? (isHighlightAffected ? 0.45 : 0.3) : 0.15),
      dashArray: parcel.status === 'PENDING' ? '4, 4' : null
    };
  };

  return (
    <div className="relative w-full h-full min-h-[560px] bg-slate-100 overflow-hidden border border-slate-300">
      <MapContainer
        center={[18.7500, 73.8500]}
        zoom={9}
        scrollWheelZoom={true}
        className="w-full h-full z-10"
        style={{ height: '100%', minHeight: '560px', width: '100%' }}
      >
        <MapInvalidator />
        <MapViewController focusTarget={mapFocusTarget} />

        {/* 1. Base Tile Layer (OpenStreetMap standard tile provider) */}
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors | BhoomiSetu GIS'
          url="https://tile.openstreetmap.org/{z}/{x}/{y}.png"
          maxZoom={19}
        />

        {/* 2. Land Parcels Polygons (Layered below corridor) */}
        {activeLayers.parcels && parcels.map((parcel) => {
          if (!parcel.polygon || parcel.polygon.length === 0) return null;
          const polygonPositions = toLeafletPolygon(parcel.polygon);
          const isSelected = selectedParcel && selectedParcel.id === parcel.id;

          return (
            <Polygon
              key={`parcel-${parcel.id}-${parcel.ulpin}`}
              positions={polygonPositions}
              pathOptions={getParcelStyle(parcel)}
              eventHandlers={{
                click: () => onSelectParcel(parcel)
              }}
            >
              <Tooltip sticky direction="top">
                <div className="text-xs font-sans p-0.5">
                  <div className="flex items-center gap-1.5 font-mono font-bold text-slate-900">
                    <span className={`w-2 h-2 rounded-full ${
                      parcel.status === 'ACQUIRED' ? 'bg-emerald-600' :
                      parcel.status === 'IN_PROGRESS' ? 'bg-amber-500' : 'bg-rose-600'
                    }`} />
                    <span>{parcel.ulpin}</span>
                  </div>
                  <div className="text-[11px] text-slate-600 mt-0.5">
                    {parcel.survey_number} • {parcel.village} ({parcel.district})
                  </div>
                  <div className="mt-1 flex items-center justify-between gap-3 border-t border-slate-200 pt-1">
                    <span className="text-[10px] font-bold px-1.5 py-0.5 rounded bg-slate-100 text-slate-800">
                      {parcel.status}
                    </span>
                    <span className="font-mono text-[11px] font-bold text-slate-800">
                      {parcel.area_hectares} Ha
                    </span>
                  </div>
                  <div className="text-[9px] text-orange-700 font-bold mt-1 uppercase tracking-wide">
                    ✓ Project-Affected Land
                  </div>
                </div>
              </Tooltip>

              <Popup>
                <div className="text-xs p-1 max-w-xs font-sans">
                  <div className="font-mono font-bold text-orange-700 text-sm">{parcel.ulpin}</div>
                  <div className="text-slate-700 font-medium">{parcel.survey_number} ({parcel.village})</div>
                  <div className="mt-2 text-[11px] space-y-1 border-t border-slate-200 pt-1.5">
                    <div><strong>Project:</strong> {parcel.project_name}</div>
                    <div><strong>Primary Owner:</strong> {parcel.owner_name}</div>
                    <div><strong>Area:</strong> {parcel.area_hectares} Ha ({(parcel.area_hectares * 10000).toLocaleString()} sq.m)</div>
                    <div><strong>Status:</strong> {parcel.status}</div>
                    <div><strong>Corridor Affected:</strong> <span className="text-emerald-700 font-bold">YES</span></div>
                  </div>
                  <button
                    onClick={() => onSelectParcel(parcel)}
                    className="mt-2.5 w-full bg-[#FF6B00] text-white py-1 px-2 rounded text-center text-xs font-semibold hover:bg-[#D9531E] cursor-pointer"
                  >
                    Open ULPIN 360° View
                  </button>
                </div>
              </Popup>
            </Polygon>
          );
        })}

        {/* 3. Centroid ULPIN & Area Pill Badges */}
        {activeLayers.parcels && activeLayers.ulpinLabels && parcels.map((parcel) => {
          if (!parcel.polygon || parcel.polygon.length === 0) return null;
          const polygonPositions = toLeafletPolygon(parcel.polygon);
          const centroid = getPolygonCentroid(polygonPositions);

          const badgeBorderColor = parcel.status === 'ACQUIRED' ? '#16A34A' :
                                   parcel.status === 'IN_PROGRESS' ? '#EA580C' : '#DC2626';
          const badgeDotColor = parcel.status === 'ACQUIRED' ? '#22C55E' :
                                parcel.status === 'IN_PROGRESS' ? '#F97316' : '#EF4444';
          const shortUlpin = parcel.ulpin.replace('ULPIN-MH-PUN-', '').replace('PUN-', '');

          return (
            <Marker
              key={`ulpin-badge-${parcel.id}-${parcel.ulpin}`}
              position={centroid}
              icon={L.divIcon({
                className: 'ulpin-centroid-badge',
                html: `<div style="background: rgba(15, 23, 42, 0.92); backdrop-filter: blur(3px); color: white; border: 1.5px solid ${badgeBorderColor}; border-radius: 4px; padding: 2px 6px; font-family: monospace; font-size: 10px; font-weight: 800; white-space: nowrap; box-shadow: 0 2px 5px rgba(0,0,0,0.45); display: flex; align-items: center; gap: 4px; cursor: pointer;">
                  <span style="display:inline-block; width:6px; height:6px; border-radius:50%; background:${badgeDotColor};"></span>
                  <span>${shortUlpin}</span>
                  <span style="color:#94a3b8; font-weight:600; font-size:9px;">• ${parcel.area_hectares}Ha</span>
                </div>`,
                iconSize: [100, 20],
                iconAnchor: [50, 10]
              })}
              eventHandlers={{
                click: () => onSelectParcel(parcel)
              }}
            />
          );
        })}

        {/* 4. Right-of-Way (RoW) Acquisition Buffer Strip (Visibly overlapping parcels) */}
        {activeLayers.corridors && corridorsGeoJSON?.features?.map((f, idx) => {
          const rawCoords = f.geometry?.coordinates || [];
          const coords = rawCoords.map(toLeafletLatLng);
          return (
            <React.Fragment key={`row-buffer-${f.properties?.segment_id || idx}`}>
              {/* 4a. 70m RoW Semi-Transparent Buffer Band */}
              <Polyline
                positions={coords}
                pathOptions={{
                  color: '#FF6B00',
                  weight: 34,
                  opacity: 0.22,
                  lineCap: 'round',
                  lineJoin: 'round'
                }}
              >
                <Tooltip sticky direction="top">
                  <div className="text-xs font-sans">
                    <span className="font-bold text-orange-800">Right-of-Way (RoW) Acquisition Corridor</span>
                    <div className="text-[10px] text-slate-600">70m Statutory Demarcation Zone • {f.properties.segment_name}</div>
                  </div>
                </Tooltip>
              </Polyline>

              {/* 4b. RoW Boundary Limit Dashed Guide */}
              <Polyline
                positions={coords}
                pathOptions={{
                  color: '#C2410C',
                  weight: 1.5,
                  opacity: 0.6,
                  dashArray: '6, 6',
                  lineCap: 'round',
                  lineJoin: 'round'
                }}
              />
            </React.Fragment>
          );
        })}

        {/* 5. Multi-Layer Highway Road (Prominently crossing through parcel polygons) */}
        {activeLayers.corridors && corridorsGeoJSON?.features?.map((f, idx) => {
          const rawCoords = f.geometry?.coordinates || [];
          const coords = rawCoords.map(toLeafletLatLng);
          const color = getCorridorColor(f.properties?.status);
          const isSelected = selectedCorridorSegment?.segment_id === f.properties?.segment_id;

          return (
            <React.Fragment key={`corridor-group-${f.properties?.segment_id || idx}`}>
              {/* 5a. Dark Outer Road Casing */}
              <Polyline
                positions={coords}
                pathOptions={{
                  color: '#0F172A',
                  weight: isSelected ? 16 : 14,
                  opacity: 0.95,
                  lineCap: 'round',
                  lineJoin: 'round'
                }}
              />

              {/* 5b. White Road Separator / Divider */}
              <Polyline
                positions={coords}
                pathOptions={{
                  color: '#FFFFFF',
                  weight: isSelected ? 11 : 9,
                  opacity: 0.95,
                  lineCap: 'round',
                  lineJoin: 'round'
                }}
              />

              {/* 5c. Active Status Colored Highway Centerline */}
              <Polyline
                positions={coords}
                pathOptions={{
                  color: isSelected ? '#1E3A8A' : color,
                  weight: isSelected ? 7 : 5,
                  opacity: 1.0,
                  lineCap: 'round',
                  lineJoin: 'round',
                  dashArray: f.properties?.status === 'PENDING' ? '8, 6' : null
                }}
                eventHandlers={{
                  click: () => onSelectCorridorSegment(f.properties)
                }}
              >
                <Tooltip sticky direction="top">
                  <div className="text-xs font-sans p-0.5">
                    <div className="text-[10px] font-bold text-orange-600 uppercase tracking-wider">
                      Project Highway Corridor
                    </div>
                    <div className="font-bold text-slate-900 mt-0.5">{f.properties.segment_name}</div>
                    <div className="text-slate-600 text-[11px]">{f.properties.project_name}</div>
                    <div className="mt-1 flex items-center gap-1.5 border-t border-slate-200 pt-1">
                      <span className="font-semibold text-slate-700">Status:</span>
                      <span className="font-bold" style={{ color }}>{f.properties.status}</span>
                    </div>
                    <div className="text-[10px] text-slate-500 font-mono mt-0.5">
                      {f.properties.length_km} km • {f.properties.land_area_ha} Ha RoW
                    </div>
                  </div>
                </Tooltip>
              </Polyline>
            </React.Fragment>
          );
        })}

        {/* 5. Field Officers Layer (When enabled) */}
        {activeLayers.fieldOfficers && fieldOfficers.map((officer) => (
          <Marker
            key={`officer-${officer.id}`}
            position={officer.last_known_location}
            icon={officerIcon}
          >
            <Popup>
              <div className="text-xs p-1 font-sans">
                <div className="font-bold text-purple-900 flex items-center gap-1">
                  <User className="w-3.5 h-3.5" />
                  {officer.name}
                </div>
                <div className="text-[11px] text-slate-600">{officer.role}</div>
                <div className="mt-1 text-[10px] space-y-0.5 text-slate-700 border-t border-slate-200 pt-1">
                  <div><strong>Assigned:</strong> {officer.assigned_project}</div>
                  <div><strong>Last Active:</strong> {officer.last_visit_time}</div>
                  <div><strong>Tasks Completed:</strong> {officer.completed_tasks}</div>
                </div>
              </div>
            </Popup>
          </Marker>
        ))}
      </MapContainer>

      {/* Floating Map Overlays */}
      {/* 1. Recenter & Fit Bounds Button */}
      <div className="absolute top-3 left-14 z-[1000]">
        <button
          onClick={onRecenter}
          className="bg-white/95 backdrop-blur-sm border border-slate-300 shadow-md px-2.5 py-1.5 rounded text-xs font-semibold text-slate-700 hover:text-slate-900 hover:bg-slate-50 flex items-center gap-1.5 transition-colors cursor-pointer"
          title="Fit bounds to National / Corridor view"
        >
          <Maximize2 className="w-3.5 h-3.5 text-orange-600" />
          <span>Recenter Corridor</span>
        </button>
      </div>

      {/* 2. Top-Right: Layer Controls */}
      <div className="absolute top-3 right-3 z-[1000]">
        <GISLayerControl
          activeLayers={activeLayers}
          onToggleLayer={onToggleLayer}
        />
      </div>

      {/* 3. Bottom-Left: Map Legend */}
      <div className="absolute bottom-4 left-3 z-[1000]">
        <GISLegend />
      </div>
    </div>
  );
}
