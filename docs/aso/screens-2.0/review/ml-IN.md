# Cutling 2.0 store frames: ml-IN (Malayalam, India)

Written from `C-words-brief.md` alone, with the ml-IN entry of `locale-facts.json`; no other language's words were read. Words file: `fastlane/compose/creative/v2/words/ml-IN.json`.

**Register.** The polite, friendly level the current Malayalam listing already uses: "നിങ്ങൾ" where the buyer is addressed, the "-ഊ" invitation for the two Mac instructions, and plain future ("-ഉം") or promise ("-ആം") forms everywhere else. The app is "Cutling" in Latin, as the store title and the 2.0 release notes write it, so "കട്ട്‌ലിംഗ്" and "കട്ട്‌ലിംഗുകൾ" always mean the saved items.

**Typography.** Every hyphen that joins a Malayalam suffix to a date or a Latin name ("23‑ന്", "Mac‑ൽ", "iPhone‑ലും") is U+2011, the non-breaking hyphen. New York and SF draw it with the same glyph as "-", and it keeps a date chip and its suffix on one line; the first render of iPhone frame 3 broke the line between them. Retyping these strings with a plain hyphen brings that break back.

**Checked.** `check_words.py ml-IN` is clean; every length in the brief is met counted in raw code points (the strictest count for Malayalam); all 17 frames (6 iPhone, 6 iPad, 5 Mac) were rendered with `build.py ml-IN C` and looked at, with nothing clipped.

## Demo data (`cseed`)

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| `cseed.names[0]` | അനു | Anu | A very common Kerala woman's name, two letters on screen, so frame 1 opens on a short chip. |
| `cseed.names[1]` | അമൽ | Amal | A common man's name in Hindu, Muslim and Christian families alike, so the pair reads as two different customers. |
| `cseed.names[2]` | ഫാത്തിമ | Fathima | A common woman's name; with Jose the four names span Kerala's communities and both genders. |
| `cseed.mac_name` | ജോസ് | Jose | A common Kerala man's name. |
| `cseed.reply` | {name}, ഓർഡർ {date} തന്നെ അയയ്ക്കാം. | {name}, (I) will send the order on {date} itself. | Malayalam uses the bare weekday as "on Tuesday", so the app's word sits unchanged; "അയയ്ക്കാം" is the first-person promise ("I'll send it") and "തന്നെ" ("right on") gives the warmth. 37 code points filled. |
| `cseed.reply_name` | ഓർഡർ അപ്ഡേറ്റ് | Order update | The loanwords a Kerala online seller uses for this message; "അപ്ഡേറ്റ്" spelled as the app spells it. |
| `cseed.mac_reply` | {name}, {plan} പാക്ക് {date} തന്നെ അയയ്ക്കാം. | {name}, (I) will send the {plan} pack on {date} itself. | The same promise as the iPhone reply; a pack is both a tier you buy and a thing you ship, so it stays a shipping reply. 49 code points filled. |
| `cseed.name_label` | പേര് | Name | The app's own word for Name. |
| `cseed.plan_label` | പാക്ക് | Pack | Indian buyers buy tiers as packs (recharge packs, combo packs); picked over the app's "പ്ലാൻ" (plan) because "I'll send the Premium plan" is not a sentence a seller writes. |
| `cseed.plan_choices` | ബേസിക്, പ്രീമിയം | Basic, Premium | The loanword pair Indian shops use, and the pair the 2.0 Malayalam release notes name. |
| `cseed.delivered` | ഓർഡർ {date}‑ന് ഡെലിവർ ചെയ്തു. | The order was delivered on {date}. | "On a date" is the dative "-ന്" on the numeral, hyphenated as All India Radio's Malayalam bulletins write "29-ന്"; "ഡെലിവർ ചെയ്തു" is what sellers write. 23 code points without the date. |
| `cseed.delivered_name` | ഡെലിവറി | Delivery | The everyday loanword. |

## Headlines the build makes from the demo data

| Frame | As built (chips in brackets) | Literal back-translation | Grammar |
|---|---|---|---|
| iphone 1 | [അനു], ഓർഡർ [ചൊവ്വാഴ്‌ച] തന്നെ അയയ്ക്കാം. | Anu, (I) will send the order on Tuesday itself. | The weekday stays the app's exact word, used bare as the time word. |
| iphone 2 | [അമൽ], ഓർഡർ [ചൊവ്വാഴ്‌ച] തന്നെ അയയ്ക്കാം. | Amal, (I) will send the order on Tuesday itself. | A name in direct address takes no ending in written Malayalam, so any name fits. |
| iphone 3 | ഓർഡർ [2026 നവംബർ 23]‑ന് ഡെലിവർ ചെയ്തു. | The order was delivered on 2026 November 23. | The suffix sits outside the chip, joined by a non-breaking hyphen. |
| mac 1 | [ജോസ്], [പ്രീമിയം] പാക്ക് [ചൊവ്വാഴ്‌ച] തന്നെ അയയ്ക്കാം. | Jose, (I) will send the Premium pack on Tuesday itself. | The plan name stands before "പാക്ക്" as a modifier, with no ending. |
| keyboard bar | പേര്, ഓർഡർ ചൊവ്വാഴ്‌ച തന്നെ അയയ്ക്കാം. | Name, (I) will send the order on Tuesday itself. | What the drawn keyboard shows above the name keys; fits on its one line. |

