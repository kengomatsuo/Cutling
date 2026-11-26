#!/bin/bash
# Fails when an add path no longer asks the free limit (cards.md U1). No build needed.
set -euo pipefail
python3 -I "$(dirname "$0")/check.py"
