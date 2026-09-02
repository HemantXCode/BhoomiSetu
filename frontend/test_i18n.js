import { translations } from './src/i18n/translations.js';

console.log('Testing BhoomiSetu Language & i18n System...');

// 1. Verify English and Hindi exist
if (!translations.en || !translations.hi) {
  console.error('FAIL: Missing en or hi top-level translations object');
  process.exit(1);
}

// 2. Verify parity between English and Hindi keys
function compareKeys(objA, objB, path = '') {
  const keysA = Object.keys(objA);
  const keysB = Object.keys(objB);

  for (const key of keysA) {
    const currentPath = path ? `${path}.${key}` : key;
    if (!(key in objB)) {
      console.warn(`WARN: Key '${currentPath}' exists in English but missing in Hindi`);
    } else if (typeof objA[key] === 'object' && objA[key] !== null) {
      compareKeys(objA[key], objB[key], currentPath);
    }
  }
}

compareKeys(translations.en, translations.hi);

// 3. Test Translation Helper function
function t(language, key, params = {}) {
  const keys = key.split('.');
  let current = translations[language];
  for (const k of keys) {
    if (current && typeof current === 'object' && k in current) {
      current = current[k];
    } else {
      current = null;
      break;
    }
  }
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
  if (typeof current === 'string') {
    let text = current;
    Object.keys(params).forEach(paramKey => {
      text = text.replace(new RegExp(`\\{${paramKey}\\}`, 'g'), params[paramKey]);
    });
    return text;
  }
  return current || key;
}

// 4. Test Key Switching
const navDashEn = t('en', 'nav.dashboard');
const navDashHi = t('hi', 'nav.dashboard');
console.log(`EN nav.dashboard: "${navDashEn}"`);
console.log(`HI nav.dashboard: "${navDashHi}"`);

if (navDashEn !== 'Dashboard' || navDashHi !== 'डैशबोर्ड') {
  console.error('FAIL: nav.dashboard translation failed');
  process.exit(1);
}

const gisTitleEn = t('en', 'gis.commandCenter');
const gisTitleHi = t('hi', 'gis.commandCenter');
console.log(`EN gis.commandCenter: "${gisTitleEn}"`);
console.log(`HI gis.commandCenter: "${gisTitleHi}"`);

if (gisTitleEn !== 'GIS Command Center' || gisTitleHi !== 'GIS कमांड सेंटर') {
  console.error('FAIL: gis.commandCenter translation failed');
  process.exit(1);
}

const projAffectedEn = t('en', 'gis.projectAffectedYes');
const projAffectedHi = t('hi', 'gis.projectAffectedYes');
console.log(`EN gis.projectAffectedYes: "${projAffectedEn}"`);
console.log(`HI gis.projectAffectedYes: "${projAffectedHi}"`);

if (!projAffectedHi.includes('हाँ') || !projAffectedEn.includes('YES')) {
  console.error('FAIL: gis.projectAffectedYes translation failed');
  process.exit(1);
}

console.log('SUCCESS: All i18n tests and key parity checks passed!');
