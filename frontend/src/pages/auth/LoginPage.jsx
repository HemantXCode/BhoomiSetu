import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { Shield, Lock, Mail, AlertCircle, CheckCircle2, Globe, KeyRound, Sparkles } from 'lucide-react';
import GovEmblem from '../../components/common/GovEmblem';

export default function LoginPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const { login, getDashboardRouteForRole, isAuthenticated, user } = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [lang, setLang] = useState('English');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // If already authenticated, redirect to appropriate dashboard
  React.useEffect(() => {
    if (isAuthenticated && user) {
      navigate(getDashboardRouteForRole(user.role), { replace: true });
    }
  }, [isAuthenticated, user, navigate, getDashboardRouteForRole]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const loggedInUser = await login(email, password);
      const targetRoute = getDashboardRouteForRole(loggedInUser.role);
      navigate(targetRoute, { replace: true });
    } catch (err) {
      setError(err.response?.data?.message || err.message || 'Invalid credentials. Please verify and retry.');
    } finally {
      setLoading(false);
    }
  };

  const handleQuickFill = (demoEmail) => {
    setEmail(demoEmail);
    setPassword('Demo@12345');
    setError(null);
  };

  return (
    <div className="min-h-screen flex flex-col bg-[#F1F5F9]">
      {/* 1. Indian Tricolor Bar */}
      <div className="gov-tricolor-bar" />

      {/* 2. Top Portal Utility Bar */}
      <div className="bg-[#0B2545] text-slate-200 text-xs py-1.5 px-4 sm:px-8 flex justify-between items-center border-b border-slate-700">
        <div className="flex items-center gap-2 font-semibold">
          <span className="w-2 h-2 rounded-full bg-green-400"></span>
          <span>Government of India | भारत सरकार</span>
        </div>
        <div className="flex items-center gap-4 text-[11px]">
          <div className="flex items-center gap-1">
            <Globe className="w-3.5 h-3.5 text-orange-400" />
            <button 
              onClick={() => setLang(lang === 'English' ? 'हिंदी' : 'English')}
              className="hover:text-orange-300 font-medium"
            >
              {lang === 'English' ? 'हिंदी' : 'English'}
            </button>
          </div>
          <span className="hidden sm:inline text-slate-400">|</span>
          <span className="hidden sm:inline">National Informatics Portal</span>
        </div>
      </div>

      {/* 3. Main Login Content */}
      <main className="flex-1 flex items-center justify-center p-4 sm:p-6 my-4">
        <div className="max-w-4xl w-full grid grid-cols-1 md:grid-cols-12 gap-0 gov-card overflow-hidden shadow-lg border-t-4 border-t-[#FF6B00]">
          
          {/* Left Hero Panel (Government Identity & Details) */}
          <div className="md:col-span-5 bg-gradient-to-b from-[#0B2545] to-[#07182C] text-white p-6 sm:p-8 flex flex-col justify-between">
            <div>
              {/* Official Government of India Identity Box */}
              <div className="bg-white p-3 rounded shadow-xs mb-4 inline-flex items-center gap-3 border border-slate-200">
                <GovEmblem />
              </div>

              <span className="text-[11px] uppercase tracking-widest text-orange-400 font-bold block mb-1">
                National Portal of India
              </span>
              <h1 className="text-2xl font-bold tracking-tight text-white mb-2 uppercase">
                BHOOMISETU
              </h1>
              <p className="text-xs text-slate-300 leading-relaxed mb-4">
                Real-Time National Land Acquisition & Management System.
              </p>

              <div className="border-t border-slate-700 pt-4 space-y-2.5 text-xs text-slate-300">
                <div className="flex items-start gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                  <span>Central to Field Officer Coordination</span>
                </div>
                <div className="flex items-start gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                  <span>Transparent Land Acquisition Tracking</span>
                </div>
                <div className="flex items-start gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                  <span>Statutory RFCTLARR Compliance</span>
                </div>
              </div>
            </div>

            <div className="mt-8 pt-4 border-t border-slate-700/80 text-[11px] text-slate-400">
              <div className="flex items-center gap-1.5 text-orange-300 font-medium mb-1">
                <Shield className="w-3.5 h-3.5 text-green-400" />
                <span>Government of India Platform</span>
              </div>
              <p>Your session and data are protected with 256-bit statutory encryption.</p>
            </div>
          </div>

          {/* Right Form Panel (Official Authentication) */}
          <div className="md:col-span-7 bg-white p-6 sm:p-8 flex flex-col justify-between">
            <div>
              <div className="border-b border-slate-200 pb-3 mb-5">
                <h2 className="text-lg font-bold text-slate-900 uppercase tracking-tight">
                  Official Officer Sign In
                </h2>
                <p className="text-xs text-slate-500">
                  Please enter your authorized Government email credentials to access your designated dashboard.
                </p>
              </div>

              {/* Error Notification */}
              {error && (
                <div className="mb-4 p-3 bg-red-50 border-l-4 border-l-red-600 border border-red-200 rounded text-xs text-red-800 flex items-start gap-2">
                  <AlertCircle className="w-4 h-4 text-red-600 shrink-0 mt-0.5" />
                  <div>
                    <span className="font-bold">Authentication Failed: </span>
                    {error}
                  </div>
                </div>
              )}

              {/* Session Expired Notification */}
              {location.search.includes('session_expired') && (
                <div className="mb-4 p-3 bg-amber-50 border-l-4 border-l-amber-600 border border-amber-200 rounded text-xs text-amber-800 flex items-start gap-2">
                  <AlertCircle className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
                  <div>Your session has expired. Please sign in again.</div>
                </div>
              )}

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase mb-1">
                    Official User ID / Email Address <span className="text-red-500">*</span>
                  </label>
                  <div className="relative">
                    <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                    <input
                      type="email"
                      required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="e.g. central.demo@example.com"
                      className="w-full pl-9 pr-3 py-2 text-sm bg-slate-50 border border-slate-300 rounded focus:bg-white focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none"
                    />
                  </div>
                </div>

                <div>
                  <div className="flex justify-between items-center mb-1">
                    <label className="block text-xs font-bold text-slate-700 uppercase">
                      Password <span className="text-red-500">*</span>
                    </label>
                    <a 
                      href="#forgot" 
                      onClick={(e) => { e.preventDefault(); alert('Please contact your designated System Administrator / Nodal Officer for password reset.'); }}
                      className="text-xs text-[#D9531E] hover:underline font-medium"
                    >
                      Forgot Password?
                    </a>
                  </div>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                    <input
                      type="password"
                      required
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="••••••••••••"
                      className="w-full pl-9 pr-3 py-2 text-sm bg-slate-50 border border-slate-300 rounded focus:bg-white focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none"
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full gov-btn-primary py-2.5 text-sm font-semibold tracking-wide uppercase disabled:opacity-50 mt-2"
                >
                  {loading ? (
                    <span className="flex items-center gap-2">
                      <span className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                      Authenticating...
                    </span>
                  ) : (
                    <span className="flex items-center gap-2">
                      <KeyRound className="w-4 h-4" />
                      Sign In to BhoomiSetu
                    </span>
                  )}
                </button>
              </form>
            </div>

            {/* Quick Demo Credentials Panel for Reviewers */}
            <div className="mt-6 pt-4 border-t border-slate-200">
              <div className="flex items-center justify-between mb-2">
                <span className="text-[11px] font-bold text-slate-700 uppercase flex items-center gap-1">
                  <Sparkles className="w-3 h-3 text-orange-500" />
                  Quick Demo Credentials (Password: Demo@12345)
                </span>
              </div>
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-1.5 text-[11px]">
                <button
                  type="button"
                  onClick={() => handleQuickFill('central.demo@example.com')}
                  className="p-1.5 text-left bg-slate-100 hover:bg-orange-50 hover:border-orange-300 border border-slate-200 rounded text-slate-800 transition-colors"
                >
                  <div className="font-bold text-orange-800">1. Central Ministry</div>
                  <div className="text-[10px] text-slate-500 truncate">central.demo@...</div>
                </button>

                <button
                  type="button"
                  onClick={() => handleQuickFill('state.demo@example.com')}
                  className="p-1.5 text-left bg-slate-100 hover:bg-orange-50 hover:border-orange-300 border border-slate-200 rounded text-slate-800 transition-colors"
                >
                  <div className="font-bold text-orange-800">2. State Govt</div>
                  <div className="text-[10px] text-slate-500 truncate">state.demo@... (MH)</div>
                </button>

                <button
                  type="button"
                  onClick={() => handleQuickFill('district.demo@example.com')}
                  className="p-1.5 text-left bg-slate-100 hover:bg-orange-50 hover:border-orange-300 border border-slate-200 rounded text-slate-800 transition-colors"
                >
                  <div className="font-bold text-orange-800">3. District Auth</div>
                  <div className="text-[10px] text-slate-500 truncate">district.demo@... (Pune)</div>
                </button>

                <button
                  type="button"
                  onClick={() => handleQuickFill('agency.demo@example.com')}
                  className="p-1.5 text-left bg-slate-100 hover:bg-orange-50 hover:border-orange-300 border border-slate-200 rounded text-slate-800 transition-colors"
                >
                  <div className="font-bold text-orange-800">4. Project Agency</div>
                  <div className="text-[10px] text-slate-500 truncate">agency.demo@... (NHAI)</div>
                </button>

                <button
                  type="button"
                  onClick={() => handleQuickFill('field.demo@example.com')}
                  className="p-1.5 text-left bg-slate-100 hover:bg-orange-50 hover:border-orange-300 border border-slate-200 rounded text-slate-800 transition-colors col-span-2 sm:col-span-1"
                >
                  <div className="font-bold text-orange-800">5. Field Officer</div>
                  <div className="text-[10px] text-slate-500 truncate">field.demo@... (Mobile)</div>
                </button>
              </div>
            </div>

          </div>
        </div>
      </main>

      {/* 4. Footer */}
      <footer className="py-3 px-4 text-center text-xs text-slate-500 border-t border-slate-200 bg-white">
        Official Digital Portal • Government of India • Ministry of Rural Development & MoRTH
      </footer>
    </div>
  );
}
