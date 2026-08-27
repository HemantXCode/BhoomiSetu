import React from 'react';

export default function StatusBadge({ status }) {
  const getBadgeConfig = (st) => {
    switch (st) {
      case 'PROPOSED':
        return {
          label: 'Proposed / Formulation',
          className: 'bg-slate-100 text-slate-800 border-slate-300'
        };
      case 'SURVEY_IN_PROGRESS':
        return {
          label: 'Survey / JMS Active',
          className: 'bg-sky-50 text-sky-800 border-sky-300'
        };
      case 'NOTIFICATION_IN_PROGRESS':
        return {
          label: 'Notification (Sec 4/11)',
          className: 'bg-indigo-50 text-indigo-800 border-indigo-300'
        };
      case 'AWARD_IN_PROGRESS':
        return {
          label: 'Award Determination',
          className: 'bg-purple-50 text-purple-800 border-purple-300'
        };
      case 'COMPENSATION_IN_PROGRESS':
        return {
          label: 'Compensation / DBT',
          className: 'bg-amber-50 text-amber-800 border-amber-300'
        };
      case 'POSSESSION_IN_PROGRESS':
        return {
          label: 'Possession in Progress',
          className: 'bg-teal-50 text-teal-800 border-teal-300'
        };
      case 'POSSESSION_HANDED_OVER':
        return {
          label: 'Handed Over / Completed',
          className: 'bg-emerald-50 text-emerald-800 border-emerald-300'
        };
      case 'DELAYED':
        return {
          label: 'Delayed / Flagged',
          className: 'bg-rose-50 text-rose-800 border-rose-300 font-semibold'
        };
      default:
        return {
          label: st || 'Unknown',
          className: 'bg-slate-100 text-slate-800 border-slate-300'
        };
    }
  };

  const { label, className } = getBadgeConfig(status);

  return (
    <span className={`inline-flex items-center px-2 py-0.5 rounded text-[11px] font-medium border ${className}`}>
      {status === 'DELAYED' && <span className="w-1.5 h-1.5 rounded-full bg-rose-600 mr-1 animate-pulse"></span>}
      {status === 'POSSESSION_HANDED_OVER' && <span className="w-1.5 h-1.5 rounded-full bg-emerald-600 mr-1"></span>}
      {label}
    </span>
  );
}
