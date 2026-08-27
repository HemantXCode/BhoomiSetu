import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight, Home } from 'lucide-react';

export default function Breadcrumbs({ items = [] }) {
  return (
    <nav className="flex items-center gap-1.5 text-xs text-slate-500 mb-4 bg-slate-100/70 px-3 py-1.5 rounded border border-slate-200" aria-label="Breadcrumb">
      <Link to="/" className="text-slate-600 hover:text-[#D9531E] flex items-center gap-1 font-medium">
        <Home className="w-3.5 h-3.5" />
        <span>Portal</span>
      </Link>

      {items.map((item, index) => {
        const isLast = index === items.length - 1;
        return (
          <React.Fragment key={index}>
            <ChevronRight className="w-3 h-3 text-slate-400 shrink-0" />
            {isLast || !item.path ? (
              <span className="font-semibold text-slate-800 truncate">{item.label}</span>
            ) : (
              <Link to={item.path} className="text-slate-600 hover:text-[#D9531E] truncate font-medium">
                {item.label}
              </Link>
            )}
          </React.Fragment>
        );
      })}
    </nav>
  );
}
