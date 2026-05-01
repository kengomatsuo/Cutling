#!/bin/bash
set -euo pipefail

export RUBYOPT="-EUTF-8"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

FASTLANE="/Users/hafang/.rbenv/shims/fastlane"

VENV="docs/_generator/.venv/bin/activate"

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

usage() {
  cat <<EOF
Usage: ./deploy.sh [command]

Commands:
  web               Build website and deploy to gh-pages
  all               Full pipeline: metadata + screenshots + build + upload
  release_notes     Translate release notes from en-US to all languages
  metadata          Upload metadata to App Store Connect (all languages)
  screenshots       Capture missing screenshots only
  frame             Add device bezels and marketing text to screenshots
  upload_screenshots Upload screenshots to App Store Connect
  upload            Upload metadata + screenshots together
  build             Build IPA for App Store
  help              Show this help

Individual steps (run in order for a full deploy):
  1. ./deploy.sh release_notes
  2. ./deploy.sh metadata
  3. ./deploy.sh screenshots
  4. ./deploy.sh frame
  5. ./deploy.sh upload_screenshots
  6. ./deploy.sh build
EOF
}

deploy_web() {
  DIST="$REPO_ROOT/dist"
  WEB="$REPO_ROOT/web"

  echo "==> Building website into dist/..."
  python3 "$WEB/_generator/generate.py" --output-dir "$DIST"

  echo "==> Copying static assets..."
  cp "$WEB/style.css" "$DIST/"
  cp "$WEB/locale-router.js" "$DIST/"
  cp "$WEB/icon.png" "$DIST/"
  cp -r "$WEB/img/" "$DIST/img/"
  cp "$REPO_ROOT/locales.json" "$DIST/"

  echo "==> Deploying to gh-pages via git worktree..."
  WORKTREE="$(mktemp -d)"
  git worktree add "$WORKTREE" gh-pages
  rsync -a --delete --exclude='.git' "$DIST/" "$WORKTREE/"
  (
    cd "$WORKTREE"
    git add -A
    if git diff --cached --quiet; then
      echo "Nothing to deploy — gh-pages is already up to date."
    else
      git commit -m "Deploy website $(date +%Y-%m-%d)"
      git push origin gh-pages
      echo "==> Deployed!"
    fi
  )
  git worktree remove --force "$WORKTREE"
  rm -rf "$WORKTREE"
}

case "${1:-help}" in
  web)              deploy_web ;;
  all)              $FASTLANE ios deploy ;;
  release_notes)    source "$VENV" && python3 translate_release_notes.py ;;
  metadata)         $FASTLANE ios upload_metadata ;;
  screenshots)      $FASTLANE ios new_screenshots ;;
  frame)            $FASTLANE ios frame ;;
  upload_screenshots) $FASTLANE ios upload_screenshots ;;
  upload)           $FASTLANE ios upload ;;
  build)            $FASTLANE ios build ;;
  help|*)           usage ;;
esac
