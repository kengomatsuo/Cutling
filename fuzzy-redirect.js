/**
 * Smart 404 redirect.
 *
 * Parses the requested path and fuzzy-matches each segment against known
 * locale codes and page names so that typos, nearby-key mistakes, and
 * common alternative spellings still land the user somewhere useful.
 *
 * Matching strategy per segment:
 *   1. Exact match (after lowercasing and _ → - normalisation)
 *   2. Alias lookup (common alternate names / translations)
 *   3. Levenshtein distance ≤ floor(len / 3), minimum 1
 *
 * After resolving locale + page, redirects via location.replace()
 * (no back-button entry) to /<SITE_BASE>/<locale>/<page>/.
 */
(function () {
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

    var KNOWN_PAGES = ['faq', 'support', 'privacy'];

    // Common alternative names / translations people might type for each page.
    var PAGE_ALIASES = {
        // faq
        'faqs': 'faq', 'fag': 'faq', 'faw': 'faq', 'fac': 'faq',
        'questions': 'faq', 'question': 'faq', 'asked': 'faq',
        'help': 'faq', 'hilfe': 'faq', 'aide': 'faq', 'ayuda': 'faq',
        'qa': 'faq', 'q-a': 'faq', 'q&a': 'faq',
        'preguntas': 'faq', 'domande': 'faq', 'perguntas': 'faq',
        // support
        'suport': 'support', 'suppport': 'support', 'suupport': 'support',
        'contact': 'support', 'contacts': 'support',
        'help': 'support', 'issue': 'support', 'issues': 'support',
        'bug': 'support', 'bugs': 'support', 'ticket': 'support',
        'troubleshoot': 'support', 'troubleshooting': 'support',
        'soporte': 'support', 'soutien': 'support', 'assistenza': 'support',
        'suporte': 'support', 'unterstutzung': 'support',
        // privacy
        'privaci': 'privacy', 'privavy': 'privacy', 'privay': 'privacy',
        'privcy': 'privacy', 'privacv': 'privacy',
        'legal': 'privacy', 'policy': 'privacy', 'terms': 'privacy',
        'data': 'privacy', 'gdpr': 'privacy',
        'privacidad': 'privacy', 'datenschutz': 'privacy',
        'confidentialite': 'privacy', 'confidentialité': 'privacy',
        'privatezza': 'privacy', 'privacidade': 'privacy'
    };

    var SITE_BASE = '/Cutling';
    var PREF_KEY   = 'cutling_lang_preference';
    var DEFAULT_LOCALE = 'en-us';

    // --- Levenshtein distance (space-optimised, two-row) ---
    function levenshtein(a, b) {
        var m = a.length, n = b.length;
        if (!m) return n;
        if (!n) return m;
        var prev = [], curr = [];
        for (var j = 0; j <= n; j++) prev[j] = j;
        for (var i = 1; i <= m; i++) {
            curr[0] = i;
            for (var j = 1; j <= n; j++) {
                curr[j] = a[i - 1] === b[j - 1]
                    ? prev[j - 1]
                    : 1 + Math.min(prev[j], curr[j - 1], prev[j - 1]);
            }
            prev = curr.slice();
        }
        return curr[n];
    }

    function fuzzyBest(input, candidates) {
        var maxDist = Math.max(1, Math.floor(input.length / 3));
        var best = null, bestDist = maxDist + 1;
        for (var i = 0; i < candidates.length; i++) {
            var d = levenshtein(input, candidates[i]);
            if (d < bestDist) { bestDist = d; best = candidates[i]; }
        }
        return bestDist <= maxDist ? best : null;
    }

    // Normalise a URL segment: lowercase, underscores → hyphens.
    function normalise(s) {
        return s.toLowerCase().replace(/_/g, '-');
    }

    function resolveSegment(raw, candidates, aliases) {
        if (!raw) return null;
        var s = normalise(raw);
        if (candidates.indexOf(s) !== -1) return s;          // 1. exact
        if (aliases && aliases[s]) return aliases[s];         // 2. alias
        return fuzzyBest(s, candidates);                      // 3. fuzzy
    }

    // Minimal browser-locale → AVAILABLE_LANGS resolver (mirrors locale-router.js).
    function browserLocale() {
        var langs = navigator.languages || [navigator.language];
        for (var i = 0; i < langs.length; i++) {
            var l = langs[i].toLowerCase();
            if (l === 'nb' || l.indexOf('nb-') === 0) return 'no';
            if (AVAILABLE_LANGS.indexOf(l) !== -1) return l;
            var base = l.split('-')[0];
            for (var k = 0; k < AVAILABLE_LANGS.length; k++) {
                if (AVAILABLE_LANGS[k] === base ||
                    AVAILABLE_LANGS[k].indexOf(base + '-') === 0) return AVAILABLE_LANGS[k];
            }
        }
        return null;
    }

    // Parse path into segments, stripping SITE_BASE prefix.
    var raw = window.location.pathname;
    var withoutBase = (raw.indexOf(SITE_BASE + '/') === 0)
        ? raw.slice(SITE_BASE.length)
        : raw;
    var segments = withoutBase.replace(/^\/|\/$/g, '').split('/').filter(Boolean);

    var locale = null;
    var page   = null;
    var idx    = 0;

    // Segment 0 → locale?
    if (segments.length > 0) {
        var matchedLang = resolveSegment(segments[0], AVAILABLE_LANGS, null);
        if (matchedLang) { locale = matchedLang; idx = 1; }
    }

    // Next segment → page?
    if (segments.length > idx) {
        var matchedPage = resolveSegment(segments[idx], KNOWN_PAGES, PAGE_ALIASES);
        if (matchedPage) page = matchedPage;
    }

    // Fall back to stored preference or browser language for locale.
    if (!locale) {
        locale = localStorage.getItem(PREF_KEY) || browserLocale() || DEFAULT_LOCALE;
    }

    var dest = SITE_BASE + '/' + locale + '/';
    if (page) dest += page + '/';

    window.location.replace(dest);
}());
