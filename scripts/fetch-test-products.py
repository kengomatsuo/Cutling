#!/usr/bin/env python3
"""Waits for an Xcode Cloud run of the Proof workflow and lays its test products out for scripts/ui-test.sh and the
device-queue film jobs (docs/release-workflow.md, step 4):

    python3 -I scripts/fetch-test-products.py <run number> <folder>

<folder>/DerivedData/Build/Products/ ends holding the run's .xctestrun and Debug-iphonesimulator, as
UI_TEST_BUILD=<folder> expects. A run whose tests failed still carries its test products, so only a run that built
nothing fails here. Signs with Undirect's Support/AppStore/asc_api.py, the key the Release and Proof workflows use.
"""
import glob, os, shutil, subprocess, sys, tempfile, time, urllib.request

sys.path.insert(0, os.path.expanduser("~/Repositories/undirect/Support/AppStore"))
import asc_api  # noqa: E402

PRODUCT = "F7610AA8-F110-4FB9-9DC6-543266C2B62E"
number, folder = int(sys.argv[1]), os.path.abspath(sys.argv[2])

while True:
    runs = asc_api.call("GET", f"/v1/ciProducts/{PRODUCT}/buildRuns?limit=20&sort=-number")["data"]
    run = next((r for r in runs if r["attributes"]["number"] == number), None)
    if not run:
        sys.exit(f"no run {number}")
    a = run["attributes"]
    print(time.strftime("%H:%M"), number, a["executionProgress"], a.get("completionStatus") or "", flush=True)
    if a["executionProgress"] == "COMPLETE":
        break
    time.sleep(60)

artifact = None
for action in asc_api.call("GET", f"/v1/ciBuildRuns/{run['id']}/actions")["data"]:
    for art in asc_api.call("GET", f"/v1/ciBuildActions/{action['id']}/artifacts")["data"]:
        if art["attributes"].get("fileType") == "TEST_PRODUCTS":
            artifact = art
if not artifact:
    sys.exit(f"run {number} left no TEST_PRODUCTS")
url = asc_api.call("GET", f"/v1/ciArtifacts/{artifact['id']}")["data"]["attributes"]["downloadUrl"]

with tempfile.TemporaryDirectory() as tmp:
    zipped = os.path.join(tmp, "tp.zip")
    urllib.request.urlretrieve(url, zipped)
    subprocess.run(["ditto", "-x", "-k", zipped, os.path.join(tmp, "x")], check=True)
    runfile = glob.glob(os.path.join(tmp, "x", "**", "Tests", "0", "*.xctestrun"), recursive=True)
    binaries = glob.glob(os.path.join(tmp, "x", "**", "Binaries", "0", "Debug-iphonesimulator"), recursive=True)
    if not runfile or not binaries:
        sys.exit("test products hold no Tests/0/*.xctestrun or Binaries/0/Debug-iphonesimulator")
    products = os.path.join(folder, "DerivedData", "Build", "Products")
    shutil.rmtree(products, ignore_errors=True)
    os.makedirs(products)
    shutil.copy2(runfile[0], products)
    shutil.copytree(binaries[0], os.path.join(products, "Debug-iphonesimulator"), symlinks=True)
print(f"run {number} ({a.get('completionStatus')}): {products}")
