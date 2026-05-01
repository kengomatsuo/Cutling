/**
 * Auto-route user to their preferred language if they haven't manually selected one.
 * Locale codes match locales.json (lowercased for web paths).
 */
var AVAILABLE_LANGS = [
  'ar-sa', 'bg', 'bn-bd', 'bn-in', 'ca', 'cs', 'da', 'de-de', 'el',
  'en-au', 'en-ca', 'en-gb', 'en-in', 'en-us',
  'es-es', 'es-mx', 'et', 'fa', 'fi', 'fil',
  'fr-ca', 'fr-fr', 'gu-in', 'he', 'hi', 'hr', 'hu', 'id', 'it', 'ja',
  'kn-in', 'ko', 'lt', 'lv', 'ml-in', 'mr-in', 'ms',
  'nl-nl', 'no', 'or-in', 'pa-in', 'pl', 'pt-br', 'pt-pt',
  'ro', 'ru', 'sk', 'sl-si', 'sr', 'sv', 'sw',
  'ta-in', 'te-in', 'th', 'tr', 'uk', 'ur-pk', 'vi',
  'zh-hans', 'zh-hant'
];

(function() {
  var PREF_KEY = 'cutling_lang_preference';
  var DEFAULT_LOCALE = 'en-us';
  var SITE_BASE = '/Cutling';

  var currentPath = window.location.pathname;
  var currentLang = getCurrentLanguage(currentPath, SITE_BASE);
  if (currentLang && currentLang !== DEFAULT_LOCALE) {
    localStorage.setItem(PREF_KEY, currentLang);
    return;
  }

  var storedLang = localStorage.getItem(PREF_KEY);
  var browserLangs = navigator.languages || [navigator.language];
  var preferredLang = storedLang || findMatchingLanguage(browserLangs);

  if (preferredLang && preferredLang !== DEFAULT_LOCALE) {
    if (!storedLang) {
      localStorage.setItem(PREF_KEY, preferredLang);
    }
    var redirectPath = buildRedirectPath(currentPath, preferredLang, SITE_BASE);
    window.location.href = redirectPath;
  }
})();

function getCurrentLanguage(pathname, siteBase) {
  var pathWithoutBase = stripSiteBase(pathname, siteBase);
  var parts = pathWithoutBase.replace(/\/$/, '').split('/').filter(Boolean);
  if (parts.length === 0) {
    return 'en-us';
  }

  var potentialLang = parts[0].toLowerCase();
  if (['faq', 'support', 'privacy', 'img', 'icon.png', 'style.css', '_generator'].indexOf(potentialLang) !== -1) {
    return 'en-us';
  }

  // Check for two-segment codes (e.g. zh-hans, pt-pt)
  if (parts.length >= 2) {
    var twoSeg = (parts[0] + '-' + parts[1]).toLowerCase();
    if (AVAILABLE_LANGS.indexOf(twoSeg) !== -1) {
      return twoSeg;
    }
  }

  if (AVAILABLE_LANGS.indexOf(potentialLang) !== -1) {
    return potentialLang;
  }

  return 'en-us';
}

function findMatchingLanguage(browserLangs) {
  for (var i = 0; i < browserLangs.length; i++) {
    var lang = browserLangs[i].toLowerCase();

    // Norwegian: browser sends "nb" but we use "no"
    if (lang === 'nb' || lang.indexOf('nb-') === 0) {
      return 'no';
    }

    if (AVAILABLE_LANGS.indexOf(lang) !== -1) {
      return lang;
    }

    // Try with common region mappings (e.g. "ar" -> "ar-sa", "de" -> "de-de")
    var withRegion = findLocaleForBase(lang);
    if (withRegion) {
      return withRegion;
    }

    // Try base language from a regional code (e.g. "de-AT" -> "de" -> "de-de")
    var base = lang.split('-')[0];
    if (base !== lang) {
      var baseMatch = findLocaleForBase(base);
      if (baseMatch) {
        return baseMatch;
      }
    }
  }

  return null;
}

function findLocaleForBase(base) {
  // Exact match first
  if (AVAILABLE_LANGS.indexOf(base) !== -1) {
    return base;
  }
  // Find first locale that starts with this base
  for (var i = 0; i < AVAILABLE_LANGS.length; i++) {
    if (AVAILABLE_LANGS[i].indexOf(base + '-') === 0) {
      return AVAILABLE_LANGS[i];
    }
  }
  return null;
}

function buildRedirectPath(currentPath, newLang, siteBase) {
  var pathWithoutBase = stripSiteBase(currentPath, siteBase);
  var langPattern = new RegExp('^/(' + AVAILABLE_LANGS.join('|').replace(/-/g, '\\-') + ')(/|$)');
  var pathWithoutLang = pathWithoutBase.replace(langPattern, '/');
  var isRoot = (pathWithoutLang === '/' || pathWithoutLang === '');

  if (isRoot) {
    return siteBase + '/' + newLang + '/';
  }

  return siteBase + '/' + newLang + pathWithoutLang;
}

function stripSiteBase(pathname, siteBase) {
  if (siteBase && pathname.indexOf(siteBase + '/') === 0) {
    return pathname.slice(siteBase.length);
  }

  if (siteBase && pathname === siteBase) {
    return '/';
  }

  return pathname;
}
