import React from 'react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';
import { 
  LayoutDashboard, 
  FolderKanban, 
  Map, 
  FileCheck2, 
  Coins, 
  Users, 
  FileText, 
  BarChart3, 
  HelpCircle,
  Smartphone
} from 'lucide-react';

export default function GovNavbar() {
  const { user } = useAuth();
  const { t } = useLanguage();
  if (!user) return null;

  const role = user.role;

  // Define authorized links based on role
  const getNavItems = () => {
    const baseItems = [
      { name: t('nav.dashboard'), path: '/dashboard', icon: LayoutDashboard, exact: true },
      { name: t('nav.projects'), path: '/projects', icon: FolderKanban }
    ];

    if (role === 'CENTRAL_MINISTRY') {
      return [
        ...baseItems,
        { name: t('nav.mobileInspection'), path: '/mobile-inspection', icon: Smartphone },
        { name: t('nav.gisCommandCenter'), path: '/gis', icon: Map },
        { name: t('nav.compensation'), path: '#compensation', icon: Coins, badge: 'Phase 5' },
        { name: t('nav.rrManagement'), path: '#rr', icon: Users, badge: 'Phase 6' },
        { name: t('nav.misReports'), path: '#mis', icon: BarChart3, badge: 'Phase 9' },
        { name: t('nav.helpManuals'), path: '#help', icon: HelpCircle }
      ];
    }

    if (role === 'STATE_GOVERNMENT') {
      return [
        ...baseItems,
        { name: t('nav.mobileInspection'), path: '/mobile-inspection', icon: Smartphone },
        { name: t('nav.gisCommandCenter'), path: '/gis', icon: Map },
        { name: t('nav.stateApprovals'), path: '#approvals', icon: FileCheck2 },
        { name: t('nav.compensation'), path: '#compensation', icon: Coins, badge: 'Phase 5' },
        { name: t('nav.stateMis'), path: '#mis', icon: BarChart3, badge: 'Phase 9' },
        { name: t('nav.helpManuals'), path: '#help', icon: HelpCircle }
      ];
    }

    if (role === 'DISTRICT_AUTHORITY') {
      return [
        ...baseItems,
        { name: t('nav.mobileInspection'), path: '/mobile-inspection', icon: Smartphone },
        { name: t('nav.cadastralMap'), path: '/gis', icon: Map },
        { name: t('nav.disbursement'), path: '#compensation', icon: Coins, badge: 'Phase 5' },
        { name: t('nav.districtMis'), path: '#mis', icon: BarChart3, badge: 'Phase 9' },
        { name: t('nav.helpManuals'), path: '#help', icon: HelpCircle }
      ];
    }

    if (role === 'PROJECT_AGENCY') {
      return [
        ...baseItems,
        { name: t('nav.mobileInspection'), path: '/mobile-inspection', icon: Smartphone },
        { name: t('nav.corridorGis'), path: '/gis', icon: Map },
        { name: t('nav.milestoneTracker'), path: '#milestones', icon: BarChart3 },
        { name: t('nav.helpManuals'), path: '#help', icon: HelpCircle }
      ];
    }

    if (role === 'FIELD_OFFICER') {
      return [
        ...baseItems,
        { name: t('nav.mobileInspection'), path: '/mobile-inspection', icon: Smartphone },
        { name: t('nav.gisMapPins'), path: '/gis', icon: Map },
        { name: t('nav.helpGuidelines'), path: '#help', icon: HelpCircle }
      ];
    }

    return baseItems;
  };

  const navItems = getNavItems();

  return (
    <nav className="bg-[#FF6B00] text-white border-y border-[#D9531E] shadow-sm sticky top-0 z-30">
      <div className="max-w-7xl mx-auto px-4 sm:px-8 flex items-center overflow-x-auto scrollbar-none">
        {navItems.map((item, idx) => {
          const Icon = item.icon;
          const isPlaceholder = item.path.startsWith('#');

          if (isPlaceholder) {
            return (
              <span
                key={idx}
                className="px-3.5 py-2.5 text-xs sm:text-sm font-medium text-orange-100 flex items-center gap-1.5 whitespace-nowrap opacity-75 cursor-not-allowed hover:bg-orange-600/30"
                title={`${item.name} is scheduled for future development phases`}
              >
                <Icon className="w-4 h-4 text-orange-200" />
                <span>{item.name}</span>
                {item.badge && (
                  <span className="bg-orange-800/80 text-[10px] px-1.5 py-0.2 rounded font-normal text-orange-200">
                    {item.badge}
                  </span>
                )}
              </span>
            );
          }

          return (
            <NavLink
              key={idx}
              to={item.path}
              className={({ isActive }) =>
                `px-3.5 py-2.5 text-xs sm:text-sm font-medium flex items-center gap-1.5 whitespace-nowrap transition-colors border-b-2 ${
                  isActive
                    ? 'bg-[#D9531E] text-white border-white font-semibold'
                    : 'text-orange-50 hover:bg-[#D9531E]/70 hover:text-white border-transparent'
                }`
              }
            >
              <Icon className="w-4 h-4" />
              <span>{item.name}</span>
            </NavLink>
          );
        })}
      </div>
    </nav>
  );
}
