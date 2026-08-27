import React from 'react';

export default function StatCard({
  title,
  value,
  unit = '',
  subtitle = '',
  icon: Icon,
  trend = null,
  colorScheme = 'orange', // 'orange', 'blue', 'green', 'amber', 'red'
  onClick = null
}) {
  const getColorStyles = () => {
    switch (colorScheme) {
      case 'green':
        return {
          border: 'border-l-4 border-l-emerald-600 border-slate-200',
          bgIcon: 'bg-emerald-50 text-emerald-700',
          badge: 'bg-emerald-100 text-emerald-800'
        };
      case 'amber':
        return {
          border: 'border-l-4 border-l-amber-500 border-slate-200',
          bgIcon: 'bg-amber-50 text-amber-700',
          badge: 'bg-amber-100 text-amber-800'
        };
      case 'red':
        return {
          border: 'border-l-4 border-l-rose-600 border-slate-200',
          bgIcon: 'bg-rose-50 text-rose-700',
          badge: 'bg-rose-100 text-rose-800'
        };
      case 'blue':
        return {
          border: 'border-l-4 border-l-sky-600 border-slate-200',
          bgIcon: 'bg-sky-50 text-sky-700',
          badge: 'bg-sky-100 text-sky-800'
        };
      case 'orange':
      default:
        return {
          border: 'border-l-4 border-l-[#FF6B00] border-slate-200',
          bgIcon: 'bg-orange-50 text-[#D9531E]',
          badge: 'bg-orange-100 text-orange-800'
        };
    }
  };

  const styles = getColorStyles();

  return (
    <div 
      className={`gov-card ${styles.border} p-4 flex flex-col justify-between transition-all ${
        onClick ? 'cursor-pointer hover:shadow-md hover:border-slate-300' : ''
      }`}
      onClick={onClick}
    >
      <div className="flex items-start justify-between gap-2">
        <div>
          <span className="text-xs font-semibold uppercase tracking-wider text-slate-500 block mb-1">
            {title}
          </span>
          <div className="text-2xl font-bold text-slate-900 leading-tight">
            {value}
            {unit && <span className="text-sm font-normal text-slate-600 ml-1">{unit}</span>}
          </div>
        </div>

        {Icon && (
          <div className={`w-9 h-9 rounded flex items-center justify-center ${styles.bgIcon}`}>
            <Icon className="w-5 h-5" />
          </div>
        )}
      </div>

      {(subtitle || trend) && (
        <div className="mt-3 pt-2 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
          <span>{subtitle}</span>
          {trend && (
            <span className={`font-semibold ${styles.badge} px-1.5 py-0.5 rounded text-[10px]`}>
              {trend}
            </span>
          )}
        </div>
      )}
    </div>
  );
}
