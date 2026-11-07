/**
 * On the English root pages, offer the visitor's own language with a link.
 * It never redirects: crawlers and visitors both get the English page first
 * (Google advises against automatic language redirects).
 * The generator fills LANG_NAMES from locales.json: { "ja": "日本語", ... }.
 */
(function () {
  var NAMES = /*LANG_NAMES*/{};
  var PREF_KEY = 'cutling_lang_preference';
  var DISMISS_KEY = 'cutling_lang_suggest_dismissed';

  function read(key) { try { return localStorage.getItem(key); } catch (e) { return null; } }
  function write(key, value) { try { localStorage.setItem(key, value); } catch (e) {} }

  function match(tags) {
    for (var i = 0; i < tags.length; i++) {
      var tag = (tags[i] || '').toLowerCase();
      if (NAMES[tag]) return tag;
      var base = tag.split('-')[0];
      if (base === 'nb' || base === 'nn') base = 'no';
      if (base === 'tl') base = 'fil';
      if (base === 'zh') return /hant|tw|hk|mo/.test(tag) ? 'zh-hant' : 'zh-hans';
      if (NAMES[base]) return base;
      for (var code in NAMES) if (code.split('-')[0] === base) return code;
    }
    return null;
  }

  var lang = read(PREF_KEY) || match(navigator.languages || [navigator.language]);
  if (!lang || lang.indexOf('en') === 0 || !NAMES[lang] || read(DISMISS_KEY) === lang) return;

  var page = location.pathname.replace(/^\/+/, '');
  var bar = document.createElement('aside');
  bar.className = 'lang-suggest';
  bar.setAttribute('lang', lang);
  var link = document.createElement('a');
  link.href = '/' + lang + '/' + page;
  link.textContent = NAMES[lang] + ' →';
  link.addEventListener('click', function () { write(PREF_KEY, lang); });
  var close = document.createElement('button');
  close.type = 'button';
  close.setAttribute('aria-label', 'Close');
  close.textContent = '×';
  close.addEventListener('click', function () { write(DISMISS_KEY, lang); bar.remove(); });
  bar.appendChild(link);
  bar.appendChild(close);
  document.body.appendChild(bar);
})();
