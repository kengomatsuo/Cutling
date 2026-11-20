/* Store source. Every App Store button on this site is a campaign link (pt and ct). A visitor
   who arrived from a listing or a post gets that source as the campaign token instead of the
   page's own, so App Store Connect > Analytics > Campaigns counts the download under the place
   that sent them: ?ref=macpip, ?utm_source=macappindex.com, a t.co referrer (x), and so on.
   Search engines and this site's own pages keep the page's token. The same file ships on the
   Cutling and Undirect sites (web/_generator/store-source.js in each repo). */
(function () {
  var KEY = "store_source";
  var NAMED = {
    "t.co": "x", "x.com": "x", "twitter.com": "x", "youtu.be": "youtube", "youtube.com": "youtube",
    "instagram.com": "instagram", "tiktok.com": "tiktok", "threads.net": "threads", "threads.com": "threads",
    "facebook.com": "facebook", "news.ycombinator.com": "hackernews", "reddit.com": "reddit"
  };
  var SEARCH = /^(google|bing|duckduckgo|yahoo|ecosia|baidu|yandex|startpage|brave|kagi|naver|qwant|seznam|search)$/;

  function clean(s) {
    return String(s).toLowerCase().replace(/[^a-z0-9-]+/g, "-").replace(/^-+|-+$/g, "").slice(0, 30);
  }

  function fromHost(host) {
    host = String(host).toLowerCase().replace(/^(www|m|l|lm|mobile|old)\./, "");
    if (NAMED[host]) return NAMED[host];
    var p = host.split(".");
    if (p.length < 2) return clean(host);
    var i = p.length - 2;
    if (p.length > 2 && p[i].length <= 3 && p[p.length - 1].length === 2) i--; // co.uk, com.au
    return clean(p[i]);
  }

  function fromParam(v) {
    v = String(v || "").trim();
    if (!v) return "";
    return v.indexOf(".") > -1 ? fromHost(v.replace(/^https?:\/\//, "").split("/")[0]) : clean(v);
  }

  function fromVisit() {
    var q;
    try { q = new URLSearchParams(location.search); } catch (e) { return ""; }
    var v = fromParam(q.get("ct") || q.get("ref") || q.get("utm_source") || q.get("source"));
    if (v) return v;
    var host;
    try { host = new URL(document.referrer).hostname; } catch (e) { return ""; }
    if (!host || host === location.hostname) return "";
    var t = fromHost(host);
    return SEARCH.test(t) ? "" : t;
  }

  var source = fromVisit();
  try {
    if (source) sessionStorage.setItem(KEY, source);
    else source = sessionStorage.getItem(KEY) || "";
  } catch (e) {}
  if (!source) return;

  function apply() {
    var links = document.querySelectorAll('a[href*="apps.apple.com"][href*="pt="]');
    for (var i = 0; i < links.length; i++) {
      try {
        var u = new URL(links[i].href);
        u.searchParams.set("ct", source);
        links[i].href = u.toString();
      } catch (e) {}
    }
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", apply);
  else apply();
})();
