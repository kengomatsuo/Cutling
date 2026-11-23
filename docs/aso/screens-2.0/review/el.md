# Greek (el): words for the 2.0 store frames, direction C (card ASG167)

Written from `C-words-brief.md` and the `el` entry of `locale-facts.json`, with no source sentence. The words file is
`fastlane/compose/creative/v2/words/el.json`.

**Register:** the informal singular (εσύ) in every line, including the shop owner's reply to the customer. The live
Greek listing (description, promotional text, 2.0 What's New) and the app's newer Greek strings («Δοκίμασέ το»,
«Γράψε εδώ με το Cutling») already speak this way, and six of the seven leading Greek listings checked on the Greek App
Store on 2026-11-23 do too (efood, Skroutz, Wolt, BOX, viva.com, viva.com Terminal; only e-shop.gr uses the plural).

**Facts used as given:** «Τρίτη», «23 Νοεμβρίου 2026», «5.000», «100».

## Demo data (`cseed`)

| Key | Greek | Literal back-translation | Choice |
|---|---|---|---|
| names | Μαρία, Νίκο, Ελένη | Maria, Niko, Eleni | Three of the most common Greek first names, two women and one man. The man's name is in the vocative (Νίκο, not Νίκος): the reply addresses the customer, so that is the form a Greek shop owner types into the blank and the keyboard offers again. |
| mac_name | Σοφία | Sofia | A woman's name, whose vocative is the same as its nominative, so it reads right both in the Mac form's Name field and in the sentence. |
| reply | {name}, το δέμα σου φεύγει την {date}! | {name}, your parcel leaves on {date}! | First name with the informal "σου", as small Greek shops write to customers. "Φεύγει" (leaves) is the everyday word for a parcel going out. "Την" before the weekday makes "on Tuesday" without touching «Τρίτη». 36 characters filled. |
| reply_name | Αποστολή | Dispatch | The word a Greek shop uses for sending an order out. |
| mac_reply | {name}, το {plan} πακέτο σου φεύγει την {date}! | {name}, your {plan} package leaves on {date}! | "Πακέτο" means both the parcel and the plan you buy, so the sentence works on either reading. The plan name goes before the noun, which reads right with both choices ("το Βασικό πακέτο", "το Premium πακέτο"). 46 characters filled. |
| name_label | Όνομα | Name | The plain field label. |
| plan_label | Πακέτο | Package (plan) | What Greek shops, phone companies and gyms call a tier you buy. |
| plan_choices | Βασικό, Premium | Basic, Premium | The pair the Greek 2.0 What's New already uses («Βασικό» ή «Premium»). |
| delivered | Το δέμα παραδόθηκε στις {date}. | The parcel was delivered on {date}. | "Στις" with a full date is the standard Greek construction. 25 characters without the date, which is why it has no "σου". |
| delivered_name | Παράδοση | Delivery | The note's name in the app. |

## Frame words (`C`)

| Key | Greek | Literal back-translation | Choice |
|---|---|---|---|
| iphone 1 k | Το γράφεις μία φορά. | You write it once. | Neuter "το" points at the text below without committing to a gender. 20 characters. |
| iphone 1 s | Πατάς την έτοιμη απάντηση και το Cutling σε ρωτά το όνομα. | You tap the ready reply and Cutling asks you the name. | "Έτοιμη απάντηση" is the Greek for a canned reply; "σε ρωτά το όνομα" is the What's New's own phrase. 58 characters. |
| iphone 2 k | Το ίδιο, στον επόμενο πελάτη. | The same, to the next customer. | Opens with "Το" like frame 1, so the pair reads as one thought: written once, the same one again. |
| iphone 2 s | Όσα ονόματα έχεις ήδη γράψει, τα διαλέγεις με ένα πάτημα. | Whatever names you have already written, you pick them with one tap. | Topic first and picked up again by "τα", the way it is said aloud. "Πάτημα" is the app's word for a tap. |
| iphone 3 k | Η ημερομηνία μπαίνει μόνη της. | The date goes in by itself. | The date is the subject, so the subline's "σωστή" agrees with it. |
| iphone 3 s | Σήμερα, αύριο ή σε μία εβδομάδα, βγαίνει σωστή τη μέρα που επικολλάς. | Today, tomorrow or in one week, it comes out right on the day you paste. | "Βγαίνει σωστή" (comes out right) is how the What's New puts it. |
| iphone 4 k | Και όσα δεν αλλάζουν ποτέ: | And the things that never change: | Leads into the list as one sentence, so the headline starts in lowercase after the colon. |
| iphone 4 h | [το IBAN σου], [η διεύθυνσή σου], [η υπογραφή σου]. | your IBAN, your address, your signature. | Greeks hand out a bank account as "το IBAN", and "υπογραφή" is the email sign-off; the Greek grid capture shows «Υπογραφή email» and «IBAN: GR16…». Each chip is under 16 characters, so the build keeps it on one line: one chip per line on iPhone and iPad. 45 characters. |
| iphone 4 s | Ένα πάτημα στο πληκτρολόγιο Cutling, σε κάθε εφαρμογή. | One tap on the Cutling keyboard, in every app. | "Πληκτρολόγιο Cutling" is how the app names its keyboard. 54 characters. |
| iphone 5 k | Χωράνε όλα. | Everything fits. | The What's New says "Χωράνε 5.000 cutling". |
| iphone 5 h | [5.000] cutling | 5,000 cutlings | The product word does not change in the plural, as in the app's «8 Cutling» and «Αναζήτηση cutling». |
| iphone 5 s | Πριν ήταν 100, και το καθένα χωράει ολόκληρο email. | Before it was 100, and each one fits a whole email. | Left out "πλέον" (now): right after a number, "100 και πλέον" reads as "100 and more". |
| iphone 6 k | iPhone, iPad και Mac. | iPhone, iPad and Mac. | No comma before "και", as Greek writes a list. |
| iphone 6 h | Πληρώνεις [μία φορά] | You pay [once] | "Μία φορά" is how a person says once; "εφάπαξ" is the billing word and colder. No final period, to stay within 18 characters. |
| iphone 6 s | Μία αγορά και για τα τρία, χωρίς λογαριασμό ή συνδρομή. | One purchase for all three, without account or subscription. | "Τα τρία" is neuter because iPhone, iPad and Mac are neuter nouns in Greek. A no-break space keeps "ή" from ending a line. |
| mac 1 k | Γράφεις μία φορά, στέλνεις σε όλους. | You write once, you send to everyone. | No objects, as a Greek slogan drops them; it fits one line at the Mac kicker size. |
| mac 1 s | Διαλέγεις την απάντηση με {cmd}, συμπληρώνεις τα κενά σε μια μικρή φόρμα και επικολλάται. | You pick the reply with ⌘⇧V, you fill in the blanks in a small form, and it is pasted. | "Συμπληρώνεις τα κενά" is the school-exercise phrase for fill in the blanks, and «Κενά» is the app's word for blanks. |
| mac 2 k | Όπου κι αν γράφεις. | Wherever you are writing. | «Όπου κι αν» is the everyday "wherever, no matter where"; "γράφεις" (you write) is what a Greek says for typing too. |
| mac 2 h | {cmd} | ⌘⇧V | As the brief gives it. |
| mac 2 s | Τα cutling σου και όσα αντέγραψες πρόσφατα ανοίγουν πάνω από κάθε εφαρμογή. | Your cutlings and what you copied recently open over every app. | "Πρόσφατα" matches the Mac app's «Πρόσφατο πρόχειρο». |
| mac 3 k | Το ιστορικό προχείρου δεν κρατά | The clipboard history does not keep | No final punctuation: the row of password dots under it is the object, "does not keep ••••••••••". «Ιστορικό προχείρου» is the app's term. |
| mac 3 s | Ό,τι ο διαχειριστής κωδικών σημειώνει ως κρυφό δεν μπαίνει ποτέ στο ιστορικό. | Whatever the password manager marks as hidden never gets into the history. | The app's own setting and Greek description use "διαχειριστής κωδικών" and "σημειώνει ως κρυφό". |
| mac 4 k | Αλλάζεις κάτι στο Mac; | You change something on the Mac? | ";" is the Greek question mark. |
| mac 4 h | Αλλάζει και στο [iPhone]. | It changes on the iPhone too. | Repeats the verb from the question, so the answer lands at once. |
| mac 4 s | Συγχρονίζεται με το δικό σου iCloud, χωρίς να ανοίξεις λογαριασμό. | It syncs with your own iCloud, without you opening an account. | "Να ανοίξεις λογαριασμό" (open an account), because iCloud is itself an account and a bare "χωρίς λογαριασμό" would contradict it. |
| mac 5 k | iPhone, iPad και Mac. | iPhone, iPad and Mac. | Same as iphone 6. |
| mac 5 h | Πληρώνεις [μία φορά] | You pay [once] | Same as iphone 6. |
| mac 5 s | Μία αγορά και για τα τρία, χωρίς λογαριασμό ή συνδρομή. | One purchase for all three, without account or subscription. | Same as iphone 6, no-break space included. |

## Headlines the build makes from the seed

| Frame | Headline |
|---|---|
| iphone 1 | [Μαρία], το δέμα σου φεύγει την [Τρίτη]! |
| iphone 2 | [Νίκο], το δέμα σου φεύγει την [Τρίτη]! |
| iphone 3 | Το δέμα παραδόθηκε στις [23 Νοεμβρίου 2026]. |
| mac 1 | [Σοφία], το [Premium] πακέτο σου φεύγει την [Τρίτη]! |
| keyboard bar, iphone 1 and 2 | Όνομα (blank), το δέμα σου φεύγει την Τρίτη! |

## Not in these words, seen on the rendered frames

The fill-in key on iPhone and iPad frames 1 and 2 reads «Γράψτε στο πληκτρολόγιό σας», the polite plural
(`CutlingKeyboard/el.lproj/Localizable.strings` line 28, carried into `locale-facts.json` as
`keyboard_type_with_your_keyboard`). Every word above it is informal, and so is the app's own «Δοκίμασέ το»; the
informal form of that key would be «Γράψε στο πληκτρολόγιό σου».
