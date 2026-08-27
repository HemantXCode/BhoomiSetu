import React from 'react';
import { Shield, ExternalLink } from 'lucide-react';

export default function GovFooter() {
  return (
    <footer className="w-full bg-[#0B2545] text-slate-300 border-t border-slate-700 mt-12 text-xs">
      {/* Top Footer Ribbon */}
      <div className="max-w-7xl mx-auto px-4 sm:px-8 py-8 grid grid-cols-1 md:grid-cols-4 gap-6">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <span className="font-bold text-white uppercase tracking-wider text-sm">BhoomiSetu</span>
            <span className="bg-orange-600 text-white text-[9px] px-1.5 py-0.5 rounded font-mono">GOI</span>
          </div>
          <p className="text-slate-400 text-xs leading-relaxed">
            National digital platform for real-time tracking, transparent compensation, and statutory compliance across the entire land acquisition lifecycle in India.
          </p>
        </div>

        <div>
          <h4 className="font-semibold text-white mb-2 text-xs uppercase tracking-wider text-orange-400">
            Quick Navigation
          </h4>
          <ul className="space-y-1.5 text-slate-400 text-xs">
            <li><a href="#" className="hover:text-white transition-colors">National Acquisition Guidelines</a></li>
            <li><a href="#" className="hover:text-white transition-colors">RFCTLARR Act, 2013 Reference</a></li>
            <li><a href="#" className="hover:text-white transition-colors">State Revenue Department Portals</a></li>
            <li><a href="#" className="hover:text-white transition-colors">Standard Operating Procedures (SOP)</a></li>
          </ul>
        </div>

        <div>
          <h4 className="font-semibold text-white mb-2 text-xs uppercase tracking-wider text-orange-400">
            National Portals
          </h4>
          <ul className="space-y-1.5 text-slate-400 text-xs">
            <li><a href="https://india.gov.in" target="_blank" rel="noreferrer" className="hover:text-white inline-flex items-center gap-1">National Portal of India <ExternalLink className="w-3 h-3 text-slate-500" /></a></li>
            <li><a href="https://digitalindia.gov.in" target="_blank" rel="noreferrer" className="hover:text-white inline-flex items-center gap-1">Digital India <ExternalLink className="w-3 h-3 text-slate-500" /></a></li>
            <li><a href="https://morth.nic.in" target="_blank" rel="noreferrer" className="hover:text-white inline-flex items-center gap-1">Ministry of Road Transport <ExternalLink className="w-3 h-3 text-slate-500" /></a></li>
            <li><a href="https://rural.nic.in" target="_blank" rel="noreferrer" className="hover:text-white inline-flex items-center gap-1">Ministry of Rural Development <ExternalLink className="w-3 h-3 text-slate-500" /></a></li>
          </ul>
        </div>

        <div>
          <h4 className="font-semibold text-white mb-2 text-xs uppercase tracking-wider text-orange-400">
            Security & Compliance
          </h4>
          <div className="bg-slate-800/80 p-3 rounded border border-slate-700 text-[11px] text-slate-300">
            <div className="flex items-center gap-1.5 text-green-400 font-semibold mb-1">
              <Shield className="w-3.5 h-3.5" />
              Role-Based Access Controlled
            </div>
            <p className="text-slate-400">
              Authorized Government Personnel Only. All access is logged with immutable audit trails.
            </p>
          </div>
        </div>
      </div>

      {/* Bottom Copyright & Disclaimer */}
      <div className="bg-[#07182C] py-3 px-4 sm:px-8 border-t border-slate-800 text-center text-slate-400 text-[11px]">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row justify-between items-center gap-2">
          <span>© 2026 BhoomiSetu. Designed & Developed for Smart India Hackathon (SIH). Government of India.</span>
          <span className="text-slate-500">Version 1.0.0 (Phase 1 Baseline) • Last Refreshed: Today</span>
        </div>
      </div>
    </footer>
  );
}
