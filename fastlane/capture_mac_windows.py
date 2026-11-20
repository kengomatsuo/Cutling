#!/usr/bin/env python3
"""Captures Cutling's Mac windows for the Mac frames, in every locale, with the window active.

    python3 fastlane/capture_mac_windows.py <Cutling.app> [locale ...]

An inactive macOS window loses its accent colour (grey traffic lights, toggles, selection,
the editor's check button). In -SNAPSHOT_MODE the debug app draws every window as the
active one (SnapshotActiveWindows in MacApp.swift) while it stays in the background, and
screencapture -l reads a window behind others, so nothing here ever takes the keyboard
focus. The store is a throwaway seeded with the sample cutlings; the appearance is light.
Writes fastlane/screenshots_mac/raw/<loc>/{03_Editor,04_Hotkey,05_Sync}.png.
"""
import os, subprocess, sys, tempfile, time
from concurrent.futures import ThreadPoolExecutor

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
    """The app's largest window at or below the normal level (the driver parks it under
    the desktop picture, so it is drawn but never covers anything)."""
    best = None
    for line in sh(winid, str(pid)).splitlines():
        n, w, h, layer = line.split()[:4]
        if int(layer) <= 0 and (best is None or float(w) * float(h) > best[1]):
            best = (n, float(w) * float(h))
    return best[0] if best else None


def shoot(app, winid, loc, frame, args):
    lang = loc.replace("_", "-")
    tag = "%s-%s" % (loc, frame)  # finds this run's instance when several run at once
    subprocess.run(["open", "-n", "-g", app, "--args", "-SNAPSHOT_MODE", "-AppleInterfaceStyle", "Light",
                    "-AppleLanguages", "(%s)" % lang, "-AppleLocale", lang.replace("-", "_"), *args,
                    "-CaptureTag", tag])
    pid = win = None
    for _ in range(60):
        time.sleep(1)
        pid = pid or sh("pgrep", "-f", "--", "-CaptureTag %s" % tag).split("\n")[0]
        win = pid and window(winid, pid)
        if win:
            break
    out = os.path.join(RAW, loc, frame + ".png")
    ok = False
    if win:
        time.sleep(3)  # the driver opens the window after 0.5-1.5 s; let it settle
        win = window(winid, pid)
        ok = subprocess.run(["screencapture", "-o", "-x", "-l", win, out]).returncode == 0 and os.path.exists(out)
    if pid:
        subprocess.run(["kill", pid])
        time.sleep(1)
    print(loc, frame, "ok" if ok else "FAIL", flush=True)
    return ok


def main():
    app, locales = sys.argv[1], sys.argv[2:] or sorted(os.listdir(RAW))
    winid = helper()
    todo = [(l, f, a) for l in locales for f, a in SHOTS.items()]
    with ThreadPoolExecutor(4) as pool:  # nothing takes focus, so four windows at once
        oks = list(pool.map(lambda t: shoot(app, winid, *t), todo))
    bad = [(l, f) for (l, f, _), ok in zip(todo, oks) if not ok]
    print("failed:", bad if bad else "none")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
