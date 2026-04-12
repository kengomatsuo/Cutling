/**
 * Auto-route user to their preferred language if they haven't manually selected one.
 * Call this early in page load (before other scripts).
 */
(function() {
  const PREF_KEY = 'cutling_lang_preference';
  const AVAILABLE_LANGS = [
    'en', 'ar', 'bg', 'bn', 'ca', 'cs', 'da', 'de', 'el', 'en-AU', 'en-GB', 'en-IN',
    'es', 'et', 'fa', 'fi', 'fil', 'fr', 'gu', 'he', 'hi', 'hr', 'hu', 'id', 'it',
    'ja', 'kn', 'ko', 'lt', 'lv', 'ml', 'mr', 'ms', 'nb', 'nl', 'or', 'pa', 'pl',
    'pt', 'pt-PT', 'ro', 'ru', 'sk', 'sl', 'sr', 'sv', 'sw', 'ta', 'te', 'th', 'tr',
    'uk', 'ur', 'vi', 'zh-Hans', 'zh-Hant'
  ];

  // Check if user has already set a preference
  const storedPref = localStorage.getItem(PREF_KEY);
  if (storedPref) {
    return; // User already chose, don't redirect
  }

  // Get current path
  const currentPath = window.location.pathname;
  
  // Check if already on a language-specific path (e.g., /vi/, /ar/)
  const currentLang = getCurrentLanguage(currentPath);
  if (currentLang && currentLang !== 'en') {
    // Already on a non-English language variant
    localStorage.setItem(PREF_KEY, currentLang);
    return;
  }

  // Get browser's preferred language
  const browserLangs = navigator.languages || [navigator.language];
  const preferredLang = findMatchingLanguage(browserLangs);

  // If a matching language is found and not English, redirect
  if (preferredLang && preferredLang !== 'en') {
    localStorage.setItem(PREF_KEY, preferredLang);
    const redirectPath = buildRedirectPath(currentPath, preferredLang);
    window.location.href = redirectPath;
  }
})();

/**
 * Extract language code from URL path.
 * Returns 'en' for root, or the language code (e.g., 'vi', 'ar').
 */
function getCurrentLanguage(pathname) {
  // Remove trailing slash and split
  const parts = pathname.replace(/\/$/, '').split('/').filter(Boolean);
  if (parts.length === 0) {
    return 'en'; // Root path
  }
  
  const potentialLang = parts[0];
  if (['faq', 'support', 'privacy', 'icon.png', 'style.css', '_generator'].includes(potentialLang)) {
    return 'en'; // Not a language code
  }
  
  return potentialLang;
}

/**
 * Find the first browser language that matches our available languages.
 * Handles language variants (e.g., 'en-US' -> 'en').
 */
function findMatchingLanguage(browserLangs) {
  for (let lang of browserLangs) {
    // Exact match
    if (AVAILABLE_LANGS.includes(lang)) {
      return lang;
    }
    
    // Try base language (e.g., 'en-US' -> 'en')
    const base = lang.split('-')[0];
    if (AVAILABLE_LANGS.includes(base)) {
      return base;
    }
  }
  
  return null;
}

/**
 * Build the redirect URL path.
 * Converts /faq/ to /vi/faq/, or / to /vi/
 */
function buildRedirectPath(currentPath, newLang) {
  const isRoot = currentPath === '/' || currentPath === '';
  const pathWithoutLang = currentPath.replace(/^\/(ar|bg|bn|ca|cs|da|de|el|en-AU|en-GB|en-IN|es|et|fa|fi|fil|fr|gu|he|hi|hr|hu|id|it|ja|kn|ko|lt|lv|ml|mr|ms|nb|nl|or|pa|pl|pt|pt-PT|ro|ru|sk|sl|sr|sv|sw|ta|te|th|tr|uk|ur|vi|zh-Hans|zh-Hant)(\/|$)/, '/');
  
  if (isRoot || pathWithoutLang === '/') {
    return `/${newLang}/`;
  }
  
  return `/${newLang}${pathWithoutLang}`;
}
