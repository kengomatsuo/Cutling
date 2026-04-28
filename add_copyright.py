#!/usr/bin/env python3
"""
Add copyright headers to all Swift source files in the Cutling project.

This script adds a standardized copyright notice to the top of each .swift file
that doesn't already contain one.

Usage:
    python3 add_copyright.py [--dry-run]

Options:
    --dry-run    Show what would be changed without modifying files
"""

import os
import sys
import argparse
from pathlib import Path

COPYRIGHT_HEADER = """//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

"""

# Directories to process (relative to script location)
SOURCE_DIRS = [
    "Cutling",
    "CutlingKeyboard",
    "CutlingUITests",
]

# Files to skip
SKIP_FILES = [
    "SnapshotHelper.swift",  # Third-party helper from fastlane
]


def has_copyright(content: str) -> bool:
    """Check if file already has a copyright notice."""
    return "Copyright" in content or "copyright" in content


def add_header(content: str, filename: str) -> str:
    """Add copyright header to file content, preserving existing header structure if present."""
    lines = content.splitlines(keepends=True)

    # Check if file starts with existing header block (// comments at top)
    insert_index = 0

    # Skip existing header lines (lines starting with //)
    for i, line in enumerate(lines):
        stripped = line.lstrip()
        if stripped.startswith("//"):
            insert_index = i + 1
        elif stripped.startswith("/*"):
            # Block comment - find end
            for j in range(i, len(lines)):
                if "*/" in lines[j]:
                    insert_index = j + 1
                    break
            break
        else:
            break

    # If there's an existing header, add a blank line before our copyright
    if insert_index > 0:
        prefix = COPYRIGHT_HEADER
    else:
        prefix = COPYRIGHT_HEADER

    # Insert the copyright header
    new_lines = lines[:insert_index] + [prefix] + lines[insert_index:]
    return "".join(new_lines)


def process_file(filepath: Path, dry_run: bool = False) -> bool:
    """Process a single Swift file. Returns True if modified."""
    try:
        content = filepath.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        print(f"  Skipping (encoding issue): {filepath}")
        return False

    if has_copyright(content):
        print(f"  Already has copyright: {filepath.name}")
        return False

    if dry_run:
        print(f"  Would add copyright: {filepath}")
        return True

    new_content = add_header(content, filepath.name)
    filepath.write_text(new_content, encoding="utf-8")
    print(f"  Added copyright: {filepath.name}")
    return True


def main():
    parser = argparse.ArgumentParser(
        description="Add copyright headers to Swift source files"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be changed without modifying files"
    )
    args = parser.parse_args()

    # Get project root (parent of script directory)
    script_dir = Path(__file__).parent
    project_root = script_dir

    print("=" * 60)
    print("Cutling - Copyright Header Adder")
    print("=" * 60)

    if args.dry_run:
        print("\nDRY RUN MODE - No files will be modified\n")

    total_files = 0
    modified_files = 0
    skipped_files = 0

    for source_dir in SOURCE_DIRS:
        dir_path = project_root / source_dir
        if not dir_path.exists():
            print(f"\nDirectory not found: {dir_path}")
            continue

        print(f"\nProcessing: {source_dir}/")
        print("-" * 40)

        swift_files = sorted(dir_path.rglob("*.swift"))

        for filepath in swift_files:
            # Skip test helpers and other specified files
            if filepath.name in SKIP_FILES:
                print(f"  Skipping: {filepath.name}")
                skipped_files += 1
                continue

            total_files += 1
            if process_file(filepath, dry_run=args.dry_run):
                modified_files += 1

    print("\n" + "=" * 60)
    print("Summary")
    print("=" * 60)
    print(f"  Total Swift files: {total_files}")
    print(f"  Modified:          {modified_files}")
    print(f"  Skipped:           {skipped_files}")
    print(f"  Already has copy:  {total_files - modified_files - skipped_files}")

    if args.dry_run:
        print("\nRun without --dry-run to apply changes")

    return 0


if __name__ == "__main__":
    sys.exit(main())
