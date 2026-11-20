#!/bin/bash
# Tests for Cutling/Placeholders.swift (fill-ins, date stamps, cursor), macOS, no Xcode target needed.
set -euo pipefail
cd "$(dirname "$0")"
out=$(mktemp -d)
swiftc -o "$out/placeholder-tests" ../../Cutling/Placeholders.swift main.swift
"$out/placeholder-tests"
