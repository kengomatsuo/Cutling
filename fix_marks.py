#!/usr/bin/env python3
"""
Reorganize Localizable.strings MARK sections.

Problems:
- "Missing Strings" section with keys that belong in existing sections
- "Additional Actions" should merge into "Common Actions"
- "Settings (Additional)" should merge into "Settings Sections"
- "Navigation Title" should merge into "Navigation & Titles"
- Duplicate "Navigation Subtitle" sections should merge into "Navigation & Titles"
- Inconsistent blank lines between sections
"""

import glob
import re
import os

MARK_RE = re.compile(r'^/\*\s*MARK:\s*-\s*(.+?)\s*\*/$')
KV_RE = re.compile(r'^"(.+?)"\s*=\s*".*";$')

# Where each key from the messy sections should go
KEY_TO_SECTION = {
    # From "Missing Strings"
    "Continue": "Buttons & Actions",
    "Enable": "Buttons & Actions",
    "Status": "Form Labels",
    "New Text Cutling": "Buttons & Actions",
    "New Image Cutling": "Buttons & Actions",
    "Delete Selected": "Common Actions",
    "Auto-detect Input Types": "Settings Sections",
    "Input Types": "Input Type Suggestions",
    "Enable iCloud Sync": "Settings Sections",
    "Keep your cutlings in sync across all your devices.": "Settings Sections",
    "Automatically detect and suggest input type categories when editing text.": "Settings Sections",
    # From "Additional Actions"
    "Redo": "Common Actions",
    # From "Navigation Title"
    "Cutlings": "Navigation & Titles",
    # From duplicate "Navigation Subtitle"
    "%lld/%lld Text, %lld/%lld Images": "Navigation & Titles",
    "%lld Cutlings": "Navigation & Titles",
    # From "Settings (Additional)"
    "Experimental Feature: iCloud": "Settings Sections",
    "Contact Support": "Settings Sections",
    "Privacy Policy": "Settings Sections",
}

SECTIONS_TO_REMOVE = {
    "Missing Strings",
    "Additional Actions",
    "Navigation Title",
    "Settings (Additional)",
}

CANONICAL_SECTION_ORDER = [
    "Navigation & Titles",
    "Common Actions",
    "Menu Items",
    "Empty States",
    "Search",
    "Form Labels",
    "Placeholders",
    "Buttons & Actions",
    "Settings Sections",
    "Image Picker",
    "Footer Texts",
    "Alerts",
    "CutlingStore Errors",
    "Input Type Suggestions",
    "Detection",
    "Clipboard Feedback",
    "Keyboard Setup",
    "Setup Guide Instructions",
    "Recently Deleted",
    "Context Menu",
    "Get Info View",
    "Color Names",
    "Accessibility",
    "Snapshot Seed Data",
]


def parse_file(filepath):
    """Parse a Localizable.strings file into ordered sections.
    Returns list of (section_name, [(line_text, key_or_none)]).
    """
    sections = []
    current_section = None
    current_lines = []

    with open(filepath, 'r', encoding='utf-8') as f:
        for raw_line in f:
            line = raw_line.rstrip('\n')
            mark_match = MARK_RE.match(line)
            if mark_match:
                if current_section is not None:
                    sections.append((current_section, current_lines))
                current_section = mark_match.group(1)
                current_lines = []
                continue

            if current_section is None:
                if line.strip():
                    current_section = "__preamble__"
                    kv = KV_RE.match(line)
                    current_lines.append((line, kv.group(1) if kv else None))
                continue

            kv = KV_RE.match(line)
            key = kv.group(1) if kv else None
            current_lines.append((line, key))

    if current_section is not None:
        sections.append((current_section, current_lines))

    return sections


def reorganize(sections):
    """Merge and redistribute sections."""
    # Build a dict: section_name -> list of (line, key)
    section_dict = {}
    for name, lines in sections:
        if name not in section_dict:
            section_dict[name] = []
        section_dict[name].extend(lines)

    # Move keys from messy sections to proper ones
    for old_section_name in list(section_dict.keys()):
        remaining = []
        for line, key in section_dict[old_section_name]:
            if key and key in KEY_TO_SECTION:
                target = KEY_TO_SECTION[key]
                if target not in section_dict:
                    section_dict[target] = []
                section_dict[target].append((line, key))
            else:
                remaining.append((line, key))
        section_dict[old_section_name] = remaining

    # Merge duplicate "Navigation Subtitle" into "Navigation & Titles"
    if "Navigation Subtitle" in section_dict:
        target = "Navigation & Titles"
        if target not in section_dict:
            section_dict[target] = []
        for line, key in section_dict["Navigation Subtitle"]:
            if key:
                section_dict[target].append((line, key))
        del section_dict["Navigation Subtitle"]

    # Remove empty/dissolved sections
    for name in SECTIONS_TO_REMOVE:
        if name in section_dict:
            # Only remove if no remaining real content
            has_content = any(key for _, key in section_dict[name])
            if not has_content:
                del section_dict[name]

    return section_dict


def write_file(filepath, section_dict):
    """Write the reorganized file with consistent formatting."""
    lines_out = []

    for i, section_name in enumerate(CANONICAL_SECTION_ORDER):
        if section_name not in section_dict:
            continue

        entries = section_dict[section_name]
        # Collect only the key-value lines (skip blank lines)
        kv_lines = [line for line, key in entries if key]
        if not kv_lines:
            continue

        if lines_out:
            lines_out.append("")
        lines_out.append(f"/* MARK: - {section_name} */")
        for kv_line in kv_lines:
            lines_out.append(kv_line)

    # Handle any sections not in canonical order (shouldn't happen, but safety)
    for section_name, entries in section_dict.items():
        if section_name in CANONICAL_SECTION_ORDER or section_name == "__preamble__":
            continue
        kv_lines = [line for line, key in entries if key]
        if not kv_lines:
            continue
        if lines_out:
            lines_out.append("")
        lines_out.append(f"/* MARK: - {section_name} */")
        for kv_line in kv_lines:
            lines_out.append(kv_line)

    lines_out.append("")  # trailing newline

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines_out))


def process_file(filepath):
    sections = parse_file(filepath)
    section_dict = reorganize(sections)
    write_file(filepath, section_dict)


def main():
    base = os.path.dirname(os.path.abspath(__file__))

    # Only process the main app Localizable.strings (not CutlingKeyboard which is already clean)
    pattern = os.path.join(base, "Cutling", "*.lproj", "Localizable.strings")
    files = sorted(glob.glob(pattern))

    print(f"Found {len(files)} files to process")
    for f in files:
        locale = os.path.basename(os.path.dirname(f)).replace('.lproj', '')
        process_file(f)
        print(f"  Fixed: {locale}")

    print("Done!")


if __name__ == "__main__":
    main()
