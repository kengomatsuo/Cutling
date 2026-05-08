#!/usr/bin/env python3
"""
Check if all Localizable.strings files have the same keys across all languages.

Usage:
    python3 check_localizations.py              # Full report (default)
    python3 check_localizations.py --keys-only  # Only show missing keys
    python3 check_localizations.py --summary    # Only show summary
"""

import re
import sys
import argparse
from pathlib import Path
from collections import defaultdict
from typing import Dict, Set, Tuple, Optional


def parse_strings_file(file_path: Path) -> Dict[str, str]:
    """
    Parse a .strings file and extract key-value pairs.
    Format: "key" = "value";
    """
    strings = {}
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        # Try with UTF-16 encoding (common for compiled .strings files)
        with open(file_path, 'r', encoding='utf-16') as f:
            content = f.read()
    
    # Remove comments (/* ... */ and //)
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    content = re.sub(r'//.*?$', '', content, flags=re.MULTILINE)
    
    # Match key-value pairs: "key" = "value";
    # This regex handles escaped quotes within strings
    pattern = r'"([^"\\]*(?:\\.[^"\\]*)*)"\s*=\s*"([^"\\]*(?:\\.[^"\\]*)*)"\s*;'
    matches = re.findall(pattern, content)
    
    for key, value in matches:
        # Unescape the key and value
        key = key.replace('\\"', '"').replace('\\n', '\n').replace('\\\\', '\\')
        value = value.replace('\\"', '"').replace('\\n', '\n').replace('\\\\', '\\')
        strings[key] = value
    
    return strings


def find_localizable_files(root_path: Path) -> Dict[str, Path]:
    """
    Find all Localizable.strings files in the main Cutling app.
    Returns a dict mapping language code to file path.
    """
    files = {}
    cutling_dir = root_path / "Cutling"
    
    if not cutling_dir.exists():
        print(f"Error: {cutling_dir} does not exist")
        return files
    
    # Look for .lproj directories
    for lproj_dir in cutling_dir.glob("*.lproj"):
        strings_file = lproj_dir / "Localizable.strings"
        if strings_file.exists():
            lang_code = lproj_dir.stem  # e.g., "en-US" from "en-US.lproj"
            files[lang_code] = strings_file
    
    return files


def compare_all_languages(strings_by_lang: Dict[str, Dict[str, str]], 
                         show_missing: bool = True,
                         show_value_diff: bool = False) -> int:
    """
    Compare all languages and report discrepancies.
    
    Args:
        strings_by_lang: Dictionary mapping language to {key: value}
        show_missing: Show missing keys by language (default: True)
        show_value_diff: Show keys with different values (default: False, 
                        usually expected for translations)
    """
    if not strings_by_lang:
        print("No localization files found!")
        return 1
    
    # Collect all keys across all languages
    all_keys: Set[str] = set()
    for strings in strings_by_lang.values():
        all_keys.update(strings.keys())
    
    print(f"Found {len(strings_by_lang)} languages")
    print(f"Total unique keys: {len(all_keys)}\n")
    
    # Check for missing keys per language
    if show_missing:
        print("=" * 80)
        print("MISSING KEYS BY LANGUAGE")
        print("=" * 80)
        missing_found = False
        missing_by_lang = {}
        
        for lang in sorted(strings_by_lang.keys()):
            missing_keys = all_keys - set(strings_by_lang[lang].keys())
            if missing_keys:
                missing_found = True
                missing_by_lang[lang] = missing_keys
                print(f"\n{lang} ({len(missing_keys)} missing):")
                for key in sorted(missing_keys):
                    print(f"  - {key}")
        
        if not missing_found:
            print("\n✓ All languages have all keys!")
        
        print()
        return missing_found
    
    # Check for inconsistent values across languages (optional)
    if show_value_diff:
        print("=" * 80)
        print("KEYS WITH DIFFERENT VALUES ACROSS LANGUAGES")
        print("=" * 80)
        inconsistencies = defaultdict(dict)
        
        for key in all_keys:
            values_by_lang = {}
            for lang in strings_by_lang:
                if key in strings_by_lang[lang]:
                    values_by_lang[lang] = strings_by_lang[lang][key]
            
            # Check if all values are the same (where the key exists)
            if len(set(values_by_lang.values())) > 1:
                inconsistencies[key] = values_by_lang
        
        if inconsistencies:
            for key in sorted(inconsistencies.keys()):
                print(f"\n'{key}':")
                for lang in sorted(inconsistencies[key].keys()):
                    value = inconsistencies[key][lang]
                    # Truncate long values for readability
                    display_value = value if len(value) <= 60 else value[:57] + "..."
                    print(f"  {lang:15} : {display_value}")
        else:
            print("\n✓ All keys have identical values across languages (unexpected for translations!)")
        
        print()
        return len(inconsistencies) > 0
    
    return 0


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Check localization consistency across all languages'
    )
    parser.add_argument(
        '--keys-only',
        action='store_true',
        help='Only show missing keys (default behavior)'
    )
    parser.add_argument(
        '--show-values',
        action='store_true',
        help='Show keys with different values across languages (not usually needed)'
    )
    parser.add_argument(
        '--summary',
        action='store_true',
        help='Only show summary (no details)'
    )
    parser.add_argument(
        '--export-missing',
        type=str,
        metavar='FILE',
        help='Export missing keys to a JSON file for analysis'
    )
    
    args = parser.parse_args()
    
    root_path = Path(__file__).parent
    
    # Find all Localizable.strings files
    files = find_localizable_files(root_path)
    
    if not files:
        print("No Localizable.strings files found in Cutling directory")
        sys.exit(1)
    
    print(f"Found {len(files)} localization files\n")
    print("Parsing files...")
    
    # Parse all files
    strings_by_lang = {}
    for lang, file_path in sorted(files.items()):
        try:
            strings_by_lang[lang] = parse_strings_file(file_path)
            print(f"  ✓ {lang}: {len(strings_by_lang[lang])} keys")
        except Exception as e:
            print(f"  ✗ {lang}: Error - {e}")
            sys.exit(1)
    
    print()
    
    # Determine what to show
    if args.summary:
        show_missing = False
        show_values = False
    else:
        show_missing = not args.show_values
        show_values = args.show_values
    
    # Compare all languages
    result = compare_all_languages(
        strings_by_lang,
        show_missing=show_missing,
        show_value_diff=show_values
    )
    
    # Print summary
    all_keys = set()
    for strings in strings_by_lang.values():
        all_keys.update(strings.keys())
    
    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print(f"Languages: {len(strings_by_lang)}")
    print(f"Total unique keys: {len(all_keys)}")
    
    missing_count = sum(len(all_keys - set(strings_by_lang[lang].keys())) 
                       for lang in strings_by_lang)
    print(f"Total missing key occurrences: {missing_count}")
    
    # Export if requested
    if args.export_missing and missing_count > 0:
        try:
            import json
            missing_data = {}
            for lang in sorted(strings_by_lang.keys()):
                missing_keys = all_keys - set(strings_by_lang[lang].keys())
                if missing_keys:
                    missing_data[lang] = sorted(list(missing_keys))
            
            with open(args.export_missing, 'w', encoding='utf-8') as f:
                json.dump(missing_data, f, ensure_ascii=False, indent=2)
            print(f"\n✓ Exported missing keys to {args.export_missing}")
        except Exception as e:
            print(f"\n✗ Failed to export: {e}")
    
    if missing_count > 0:
        print("\n⚠️  Missing keys found!")
        sys.exit(1)
    else:
        print("\n✓ All localizations are complete!")
        sys.exit(0)


if __name__ == "__main__":
    main()
