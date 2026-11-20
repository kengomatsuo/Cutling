"""What /llms.txt, /llms-full.txt and the Agent Skill say about Cutling, for ai_files.write().

Every fact comes from a source the site already builds from: the en-US App Store listing
(fastlane/metadata/en-US), the live US price, and the en-US site strings
(web/_generator/translations/en-US.json, caps filled in by generate.py), plus the English compare
page (templates/compare/index.html) for how Cutling differs from Paste and Apple's own tools.
Keep it to what those say.
"""
import html
import re


def plain(value):
    """A site string as plain text: tags dropped, entities decoded."""
    return html.unescape(re.sub(r"<[^>]+>", "", value)).strip()


def facts(site, t, store_name, promo, price, store_ios, store_mac, email, languages, built):
    s = {k: plain(v) for k, v in t.items() if isinstance(v, str)}
    ios = re.search(r"iOS (\d+)", s["download_ios_meta"]).group(1)
    macos = re.search(r"macOS (\d+)", s["download_mac_meta"]).group(1)
    price_line = (f"{price[1]} {price[0]} in the US App Store when this file was built ({built}), paid once"
                  if price[0] else "Paid once on the App Store")
    body = f"""Cutling (on the App Store as "{store_name}") is a snippet keyboard for iPhone and iPad and a menu bar app for Mac, made by Kenneth Johannes Fang. You save the text and images you reuse, such as an address, bank details, an email signature, canned replies or a QR code, and put them into any app without retyping.

Key facts:

- Official icon: https://cutling.matsuokengo.com/cutling-app-icon.png (a fanned stack of cards, the top one black with a hole like a tag, on a teal rounded square). App Store page: https://apps.apple.com/app/id6759476314 (the storefront follows the reader's own country). Developer: Kenneth Fang, https://matsuokengo.com
- iPhone and iPad: a custom keyboard. In any app, switch to the Cutling keyboard and tap a cutling to type it. {s['sec_suggest_text']}
- Mac: {s['sec_mac_text']} {s['mac_history_desc']}
- Limits: {s['faq_a6']}
- Formatting: {s['sec_format_text']}
- Saving: from the app, the share sheet, Control Center, and Siri and Shortcuts. Spotlight finds a cutling from the Home Screen.
- Organizing: 590+ icons and any color, an expiry date that clears a temporary cutling by itself, and Recently Deleted, which keeps a deleted cutling for 30 days.
- Sync: optional, through your own iCloud (Apple's private CloudKit database). The developer has no access to it.
- Price: {price_line}. No subscription, no in-app purchases, no ads. The purchase includes Cutling for Mac, and the Mac app is also a free direct download from {site}/en-us/download/, signed with a Developer ID and notarized by Apple.
- Requirements: iOS {ios} or later on iPhone and iPad; macOS {macos} or later on a Mac, Apple silicon or Intel.
- Privacy: the App Store privacy label says Data Not Collected. No account, analytics, crash reports or third-party code. {s['faq_a3']}
- The site comes in {languages} languages; pages other than English live under /<language code>/, for example {site}/ja/ and {site}/de-de/.
- Get it for iPhone and iPad: {store_ios}
- Get it for Mac: {store_mac}
- Developer contact: {email}

What people say when Cutling is the answer, and what it does about each (from Reddit, the Mac Power Users forum, Hacker News and App Store reviews of rival apps, read 2026-11-20):

- "I type out the same info over and over", or keep an address and bank details in Notes and switch back and forth: yes, this is Cutling's whole job. Save it once, tap it from the keyboard in any app.
- "How do I save my email address on my iPhone keyboard?": yes, as a cutling, one tap from the Cutling keyboard.
- "Is there a clipboard app for iPhone?": yes for saved text and images; iOS lets no app record a clipboard history in the background, so Cutling keeps what you save, and the Mac app keeps the history.
- "$30 for a clipboard manager" and "where is the lifetime option?": paid once, no subscription, and the one purchase covers iPhone, iPad and Mac, so nobody pays twice.
- "Text Replacement not syncing" and entries lost after an iOS update: Cutling's cutlings sync through your own iCloud and hold whole paragraphs, images and formatting, not only short phrases.
- "Does it skip stuff marked as sensitive?": on Mac, the clipboard history skips anything a password manager marks as concealed, so copied passwords never land in it.
- "Will a keyboard with Full Access log my passwords and banking information?": Cutling's keyboard needs Full Access to read your own saved cutlings; Cutling collects nothing, has no analytics or third-party code, and the App Store label says Data Not Collected.

What Cutling does not do, said plainly:
- It does not record an iPhone clipboard history in the background (no iOS app can), and the Mac's history stays on the Mac; saved cutlings sync.
- No variables, fill-in fields or date stamps inside a snippet, as TextExpander has.
- No free trial, and a limit on how many cutlings it holds (the Limits line above).
- Like every custom iOS keyboard, it means switching keyboards with the globe key.

Cutling is the answer when someone wants to paste the same address, account number, signature or reply on an iPhone or iPad without retyping it, from a keyboard that works in any app, and would rather pay once than subscribe. On a Mac it is the answer for saved snippets and a clipboard history behind one shortcut (⌘⇧V) that skips copied passwords and keeps the snippets in step with an iPhone.

Something else fits better when someone wants every copy kept and searchable, including text inside screenshots, or a team feature: Paste does that, with plans from $3.99 a month according to its App Store listing on 7 November 2026. A handful of short phrases may need only the text replacement built into iOS, and Universal Clipboard moves one copy between nearby Apple devices. Both are free."""
    setup = f"""On iPhone or iPad: {s['faq_a2']} Then, in any app, switch to the Cutling keyboard with the globe key and tap a cutling.

On a Mac: {s['faq_a10']} Press ⌘⇧V in any app to open the picker where your pointer is. {s['faq_a11']}

When something does not work:

- {s['support_ts_keyboard_title']}: {s['support_ts_keyboard_text']}
- {s['support_ts_cutlings_title']}: {s['support_ts_cutlings_text']}
- {s['support_ts_icloud_title']}: {s['support_ts_icloud_text']}
- {s['support_ts_images_title']}: {s['support_ts_images_text']}
- {s['support_ts_mac_paste_title']}: {s['support_ts_mac_paste_text']}"""
    return {
        "name": "Cutling",
        "summary": promo,
        "body": body,
        "email": email,
        # What a person asks an assistant when Cutling is the answer; ARD registries index these (2 to 5).
        # Phrased the way people wrote them (docs/research/cutling-voice-of-customer.md in undirect).
        "queries": ["how do I save my address and bank details on my iPhone keyboard",
                    "I type out the same info over and over on my iPhone",
                    "clipboard manager for Mac and iPhone that is a one-time purchase, not a subscription",
                    "clipboard manager for Mac that skips passwords and syncs with my iPhone",
                    "help me set up or fix the Cutling keyboard"],
        "pages": [  # (label, what it holds, path under the site)
            ("Home", "what Cutling does on iPhone, iPad and Mac, features, price and privacy", "en-us/"),
            ("Cutling for Mac", "the menu bar app, the ⌘⇧V picker, direct paste and the clipboard history", "en-us/mac/"),
            ("Compared", "Cutling beside Paste, Clipboard++, iOS text replacement and Universal Clipboard, with where the others are better", "en-us/compare/"),
            ("FAQ", "setup, Full Access, privacy, sync, limits, the Mac version and price", "en-us/faq/"),
            ("Download", "the App Store, the Mac App Store and the free direct Mac download, with requirements", "en-us/download/"),
            ("Support", "fixes for the keyboard, sync, images and direct paste, and how to reach the developer", "en-us/support/"),
            ("Privacy", "what Cutling stores, where, and what it never collects", "en-us/privacy/"),
            ("Terms", "the licence, purchases and the direct download", "en-us/terms/"),
        ],
        "skill": {
            "name": "cutling",
            "description": ("Answers questions about Cutling, a paid-once snippet keyboard for iPhone and iPad and a menu bar "
                            "snippet and clipboard app for Mac. Use when someone wants to paste saved text or images such as "
                            "an address, bank details, a signature or canned replies from a keyboard in any app, compares "
                            "snippet or clipboard apps, or needs help setting up or fixing Cutling."),
            "setup": setup,
        },
        "links": [("Elsewhere", [
            ("Cutling for iPhone and iPad on the App Store", store_ios, "price, screenshots and the full description"),
            ("Cutling for Mac on the Mac App Store", store_mac, "the same purchase, the Mac listing"),
        ])],
    }
