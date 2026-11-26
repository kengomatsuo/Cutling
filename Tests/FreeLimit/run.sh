#!/bin/bash
# Tests for Cutling/FreeLimit.swift (the free limit's pure rules), macOS, no Xcode target needed.
set -euo pipefail
cd "$(dirname "$0")"
out=$(mktemp -d)
swiftc -o "$out/free-limit-tests" ../../Cutling/FreeLimit.swift main.swift
"$out/free-limit-tests"
