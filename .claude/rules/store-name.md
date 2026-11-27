---
paths:
  - "fastlane/metadata*/**/name.txt"
  - "docs/aso/proposal.json"
  - "docs/aso/data/*"
---

# Store name

The App Store name starts with the name the app shows under its icon in that
language (`Cutling/<lang>.lproj/InfoPlist.strings`, `CFBundleDisplayName`):
カットリング in Japanese, 컷링 in Korean, Катлинг in Russian, Latin "Cutling"
where the icon says Cutling. Someone who sees the icon then finds the same
name on the store page. The descriptor after " - " stays translated, and the
whole name stays within 30 characters.
