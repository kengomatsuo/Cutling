---
name: Use existing translations as reference
description: When adding new localized strings, always check the project's existing Localizable.strings files first to reuse established translations for terms like Cutlings, snippets, etc.
type: feedback
originSessionId: 53377dd3-e8f0-4c54-b853-d1277b0f37cd
---
Never generate translations from scratch when the project already has existing translations. Always read the existing Localizable.strings files in each locale first and use them as reference for vocabulary, tone, and how product terms are translated.

**Why:** The user has established translations for key terms (e.g., "Cutlings" may be translated differently per locale). Generating translations independently leads to inconsistent terminology and wasted effort. This has happened repeatedly.

**How to apply:** Before writing any new localized strings, read a representative sample of existing locale files (e.g., the main app's Localizable.strings) to understand how key terms are translated. Match the existing vocabulary and style. This applies to both the main app and the keyboard extension targets.