## Frame words (`C`)

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| `C.iphone.1.k` | ഒരിക്കൽ എഴുതിയാൽ മതി | (It is) enough if (you) write (it) once | "-ആൽ മതി" is the everyday Malayalam way to say "you only have to"; 20 code points. |
| `C.iphone.1.s` | സൂക്ഷിച്ച മറുപടി ടാപ്പ് ചെയ്താൽ Cutling പേര് ചോദിക്കും. | If (you) tap the kept reply, Cutling will ask the name. | "സൂക്ഷിച്ച" (kept) instead of "സേവ് ചെയ്ത" so two "ചെയ്" verbs do not follow each other; 55 code points. |
| `C.iphone.2.k` | അതേ മറുപടി അടുത്ത കസ്റ്റമർക്കും | The same reply to the next customer too | "-ഉം" (too) ties it to frame 1; "കസ്റ്റമർ" is the shop owner's word, where "ഉപഭോക്താവ്" would read as officialese. |
| `C.iphone.2.s` | മുമ്പ് ഉപയോഗിച്ച പേരുകൾ കീബോർഡിൽ തയ്യാർ, ഒറ്റ ടാപ്പിൽ ചേർക്കാം. | The names used before (are) ready on the keyboard; (you) can add (one) in a single tap. | "തയ്യാർ" (ready) carries "waiting", and the app uses the same word. |
| `C.iphone.3.k` | തീയതി Cutling തനിയെ ചേർക്കും | The date, Cutling will add by itself | The date comes first as the frame's topic; "തനിയെ" (on its own) over the bookish "സ്വയം". |
| `C.iphone.3.s` | ഇന്നോ നാളെയോ ഒരാഴ്ച കഴിഞ്ഞോ, എന്ന് പേസ്റ്റ് ചെയ്താലും തീയതി കൃത്യം. | Today or tomorrow or a week later; whichever day (you) paste, the date (is) exact. | The "-ഓ … -ഓ" chain is Malayalam's own "or"; "എന്ന് … -ആലും" is "whenever". |
| `C.iphone.4.k` | നിങ്ങളുടെ മാറാത്ത വിവരങ്ങളും | Your details that don't change, too | One "നിങ്ങളുടെ" covers the whole list, since Malayalam does not repeat a possessive on each item; "-ഉം" is the "and". 28 code points. |
| `C.iphone.4.h` | [ബാങ്ക് അക്കൗണ്ട്], [വിലാസം], [ഇമെയിൽ ഒപ്പ്] | [Bank account], [address], [email signature] | All three chips are the app's own strings (Bank Account, Address, Email Signature), and the keyboard under this line shows the bank and signature tiles by those names. 44 of 50. |
| `C.iphone.4.s` | ഏത് ആപ്പിലും Cutling കീബോർഡിൽ, ഓരോന്നിനും ഒരൊറ്റ ടാപ്പ്. | In any app, on the Cutling keyboard, one single tap for each. | "ഒരൊറ്റ" is the emphatic native "just one"; 56 code points. |
| `C.iphone.5.k` | എല്ലാത്തിനും ഇടമുണ്ട് | There is room for everything | A plain idiom. |
| `C.iphone.5.h` | [5,000] കട്ട്‌ലിംഗുകൾ | [5,000] cutlings | Number and plural product word exactly as the facts give them. |
| `C.iphone.5.s` | മുമ്പ് 100 ആയിരുന്നു, ഓരോന്നിലും ഒരു മുഴുവൻ ഇമെയിലും കൊള്ളും. | Before (it) was 100; in each one, even a whole email will fit. | "കൊള്ളും" (fits) is the everyday verb; "-ഉം" on ഇമെയിൽ means "even". |
| `C.iphone.6.k` | iPhone‑ലും iPad‑ലും Mac‑ലും | On iPhone, on iPad and on Mac | Malayalam joins a list with "-ഉം" on each item; Apple's names stay in Latin script, suffixed as the app writes "Mac-ൽ". |
| `C.iphone.6.h` | പണം [ഒരിക്കൽ] മാത്രം | Money [once] only | The headline ellipsis for "you pay only once", chip on "ഒരിക്കൽ" (once); 18 code points. |
| `C.iphone.6.s` | ഒറ്റ വാങ്ങലിൽ മൂന്നും ഉൾപ്പെടും, അക്കൗണ്ടോ സബ്‌സ്ക്രിപ്ഷനോ ഇല്ല. | In one purchase all three are included; no account or subscription. | Echoes the store description's "ഒറ്റ വാങ്ങലിൽ … ഉൾപ്പെടും"; "സബ്‌സ്ക്രിപ്ഷൻ" is the word Indian App Store buyers see, over the newspaper-era "വരിസംഖ്യ". |
| `C.mac.1.k` | ഒരിക്കൽ എഴുതൂ, എല്ലാവർക്കും അയയ്ക്കൂ | Write once, send to everyone | The polite "-ഊ" invitation the current Malayalam listing already uses. |
| `C.mac.1.s` | {cmd} അമർത്തി മറുപടി തിരഞ്ഞെടുക്കൂ, പേസ്റ്റ് ചെയ്യും മുമ്പ് ഒഴിവുകൾ ചെറിയൊരു ഫോമിൽ പൂരിപ്പിക്കാം. | Press ⌘⇧V and choose the reply; before pasting, (you) can fill in the blanks in a small form. | "ഒഴിവുകൾ പൂരിപ്പിക്കുക" is the school exam's "fill in the blanks" and "ഒഴിവുകൾ" is the app's word; "ചെറിയൊരു" avoids the calque "ഒരു ചെറിയ". Three lines on the Mac, inside its room. |
| `C.mac.2.k` | എവിടെ ടൈപ്പ് ചെയ്യുമ്പോഴും | Wherever (you) are typing | "എവിടെ … -ഉം" is "wherever". |
| `C.mac.2.h` | {cmd} | (the ⌘⇧V keys) | Fixed by the brief. |
| `C.mac.2.s` | കട്ട്‌ലിംഗുകളും അവസാനം പകർത്തിയവയും ഏത് ആപ്പിന്റെയും മുകളിൽ തുറക്കും. | The cutlings and the last-copied ones open on top of any app. | "Your" is left out, as Malayalam does when it is plain; the chillu ൾ turns back into ള before "-ഉം". |
| `C.mac.3.k` | Mac‑ലെ ക്ലിപ്പ്ബോർഡ് ചരിത്രം ഒഴിവാക്കുന്നത് | What the clipboard history on the Mac leaves out | A noun clause ("that which it leaves out"), so the password dots under it are the thing left out; "ക്ലിപ്പ്ബോർഡ് ചരിത്രം" is the app's name for the feature. |
| `C.mac.3.s` | പാസ്‌വേഡ് മാനേജർ മറച്ചതായി അടയാളപ്പെടുത്തിയതൊന്നും ചരിത്രത്തിൽ എത്തില്ല. | Nothing the password manager marked as hidden reaches the history. | The same words as the app's own setting ("മറച്ചതായി അടയാളപ്പെടുത്തിയവ ഒഴിവാക്കും"). |
| `C.mac.4.k` | Mac‑ൽ എന്തെങ്കിലും മാറ്റിയാൽ | If (you) change something on the Mac | The conditional "-ആൽ" carries into the headline as one sentence. |
| `C.mac.4.h` | [iPhone]‑ലും മാറും | (It) changes on the [iPhone] too | Chip on "iPhone"; the suffix "-ലും" stays outside it, joined by the non-breaking hyphen. |
| `C.mac.4.s` | സ്വന്തം iCloud വഴി സിങ്ക് ആകും, അക്കൗണ്ട് ഉണ്ടാക്കേണ്ട. | (It) syncs through (your) own iCloud; no need to make an account. | "സിങ്ക്" as the store description writes it, over the app's formal "സമന്വയം"; "സ്വന്തം" (own) already says "yours". |
| `C.mac.5.k` | iPhone‑ലും iPad‑ലും Mac‑ലും | On iPhone, on iPad and on Mac | The same string as `C.iphone.6.k`, as the brief allows. |
| `C.mac.5.h` | പണം [ഒരിക്കൽ] മാത്രം | Money [once] only | The same string as `C.iphone.6.h`, as the brief allows. |
| `C.mac.5.s` | ഒറ്റ വാങ്ങലിൽ മൂന്നും ഉൾപ്പെടും, അക്കൗണ്ടോ സബ്‌സ്ക്രിപ്ഷനോ ഇല്ല. | In one purchase all three are included; no account or subscription. | The same string as `C.iphone.6.s`, as the brief allows. |
