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
  snap [--all]      Capture screenshots (missing only, or --all from scratch)
  frame             Add device bezels and marketing text to screenshots
  screenshots       Upload framed screenshots to App Store Connect
  upload            Upload metadata + framed screenshots together
  build             Build IPA for App Store
  dist              Build, notarize & publish the macOS Developer ID app to a
                    GitHub Release (direct download, outside the App Store)
  help              Show this help

Individual steps (run in order for a full deploy):
  1. ./deploy.sh release_notes
  2. ./deploy.sh metadata
  3. ./deploy.sh snap [--all]
  4. ./deploy.sh frame
  5. ./deploy.sh screenshots
  6. ./deploy.sh build

Direct-download (Developer ID) release:
  ./deploy.sh dist
  One-time setup, store the notary credential in the keychain first:
    xcrun notarytool store-credentials "$NOTARY_PROFILE" \\
      --apple-id "kennethfang1000@gmail.com" --team-id "$TEAM_ID" \\
      --password "<app-specific-password from appleid.apple.com>"
EOF
}

# --- Developer ID direct-download release -----------------------------------
TEAM_ID="PM3K35YS39"
NOTARY_PROFILE="cutling-notary"       # keychain profile created via notarytool store-credentials
DIST_SCHEME="Cutling"

dist_release() {
  local build_dir="$REPO_ROOT/build/dist"
  local archive="$build_dir/Cutling.xcarchive"
  local export_dir="$build_dir/export"
  local app="$export_dir/Cutling.app"
  local dmg_dir="$build_dir/dmg"

  # Version + build number drive the DMG name and the git tag.
  local version
  version="$(grep -m1 'MARKETING_VERSION' "$REPO_ROOT/Cutling.xcodeproj/project.pbxproj" \
    | sed -E 's/.*= *([^;]+);/\1/' | tr -d ' ')"
  local build_num
  build_num="$(grep -m1 'CURRENT_PROJECT_VERSION\[sdk=macosx\*\]' "$REPO_ROOT/Cutling.xcodeproj/project.pbxproj" \
    | sed -E 's/.*= *([^;]+);/\1/' | tr -d ' ')"
  # Lowercase, version-embedded asset name. Because the filename changes per
  # version, the website links to the releases/latest PAGE rather than a fixed
  # asset URL.
  local dmg="$build_dir/cutling-$version-macos.dmg"
  local tag="v$version-mac"

  echo "==> Building Cutling $version ($build_num) for Developer ID distribution"

  # Verify the notary credential exists before spending minutes on a build.
  if ! xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" >/dev/null 2>&1; then
    echo "ERROR: notary keychain profile '$NOTARY_PROFILE' not found." >&2
    echo "Create it once with:" >&2
    echo "  xcrun notarytool store-credentials \"$NOTARY_PROFILE\" \\" >&2
    echo "    --apple-id \"kennethfang1000@gmail.com\" --team-id \"$TEAM_ID\" \\" >&2
    echo "    --password \"<app-specific-password>\"" >&2
    exit 1
  fi

  rm -rf "$build_dir"
  mkdir -p "$build_dir"

  echo "==> Archiving (this can take a few minutes)..."
  xcodebuild archive \
    -project "$REPO_ROOT/Cutling.xcodeproj" \
    -scheme "$DIST_SCHEME" \
    -destination 'generic/platform=macOS' \
    -archivePath "$archive" \
    -allowProvisioningUpdates

  echo "==> Exporting Developer ID app..."
  xcodebuild -exportArchive \
    -archivePath "$archive" \
    -exportOptionsPlist "$REPO_ROOT/ExportOptions-DeveloperID.plist" \
    -exportPath "$export_dir" \
    -allowProvisioningUpdates

  [ -d "$app" ] || { echo "ERROR: exported app not found at $app" >&2; exit 1; }

  echo "==> Packaging DMG..."
  rm -rf "$dmg_dir"; mkdir -p "$dmg_dir"
  cp -R "$app" "$dmg_dir/"
  ln -s /Applications "$dmg_dir/Applications"
  # Ship the license terms alongside the binary so the direct-download build
  # carries its terms (the App Store build is covered by Apple's EULA + listing).
  cp "$REPO_ROOT/LICENSE" "$dmg_dir/LICENSE.txt"
  hdiutil create -volname "Cutling" -srcfolder "$dmg_dir" -ov -format UDZO "$dmg"

  echo "==> Notarizing DMG (waits for Apple)..."
  xcrun notarytool submit "$dmg" --keychain-profile "$NOTARY_PROFILE" --wait

  echo "==> Stapling ticket..."
  xcrun stapler staple "$dmg"
  xcrun stapler validate "$dmg"

  echo "==> Publishing GitHub release $tag..."
  if gh release view "$tag" >/dev/null 2>&1; then
    gh release upload "$tag" "$dmg" --clobber
  else
    # Drop any stale local tag that isn't on the remote; otherwise
    # `gh release create` refuses ("tag exists locally but has not been
    # pushed"). With no local tag, gh creates and pushes the tag itself.
    git tag -d "$tag" >/dev/null 2>&1 || true
    gh release create "$tag" "$dmg" \
      --title "Cutling $version (macOS, direct download)" \
      --notes "Direct-download build of Cutling for macOS, signed with Developer ID and notarized by Apple. Includes direct paste (Accessibility). Download the DMG, drag Cutling to Applications."
  fi

  echo "==> Done: $dmg"
}

deploy_web() {
  DIST="$REPO_ROOT/dist"
  WEB="$REPO_ROOT/web"

  echo "==> Building website into dist/..."
  python3 "$WEB/_generator/generate.py" --output-dir "$DIST"

  echo "==> Copying static assets..."
  cp "$WEB/style.css" "$DIST/"
  cp "$WEB/locale-router.js" "$DIST/"
  cp "$WEB/fuzzy-redirect.js" "$DIST/"
  cp "$WEB/favicon.ico" "$DIST/"
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
  snap)
    if [ "${2:-}" = "--all" ]; then
      $FASTLANE ios screenshots
    else
      $FASTLANE ios new_screenshots
    fi
    ;;
  frame)            $FASTLANE ios frame ;;
  screenshots)      $FASTLANE ios upload_screenshots ;;
  upload)           $FASTLANE ios upload ;;
  build)            $FASTLANE ios build ;;
  dist)             dist_release ;;
  help|*)           usage ;;
esac
