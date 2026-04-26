#!/bin/bash
set -euo pipefail

export RUBYOPT="-EUTF-8"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

FASTLANE="/Users/hafang/.rbenv/shims/fastlane"

usage() {
  cat <<EOF
Usage: ./deploy.sh [command]

Commands:
  all               Full pipeline: metadata + screenshots + build + upload
  metadata          Upload metadata to App Store Connect (all languages)
  screenshots       Capture missing screenshots only
  frame             Add device bezels and marketing text to screenshots
  upload_screenshots Upload screenshots to App Store Connect
  upload            Upload metadata + screenshots together
  build             Build IPA for App Store
  help              Show this help

Individual steps (run in order for a full deploy):
  1. ./deploy.sh metadata
  2. ./deploy.sh screenshots
  3. ./deploy.sh frame
  4. ./deploy.sh upload_screenshots
  5. ./deploy.sh build
EOF
}

case "${1:-help}" in
  all)              $FASTLANE ios deploy ;;
  metadata)         $FASTLANE ios upload_metadata ;;
  screenshots)      $FASTLANE ios new_screenshots ;;
  frame)            $FASTLANE ios frame ;;
  upload_screenshots) $FASTLANE ios upload_screenshots ;;
  upload)           $FASTLANE ios upload ;;
  build)            $FASTLANE ios build ;;
  help|*)           usage ;;
esac
