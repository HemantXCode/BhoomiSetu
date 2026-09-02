import React, { useState, useRef, useEffect } from 'react';
import { useLanguage } from '../../context/LanguageContext';
import { Search, X, Loader2, LandPlot } from 'lucide-react';

export default function ULPINSearch({
  searchQuery,
  searchResults,
  isSearching,
  onSearchChange,
  onSelectParcel,
  onClear
}) {
  const { t } = useLanguage();
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef(null);

  // Close dropdown on outside click
  useEffect(() => {
    function handleClickOutside(event) {
      if (containerRef.current && !containerRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleInputChange = (e) => {
    const val = e.target.value;
    onSearchChange(val);
    setIsOpen(val.trim().length > 0);
  };

  const handleSelect = (parcel) => {
    onSelectParcel(parcel);
    setIsOpen(false);
  };

  const handleClear = () => {
    onClear();
    setIsOpen(false);
  };

  return (
    <div ref={containerRef} className="relative w-full max-w-md">
      <div className="relative flex items-center">
        <Search className="w-4 h-4 text-slate-400 absolute left-3 pointer-events-none" />
        <input
          type="text"
          value={searchQuery}
          onChange={handleInputChange}
          onFocus={() => setIsOpen(searchQuery.trim().length > 0 && searchResults.length > 0)}
          placeholder={t('gis.searchUlpin')}
          className="w-full pl-9 pr-8 py-2 border border-slate-300 rounded bg-white text-slate-900 text-xs sm:text-sm font-medium focus:outline-none focus:ring-2 focus:ring-orange-500 shadow-sm min-h-[42px]"
        />
        {isSearching ? (
          <Loader2 className="w-4 h-4 text-orange-500 animate-spin absolute right-3" />
        ) : searchQuery ? (
          <button
            onClick={handleClear}
            className="p-1 text-slate-400 hover:text-slate-600 absolute right-2.5 cursor-pointer"
            title="Clear search"
          >
            <X className="w-4 h-4" />
          </button>
        ) : null}
      </div>

      {/* Dropdown Suggestions */}
      {isOpen && (
        <div className="absolute top-full left-0 right-0 mt-1 bg-white border border-slate-300 rounded shadow-xl z-50 max-h-72 overflow-y-auto">
          {searchResults.length > 0 ? (
            <div className="py-1 divide-y divide-slate-100">
              <div className="px-3 py-1.5 text-[11px] font-bold text-slate-500 bg-slate-50 uppercase tracking-wider">
                Matching Land Parcels ({searchResults.length})
              </div>
              {searchResults.map((p) => (
                <button
                  key={p.id}
                  onClick={() => handleSelect(p)}
                  className="w-full px-3 py-2 text-left hover:bg-orange-50 flex items-center justify-between gap-2 transition-colors cursor-pointer"
                >
                  <div className="flex items-center gap-2">
                    <LandPlot className="w-4 h-4 text-orange-600 flex-shrink-0" />
                    <div>
                      <div className="text-xs font-bold font-mono text-slate-900">
                        {p.ulpin}
                      </div>
                      <div className="text-[11px] text-slate-600">
                        {p.survey_number} • {p.village}, {p.district}
                      </div>
                    </div>
                  </div>
                  <div className="text-right flex flex-col items-end">
                    <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded ${
                      p.status === 'ACQUIRED' ? 'bg-emerald-100 text-emerald-800' :
                      p.status === 'IN_PROGRESS' ? 'bg-amber-100 text-amber-800' :
                      'bg-rose-100 text-rose-800'
                    }`}>
                      {p.status}
                    </span>
                    <span className="text-[10px] text-slate-500 font-mono mt-0.5">
                      {p.area_hectares} Ha
                    </span>
                  </div>
                </button>
              ))}
            </div>
          ) : (
            <div className="p-3 text-xs text-slate-500 text-center">
              No matching parcels found.
            </div>
          )}
        </div>
      )}
    </div>
  );
}
