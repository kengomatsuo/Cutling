#!/bin/bash
# Converter tests for Cutling/RichText.swift (macOS, no Xcode target needed).
set -euo pipefail
cd "$(dirname "$0")"
out=$(mktemp -d)
swiftc -o "$out/richtext-tests" ../../Cutling/RichText.swift stub.swift main.swift
"$out/richtext-tests"
