---
paths:
  - "Cutling/Mac/**"
  - "Cutling/*.lproj/Localizable.strings"
---

# Mac UI strings

- Every UI literal in `Cutling/Mac/*.swift` needs a key in all 76 `Localizable.strings`; `check_mac_ui_strings.py` gates `./deploy.sh build|dist|mas` (2026-10-01). Locales are written from the meaning brief in [docs/mac-strings-brief.md](docs/mac-strings-brief.md), never from the English.
- A view property rendered with `Text(x)` is `LocalizedStringKey`, never `String`: a `String` skips lookup and ships English (welcome window `PermissionRow`, 2026-10-01).
