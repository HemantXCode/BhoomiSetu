import React from 'react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
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
  if (!user) return null;

  const role = user.role;

  // Define authorized links based on role
  const getNavItems = () => {
    const dashboardPath = (() => {
      switch (role) {
        case 'CENTRAL_MINISTRY': return '/central/dashboard';
        case 'STATE_GOVERNMENT': return '/state/dashboard';
        case 'DISTRICT_AUTHORITY': return '/district/dashboard';
        case 'PROJECT_AGENCY': return '/agency/dashboard';
        case 'FIELD_OFFICER': return '/field/dashboard';
        default: return '/login';
      }
    })();

    const baseItems = [
      { name: 'Dashboard', path: dashboardPath, icon: LayoutDashboard, exact: true },
      { name: 'Projects Directory', path: '/projects', icon: FolderKanban }
    ];

    if (role === 'CENTRAL_MINISTRY') {
      return [
        ...baseItems,
        { name: 'National GIS Map (Ph-4)', path: '#gis-map', icon: Map, badge: 'Phase 4' },
        { name: 'Compensation (Ph-5)', path: '#compensation', icon: Coins, badge: 'Phase 5' },
        { name: 'R&R Management (Ph-6)', path: '#rr', icon: Users, badge: 'Phase 6' },
        { name: 'MIS Reports (Ph-9)', path: '#mis', icon: BarChart3, badge: 'Phase 9' },
        { name: 'Help & Manuals', path: '#help', icon: HelpCircle }
      ];
    }

    if (role === 'STATE_GOVERNMENT') {
      return [
        ...baseItems,
        { name: 'State GIS Map (Ph-4)', path: '#gis-map', icon: Map, badge: 'Phase 4' },
        { name: 'State Approvals', path: '#approvals', icon: FileCheck2 },
        { name: 'Compensation (Ph-5)', path: '#compensation', icon: Coins, badge: 'Phase 5' },
        { name: 'State MIS (Ph-9)', path: '#mis', icon: BarChart3, badge: 'Phase 9' },
        { name: 'Help & Manuals', path: '#help', icon: HelpCircle }
      ];
    }

    if (role === 'DISTRICT_AUTHORITY') {
      return [
        ...baseItems,
        { name: 'Field Queue', path: '#field-queue', icon: FileCheck2 },
        { name: 'Land Cadastral Map (Ph-4)', path: '#gis-map', icon: Map, badge: 'Phase 4' },
        { name: 'Disbursement (Ph-5)', path: '#compensation', icon: Coins, badge: 'Phase 5' },
        { name: 'District MIS (Ph-9)', path: '#mis', icon: BarChart3, badge: 'Phase 9' },
        { name: 'Help & Manuals', path: '#help', icon: HelpCircle }
      ];
    }

    if (role === 'PROJECT_AGENCY') {
      return [
        ...baseItems,
        { name: 'Project Proposals', path: '#proposals', icon: FileText },
        { name: 'Agency GIS (Ph-4)', path: '#gis-map', icon: Map, badge: 'Phase 4' },
        { name: 'Milestone Tracker', path: '#milestones', icon: BarChart3 },
        { name: 'Help & Manuals', path: '#help', icon: HelpCircle }
      ];
    }

    if (role === 'FIELD_OFFICER') {
      return [
        ...baseItems,
        { name: 'Mobile Inspection', path: '/field/dashboard', icon: Smartphone },
        { name: 'GPS Verification (Ph-4)', path: '#gps', icon: Map, badge: 'Phase 4' },
        { name: 'Help & Guidelines', path: '#help', icon: HelpCircle }
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
