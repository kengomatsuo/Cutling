#!/bin/bash
# Prints how CodeDetector reads sample snippets on this Mac (uses the on-device model when available).
set -euo pipefail
cd "$(dirname "$0")"
out=$(mktemp -d)
swiftc -o "$out/code-detector" ../../Cutling/CodeDetector.swift ../../Cutling/RichText.swift ../RichText/stub.swift main.swift
"$out/code-detector"
