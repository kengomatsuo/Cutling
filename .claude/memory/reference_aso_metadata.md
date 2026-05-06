---
name: ASO metadata workflow and rules
description: How to create/update App Store metadata (name, subtitle, keywords) across all 60 locales, character limits, deduplication rules, and verification
type: reference
---

## App Store metadata files

Located at `fastlane/metadata/{locale}/` with these files:
- **name.txt** — 30 chars max, strongest keyword weight
- **subtitle.txt** — 30 chars max, second strongest
- **keywords.txt** — 100 chars max, comma-separated, no spaces after commas

Total indexed surface: 160 characters per locale. Every character counts.

## Key rules

1. **No word repetition** between name, subtitle, and keywords — Apple cross-references all three fields
2. **Name format**: `{Brand} - {Keyword1} {Keyword2}` (dash separator)
   - Brand uses locale-specific form (see `reference_cutling_translations.md`)
   - Some locales keep Latin "Cutling", others transliterate (Arabic, Hindi, Japanese, Korean, Thai, Hebrew)
3. **Subtitle**: Complementary action keywords (copy, paste, save, snippets, text)
4. **Keywords**: Fill remaining 100-char budget with unique terms not in name/subtitle
5. For non-English markets, include BOTH native language terms AND English loanwords
6. For Indic scripts where native words exceed 30 chars, use English in name, native in keywords

## Verification

Run `./fastlane/verify_metadata.sh` to check:
- Character limits for all 60 locales
- Latin-script keyword duplication between name/subtitle/keywords

## Update cadence

- Apple needs **4+ weeks** to stabilize rankings after a metadata change
- Don't update more than once per release cycle
- Screenshot captions are indexed since mid-2025 — treat them as keyword surface too

**How to apply:** After any metadata change, always run the verify script. When adding new locales or keywords, reference existing Localizable.strings for vocabulary consistency.
