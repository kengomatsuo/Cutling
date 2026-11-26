"""Writes one language's words file from a compact list: python3 -c via _put.put(loc, lines, ask, note, hi, bt, digits)."""
import json
from pathlib import Path
D = Path(__file__).parent
KEYS = ["1h","1s","2h","2s","3h","3s","4h","4s","5h","5s","6h","6s","7h","7s","8h","8s","8f"]
def put(loc, L, ask, note, hi="4815", bt="", digits=None):
    assert len(L) == 17, (loc, len(L))
    p = D / f"{loc}.json"
    d = json.loads(p.read_text()) if p.exists() else {}
    main = {}
    for k, v in zip(KEYS, L):
        main.setdefault(k[0], {})[{"h": "h", "s": "s", "f": "f"}[k[1]]] = v
    d["main"] = main
    d["demo"] = {"ask": ask, "note": note, "note_hi": hi}
    if digits: d["digits"] = digits
    d.setdefault("_bt", {})["main"] = bt
    p.write_text(json.dumps(d, ensure_ascii=False, indent=1) + "\n")


def put2(loc, pd, qr, bt=""):
    """Personal details (Keys) and Quick replies (Night flight) headlines; the fine line in frame 6 is main.8.f."""
    assert len(pd) == 6 and len(qr) == 6, loc
    p = D / f"{loc}.json"
    d = json.loads(p.read_text())
    f = d["main"]["8"]["f"]
    d["keys_pd"] = {str(i + 1): {"h": h} for i, h in enumerate(pd)}
    d["keys_pd"]["6"]["f"] = f
    d["night_qr"] = {str(i + 1): {"h": h} for i, h in enumerate(qr)}
    d["night_qr"]["6"]["f"] = f
    d.setdefault("_bt", {})["pd_qr"] = bt
    p.write_text(json.dumps(d, ensure_ascii=False, indent=1) + "\n")
