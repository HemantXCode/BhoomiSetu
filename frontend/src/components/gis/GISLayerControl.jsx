import React, { useState } from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { SlidersHorizontal, ChevronDown, ChevronUp } from 'lucide-react';

export default function GISLayerControl({ activeLayers, onToggleLayer }) {
  const { t } = useLanguage();
  const [isOpen, setIsOpen] = useState(true);

  const layersConfig = [
    { key: 'corridors', label: t('gis.projectCorridorLayer'), count: 'RoW' },
    { key: 'parcels', label: t('gis.cadastralParcelsLayer'), count: 'ULPIN' },
    { key: 'affectedHighlight', label: t('gis.affectedHighlightLayer'), count: 'RoW' },
    { key: 'ulpinLabels', label: t('gis.ulpinLabelsLayer'), count: 'Pills' },
    { key: 'acquisitionStatus', label: t('gis.acquisitionStatusLayer'), count: 'Colors' }
  ];

  return (
    <div className="bg-white/95 backdrop-blur-sm border border-slate-300 shadow-md rounded text-xs p-2.5 min-w-[220px] z-[1000]">
      <div
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center justify-between font-bold text-slate-800 uppercase tracking-wider text-[11px] cursor-pointer pb-1 select-none"
      >
        <span className="flex items-center gap-1.5">
          <SlidersHorizontal className="w-3.5 h-3.5 text-orange-600" />
          {t('gis.layerControls')}
        </span>
        <button className="p-0.5 text-slate-500 hover:text-slate-800 cursor-pointer">
          {isOpen ? <ChevronUp className="w-3.5 h-3.5" /> : <ChevronDown className="w-3.5 h-3.5" />}
        </button>
      </div>

      {isOpen && (
        <div className="mt-2 space-y-2 border-t border-slate-200 pt-2">
          {layersConfig.map((layer) => (
            <label
              key={layer.key}
              className="flex items-center justify-between gap-2 cursor-pointer hover:bg-slate-50 p-1 rounded transition-colors"
            >
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={activeLayers[layer.key] !== false}
                  onChange={() => onToggleLayer(layer.key)}
                  className="rounded border-slate-300 text-orange-600 focus:ring-orange-500 cursor-pointer w-3.5 h-3.5"
                />
                <span className="text-[11px] font-medium text-slate-700 select-none">
                  {layer.label}
                </span>
              </div>
              <span className="text-[9px] text-slate-400 font-mono">
                {layer.count}
              </span>
            </label>
          ))}
        </div>
      )}
    </div>
  );
}
