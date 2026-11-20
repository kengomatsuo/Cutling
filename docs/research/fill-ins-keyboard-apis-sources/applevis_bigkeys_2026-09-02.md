# https://www.applevis.com/forum/ios-ipados/bigkeys-large-key-keyboard-low-vision-voiceover-support  post by the app's developer dated 2 September 2026 (read in Chrome 2026-11-21). A developer's claims on a shipped keyboard, not Apple.
- Keys drawn as custom shapes publish no accessibility elements unless made so; he tests with Apple's accessibility audit on every build.
- Every key carries a label and the keyboard-key trait, "which is what makes them eligible for Touch Typing".
- Touch Typing works (rest finger, slide, lift: the key at lift-off is inserted); the keyboard's own gesture recogniser never sees the touches under VoiceOver. Standard typing style works (focus key, double-tap).
- Long press never fires under VoiceOver, so alternates go in the rotor under Actions.
- Own key speech switches off while VoiceOver runs; word announcements are posted at low priority.
- No Full Access needed for any of that.
