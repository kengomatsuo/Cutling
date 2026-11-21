https://manual.raycast.com/ios/keyboard.md fetched 2026-11-21
# Keyboard

> Available on: iOS
> Tier: More with Pro

A full keyboard for iPhone and iPad with Raycast built in. Quick Fix, Ask AI, Translate, dictation, Snippets, GIFs, and emoji, one tap from any text field.

The Raycast Keyboard is a full typing keyboard for iPhone and iPad with Raycast built in. Type with autocorrect and suggestions as usual, and when you need more, it's one tap above the keys: fix a message with Quick Fix, ask AI, translate, run an [AI Command](https://manual.raycast.com/ai/ai-commands), [dictate](https://manual.raycast.com/ai/dictation), expand a [Snippet](https://manual.raycast.com/core-features/snippets), or find the right GIF or emoji. All without leaving the app you're in.

![The Raycast Keyboard on an iPad and two iPhones, with Ask AI open on one iPhone](https://fz1sd71lwhbqy6sh.public.blob.vercel-storage.com/raycast/images/app/ios/keyboard/ios-keyboard-hero.png)

> [!NOTE]
> The Raycast Keyboard types in English and several languages you can download, listed in [Languages](#languages). To type in another language, switch to [Secondary Mode](#secondary-mode) and keep your usual keyboard for typing.

## Get Started

1. On **Home**, tap your avatar in the top right, then **Keyboard**. You can also tap **Keyboard** in **More**.
2. Tap **Set Up Keyboard**. The **Enable Raycast keyboard** screen lists the steps, and **Open Settings** takes you to the Raycast page in the iOS Settings app. A picture-in-picture video plays the steps while you're in Settings.
3. Tap **Keyboards**, then turn on **Raycast** and **Allow Full Access**.
4. Return to Raycast and customize the keyboard on the **Configure your keyboard** screen, then tap **Done**.

If you used the Raycast Keyboard before, it switches to the full typing keyboard automatically, and **Home** shows a **Customize** button that opens the keyboard settings. If you prefer to use Raycast as a companion to another keyboard, you can switch it to [Secondary Mode](#secondary-mode).

### Replace the iOS Keyboard

To type with Raycast by default, replace the default iOS keyboard:

1. In the iOS Settings app, go to **General → Keyboard → Keyboards**.
2. Tap **Edit**.
3. Drag **Raycast** to the top of the list.
4. Tap the red minus button next to **English**.
5. Tap **Delete**.

> [!NOTE]
> iOS doesn't allow third-party keyboards in some fields, such as password fields, and some apps turn off third-party keyboard support. In those places, iOS shows its own keyboard even after you delete it from the list.

### Full Access

Typing, Emoji, Snippets, Quicklinks, and Search work without **Allow Full Access**. Quick Fix, Ask AI, AI Commands, Dictation, GIFs search, and creating a Snippet from the keyboard require the permission, since iOS only lets keyboards with Full Access connect to the internet and share data with the Raycast app.

When you tap one of these without Full Access, the keyboard explains why and shows **Open Settings**. You can also turn it on in the iOS Settings app under **Apps → Raycast → Keyboards → Allow Full Access**.

## Layout

The keyboard is made up of four rows:

| Row             | What it contains                                                                                                   |
| --------------- | ------------------------------------------------------------------------------------------------------------------ |
| Suggestion bar  | The leading button on the left, three word or emoji suggestions, and Dictation on the right. |
| Action Row      | Shortcuts to Raycast features. By default: **Quick Fix**, **GIFs**, **Search**, and **Ask AI**.                    |
| Letter keys     | Your chosen layout, QWERTY by default.                                                                             |
| Bottom row      | **123**, Emoji, Globe, space, and return. Email fields add an **@** key. |

In landscape, the Action Row is hidden and its actions move to the  **Keyboard Actions** menu at the left of the suggestion bar. Turn on **Always Show in Landscape** in [Action Row settings](#action-row) to keep the row visible.

To hide the suggestion bar, turn off **Show Top Bar** in [Top Row settings](#top-row). The bar also hides on its own when **Show Suggestions** and **Dictation Button** are off and **Leading Button** is set to **Hidden**.

### Leading Button

The leading button in the top left of the keyboard opens **Grid & Recents** by default. You can set it to open **Search** instead, or hide it, in [Custom Keys settings](#custom-keys).

![The Grid & Recents panel open on an iPhone, showing GIFs, AI Commands, Snippets, Quicklinks, and recent items](https://fz1sd71lwhbqy6sh.public.blob.vercel-storage.com/raycast/images/app/ios/keyboard/ios-primary-grid-and-recents.png)

#### Grid & Recents

**Grid & Recents** gives you quick access to **GIFs**, **AI Commands**, **Snippets**, and **Quicklinks**. Tap a feature to open it, or pick one of your recently used AI Commands, Snippets, or Quicklinks from **Recents**.

Tap **Dictate** to start dictation, with a style picker next to it to choose how your transcript is formatted.

Tap Keyboard button in the top left of the panel to go back to the typing keyboard. The search button next to it opens [Search](#search), and going back from Search returns you to Grid & Recents. The search button doesn't appear when **Leading Button** is set to **Search**.

#### Search

**Search** lets you find your Snippets, Quicklinks, and AI Commands, and the keyboard's own commands: **Ask AI**, **Quick Fix**, **Translate**, **Dictation**, **GIF**, **Emoji & Symbols**, **Text Styles**, **Snippets**, **Create Snippet**, **Quicklinks**, **AI Commands**, **Close Keyboard**, and **Settings**. Before you type, Search shows your recent items and the commands. You can also open Search from the Action Row.

Search also answers calculations and weather questions. Type a calculation or conversion, such as `20% of 80` or `10 usd in eur`, or a city's weather, such as `weather in London`, and the answer appears in a **Calculator** or **Weather** section above the results.

### Typing Keys

- **Shift:** Tap for one capital letter, double-tap for Caps Lock. While Caps Lock is on, autocorrect pauses.
- **123:** Tap to show numbers and symbols, or press and slide onto a symbol to type it and return to letters.
- **Delete:** Hold and slide left to delete whole words.
- **Space bar:** Touch and hold, then drag to move the cursor like a trackpad.
- **Currency:** The currency key on the number layout matches your region. Long-press it for other currency symbols.

In web address, web search, and email fields, the keyboard adds a period key next to return. Long-press it for up to six domain endings that match your region and typing languages, such as `.co.uk` in the UK or `.se` in Sweden, or hold and release to type `.com`. Number fields show a number pad.

## Typing Assistance

As you type, the suggestion bar shows word suggestions, corrections, and emoji. The keyboard also:

- Corrects misspelled words when you type a space or punctuation, using the words around them to pick the right correction.
- Keeps letters you repeat for emphasis, such as "soooo", instead of correcting them.
- Capitalizes the start of each sentence.
- Types a period and a space when you tap the space bar twice.
- Lets you slide across the letters to type a word.
- Uses your iOS Text Replacements. Text Replacements expand even where autocorrect is off.
- Suggests your contacts' names when **Contact Name Suggestions** is on in [Typing settings](#typing).

To undo an autocorrection, tap the original word in the suggestion bar. If you go back to a word that was corrected after you moved on, the keyboard offers to undo the correction.

The keyboard learns the words you use. To clear what it has learned, go to **Settings → Keyboard → Typing** and tap **Reset Keyboard Learning**. Your other keyboard settings stay the same.

Autocorrect is off in fields where it doesn't help, such as web addresses, email addresses, usernames, and search fields. Suggestions still appear there. Password, one-time code, phone number, card number, postal code, and date fields get no typing assistance.

## Languages

The keyboard comes with English as standard, and you can download Spanish (**Español**), French (**Français**), Italian (**Italiano**), Portuguese (**Português (Portugal)** and **Português (Brasil)**), Dutch (**Nederlands**), Danish (**Dansk**), German (**Deutsch**), and Swedish (**Svenska**). Turn on more than one language and switch between them as you type, in the same message, without changing keyboards. Autocorrect and suggestions follow the language you're writing in, even when you switch languages mid-sentence.

1. Go to **Settings → Keyboard → Language & Layout**.
2. Under **Available**, tap the download button next to a language.

When the download finishes, the language moves to **Installed**. To change the letter layout, pick one in **Keyboard Layout** in [Language & Layout settings](#language-and-layout).

In languages with accented letters, suggestions and corrections match words even when you leave out the accents.

Typing languages are separate from the **Dictation Languages** in [Features settings](#features).

## AI
**Pro Exclusive**

**Quick Fix**

Tap **Quick Fix** to fix the spelling and grammar of the text you're writing. If you selected text, Quick Fix corrects the selection. Otherwise, it corrects all the text in the field. The text is replaced in place. You can also cancel Quick Fix while it runs.

![Quick Fix correcting a message on an iPhone, with Fixing shown above the keyboard](https://fz1sd71lwhbqy6sh.public.blob.vercel-storage.com/raycast/images/app/ios/keyboard/ios-primary-quick-fix.png)

**Ask AI**

Tap **Ask AI**, type your instruction, then tap **Ask**. Ask AI uses the selected text, or all the text in the field, as context. If the field is empty, Ask AI answers your entered instruction on its own.

![Entering a question in Ask AI on the iPhone keyboard](https://fz1sd71lwhbqy6sh.public.blob.vercel-storage.com/raycast/images/app/ios/keyboard/ios-primary-ask-ai-question.png)

Tap the image button to attach up to four images with **Use Copied Image** or **Choose from Photo Library**. The photo picker opens in the Raycast app and returns you to the keyboard. With an image attached, Ask AI uses the image instead of the field text.

When the answer is ready, you can:

- **Insert** it at the cursor.
- **Replace** the original text with it.
- Copy it to the clipboard.
- Regenerate it.

Ask AI uses the **Ask AI Model** you pick in [Features settings](#features), and the model must support images. If you leave Ask AI before you tap **Ask**, the keyboard keeps your question and images for a day and restores them when you return to the same app.

**Translate**

Tap **Translate** to translate the selected text, or all the text in the field. Pick the languages with **From** and **To**. **From** is set to **Detect** by default, and the keyboard remembers your last choices. When the translation is ready, tap **Insert** to add it at the cursor or **Replace** to replace the original text. You can also copy it.

Translate isn't in the Action Row by default. Add it with **Customize Actions** in [Action Row settings](#action-row), or find it in Search.

**AI Commands**

![Change Tone to Professional showing a rewritten message on an iPhone, with Insert and Replace actions](https://fz1sd71lwhbqy6sh.public.blob.vercel-storage.com/raycast/images/app/ios/keyboard/ios-primary-ai-command.png)

Open **AI Commands**, then tap a command to run it on the selected text or all the text in the field. If the command has an argument, the keyboard asks for it first. When the result is ready, you can **Insert** it, **Replace** the original text, copy it, or regenerate it.

Your own commands use the model you chose for them. Built-in commands use your default AI Commands model. Commands with placeholders that iOS doesn't support show a **Not Supported Command** alert.

To run a command in one tap, add it to the Action Row or the Search menu from the **AI Commands** section in **Customize Actions**.

**Dictation**

To dictate into any text field, tap the Dictation button in the suggestion bar. You can also tap **Dictate** in the Grid & Recents panel or the Search results.

![Dictation recording on an iPhone, with Listening in the suggestion bar, the Messaging style selected, and a checkmark button to finish](https://fz1sd71lwhbqy6sh.public.blob.vercel-storage.com/raycast/images/app/ios/keyboard/ios-primary-dictation-active.png)

1. Start dictation.
2. Speak.
3. Tap the checkmark button to finish.

Raycast transcribes your speech and inserts it into the field. The keyboard records in your app, without switching to Raycast. The first time you grant microphone access, Raycast can open once.

To stop without inserting text, tap the cancel button.

Dictation needs [Full Access](#full-access). If recording in the keyboard isn't available, or you turn off **Record in Keyboard** in [Features settings](#features), dictation records in the Raycast app instead: the first dictation opens Raycast to start recording, then returns to your app. If Raycast can't return automatically, it shows **Swipe back to continue**. This is a limitation of iOS.

Dictations you record in the keyboard appear in **Dictation History** the next time the Raycast app becomes active.

While you record, tap **Style** to pick one of your styles to format the transcript or **None** (selected by default). To pick a dictation language, touch and hold the dictation button and slide to a language.

See [Dictation](https://manual.raycast.com/ai/dictation) for dictation models, styles, vocabulary, history, and settings.

## Text Styles & Change Case

Text Styles turns your text into Unicode letters that keep their look in any app, such as **Bold Serif**, **Script**, **Fraktur**, **Monospace**, and **Circled**. Change Case switches between cases such as **Uppercase**, **Sentence Case**, **Title Case**, **Snake Case**, and **Camel Case**. Title Case keeps short words like "and" and "of" lowercase, unless they start or end the text.

Tap a style or case to apply it to the selected text, or to all the text in the field if nothing is selected. Neither is in the Action Row by default. Add them with **Customize Actions** in [Action Row settings](#action-row). You can also find **Text Styles** in Search.

## Snippets & Quicklinks

**Snippets**

Type a Snippet's keyword in any app and the keyboard replaces it with the Snippet. Keywords don't expand in the middle of a word. To stop the keyboard expanding Snippets, turn off **Snippet Expansion** in [Features settings](#features). Expansion also follows the **Enable Snippet Expansion** and **Expansion Mode** settings in **Settings → Snippets**:

- **Immediately**: Expands as soon as you type the keyword.
- **After Delimiter**: Waits until you type a delimiter, such as a space or return.

If the Snippet has arguments, the keyboard asks for them first, and a `{cursor}` placeholder places the cursor in the expanded text. To type your keyword prefix faster, turn on **Show Custom Key** in [Custom Keys](#custom-keys). By default, tapping the key types your keyword prefix. When you type the prefix, the suggestion bar shows matching keywords.

You can also open **Snippets** from the leading button:
- Tap a Snippet to insert it.
- Long-press a Snippet to **Copy** it or **Edit** it in the Raycast app.
- Tap **Create Snippet** to save the selected text, or all the text in the field, as a new Snippet. Give it a name, a keyword, and a tag, then tap **Save Snippet**.

See [Snippets](https://manual.raycast.com/core-features/snippets) for more information about using Snippets across Raycast.

**Quicklinks**

Open **Quicklinks** from the leading button, then tap a Quicklink to insert its link. If the link has an `{argument}` placeholder, the keyboard asks for the value first. Long-press a Quicklink to **Copy** it, **Open** it, or **Edit** it in the Raycast app.

## Calculator, GIFs & Emoji

**Calculator**

Type a calculation or conversion, such as `12*4`, `20% of 80`, or `10 usd in eur`, and the result appears in the suggestion bar. Tap the result to replace the calculation with the answer in the selected field. You can also type calculations into Search. 

**GIFs**

Tap **GIFs** to search for a GIF, then tap a GIF to copy it and paste it into your message. Your recent GIFs appear first, and **Show Trending GIFs** switches to what's popular. You can choose between Giphy and Klipy in [Features settings](#features).

**Emoji**

Tap the emoji key to search emoji and symbols. Your recent emoji appear first. Local results show at once, and an AI search adds more matches a moment later. Tap the sparkle button next to the search field to run the AI search right away. Pick a larger grid with the **Size** setting in [Features settings](#features).

> [!TIP]
> Before searching for an emoji, tap **Suggest** to get emoji suggestions that match what you've already typed in an app.

Long-press the emoji key, or the **Emoji** action, to show a grid of up to eight emoji: your recent emoji, or a set you choose in [Features settings](#features). Hold and slide to pick one from one gesture.

## Settings

Open **Settings → Keyboard** in the Raycast app to customize the keyboard. A live preview at the top shows your changes. The settings are grouped in tabs: **Mode**, **Custom Keys**, **Typing**, **Language & Layout**, **Theme**, and **Features**.

### Mode

- **Mode**: Primary Mode (default) or [Secondary Mode](#secondary-mode).

### Custom Keys

The **Custom Keys** tab has three sections.

#### Top Row

- **Show Top Bar**: Shows the suggestion bar above the keys. On by default. When it's off, **Leading Button**, **Dictation Button**, **Customize Search Actions**, and **Show Suggestions** are unavailable.
- **Leading Button**: Grid & Recents (default), Hidden, or Search.
- **Dictation Button**: Shows the dictation button in the suggestion bar. On by default.
- **Customize Search Actions**: When the leading button is Search, choose the actions and AI Commands that appear when you hold it. Quick Fix, GIFs, Search, and Ask AI by default.

#### Action Row

- **Show Action Row**: On by default.
- **Always Show in Landscape**: Keeps the Action Row visible in landscape instead of moving its actions to a menu. Off by default.
- **Customize Actions**: Choose and reorder the actions: Quick Fix, Dictation, GIFs, Search, Emoji, Text Styles, Change Case, Snippets, Create Snippet, Quicklinks, AI Commands, Ask AI, Translate, Grid, and Close Keyboard. You can also add your own AI Commands. By default, Quick Fix, GIFs, Search, and Ask AI are shown.

#### Bottom Row

- **Show Custom Key**: Adds a key you can set up to the bottom row. When it's on, you can set:
  - **Tap Action**: Snippet Modifier by default. Pick one of the keyboard's actions, such as Close Keyboard, or one of your AI Commands. The key shows that action's icon.
  - **Long Press Action**: None by default. Pick one of the keyboard's actions or one of your AI Commands.
  - **Snippet Modifier**: The prefix the key types.
- **Show Emoji Key**: On by default.
- **Show Period Key**: Off by default. Long-press the period key for punctuation such as **&**, **%**, and **?**.
- **Drag to arrange**: Drag the keys to change their order around the space bar.

### Typing

- **Currency Symbol**: Automatic (default), which matches your region, or Dollar ($), Euro (€), Pound (£), Yen (¥), Won (₩), Ruble (₽), or Hryvnia (₴).
- **Show Numbers on Letter Keys**: Shows a digit on each top-row key. Long-press a key to type its digit. Off by default.
- **Dedicated Number Row**: Adds a row of numbers above the letter keys and turns off **Show Numbers on Letter Keys**. iPhone only. Off by default.
- **Key Haptic Feedback**: Off, Soft, Medium, or Hard. Soft by default if keyboard haptics are on in iOS Settings, otherwise Off.
- **Character Preview**: None, Detached (default), or Attached.
- **Key Sound**: On by default.
- **Show Suggestions**: On by default.
- **Contact Name Suggestions**: Suggests your contacts' names as you type. Off by default. Turning it on asks for access to your contacts. Uses up to 5,000 contacts.
- **Auto-Correction**: On by default.
- **Auto-Capitalization**: On by default.
- **Slide to Type**: On by default.
- **Reset Keyboard Learning**: Clears the words, word pairs, and capitalization the keyboard has learned from your typing.

### Language & Layout

- **Keyboard Layout**: QWERTY (default), QWERTZ, AZERTY, Dvorak, Colemak, Colemak-DH, Workman, Swedish, German, Spanish, or Danish.
- **Installed**: English and the languages you've downloaded, each with a switch to turn it on or off.
- **Available**: Languages you can download: Español, Français, Português (Portugal), Português (Brasil), Italiano, Nederlands, Dansk, Deutsch, and Svenska.

### Theme

- **Theme**: Default, Clear, Physical, Mechanical, or iOS 5. Physical and Mechanical also offer Automatic (default), Dark, or Light keys.

### Features

**Emoji**

- **Preferred Skin Tone**: Default, Light, Medium Light, Medium, Medium Dark, or Dark.
- **Size**: Standard (default) with three rows, or Large with two rows, in emoji search.
- **Long-Press Emoji Grid**: Recents (default), or Custom with up to eight emoji you choose.

**GIF**

- **Provider**: Giphy (default) or Klipy.

**Snippets**

- **Snippet Expansion**: Expands Snippet keywords as you type. On by default.

**Dictation**

- **Record in Keyboard**: Records dictation in the keyboard without switching apps. When recording can't start in the keyboard, Raycast opens to record instead. On by default.
- **Show iOS Dictation Button**: Shows Apple's dictation button below the keyboard when iOS dictation is on. Off by default.
- **Insert mode**: Auto-insert (default), Review first, or Review on AI command.
- **Dictation Languages**: The languages you can pick when you dictate. Auto and English by default.
- **Disable session**: When dictation records in the Raycast app, a session lets you dictate again without opening the app each time. Ends the session Immediately, or after 5 minutes (default), 10, 15, or 30 minutes, or 1 hour. With Immediately, every dictation that records in the Raycast app opens the app.

**AI**

- **Ask AI Model**: The model Ask AI uses in the keyboard. Your default chat model unless you change it.

## iPad

On iPad, the keyboard uses a full-size layout with a key to hide the keyboard. The 12.9-inch and 13-inch iPads add a number row, Tab, and Caps Lock. On other iPads, turn on **Show Numbers on Letter Keys** in [Typing settings](#typing) to show a digit on each top-row key, then pull down on a key to type its digit. The floating keyboard uses the iPhone layout.

## Privacy

Full Access lets the keyboard connect to the internet for AI, Dictation, and GIFs, and read your Snippets, Quicklinks, and AI Commands from the Raycast app. Raycast doesn't store or share sensitive information.

- What the keyboard learns from your typing stays on your device. **Reset Keyboard Learning** deletes it.
- **Contact Name Suggestions**: Uses only your contacts' names, not their phone numbers or email addresses. The names are kept in a local copy on your device.
- Keyboard usage analytics record which features you use, how often, and your keyboard settings. They never include what you type, your corrections or suggestions, your Snippets, dictation, or searches, or the app you're typing in.
- Nothing from password, one-time code, or card number fields is collected.

## Secondary Mode

If you'd rather keep your usual keyboard for typing, go to **Settings → Keyboard → Mode** and pick **Secondary**. Use Secondary Mode to type in a language the Raycast Keyboard doesn't support.

![The Raycast Keyboard in Secondary Mode on an iPhone, showing the Dictate bar, Search, the feature grid, and recent items with no letter keys](https://fz1sd71lwhbqy6sh.public.blob.vercel-storage.com/raycast/images/app/ios/keyboard/ios-secondary-mode.png)

In Secondary Mode, the keyboard has no letter keys. It opens on the Grid & Recents panel, with Dictate, Search, GIFs, Commands, Snippets, Quicklinks, and your recent items. Tap the Globe key key to switch between Raycast and your usual keyboard.

Secondary Mode doesn't use themes, the Action Row, the Custom Keys settings, or Language & Layout. Its **Typing** tab has **Key Sound**, **Auto-Correction**, and **Switch Keyboard on Close**, which switches to your next keyboard when you close a Raycast feature.


---

## Need Help?

Contact Raycast Support if you have any questions or would like help with Keyboard. Use the **Send Feedback** command directly in Raycast to report bugs and billing issues, log feature requests, or any other queries you would like to speak to us about.

You can view all Raycast Support contact options at https://manual.raycast.com/contact-support
