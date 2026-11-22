#!/usr/bin/env python3
"""Create or update one In-App Event from fastlane/events/<name>/event.json, upload its card and
details media to every localization, and read the event back.

    python3 fastlane/create_event.py 2.0              # build or update, no review
    python3 fastlane/create_event.py 2.0 --readback   # print what App Store Connect holds
    python3 fastlane/create_event.py 2.0 --submit     # add to the open review submission and send it

Submitting is a store submission and waits for the owner's yes. Cutling's event goes to review with
the app version it promotes: an event sent alone is reviewed against the live version
(docs/aso/in-app-events.md). With --submit the event joins the iOS submission already in
READY_FOR_REVIEW (the version's), or a new one if none is open.

Copied from Undirect's Support/AppStore/create_event.py. Apple's limits: name 30 characters in title
case, short description 50 and long description 120 in sentence case; card 16:9 at least 1920x1080,
details 9:16 at least 1080x1920; at most 31 days, published at most 14 days before it starts.

Auth: ASC_KEY_ID, ASC_ISSUER_ID and ASC_PRIVATE_KEY_PATH, defaulting to the Admin team key in
~/.appstoreconnect/private_keys, the key fastlane and Undirect's scripts use."""
import base64, json, os, subprocess, sys, time, urllib.error, urllib.request

APP = "6759476314"
BASE = "https://api.appstoreconnect.apple.com"
KEY_ID = os.environ.get("ASC_KEY_ID", "V48TZG72KY")
ISSUER = os.environ.get("ASC_ISSUER_ID", "79deecfa-75ef-43ad-80c2-e25e55f38f41")
KEY_PATH = os.environ.get("ASC_PRIVATE_KEY_PATH", os.path.expanduser(f"~/.appstoreconnect/private_keys/AuthKey_{KEY_ID}.p8"))
_token = {"v": None, "exp": 0}


def b64(b):
    return base64.urlsafe_b64encode(b).rstrip(b"=").decode()


