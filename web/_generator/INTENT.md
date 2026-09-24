# Cutling website — meaning brief

This file states what every string on the Cutling website must **mean**. It is not
copy to translate. Write each string fresh in your target language, from the meaning
described here, the way a native copywriter for that market would write it.

Nobody reading your output should be able to tell it came from English.

---

## The product, in one paragraph

Cutling is a clipboard manager for iPhone, iPad and Mac. You save pieces of text and
images you reuse a lot — your address, an email signature, a QR code, a bank account
number — and then you can drop any of them into any app without hunting for them.

On iPhone and iPad it does this through a custom keyboard: you switch to the Cutling
keyboard inside whatever app you are in, tap a saved item, and it is inserted. On Mac
it lives in the menu bar and answers a keyboard shortcut you press from anywhere; a
small floating picker opens at your cursor and you choose an item.

It costs money once. There are no ads, no subscription, no in-app purchases, no
accounts, no analytics, no tracking, no third-party code. There is no server: the
developer has literally no way to see your data. Your saved items live on your device,
and only sync — through your own iCloud, optionally — if you turn that on.

The developer is one person, Kenneth Johannes Fang.

## The word "cutling"

**"Cutling" is the product name and a coined noun. It is a name, not a description.
Never translate it into a word meaning "a cut", "a piece", "a slice", "cutting",
"trimming" or anything about cutting things.**

An Indonesian version of this site once rendered *your cutlings* as *potongan daging* —
cuts of meat. That is the failure this brief exists to prevent.

A **cutling** is one saved item: a piece of text, or an image. The site uses the word
constantly, both singular and plural.

**Use exactly the form the app itself already uses in your language.** Before writing
anything, read these two files and follow them:

- `Cutling/<your-lproj>/Localizable.strings` — the app's own hand-written strings in
  your language. This is the authority for how "Cutling", "cutling", "cutlings",
  "clipboard", "keyboard", "snippet", "sync" and "Full Access" are said in your
  language. Match it. If the app leaves "Cutling" in Latin script, so do you. If the
  app transliterates it, use that transliteration everywhere.
- `fastlane/metadata/<your-locale>/name.txt` — the App Store name. The part before
  the dash is the brand form for your locale; the `app_name` key must be exactly that
  brand form alone, with no tagline.

If your language marks plurals and the brand form is a borrowed noun, use the natural
plural of that borrowed noun. If your language does not mark plurals, do not invent one.

## Voice

Plain, warm, direct, confident, never salesy. Short sentences. Address the reader the
way a good consumer app addresses them in your language — pick the register (formal
or informal "you", or an impersonal construction) that a well-made Apple-adjacent app
would use for your market, and hold it consistently across all 178 strings.

Do not write English word order in your language's words. Compose the sentence the way
your language builds it. Idioms, punctuation conventions, spacing, quotation marks and
sentence rhythm follow your language, not English. Chinese, Japanese, Korean and Thai
use their own punctuation and no space before Latin brand names unless your app strings
already do.

Do not add exclamation marks. Do not add marketing adjectives that are not in the
meaning. Do not pad. If your language says something in fewer words, use fewer words.

## Hard mechanical rules

1. **Output valid JSON**, UTF-8, same 181 keys as `translations/en-US.json`, nothing
   added, nothing dropped. Preserve `_language_code` and `_language_name` as the correct
   values for your locale (`_language_name` is your language's own name for itself, as
   listed in `locales.json`). Preserve `_rtl` as the right boolean for your script.
