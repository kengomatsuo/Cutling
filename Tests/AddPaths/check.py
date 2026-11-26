#!/usr/bin/env python3
"""Every way to add a cutling asks the free limit (docs/plans/unlock/cards.md U1).

Lists each add path with the function that guards it and fails when that function no longer calls
CutlingStore.canAdd / needsUnlock, and when a file starts calling `store.add(` that this list does not know.
"""
import re, sys
from pathlib import Path

root = Path(__file__).resolve().parents[2]
failures = []

def body(path, signature):
    text = (root / path).read_text()
    i = text.find(signature)
    if i < 0:
        failures.append(f"{path}: no `{signature}`")
        return ""
    j = text.index("{", i)
    depth = 0
    for k in range(j, len(text)):
        depth += text[k] == "{"
        depth -= text[k] == "}"
        if depth == 0:
            return text[j:k]
    return text[j:]

# path name -> (file, signature of the function that guards it, tokens one of which must appear in its body)
GUARD = ("canAdd(", "needsUnlock", "wouldNeedUnlock")
PATHS = {
    "app + (text editor save)":        ("Cutling/TextDetailView.swift", "private func saveAndDismiss", GUARD),
    "app + (image editor save)":       ("Cutling/ImageDetailView.swift", "private func saveCutling", GUARD),
    "drop and paste into the grid":    ("Cutling/MainContentView.swift", "private func present(_ draft", GUARD),
    "iPhone Duplicate":                ("Cutling/CardView.swift", "private func duplicate()", GUARD),
    "store.duplicate":                 ("Cutling/CutlingStore.swift", "func duplicate(", GUARD),
    "Recently Deleted restore (store)": ("Cutling/CutlingStore.swift", "func restore(", GUARD),
    "Recently Deleted restore (iPhone)": ("Cutling/RecentlyDeletedView.swift", "private func recover(", GUARD),
    "Recently Deleted restore (Mac)":  ("Cutling/Mac/MacSettingsView.swift", "private func restore(", GUARD),
    "import text replacements (store)": ("Cutling/CutlingStore.swift", "func importTextReplacements(", GUARD),
    "import text replacements (screen)": ("Cutling/KeyboardView.swift", "store.importTextReplacements()", GUARD),
    "Mac Save as Cutling":             ("Cutling/CutlingStore.swift", "func promoteHistoryToSaved(", GUARD),
    "Mac + and Duplicate":             ("Cutling/Mac/MacPickerView.swift", "private func unlockFirst(", GUARD),
    "pending items (store)":           ("Cutling/CutlingStore.swift", "func savePending(", GUARD),
    "keyboard clip, image":            ("CutlingKeyboard/KeyboardViewController.swift", "private func addImageFromClipboard", GUARD),
    "keyboard clip, text":             ("CutlingKeyboard/KeyboardViewController.swift", "private func addTextFromClipboard", GUARD),
    "Share and Action (the form)":     ("CutlingShare/ShareView.swift", "private var limitBlocks", GUARD),
    "Share and Action (save)":         ("CutlingShare/ShareView.swift", "private func save()", ("limitBlocks",)),
    "Save Text intent":                ("Cutling/SaveTextToCutlingIntent.swift", "func perform()", GUARD),
    "Save Image intent":               ("Cutling/SaveImageToCutlingIntent.swift", "func perform()", GUARD),
}
for name, (path, signature, tokens) in PATHS.items():
    if signature.startswith("store."):  # a call site, not a declaration: the whole file must guard it
        text = (root / path).read_text()
        ok = any(t in text for t in tokens)
    else:
        ok = any(t in body(path, signature) for t in tokens)
    if not ok:
        failures.append(f"{name}: {path} `{signature}` does not ask {' / '.join(tokens)}")

# Every file that calls `store.add(` / `CutlingStore.shared.add(` is one of the known add paths above (or the starter).
KNOWN = {
    "Cutling/TextDetailView.swift", "Cutling/ImageDetailView.swift", "Cutling/SaveTextToCutlingIntent.swift",
    "Cutling/SaveImageToCutlingIntent.swift", "CutlingKeyboard/KeyboardViewController.swift", "CutlingShare/ShareView.swift",
    "Cutling/SetupFlows.swift",  # the starter "Try Me", added once to an empty store, never counted
}
for folder in ("Cutling", "CutlingKeyboard", "CutlingShare", "CutlingAction", "CutlingWidgets"):
    for f in (root / folder).rglob("*.swift"):
        rel = str(f.relative_to(root))
        if rel == "Cutling/CutlingStore.swift":
            continue
        if re.search(r"\b(store|CutlingStore\.shared)\.add\(", f.read_text()) and rel not in KNOWN:
            failures.append(f"{rel} adds a cutling but is not in the add-path list")

if failures:
    print("\n".join("FAIL " + f for f in failures))
    sys.exit(1)
print(f"AddPaths: {len(PATHS)} add paths all ask the free limit")