def token():
    if time.time() < _token["exp"] - 60:
        return _token["v"]
    now = int(time.time())
    signing = (b64(json.dumps({"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}).encode()) + "." +
               b64(json.dumps({"iss": ISSUER, "iat": now, "exp": now + 1100, "aud": "appstoreconnect-v1"}).encode()))
    der = subprocess.run(["openssl", "dgst", "-sha256", "-sign", KEY_PATH], input=signing.encode(),
                         capture_output=True, check=True).stdout
    i = 2 if der[1] < 0x80 else 2 + (der[1] & 0x7F)          # DER ECDSA signature to raw r||s
    r = der[i + 2:i + 2 + der[i + 1]]; i += 2 + der[i + 1]
    s = der[i + 2:i + 2 + der[i + 1]]
    sig = r.lstrip(b"\0").rjust(32, b"\0") + s.lstrip(b"\0").rjust(32, b"\0")
    _token.update(v=f"{signing}.{b64(sig)}", exp=now + 1100)
    return _token["v"]


def req(method, path, body=None, raw=None, headers=None, absolute=False):
    url = path if absolute or path.startswith("http") else BASE + path
    h = headers or {"Authorization": "Bearer " + token(), "Content-Type": "application/json"}
    data = raw if raw is not None else (json.dumps(body).encode() if body else None)
    for attempt in range(3):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, method=method, data=data, headers=h), timeout=120) as x:
                t = x.read()
                return json.loads(t) if t and not absolute else {}
        except urllib.error.HTTPError as e:
            if e.code in (429, 500, 502, 503) and attempt < 2:
                time.sleep(3 * (attempt + 1)); continue
            sys.exit(f"{method} {path[:90]} -> {e.code} {e.read().decode()[:1500]}")
    raise RuntimeError(f"{method} {path[:90]}: no answer after 3 tries")


def pages(path):
    out = []
    while path:
        d = req("GET", path); out += d.get("data", []); path = d.get("links", {}).get("next")
    return out


if len(sys.argv) < 2 or sys.argv[1].startswith("-"):
    sys.exit(__doc__)
name = sys.argv[1]
here = os.path.join(os.path.dirname(os.path.abspath(__file__)), "events", name)
spec = json.load(open(os.path.join(here, "event.json")))
localizations = {code: text for code, text in spec["localizations"].items()}

too_long = [(c, k, len(v)) for c, t in localizations.items() for k, v in t.items()
            if len(v) > {"name": 30, "shortDescription": 50, "longDescription": 120}[k]]
if too_long:
    sys.exit(f"over Apple's limits: {too_long}")

existing = pages(f"/v1/apps/{APP}/appEvents?limit=50")
event = next((e for e in existing if e["attributes"]["referenceName"] == spec["referenceName"]), None)


def readback(event_id):
    a = req("GET", f"/v1/appEvents/{event_id}")["data"]["attributes"]
    sched = (a.get("territorySchedules") or [{}])[0]
    print(f"event {event_id} {a['referenceName']!r} state={a.get('eventState')} badge={a.get('badge')} "
          f"publish={sched.get('publishStart')} start={sched.get('eventStart')} end={sched.get('eventEnd')} "
          f"territories={len(sched.get('territories', []))} deepLink={a.get('deepLink')}")
    locs = pages(f"/v1/appEvents/{event_id}/localizations?limit=200")
    missing = []
    for l in sorted(locs, key=lambda l: l["attributes"]["locale"]):
        la = l["attributes"]
        media = {s["attributes"]["appEventAssetType"]: s["attributes"].get("assetDeliveryState", {}).get("state")
                 for s in req("GET", f"/v1/appEventLocalizations/{l['id']}/appEventScreenshots")["data"]}
        media.update({v["attributes"]["appEventAssetType"]: v["attributes"].get("videoDeliveryState", {}).get("state")
                      for v in req("GET", f"/v1/appEventLocalizations/{l['id']}/appEventVideoClips")["data"]})
        want = localizations.get(la["locale"], {})
        same = all(la.get(k) == v for k, v in want.items())
        if not same or len(media) < 2:
            missing.append(la["locale"])
        print(f"  {la['locale']:7} text={'same' if same else 'DIFFERS'} media={media} | {la.get('name')} | {la.get('shortDescription')}")
    print(f"{len(locs)} localizations, {len(locs) - len(missing)} match event.json with both images"
          + (f"; not matching: {missing}" if missing else ""))


if "--readback" in sys.argv:
    readback(event["id"]) if event else sys.exit("no event named " + spec["referenceName"])
    sys.exit(0)

schedule = {"publishStart": spec["publishStart"], "eventStart": spec["eventStart"], "eventEnd": spec["eventEnd"]}
if not event:
    territories = [t["id"] for t in pages("/v1/territories?limit=200")]
    event = req("POST", "/v1/appEvents", {"data": {"type": "appEvents", "attributes": {
        "referenceName": spec["referenceName"], "badge": spec["badge"], "priority": spec["priority"],
        "purpose": spec["purpose"], "primaryLocale": spec["primaryLocale"],
        "territorySchedules": [{"territories": territories, **schedule}]},
        "relationships": {"app": {"data": {"type": "apps", "id": APP}}}}})["data"]
    print("event", event["id"], "created")
else:
    print("event", event["id"], "exists", event["attributes"].get("eventState"))
    old = (event["attributes"].get("territorySchedules") or [{}])[0]
    if any(old.get(k) != v for k, v in schedule.items()) and old.get("territories"):
        req("PATCH", f"/v1/appEvents/{event['id']}", {"data": {"type": "appEvents", "id": event["id"], "attributes": {
            "territorySchedules": [{"territories": old["territories"], **schedule}]}}})
        print("dates moved to", schedule)
# Needed before review although the create request takes neither (Undirect, 2026-11-20).
req("PATCH", f"/v1/appEvents/{event['id']}", {"data": {"type": "appEvents", "id": event["id"], "attributes": {
    "deepLink": spec["deepLink"], "purchaseRequirement": spec["purchaseRequirement"],
    "badge": spec["badge"], "priority": spec["priority"], "purpose": spec["purpose"]}}})

media = {kind: open(os.path.join(here, file), "rb").read() for kind, file in spec["media"].items()}
locs = {l["attributes"]["locale"]: l for l in pages(f"/v1/appEvents/{event['id']}/localizations?limit=200")}
for code, text in localizations.items():
    if code in locs:
        req("PATCH", f"/v1/appEventLocalizations/{locs[code]['id']}", {"data": {"type": "appEventLocalizations", "id": locs[code]["id"], "attributes": text}})
        loc_id = locs[code]["id"]
    else:
        loc_id = req("POST", "/v1/appEventLocalizations", {"data": {"type": "appEventLocalizations", "attributes": {"locale": code, **text},
            "relationships": {"appEvent": {"data": {"type": "appEvents", "id": event["id"]}}}}})["data"]["id"]
    # An image already up is kept only when its size matches the local file; changed art replaces it.
    have = {s["attributes"]["appEventAssetType"]: s for s in req("GET", f"/v1/appEventLocalizations/{loc_id}/appEventScreenshots")["data"]}
    for kind, data in media.items():
        if kind in have:
            if have[kind]["attributes"].get("fileSize") == len(data): continue
            req("DELETE", f"/v1/appEventScreenshots/{have[kind]['id']}")
        shot = req("POST", "/v1/appEventScreenshots", {"data": {"type": "appEventScreenshots", "attributes": {
            "fileName": spec["media"][kind], "fileSize": len(data), "appEventAssetType": kind},
            "relationships": {"appEventLocalization": {"data": {"type": "appEventLocalizations", "id": loc_id}}}}})["data"]
        for op in shot["attributes"]["uploadOperations"]:
            req(op["method"], op["url"], raw=data[op["offset"]:op["offset"] + op["length"]],
                headers={h["name"]: h["value"] for h in op["requestHeaders"]}, absolute=True)
        req("PATCH", f"/v1/appEventScreenshots/{shot['id']}", {"data": {"type": "appEventScreenshots", "id": shot["id"],
            "attributes": {"uploaded": True}}})
    print(code, "text and media up")

if "--submit" in sys.argv:
    drafts = req("GET", f"/v1/reviewSubmissions?filter[app]={APP}&filter[platform]=IOS&filter[state]=READY_FOR_REVIEW")["data"]
    sub = drafts[0] if drafts else req("POST", "/v1/reviewSubmissions", {"data": {"type": "reviewSubmissions", "attributes": {"platform": "IOS"},
        "relationships": {"app": {"data": {"type": "apps", "id": APP}}}}})["data"]
    req("POST", "/v1/reviewSubmissionItems", {"data": {"type": "reviewSubmissionItems", "relationships": {
        "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": sub["id"]}},
        "appEvent": {"data": {"type": "appEvents", "id": event["id"]}}}}})
    out = req("PATCH", f"/v1/reviewSubmissions/{sub['id']}", {"data": {"type": "reviewSubmissions", "id": sub["id"], "attributes": {"submitted": True}}})
    print("submitted", sub["id"], out["data"]["attributes"]["state"])

readback(event["id"])
