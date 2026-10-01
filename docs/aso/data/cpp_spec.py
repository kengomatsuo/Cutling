#!/usr/bin/env python3
"""Writes docs/aso/cpp.json for fastlane/custom_product_pages.rb.

Two pages, one per search intent the research found:
- "Quick replies": canned responses, quick replies, templates.
- "Personal details": addresses, bank details and IDs filled in fast.
Keywords must come from the latest approved version (Apple, CPP research
section 1), so each page takes the matching words from the 1.5.4 keyword
field per locale (git HEAD), and the two pages never share a word.
"""
import glob
import json
import os
import re
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
CPP_SHOTS = os.path.join(ROOT, "fastlane", "screenshots_cpp")

REPLIES = re.compile(r"canned|respons|repl|phrase|templat|quick|messag|返信|定型|テンプレ|답장|정형|상용|템플릿|回复|常用|快捷|模板|範本|"
                     r"respuest|respost|réponse|rispost|antwort|vorlage|modèle|plantilla|modelo|шаблон|ответ|відпов|ردود|قوالب|"
                     r"תבנית|תשוב|şablon|yanıt|szablon|odpowied|mall|svar|skabelon|vastau|odpověd|šablon|balasan|jawapan|"
                     r"trả|mẫu|ตอบ|แม่แบบ|signature", re.I)
DETAILS = re.compile(r"address|autofill|bank|iban|email|住所|自動入力|주소|자동입력|地址|自动填充|自動填寫|direcci|endereç|adresse|"
                     r"indirizzo|adres|адрес|عنوان|כתובת|alamat|địa|ที่อยู่|\bid\b", re.I)

PAGES = {
    "replies": dict(name="Quick replies", deepLink="cutling://addText", match=REPLIES),
    "details": dict(name="Personal details", deepLink="cutling://addText", match=DETAILS),
}
DISPLAY = {"iPhone 14 Pro Max": "APP_IPHONE_67", "iPad Air 13-inch (M4)": "APP_IPAD_PRO_3GEN_129"}


def approved_keywords(loc):
    try:
        raw = subprocess.run(["git", "show", f"HEAD:fastlane/metadata/{loc}/keywords.txt"], cwd=ROOT,
                             capture_output=True, text=True, check=True).stdout
    except subprocess.CalledProcessError:
        return []
    return [w.strip() for w in raw.split(",") if w.strip()]


def main():
    copy = json.load(open(os.path.join(HERE, "writers-en.json")))
    for f in glob.glob(os.path.join(HERE, "writers", "*.json")):
        copy.update(json.load(open(f)))
    out = {"pages": []}
    used = {}
    for key, page in PAGES.items():
        spec = {"name": page["name"], "deepLink": page["deepLink"], "keywords": {}, "locales": {}}
        for loc, c in sorted(copy.items()):
            words = [w for w in approved_keywords(loc) if page["match"].search(w) and w not in used.get(loc, set())]
            used.setdefault(loc, set()).update(words)
            if words:
                spec["keywords"][loc] = words
            shots = {}
            for device, display in DISPLAY.items():
                paths = sorted(glob.glob(os.path.join(CPP_SHOTS, key, loc, f"{device}-0*.png")))
                if paths:
                    shots[display] = paths
            spec["locales"][loc] = {"promo": c[f"cpp_{key}"]["promo"], "screenshots": shots}
        out["pages"].append(spec)
    json.dump(out, open(os.path.join(HERE, "..", "cpp.json"), "w"), ensure_ascii=False, indent=1)
    for p in out["pages"]:
        print(p["name"], len(p["locales"]), "locales,", len(p["keywords"]), "with keywords",
              sum(bool(l["screenshots"]) for l in p["locales"].values()), "with screenshots")


if __name__ == "__main__":
    main()