2. **Never write a raw `&`, `<` or `>`.** Write `&amp;` `&lt;` `&gt;` instead.
   The other entities — `&mdash;` `&ldquo;` `&rdquo;` `&copy;` — are available to you,
   but none of them is compulsory. Where English uses an ampersand to join two words,
   **use your language's own conjunction** (*and*, *i*, *und*, *と*, *和*, *و*) unless
   an ampersand is genuinely idiomatic in your language's UI, in which case write it
   as `&amp;`.
   `&ldquo;…&rdquo;` marks a quotation: if your language uses different quotation marks
   («» 「」 „" etc.), use your language's marks as literal characters instead and drop
   the entities. `&mdash;` is an em dash used as a break in a sentence; if your language
   does not use em dashes that way, restructure the sentence rather than keeping it.
3. **Links stay intact.** Seven strings carry HTML: `faq_a10`, `support_contact_text`,
   `support_more_help_text`, `privacy_icloud_outro`, `privacy_changes_log`,
   `privacy_contact_text`, `terms_contact_text`. Keep the `<a href="…">` and `</a>`
   tags and the `<strong>` tags, with the href value character-for-character unchanged,
   and put your translated words between the tags so the link wraps the right phrase.
4. **Never translate**: Cutling, Apple, App Store, Mac App Store, iPhone, iPad, Mac,
   macOS, iOS, iCloud, CloudKit, Apple ID, Developer ID, Dock, DMG, Applications
   folder, QR, SDK, Kenneth Johannes Fang, `kenneth@matsuokengo.com`. Use each one's
   official Apple form in your language where Apple has one (e.g. the App Store's own
   localized name), and otherwise leave it in Latin script.
5. **Key names, HTML and code are never translated** — only the values.
6. Numbers stay: 100, 25, 2,000, 750+, 12, 30, 48, 13, 18, 14. Format them the way
   your language formats numbers (decimal and thousands separators, digit shapes if
   your locale genuinely uses them in app UI).
7. Dates: `March 8, 2026` and `July 1, 2026` — write them in your language's normal
   date form, same dates.

---

# The strings

Each entry gives the key, where it appears, and what it must say.

## Chrome — navigation, footer, titles

- `app_name` — the brand form for your locale, alone. Shown next to the app icon in
  the top navigation bar and as image alt text.
- `nav_home` — nav link to the front page. One word. The word your language uses for
  a website's front page, not the word for a dwelling.
- `nav_mac` — nav link to the Mac page. Just `Mac`.
- `nav_download` — nav link to the download page. One word or short phrase.
- `nav_faq` — nav link to the questions page. Your language's normal short form for
  frequently asked questions; if the abbreviation "FAQ" is what people actually use in
  your market, keep it.
- `nav_support` — nav link to the help page. The noun for help or assistance, never a
  verb meaning "to support".
- `nav_privacy` — nav link to the privacy policy. The noun "privacy", not "private".
- `nav_terms` — nav link to the terms of use. The noun.
- `language_picker_label` — the word "language", labelling the language chooser.
- `footer_copyright` — a copyright line: `&copy;` then 2026, then the name Kenneth
  Johannes Fang, then your language's standard all-rights-reserved formula. If your
  market has no such formula, the year and name alone are fine.

Page `<title>` strings. Each is brand plus page name, joined by `&mdash;` (or your
language's normal title separator). They appear in browser tabs and search results.

- `page_title_home` — brand, then the front-page promise: that the reader's clipboard
  becomes organised.
- `page_title_faq` — the questions page.
- `page_title_support` — the help page.
- `page_title_privacy` — the privacy policy.
- `page_title_mac` — the Mac page: "Cutling for Mac".
- `page_title_download` — the download page.
- `page_title_terms` — the terms of use page.

## Front page — hero

- `hero_title` — the headline, large, centred. It says: your clipboard, now organised.
  Very short. A noun phrase, not a sentence, if that reads better in your language.
- `hero_subtitle` — one paragraph under the headline. It must convey: you save text
  snippets and images, and can reach them instantly — from a custom keyboard on iPhone
  and iPad, or from a menu-bar app and a global keyboard shortcut on Mac. Then, curtly:
  no accounts, no tracking, just your own things. Keep that closing turn brisk.
- `cta_button` — button label. Invites downloading from the App Store. Use Apple's
  own localized wording for "Download on the App Store" in your market if one exists.
- `cta_button_mac` — secondary button leading to the Mac page. Says: get Cutling for
  Mac. Short, brand form plus "for Mac".

## Front page — how it works (four steps)

- `how_it_works_title` — section heading: how the app works.

- `step1_title` — short imperative heading: save it.
- `step1_text` — you add text snippets or images to your collection: addresses,
  signatures, QR codes, anything you reuse often.
- `img_alt_main_view` — alt text for a screenshot of the app's main screen showing
  saved cutlings.

- `step2_title` — short imperative heading: make it yours / customise it.
- `step2_text` — you can pick from more than 750 icons and 12 colours to organise your
  cutlings, and set expiry dates on ones you only need temporarily.
- `img_alt_text_details` — alt text: editing a cutling, choosing icons and colours.

- `step3_title` — short heading: reach it anywhere.
- `step3_text` — inside any app you switch to the Cutling keyboard and tap to paste,
  without leaving what you were doing.
- `img_alt_keyboard` — alt text: the Cutling keyboard open in the Messages app.

- `step4_title` — short heading: sync across devices.
- `step4_text` — you can optionally turn on iCloud so your cutlings stay in sync
  across iPhone, iPad and Mac.
- `img_alt_settings` — alt text: the settings screen with iCloud sync.

## Front page — why it costs money

- `why_paid_title` — heading: why Cutling is a paid app.
- `why_paid_emphasis` — a single emphasised line, four flat denials: no ads, no
  tracking, no subscriptions, no in-app purchases. Keep it clipped in your language's
  own idiom for such a list; it does not have to be four sentences.
- `why_paid_p1` — you pay once and own it forever, full stop. Buying on iPhone or iPad
  includes the Mac app at no extra cost through Apple's universal purchase, and the Mac
  app can also always be downloaded free directly from this website.
- `why_paid_p2` — there are no servers to run and no database holding your data, which
  keeps costs low and makes the app sustainable and long-lived, with no need to make
  money from your attention or your information.
- `why_paid_p3` — no upselling, no "premium" tier, no nagging to upgrade; you get the
  whole app from the first day. Put the word premium in quotation marks.

## Front page — feature grid

- `features_title` — section heading over the grid: features.

Eight cards, each a short title and one or two sentences. Titles are noun phrases and
must stay short enough for a card heading.

- `feature_text_snippets_title` / `_desc` — text snippets. Up to 100 text cutlings, each
  up to 2,000 characters.
- `feature_image_cutlings_title` / `_desc` — image cutlings. Up to 25 images for quick
  access: QR codes, signatures, diagrams.
- `feature_custom_keyboard_title` / `_desc` — the custom keyboard. Insert cutlings from
  inside any app without switching apps; one tap pastes.
- `feature_icons_colors_title` / `_desc` — icons and colours. More than 750 icons and 12
  colours to organise your collection. The title joins the two nouns.
- `feature_expiration_title` / `_desc` — expiry dates. Set an auto-delete date on
  temporary snippets and they remove themselves.
- `feature_icloud_title` / `_desc` — iCloud sync. Keeps cutlings in step across all your
  Apple devices; optional and private.
- `feature_recently_deleted_title` / `_desc` — recently deleted. Deleted something by
  accident? You can get it back within 30 days. Keep the question-then-answer shape only
  if it is natural in your language.
- `feature_devices_title` / `_desc` — iPhone, iPad and Mac. One app across all your Apple
  devices, feeling native on each. The title lists all three.

## Front page — privacy teaser

- `privacy_teaser_title` — short heading meaning privacy comes first.
- `privacy_teaser_text` — Cutling collects no data at all: no analytics, no crash
  reports, no third-party SDKs. Your cutlings stay on your device, or in your own iCloud
  account if you choose to switch sync on. The developer cannot reach your data, full
  stop.
- `privacy_teaser_link` — link text: read the full privacy policy.

## FAQ page

- `faq_title` — page heading: frequently asked questions.

Questions are written as a user would ask them. Answers are two to four sentences,
calm and concrete.

- `faq_q1` — what is a "cutling"? (word in quotation marks)
- `faq_a1` — a cutling is one saved item, a piece of text or an image you want kept
  within reach. Explain the name: think of it as a cutting taken from your clipboard
  that you can reuse whenever. **If the pun does not survive into your language, drop
  the pun and simply say plainly what a cutling is — never invent a false etymology,
  and never translate the name itself.**
- `faq_q2` — how do I set up the Cutling keyboard?
- `faq_a2` — the path is Settings > General > Keyboard > Keyboards > Add New Keyboard,
  then choose Cutling; then tap Cutling and switch on "Allow Full Access". There is also
  a setup guide inside the app. **Use the exact wording iOS itself uses in your language
  for those Settings items** — your app strings file and Apple's own localisation are the
  reference. Separate the steps with `&gt;`.
- `faq_q3` — why does the keyboard need Full Access?
- `faq_a3` — Full Access lets the keyboard read your saved cutlings out of local storage
  so it can show them. Cutling does not use the permission to log keystrokes, reach the
  internet or send anything anywhere. Everything stays on the device.
- `faq_q4` — is my data safe?
- `faq_a4` — yes. Zero data collected: no analytics, no tracking, no crash reports, no
  third-party SDKs. Cutlings are stored locally on the device, or in your own iCloud
  account if you switch sync on. The developer has no way of reaching your data.
- `faq_q5` — how does iCloud sync work?
- `faq_a5` — when switched on, it uses Apple's private CloudKit database to keep
  cutlings in sync across your Apple devices. Only you can reach that data, through your
  Apple ID. The developer has no access to synced data. It is optional and can be
  switched off in settings at any time.
- `faq_q6` — are there limits on how many cutlings I can save?
- `faq_a6` — up to 100 text cutlings and 25 image cutlings; text cutlings hold up to
  2,000 characters each.
- `faq_q7` — does Cutling work on Mac?
- `faq_a7` — yes. On Mac it lives in the menu bar and can be called up anywhere with a
  global keyboard shortcut. You pick a cutling and it is pasted straight into whichever
  app you were using. With iCloud sync on, your cutlings stay consistent across iPhone,
  iPad and Mac.
- `faq_q10` — how do I install the Mac version?
- `faq_a10` — there are two ways, both on the download page (this phrase is the link,
  href `../download/`). From the Mac App Store it installs like any other app.
  Alternatively download it free directly: it is signed with a Developer ID and notarised
  by Apple, so it opens normally with no security warnings — you open the DMG and drag
  Cutling into your Applications folder.
- `faq_q11` — what is direct paste on Mac, and why does it ask for Accessibility
  permission?
- `faq_a11` — direct paste is optional. With it on, choosing a cutling from the picker
  sends a single Command-V to the app you were using, so the text arrives at your cursor.
  macOS requires Accessibility permission to send that keystroke. It is off by default,
  and with it off Cutling simply copies to the clipboard so you paste yourself. Use
  Apple's localized name for the Accessibility privacy setting and for Command-V in your
  language.
- `faq_q8` — is there a subscription or are there in-app purchases?
- `faq_a8` — no. Cutling is a one-time purchase: no subscriptions, no in-app purchases,
  no ads. Pay once, own it forever.
- `faq_q9` — what happens to deleted cutlings?
- `faq_a9` — they move to a "Recently Deleted" folder and are kept there for 30 days.
  You can restore them in that window or let them expire on their own. Use the app's own
  name for that folder in your language, in quotation marks.

## Support page

- `support_title` — page heading: support / help.
- `support_subtitle` — one short line offering help. Warm, not chirpy.
- `support_contact_title` — heading: contact.
- `support_contact_text` — for questions, feedback or bug reports, write to the email
  address. The address is the link text and the href is `mailto:kenneth@matsuokengo.com`.
- `support_contact_response` — the developer aims to reply within 48 hours. First
  person singular.
- `support_troubleshooting_title` — heading: troubleshooting.

Five problems, each a title naming the symptom and a paragraph fixing it.

- `support_ts_keyboard_title` — the keyboard does not appear.
- `support_ts_keyboard_text` — check the keyboard has been added: Settings > General >
  Keyboard > Keyboards > Add New Keyboard > Cutling, then tap Cutling and switch on
  "Allow Full Access". Same iOS wording and `&gt;` separators as `faq_a2`.
- `support_ts_cutlings_title` — cutlings do not show up in the keyboard.
- `support_ts_cutlings_text` — make sure Full Access is on for the Cutling keyboard;
  without it the keyboard cannot read your saved cutlings from local storage.
- `support_ts_icloud_title` — iCloud sync is not working.
- `support_ts_icloud_text` — check iCloud is on for the device (Settings > [your name] >
  iCloud) and that Cutling has iCloud access. Changes can take a moment to reach other
  devices. Keep the square brackets around the placeholder for the person's own name.
- `support_ts_images_title` — images do not load in the keyboard.
- `support_ts_images_text` — image cutlings need Full Access. If they still do not
  appear, remove the Cutling keyboard in Settings and add it again.
- `support_ts_mac_paste_title` — direct paste is not working on Mac.
- `support_ts_mac_paste_text` — it is off by default; switch it on in Settings > Paste,
  then grant Accessibility access when asked (System Settings > Privacy and Security >
  Accessibility, using Apple's own localized name for that panel). Without it, Cutling copies to the clipboard so you can paste yourself
  with Command-V.
- `support_more_help_title` — heading: more help.
- `support_more_help_text` — point at the FAQ (the word FAQ is the link, href `../faq/`)
  for common questions about features, privacy and how the app works.

## Privacy policy

Legal text. Precise, plain, no flourish. Keep every factual claim exactly as stated.

- `privacy_page_title` — heading: privacy policy.
- `privacy_effective` — effective date: 8 March 2026, in your language's date form.
- `privacy_summary` — a one-paragraph summary in a highlighted box: Cutling does not
  collect, store or transmit any of your data to the developer. Your data stays on your
  device, or syncs privately through your own iCloud account, which is optional.
- `privacy_overview_title` — heading: overview.
- `privacy_overview_text` — Cutling is a keyboard extension that lets you save and
  quickly insert text snippets and images such as addresses, signatures, QR codes and
  other frequently used content. This policy explains how the app handles your data.
- `privacy_collection_title` — heading: data collection.
- `privacy_collection_text` — no personal data is collected at all: no analytics, no
  crash reports, no usage tracking, no advertising identifiers. The app contains no
  third-party analytics or tracking frameworks. The developer has no ability to read,
  reach or retrieve your data.
- `privacy_cutlings_title` — heading: your cutlings.
- `privacy_cutlings_text` — every cutling you create, text or image, is stored locally
  on your device, and your data is never sent to the developer or to any third-party
  server.
- `privacy_icloud_title` — heading: iCloud sync, marked optional in parentheses.
- `privacy_icloud_intro` — Cutling offers optional iCloud sync to keep cutlings
  synchronised across your Apple devices. Ends by introducing the list below, so it
  should end with a colon.
- `privacy_icloud_li1` — list item: cutlings sync through your own iCloud account using
  Apple's private CloudKit database.
- `privacy_icloud_li2` — list item: only you can reach your synced data, through your
  Apple ID.
- `privacy_icloud_li3` — list item: the developer has no access to your iCloud data.
- `privacy_icloud_li4` — list item: you can switch sync off at any time in the app's
  settings.
- `privacy_icloud_outro` — with iCloud sync off, your data stays strictly local to your
  device. iCloud sync is provided by Apple and governed by Apple's iCloud terms and
  conditions — that phrase is the link, href
  `https://www.apple.com/legal/internet-services/icloud/`, unchanged.
- `privacy_keyboard_title` — heading: keyboard extension.
- `privacy_keyboard_text` — Cutling includes a custom keyboard extension that needs
  Full Access to read from the device clipboard. The permission is used only so you can
  paste and manage your saved cutlings. The keyboard does not log, record or transmit
  your keystrokes or your clipboard contents. All clipboard access happens locally on
  the device.
- `privacy_thirdparty_title` — heading: third-party services.
- `privacy_thirdparty_text` — Cutling uses no third-party services, SDKs or APIs, and
  no data is sent to external servers.
- `privacy_children_title` — heading: children's privacy.
- `privacy_children_text` — no data is collected from anyone, children under 13
  included. The app is safe for all ages.
- `privacy_changes_title` — heading: changes to this policy.
- `privacy_changes_text` — if the policy is updated, the changes will be posted on this
  page with a new effective date.
- `privacy_changes_log` — a dated changelog entry. The date 8 March 2026 is wrapped in
  `<strong>…</strong>` and followed by a colon inside the tags; then: updated to cover
  the addition of image cutlings and the optional iCloud sync feature, and clarified
  that iCloud sync is optional, can be switched off, and that synced data sits in your
  own iCloud account.
- `privacy_contact_title` — heading: contact.
- `privacy_contact_text` — if you have questions about this policy you can reach the
  developer at the email address; address is the link text, href
  `mailto:kenneth@matsuokengo.com`.

## Mac page

- `mac_hero_title` — headline: Cutling for Mac.
- `mac_hero_subtitle` — your clipboard is one keyboard shortcut away. Cutling lives in
  the menu bar and appears wherever your cursor is, so you can drop a saved snippet into
  any app without breaking your flow.
- `mac_appstore_button` — button: download on the Mac App Store. Apple's own localized
  wording where it exists.
- `mac_download_button` — button: download directly, free. Mark the free part in
  parentheses.
- `mac_features_title` — section heading: built for the desktop.

Six cards, short title plus two sentences.

- `mac_menubar_title` / `_desc` — it lives in the menu bar. Cutling sits quietly in the
  menu bar, out of the Dock and out of your way; click the icon to see your saved
  cutlings and your recent clipboard history.
- `mac_hotkey_title` / `_desc` — global shortcut. Press your shortcut from any app and a
  floating picker opens right at the cursor; you can rebind it to any key combination in
  settings.
- `mac_directpaste_title` / `_desc` — direct paste. You can optionally let Cutling paste
  your choice straight into the app you were using; off by default, and always yours to
  turn on.
- `mac_history_title` / `_desc` — clipboard history. Everything you copy is captured
  automatically so nothing gets lost, and you can save the ones worth keeping with one
  click.
- `mac_sync_title` / `_desc` — iCloud sync. Turn on iCloud to keep saved cutlings in step
  across iPhone, iPad and Mac; optional and private.
- `mac_privacy_title` / `_desc` — private by design. No accounts, no analytics, no
  tracking; your clipboard stays on your Mac, or in your own iCloud if you enable sync.
- `mac_cta_title` — closing heading, an invitation to try it.
- `mac_cta_text` — download Cutling for Mac and keep everything you reuse one shortcut
  away.

## Download page

- `download_title` — heading: download Cutling.
- `download_subtitle` — one app, feeling native on every Apple device.
- `download_ios_title` — iPhone and iPad.
- `download_ios_desc` — save snippets and images and insert them from any app using the
  custom keyboard.
- `download_ios_button` — button: download on the App Store.
- `download_ios_meta` — small print: needs iOS 18 or later.
- `download_mac_title` — Mac.
- `download_mac_desc` — a menu-bar app with a global keyboard shortcut and optional
  direct paste. Available on the Mac App Store, or as a free direct download signed with
  a Developer ID and notarised by Apple.
- `download_mac_appstore_button` — button: download on the Mac App Store.
- `download_mac_button` — button: download directly, free in parentheses.
- `download_mac_meta` — small print: on the Mac App Store, or free directly from this
  site; needs macOS 14 or later; universal, meaning Apple silicon and Intel.
- `download_mac_install_title` — heading: installing on Mac.
- `download_mac_install_text` — from the Mac App Store it installs like any other app.
  For the direct download you open the DMG and drag Cutling into your Applications
  folder. Because the app is notarised by Apple it opens normally, with no security
  warnings.

## Terms of use

Legal text again. Precise and plain.

- `terms_title` — heading: terms of use.
- `terms_effective` — effective date: 1 July 2026.
- `terms_intro` — these terms govern your use of Cutling, called "the app" hereafter
  (quotation marks around it). By downloading or using it you agree to them; if you do
  not agree, do not use it.
- `terms_license_title` — heading: licence.
- `terms_license_text` — Cutling is licensed to you, not sold, for personal or business
  use on devices you own or control. The licence is personal, non-exclusive and
  non-transferable. You may not copy, redistribute, resell, reverse engineer or modify
  the app except where the law allows it.
- `terms_appstore_title` — heading: App Store purchases.
- `terms_appstore_text` — copies obtained through the Apple App Store are also subject
  to Apple's Licensed Application End User Licence Agreement, and where those terms
  conflict with these, Apple's terms govern for App Store copies. Use Apple's official
  name for that agreement in your language if one exists.
- `terms_direct_title` — heading: direct download.
- `terms_direct_text` — the Mac app is also distributed directly as a Developer ID
  signed, Apple-notarised build. It is the same software, offered so you can install it
  outside the Mac App Store. It updates from inside the app, or by downloading a newer
  build from this site.
- `terms_payment_title` — heading: payment.
- `terms_payment_text` — Cutling is a one-time purchase, with no subscriptions, no
  in-app purchases and no recurring charges. Refunds for App Store purchases are handled
  by Apple under Apple's policies.
- `terms_warranty_title` — heading: no warranty.
- `terms_warranty_text` — the app is provided "as is" (in quotation marks), without
  warranties of any kind, express or implied. The developer does not warrant that it
  will be uninterrupted, error-free or fit for any particular purpose. You use it at
  your own risk. Use your jurisdiction's conventional legal phrasing for a warranty
  disclaimer.
- `terms_liability_title` — heading: limitation of liability.
- `terms_liability_text` — to the fullest extent the law permits, the developer is not
  liable for indirect, incidental or consequential damages, nor for any loss of data,
  arising from your use of the app. Back up anything you cannot afford to lose.
- `terms_changes_title` — heading: changes to these terms.
- `terms_changes_text` — the terms may be updated from time to time, and material
  changes will be posted on this page with a new effective date.
- `terms_contact_title` — heading: contact.
- `terms_contact_text` — questions about these terms? Email the address; the address is
  the link text, href `mailto:kenneth@matsuokengo.com`.
