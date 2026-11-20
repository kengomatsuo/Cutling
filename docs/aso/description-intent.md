# App Store description: meaning brief

What each added line of Cutling's App Store description (`fastlane/metadata/<locale>/description.txt`
for iOS, `fastlane/metadata_mac/<locale>/description.txt` for Mac; today both trees hold the same
text) must mean. No locale is the source the others are translated from: each line is written
fresh in its language from this brief, in the voice of the description already in that file.

## Last bullet: the Mac clipboard history skips passwords

- Where: the final line of the "Why Cutling?" bullet list, after the colour-label and icon bullet,
  with the same bullet mark and punctuation the file's other bullets use.
- Meaning: one purchase includes Cutling for Mac, which keeps a history of what you copy, and that
  history skips anything a password manager marks as concealed, so copied passwords never land in it.
- Why it is there: a reviewer could not tell from the listing whether the history records passwords.
  It does not; the line answers that before anyone has to ask.
- Length: one line, about as long as the longest bullet already in the file.
- Words: name the history and the password manager the way the app's own strings in that language
  do (`Cutling/<lproj>/Localizable.strings`, the line about items flagged as concealed by password
  managers being ignored). Keep "Cutling" and "Mac" in their brand form.
