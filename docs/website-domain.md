# Website domain

The website and docs moved from `kengomatsuo.github.io/Cutling` to
`cutling.matsuokengo.com` on 2026-08-15: GitHub Pages serving the `gh-pages` branch, a
Cloudflare DNS-only CNAME to `kengomatsuo.github.io`. The App Store listing URLs and the
Sparkle appcast sit on a domain that survives any move off GitHub Pages.

Three things break the site if forgotten:

1. `web/CNAME` must be copied into `dist/` by `deploy_web`. The rsync uses `--delete`, so a
   CNAME that lives only on `gh-pages` is wiped and the custom domain unsets without a
   message.
2. The site is served at the domain root, so `SITE_BASE` in `web/locale-router.js` and
   `web/fuzzy-redirect.js` stays `''`, never `'/Cutling'`.
3. The Cloudflare record stays DNS-only (grey cloud) unless SSL/TLS mode is Full (Strict).
   The proxy blocks GitHub's certificate issuance.

## DNS records

Zone `matsuokengo.com`, id `ca38f216238ea0cd50ab8c48ae70fc89`. Add records through the API
with the Zone > DNS > Edit token in the macOS login keychain, never by asking the owner to
click:

    security find-generic-password -s cloudflare-api-token -a matsuokengo -w

Use it as a Bearer token against `https://api.cloudflare.com/client/v4`. The
`wrangler login` OAuth token in `~/Library/Preferences/.wrangler/config/default.toml`
cannot do this: it carries `zone:read` and no DNS write, so creating a record returns
`403 {"code": 10000, "message": "Authentication error"}`. The token was set up on
2026-08-15 during the move.
