---
paths:
  - "Cutling/CloudKitSyncManager.swift"
  - "CutlingKeyboard/KeyboardSyncHelper.swift"
  - "CutlingShare/ShareView.swift"
  - "Cutling/Cutling.swift"
---

# CloudKit sync

- A new synced field is written by three record builders (`CloudKitSyncManager.record(for:)`, `KeyboardSyncHelper.buildRecord`, `ShareView.buildRecord`), read in `CloudKitSyncManager.cutling(from:)`, and merged through `Cutling.merging(remote:onto:)`, because a remote change replaces the whole struct and a record from an older build lacks the field. New fields are written only while `CloudKitSchema.writesMetadataFields` is true (debug builds, or release once `productionHasMetadataFields` is flipped after the schema is deployed in the CloudKit Console), since production rejects unknown fields (2026-10-02). Full account: [docs/formatting-plan.md](docs/formatting-plan.md)
