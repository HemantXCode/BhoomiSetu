import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';
import { Bell, User, LogOut, Globe, PhoneCall, ShieldCheck } from 'lucide-react';
import GovEmblem from './GovEmblem';

export default function GovHeader() {
  const { user, logout } = useAuth();
  const { language, setLanguage, t } = useLanguage();
  const [fontSize, setFontSize] = useState('A');

  const getRoleDisplayName = (role) => {
    switch (role) {
      case 'CENTRAL_MINISTRY': return t('roles.CENTRAL_MINISTRY');
      case 'STATE_GOVERNMENT': return `${t('roles.STATE_GOVERNMENT')} (${user?.state_name || 'Revenue'})`;
      case 'DISTRICT_AUTHORITY': return `${t('roles.DISTRICT_AUTHORITY')} (${user?.district_name || 'District'})`;
      case 'PROJECT_AGENCY': return `${t('roles.PROJECT_AGENCY')} (${user?.agency_name || 'PSU'})`;
      case 'FIELD_OFFICER': return `${t('roles.FIELD_OFFICER')} (${user?.district_name || 'Unit'})`;
      default: return role || t('roles.authorizedOfficer');
    }
  };

  return (
    <header className="w-full bg-white border-b border-slate-200">
      {/* 1. Indian Flag Tricolor Accent */}
      <div className="gov-tricolor-bar" />

      {/* 2. Top Government Utility Bar */}
      <div className="bg-[#0B2545] text-slate-200 text-xs py-1.5 px-4 sm:px-8 flex flex-wrap justify-between items-center border-b border-slate-700">
        <div className="flex items-center gap-3">
          <span className="font-semibold text-slate-100 flex items-center gap-1.5">
            <span className="inline-block w-2 h-2 rounded-full bg-green-400"></span>
            {t('common.govIndia')}
          </span>
          <span className="hidden md:inline text-slate-400">|</span>
          <span className="hidden md:inline text-slate-300">{t('common.ministry')}</span>
        </div>

        <div className="flex items-center gap-4 text-[11px]">
          {/* Accessibility Font Size Adjuster */}
          <div className="hidden sm:flex items-center gap-1 bg-slate-800 px-2 py-0.5 rounded text-slate-300">
            <span>{t('common.font')}</span>
            <button 
              onClick={() => setFontSize('A-')} 
              className={`px-1 hover:text-white ${fontSize === 'A-' ? 'text-orange-400 font-bold' : ''}`}
            >
              A-
            </button>
            <button 
              onClick={() => setFontSize('A')} 
              className={`px-1 hover:text-white ${fontSize === 'A' ? 'text-orange-400 font-bold' : ''}`}
            >
              A
            </button>
            <button 
              onClick={() => setFontSize('A+')} 
              className={`px-1 hover:text-white ${fontSize === 'A+' ? 'text-orange-400 font-bold' : ''}`}
            >
              A+
            </button>
          </div>

          {/* Language Switch: English | हिन्दी */}
          <div className="flex items-center gap-1.5 bg-slate-800/80 px-2 py-0.5 rounded border border-slate-700">
            <Globe className="w-3.5 h-3.5 text-orange-400" />
            <button 
              onClick={() => setLanguage('en')}
              className={`px-1.5 py-0.5 rounded text-[11px] font-semibold transition-colors cursor-pointer ${
                language === 'en' ? 'bg-orange-600 text-white shadow-xs' : 'text-slate-300 hover:text-white'
              }`}
              title="Switch to English"
            >
              English
            </button>
            <span className="text-slate-500">|</span>
            <button 
              onClick={() => setLanguage('hi')}
              className={`px-1.5 py-0.5 rounded text-[11px] font-semibold transition-colors cursor-pointer ${
                language === 'hi' ? 'bg-orange-600 text-white shadow-xs' : 'text-slate-300 hover:text-white'
              }`}
              title="हिन्दी में बदलें"
            >
              हिन्दी
            </button>
          </div>

          {/* Helpdesk */}
          <div className="hidden sm:flex items-center gap-1 text-slate-300">
            <PhoneCall className="w-3.5 h-3.5 text-green-400" />
            <span>{t('common.tollFree')}</span>
          </div>
        </div>
      </div>

      {/* 3. Main Official Portal Brand Header */}
      <div className="py-3 px-4 sm:px-8 flex flex-col md:flex-row justify-between items-center gap-4 bg-white">
        {/* Left: Official Government of India Identity + BhoomiSetu Platform Brand */}
        <div className="flex items-center flex-wrap sm:flex-nowrap gap-4 sm:gap-5">
          {/* Government of India Identity: Ashoka Emblem + भारत सरकार / GOVERNMENT OF INDIA */}
          <GovEmblem />

          {/* Clean Vertical Divider */}
          <div className="hidden sm:block h-12 w-px bg-slate-300 self-center"></div>

          {/* Portal Names & Subtitle */}
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl sm:text-2xl font-bold tracking-tight text-[#D9531E] uppercase font-sans">
                BHOOMISETU
              </h1>
              <span className="bg-orange-100 text-[#D9531E] border border-orange-200 text-[10px] font-bold px-2 py-0.5 rounded tracking-wide font-sans">
                {t('common.officialPortal')}
              </span>
            </div>
            <p className="text-xs sm:text-sm text-slate-700 font-medium">
              {t('common.tagline')}
            </p>
            <p className="text-[11px] text-slate-500 hidden sm:block">
              {t('common.subTagline')}
            </p>
          </div>
        </div>

        {/* Right Officer Status & Actions */}
        {user && (
          <div className="flex items-center gap-3 w-full md:w-auto justify-end border-t md:border-t-0 pt-2 md:pt-0 border-slate-100">
            {/* Notification Bell */}
            <button 
              className="relative p-2 text-slate-600 hover:text-[#D9531E] hover:bg-orange-50 rounded border border-slate-200 cursor-pointer"
              title="System Alerts"
            >
              <Bell className="w-4 h-4" />
              <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full animate-pulse"></span>
            </button>

            {/* Officer Information Card */}
            <div className="flex items-center gap-2.5 bg-slate-50 border border-slate-200 px-3 py-1.5 rounded text-left">
              <div className="w-8 h-8 rounded bg-[#D9531E] text-white flex items-center justify-center font-bold text-xs">
                <User className="w-4 h-4" />
              </div>
              <div className="text-xs">
                <div className="font-semibold text-slate-900 leading-tight">{user.name}</div>
                <div className="text-[11px] text-[#D9531E] font-medium flex items-center gap-1">
                  <ShieldCheck className="w-3 h-3 inline text-green-600" />
                  {getRoleDisplayName(user.role)}
                </div>
              </div>
            </div>

            {/* Logout Button */}
            <button
              onClick={logout}
              className="gov-btn-secondary py-1.5 px-3 text-xs text-red-700 hover:bg-red-50 hover:border-red-300 cursor-pointer"
              title="Secure Sign Out"
            >
              <LogOut className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">{t('common.logout')}</span>
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
