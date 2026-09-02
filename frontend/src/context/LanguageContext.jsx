import React, { createContext, useContext, useState, useEffect } from 'react';
import { translations } from '../i18n/translations';

const LanguageContext = createContext(null);

export function LanguageProvider({ children }) {
  // Read initial language from localStorage or default to 'en'
  const [language, setLanguageState] = useState(() => {
    return localStorage.getItem('bhoomi_lang') || 'en';
  });

  const setLanguage = (newLang) => {
    const validLang = newLang === 'hi' || newLang === 'हिन्दी' || newLang === 'हिंदी' ? 'hi' : 'en';
    setLanguageState(validLang);
    localStorage.setItem('bhoomi_lang', validLang);
  };

  // Translation helper supporting nested keys like 'nav.dashboard' and interpolation like {count}
  const t = (key, params = {}) => {
    if (!key) return '';
    const keys = key.split('.');
    
    // 1. Try currently active language
    let current = translations[language];
    for (const k of keys) {
      if (current && typeof current === 'object' && k in current) {
        current = current[k];
      } else {
        current = null;
        break;
      }
    }

    // 2. Fallback to English if missing in active language
    if (!current) {
      let fallback = translations.en;
      for (const k of keys) {
        if (fallback && typeof fallback === 'object' && k in fallback) {
          fallback = fallback[k];
        } else {
          fallback = null;
          break;
        }
      }
      current = fallback || key;
    }

    // 3. String interpolation for {param}
    if (typeof current === 'string') {
      let text = current;
      Object.keys(params).forEach(paramKey => {
        text = text.replace(new RegExp(`\\{${paramKey}\\}`, 'g'), params[paramKey]);
      });
      return text;
    }

    return current || key;
  };

  return (
    <LanguageContext.Provider
      value={{
        language,
        setLanguage,
        t,
        isHindi: language === 'hi'
      }}
    >
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
}
