import React from 'react';
import emblemImg from '../../assets/emblem.png';

/**
 * Official Government of India Emblem & Identity Component
 * Uses the exact official State Emblem of India image asset.
 * Paired with bilingual government typography:
 * - Hindi: "भारत सरकार"
 * - English: "GOVERNMENT OF INDIA"
 * Clean, minimal, non-decorative official government portal look.
 */
export default function GovEmblem({ className = "" }) {
  return (
    <div className={`flex items-center gap-2.5 bg-transparent select-none ${className}`}>
      {/* Official Government of India Lion Capital Emblem Asset */}
      <img
        src={emblemImg}
        alt="Government of India Emblem"
        className="h-12 sm:h-14 w-auto object-contain shrink-0"
      />

      {/* Official Government Bilingual Typography */}
      <div className="flex flex-col justify-center leading-tight">
        <span className="text-[13px] sm:text-[14px] font-bold text-[#1E293B] tracking-tight font-sans">
          भारत सरकार
        </span>
        <span className="text-[10px] sm:text-[11px] font-bold text-slate-700 tracking-wider uppercase font-sans mt-0.5">
          GOVERNMENT OF INDIA
        </span>
      </div>
    </div>
  );
}
