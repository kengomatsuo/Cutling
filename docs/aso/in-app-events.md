# In-app events: Apple's rules that bind Cutling's events

Read 2026-11-22 for the 2.0 event (card ASG152). Art rules and Apple's overlay measurements are in
Undirect's `docs/research/in-app-event-art.md`; the build script copies Undirect's
`Support/AppStore/create_event.py`.

| Rule | Apple's words | Page |
|---|---|---|
| No prices | "Don't include specific prices in your metadata"; "Including specific pricing will lead to rejection by App Review." | [In-App Events](https://developer.apple.com/app-store/in-app-events/) |
| Sales alone are weak events | "Price promotions that don't introduce any new content, features, or goods" are not good candidates | same |
| Text limits | name "up to 30 characters long and written in title case"; short description "up to 50 characters written in sentence case"; long description "up to 120 characters written in sentence case"; "Avoid using all capitals", "Don't use multiple punctuation points" | same |
| Length and lead time | "a maximum of 31 days from the start date"; published "a maximum of 14 days in advance of the start date" | [Offer in-app events](https://developer.apple.com/help/app-store-connect/offer-in-app-events/offer-in-app-events/) |
| Moving dates | Before publication "you can adjust the country or region availability, priority, start time, end time, and publish date"; after publication "you can modify only the start and end dates"; after it begins, "the end date only" | [Manage events](https://developer.apple.com/help/app-store-connect/offer-in-app-events/manage-events) |
| Editing in review | "you'll need to remove it from review in order to edit any details except for Country or Region Availability" | same |
| Tie to a version | "you can choose to submit an In-App Event with or without an iOS app version"; without one, "The In-App Event will be reviewed together with the latest version of the selected platform." | [Submit an in-app event](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-event) |
| Accuracy | "All event metadata must be accurate and pertain to the event itself"; "Events must happen at the times and dates you select" | [Guideline 2.3.13](https://developer.apple.com/app-store/review/guidelines/) |
| Missing language | the primary language "will be the default language that displays to users if your event isn't localized for their device's language" | Offer in-app events |
| Major Update badge | "Introducing significant new features, content, or experiences" that "go beyond minor enhancements like UI adjustments or bug fixes" | [Badges](https://developer.apple.com/help/app-store-connect/reference/in-app-events/in-app-event-badges) |
| Video | card `.mov/.m4v/.mp4` 16:9, 1920x1080 to 3840x2160, 30 or 60 fps, 500 MB; details 9:16, 1080x1920 to 2160x3840; "Videos autoplay and repeat, so aim to create a seamless loop" | [Media specifications](https://developer.apple.com/help/app-store-connect/reference/in-app-events/in-app-event-media-and-audio-specifications) |
| Counts | up to 10 published at a time, 15 approved per app | In-App Events; Offer in-app events |

## What follows for Cutling

- The event goes to review **in the same submission as 2.0**. Sent alone before 2.0 is approved, it is
  reviewed against the live 1.6.2, which has none of what it promotes, and 2.3.13 asks for accurate
  metadata.
- The event starts on the day 2.0 is live. Its dates are set from the planned release and moved, before
  it publishes, once 2.0 is approved.
- A Black Friday mention may name the sale but never the $2.99 price.

Not found on any page read: whether text or image edits after approval need a new review, video length
limits, and whether a localization without its own images falls back to the primary locale's.
