"""What the Cutling version live on the App Store can do, for the site (generate.py) and the AI files (ai_facts.py).

A value changes on the day a release that has it is live, never before: the repo's app code can be ahead of the store.
"""
import re

# The snippet caps, written into every locale's copy where it says {{MAX_TEXT_CUTLINGS}} or {{MAX_IMAGE_CUTLINGS}}.
LIVE_CAPS = {"MAX_TEXT_CUTLINGS": 100, "MAX_IMAGE_CUTLINGS": 25}

# Features in the live version. While a feature is True, a page block between <!-- live:NAME --> and
# <!-- /live:NAME --> shows, and each site string in LIVE_KEYS takes its `<key>_live` wording.
LIVE_FEATURES = {"fill-ins": False}
LIVE_KEYS = {"faq_a15": "fill-ins"}


def is_live(feature):
    return LIVE_FEATURES.get(feature, False)


def apply_keys(translation):
    """A locale's strings with every live feature's `_live` wording in place, and the `_live` keys left out."""
    out = {k: v for k, v in translation.items() if not k.endswith("_live")}
    for key, feature in LIVE_KEYS.items():
        if is_live(feature) and translation.get(key + "_live"):
            out[key] = translation[key + "_live"]
    return out


def apply_blocks(html):
    """Keeps a live feature's page blocks (markers dropped) and removes the others'."""
    def block(match):
        return match.group(2) if is_live(match.group(1)) else ""
    return re.sub(r"[ \t]*<!-- live:([\w-]+) -->\n?(.*?)[ \t]*<!-- /live:\1 -->\n?", block, html, flags=re.S)
