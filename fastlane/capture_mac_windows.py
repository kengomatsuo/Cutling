#!/usr/bin/env python3
"""Captures Cutling's Mac windows for the Mac frames, in every locale, with the window active.

    python3 fastlane/capture_mac_windows.py <Cutling.app> [locale ...]

An inactive macOS window loses its accent colour (grey traffic lights, toggles, selection,
the editor's check button), so each window is brought to the front for about two seconds,
shot with screencapture -l, and focus goes back to the app that had it. The app runs with
-SNAPSHOT_MODE (a throwaway store seeded with the sample cutlings), in light appearance.
Writes fastlane/screenshots_mac/raw/<loc>/{03_Editor,04_Hotkey,05_Sync}.png.
"""
import os, subprocess, sys, tempfile, time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, "fastlane", "screenshots_mac", "raw")
SHOTS = {  # frame -> launch arguments that open its window
    "03_Editor": ["-SNAPSHOT_SCREEN", "editor"],
    "04_Hotkey": ["-SNAPSHOT_SCREEN", "settings", "-SNAPSHOT_SETTINGS_TAB", "hotkey"],
    "05_Sync": ["-SNAPSHOT_SCREEN", "settings", "-SNAPSHOT_SETTINGS_TAB", "sync", "-iCloudSyncEnabled", "YES"],
}


def sh(*a):
    return subprocess.run(a, capture_output=True, text=True).stdout.strip()


def helper():
    out = os.path.join(tempfile.gettempdir(), "cutling-winid")
    if not os.path.exists(out):
        subprocess.run(["swiftc", "-O", os.path.join(ROOT, "fastlane", "compose", "mac", "winid.swift"), "-o", out], check=True)
    return out


def window(winid, pid):
    """The largest normal window the app has on screen."""
    best = None
    for line in sh(winid, str(pid)).splitlines():
        n, w, h, layer = line.split()[:4]
        if layer == "0" and (best is None or float(w) * float(h) > best[1]):
            best = (n, float(w) * float(h))
    return best[0] if best else None


def shoot(app, winid, loc, frame, args):
    exe = os.path.join(app, "Contents", "MacOS")
    lang = loc.replace("_", "-")
    front = sh("osascript", "-e", 'tell application "System Events" to get bundle identifier of first process whose frontmost is true')
    subprocess.run(["open", "-n", "-g", app, "--args", "-SNAPSHOT_MODE", "-AppleInterfaceStyle", "Light",
                    "-AppleLanguages", "(%s)" % lang, "-AppleLocale", lang.replace("-", "_"), *args])
    pid = win = None
    for _ in range(40):
        time.sleep(1)
        pid = pid or sh("pgrep", "-nf", exe)
        win = pid and window(winid, pid)
        if win:
            break
    out = os.path.join(RAW, loc, frame + ".png")
    ok = False
    if win:
        time.sleep(2)  # the driver opens the window after 0.5-1.5 s; let it settle
        subprocess.run(["osascript", "-e", 'tell application "System Events" to set frontmost of (first process whose unix id is %s) to true' % pid])
        time.sleep(1.5)
        win = window(winid, pid)
        ok = subprocess.run(["screencapture", "-o", "-x", "-l", win, out]).returncode == 0 and os.path.exists(out)
    if front:
        subprocess.run(["open", "-b", front])
    if pid:
        subprocess.run(["kill", pid])
        time.sleep(1)
    print(loc, frame, "ok" if ok else "FAIL", flush=True)
    return ok


def main():
    app, locales = sys.argv[1], sys.argv[2:] or sorted(os.listdir(RAW))
    winid = helper()
    bad = [(l, f) for l in locales for f, a in SHOTS.items() if not shoot(app, winid, l, f, a)]
    print("failed:", bad if bad else "none")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
