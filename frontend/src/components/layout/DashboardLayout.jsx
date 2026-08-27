import React from 'react';
import GovHeader from '../common/GovHeader';
import GovNavbar from '../common/GovNavbar';
import GovFooter from '../common/GovFooter';

export default function DashboardLayout({ children }) {
  return (
    <div className="min-h-screen flex flex-col bg-[#F8FAFC]">
      {/* 1. Official Government Header */}
      <GovHeader />

      {/* 2. Top Orange Navigation Bar */}
      <GovNavbar />

      {/* 3. Main Government Content Portal */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-8 py-6">
        {children}
      </main>

      {/* 4. Official Footer */}
      <GovFooter />
    </div>
  );
}
