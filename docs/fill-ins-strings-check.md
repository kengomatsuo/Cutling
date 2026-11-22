# Fill-in strings: back-check (board ASG91)

The keyboard's fill-in screen strings in `CutlingKeyboard/<locale>.lproj/Localizable.strings`, written from [fill-ins-strings-brief.md](fill-ins-strings-brief.md) (K3, K4, K5) and checked back on 2026-11-21.

| Brief key | `.strings` key | Where |
|---|---|---|
| K3 `own-keyboard` | `"Type with Your Keyboard"` | wide key's label |
| K4 `insert` | `"Insert"` | VoiceOver label of the return key on the last blank |
| K5 `announce` | `"%@, %lld of %lld"` | VoiceOver announcement when a blank comes up (label, number, total) |

How each line was made: one writer per batch of up to four languages got the brief, the language and that locale's existing app words, never an English string, and returned the string with its own back-translation. A separate reader per batch of about seven languages, told only each string's role and not what it should say, wrote what a native reader understands from it and whether it is natural. A line flagged by its reader went back to a fresh writer with the brief made clearer (round 2, and round 3 for Punjabi), and the new line was read again. "Read back as" below is that independent reading of the string as shipped. Width is the wide-key label at 16 pt semibold, measured with the system font on macOS; on a 375-pt iPhone the label has about 331 pt beside its icon.

Removed from every locale, since nothing in the keyboard uses them any more: `"Type it with your keyboard"`, `"%lld of %lld"`, `"Done"`. Locales that share a language share one line (listed together in the first column); es and es-MX, fr and fr-CA came out the same, pt and pt-PT differ.

| Locale | Wide key | Read back as | Return key (VoiceOver) | Read back as | Announcement | Read back as | Width pt | Check | Note |
|---|---|---|---|---|---|---|---|---|---|
| en, en-AU, en-CA, en-GB, en-IN | `Type with Your Keyboard` |  | `Insert` |  | `%@, %lld of %lld` |  | 188 | given | Given in the card; not back-checked. |
| de, de-DE | `Mit normaler Tastatur tippen` | Type with the normal keyboard. | `Text einfügen` | Insert text. 'Einfügen' is also German's standard word for Paste, so it may be heard as 'Paste text'. | `%@, %lld von %lld` | {label}, item {n} of {total}. | 215 | ok | Round 2 return key: German's word for insert is the app's Paste word, so "Text" tells the two keys apart (round 1 wrote "Übernehmen", read back as Apply). |
| nl, nl-NL | `Typ met je gewone toetsenbord` | Use your normal keyboard to type. | `Invoegen` | Insert (put the text in). | `%@, %lld van %lld` | Field called {label}, number {n} out of {total}. | 239 | ok |  |
| da | `Skriv på dit normale tastatur` | Type on your normal keyboard. | `Indsæt tekst` | Insert text. 'Indsæt' is also Danish's standard word for Paste, so it may be heard as 'Paste text'. | `%@, %lld af %lld` | {label}, item {n} of {total}. | 215 | ok | Round 2 return key, same reason as German (round 1 wrote "Anvend", read back as Apply). |
| sv | `Skriv med vanligt tangentbord` | Type with the regular keyboard | `Infoga` | Insert | `%@, %lld av %lld` | {label}, n of total | 228 | ok |  |
| nb | `Skriv på vanlig tastatur` | Type on the regular keyboard. | `Sett inn` | Insert. | `%@, %lld av %lld` | Item {n} of {total}, named {label}. | 174 | ok |  |
| fi | `Kirjoita omalla näppäimistöllä` | Type with your own keyboard. 'Oma' means 'own', not 'regular' or 'usual'. It can also read as 'a keyboard of your own', which suggests a personal or hardware keyboard. | `Lisää teksti` | Add the text. This is not 'more text', which would need the partitive form 'tekstiä'. | `%@, kenttä %lld, yhteensä %lld` | Field called {label}, field number {n}, {total} in total. | 221 | ok |  |
| et | `Kirjuta tavalise klaviatuuriga` | Type with the regular keyboard. | `Sisesta` | Enter, as in submitting input. It can also be read as Insert. | `%@, %lld %lld-st` | {label}, {n} out of {total}, spoken as e.g. 'kolm viiest'. | 213 | ok | Spoken form depends on the speech engine expanding "5-st" as viiest. |
| lt | `Rašyti įprasta klaviatūra` | Type with the usual keyboard | `Įterpti` | Insert | `%@, %lld iš %lld` | {label}, item {n} of {total} | 181 | ok |  |
| lv | `Rakstīt ar savu tastatūru` | Type with your own keyboard. | `Ievietot` | Insert. | `%@, %lld no %lld` | Item {n} of {total}, named {label}. | 185 | see note | Checker calls "savu" (own) vague; it is what the brief asks for. |
| pl | `Wpisz na swojej klawiaturze` | Type it in on your own keyboard. The perfective 'wpisz' suggests entering one specific thing, while 'pisz' would mean ongoing typing. | `Wstaw` | Insert. | `%@, %lld z %lld` | Field called {label}, number {n} out of {total}. | 210 | ok |  |
| cs | `Psát na běžné klávesnici` | Type on the regular keyboard. | `Vložit text` | Insert text. 'Vložit' is also Czech's standard word for Paste, so a listener may hear it as 'Paste text'. | `%@, %lld z %lld` | {label}, item {n} of {total}. | 184 | ok | Round 2 wide key (imperfective; round 1's "Napsat" wanted an object) and return key (round 1 wrote "Dokončit", read back as Finish). |
| sk | `Písať na bežnej klávesnici` | Type on the regular keyboard. | `Vložiť` | Insert. 'Vložiť' is also Slovak's standard word for Paste, so it may be heard as 'Paste'. | `%@, %lld z %lld` | {label}, item {n} of {total}. | 192 | ok | Round 2 wide key (imperfective). Checkers note Vložiť is iOS's Paste word in Slovak; the app's own Paste is Prilepiť. |
| sl, sl-SI | `Tipkaj na običajni tipkovnici` | Type using the normal (standard) keyboard. | `Vstavi` | Insert (put the text in). It does not mean Paste, which is 'Prilepi'. | `%@, %lld od %lld` | {label}, item {n} of {total}. | 207 | ok | Round 2 wide key (round 1's "Vpiši" wanted an object). |
| hr | `Upiši na običnoj tipkovnici` | Type using your regular keyboard. | `Umetni` | Insert. | `%@, %lld od %lld` | Field called {label}, number {n} out of {total}. | 196 | ok |  |
| sr | `Куцај на обичној тастатури` | Type on the regular keyboard. 'Kucati' is the everyday Serbian verb for typing. | `Уметни` | Insert. It does not mean Paste, which is 'Налепи'. | `%@, %lld од %lld` | {label}, item {n} of {total}. | 215 | ok | Round 2 wide key, "Куцај" (round 1's "Упиши" wanted an object). All Cyrillic. |
| bg | `Пиши с обичайната клавиатура` | Type with your usual keyboard. | `Вмъкни` | Insert. It does not mean Paste, which is 'Постави'. | `%@, %lld от %lld` | {label}, item {n} of {total}. | 250 | ok | Round 2 wide key (round 1's "Въведи" wanted an object). |
| ru | `Ввести с обычной клавиатуры` | Enter text using the regular keyboard. | `Вставить текст` | Insert text. 'Вставить' is also Russian's standard word for Paste, so it may be heard as 'Paste text'. | `%@, %lld из %lld` | {label}, item {n} of {total}. | 241 | ok | Round 2 wide key and return key (round 1's "Ввести текст" read back as start typing or submit). |
| uk | `Набрати на своїй клавіатурі` | Type on your own keyboard. The infinitive is the normal form for a Ukrainian button. | `Ввести текст` | Enter the text. | `%@, %lld з %lld` | Field called {label}, number {n} out of {total}. | 221 | ok | Return key "Ввести текст" (enter the text) passed its check, so it stays, though Russian moved to insert. |
| el | `Γράψτε στο πληκτρολόγιό σας` | Type on your keyboard. | `Εισαγωγή` | Insert, or Enter. It can also be read as Import or Input. | `%@, %lld από %lld` | {label}, {n} of {total}. | 228 | ok |  |
| ro | `Scrie pe tastatura ta` | Type on your keyboard | `Inserează` | Insert | `%@, %lld din %lld` | {label}, item {n} of {total} | 153 | ok |  |
| hu | `Beírás a saját billentyűzeten` | Typing on your own keyboard. | `Beszúrás` | Insert. | `%@, %lld. mező, összesen %lld` | {label}, field number {n}, {total} in all. | 212 | see note | Checker calls "saját" (own) vague and names Gépelés as the more usual noun; mező matches the app's Kitöltendő mező. |
| tr | `Kendi Klavyenizle Yazın` | Type with your own keyboard. | `Ekle` | Add (insert). A bare stem is the usual form for Turkish buttons, so it does not clash with the polite form in S1. | `%@, %lld. alan, toplam %lld` | Field called {label}, the {n}th field, {total} in all. | 176 | see note | Title Case follows the app's existing buttons (Klavyenizi Test Edin); the checker calls it an English habit. |
| he | `הקלד במקלדת הרגילה` | Type on the regular keyboard. | `הכנס את הטקסט` | Insert the text. | `%@, %lld מתוך %lld` | {label}, {n} of {total}. | 157 | ok | Round 2 return key: the object makes the unvowelled verb read only one way for the speech engine (round 1's bare "הכנס" could be read as "the conference"). |
| ar, ar-SA | `الكتابة بلوحة مفاتيحك` | Typing with your keyboard | `إدراج` | Insert | `%@، %lld من %lld` | {label}, item {n} of {total} | 145 | ok |  |
| fa | `تایپ با صفحه‌کلید معمولی` | Type with the regular keyboard. | `درج` | Insert. | `%@، %lld از %lld` | Item {n} of {total}, named {label}. | 174 | ok | iOS formats the numbers in the locale's digits. |
| ur, ur-PK | `اپنے عام کی بورڈ سے لکھیں` | Type with your normal keyboard. | `داخل کریں` | Enter (insert or submit it). | `%1$@، %3$lld میں سے %2$lld` | Field called {label}, number {n} out of {total}. | 179 | ok |  |
| hi | `सामान्य कीबोर्ड पर टाइप करें` | Type on the normal keyboard. | `डालें` | Put in / Insert. The verb can also mean pour. | `%1$@, %3$lld में से %2$lld` | {label}, {n} out of {total}. | 170 | ok |  |
| mr, mr-IN | `नेहमीच्या कीबोर्डवर टाइप करा` | Type on the usual keyboard | `समाविष्ट करा` | Insert (literally 'include') | `%1$@, %3$lld पैकी %2$lld` | {label}, item {n} of {total} | 178 | ok |  |
| bn, bn-BD | `সাধারণ কীবোর্ডে টাইপ করুন` | Type on the regular keyboard. | `সন্নিবেশ করুন` | Insert. | `%1$@, %3$lldটির মধ্যে %2$lld` | {label}, {n} of {total}. | 189 | ok |  |
| gu, gu-IN | `સામાન્ય કીબોર્ડ પર ટાઇપ કરો` | Type on the normal keyboard. | `દાખલ કરો` | Enter (it) / insert (it). Readers will most likely take it as 'Enter', as in entering data. | `%1$@, %3$lldમાંથી %2$lld` | {label}, {n} out of {total} | 184 | ok |  |
| pa, pa-IN | `ਆਮ ਕੀਬੋਰਡ ਨਾਲ ਟਾਈਪ ਕਰੋ` | Type with the regular keyboard. | `ਟੈਕਸਟ ਪਾਓ` | Insert the text. Because the same phrasing appears in forms (as in 'ਨਾਮ ਪਾਓ', 'enter your name'), a listener may also hear it as 'Enter text', an instruction to type rather than a key action. | `%1$@, %3$lld ਵਿੱਚੋਂ %2$lld` | {label}, {n} of {total} (for example, 'Name, 3 of 10'). | 173 | ok | Round 3 wide key uses ਨਾਲ (with), since ਤੇ without the apostrophe also reads as "and". The return key can also be heard as "enter text". |
| or, or-IN | `ସାଧାରଣ କୀବୋର୍ଡରେ ଟାଇପ୍ କରନ୍ତୁ` | Type on the regular keyboard | `ସନ୍ନିବେଶ କରନ୍ତୁ` | Insert | `%1$@, %3$lldଟି ମଧ୍ୟରୁ %2$lld` | {label}, item {n} of {total} | 239 | ok |  |
| ta, ta-IN | `வழக்கமான விசைப்பலகையில் தட்டச்சிடவும்` | Please type on the usual keyboard. | `செருகு` | Insert. | `%1$@, %3$lldஇல் %2$lld` | {label}, {n} out of {total}. | 317 | ok | Widest label, 317 of about 331 pt on a 375-pt iPhone. A 24-code-point rewrite read as "open own keyboard" to its checker, so the first draft stays. |
| te, te-IN | `మీ మామూలు కీబోర్డ్‌లో టైప్ చేయండి` | Type on your usual keyboard. | `టెక్స్ట్ చేర్చు` | Add text. | `%1$@, %3$lldలో %2$lld` | {label}, {n} of {total}. | 251 | see note | UNSURE: both writers chose చేర్చు to match the app's own Inserted notice (చేర్చబడింది); both checkers read it as add/include and name చొప్పించు as the usual word for insert. |
| kn, kn-IN | `ನಿಮ್ಮ ಸಾಮಾನ್ಯ ಕೀಬೋರ್ಡ್‌ನಲ್ಲಿ ಟೈಪ್ ಮಾಡಿ` | Type on your regular keyboard. | `ಸೇರಿಸಿ` | Add (or Insert). It does not say what is added. | `%1$@, %3$lldರಲ್ಲಿ %2$lld` | {label}, {n} of {total} (as in 'ಹತ್ತರಲ್ಲಿ ಮೂರು', '3 of 10'). | 307 | ok | 307 pt. Return key is the polite form from the re-run, to match the polite wide key. |
| ml, ml-IN | `സാധാരണ കീബോർഡിൽ ടൈപ്പ് ചെയ്യുക` | Type on the regular keyboard | `ചേർക്കുക` | Add (it can also mean insert or include) | `%1$@, %3$lld-ൽ %2$lld` | {label}, number n out of total (for example 'Name, 3 out of 10') | 277 | ok |  |
| th | `พิมพ์ด้วยคีย์บอร์ดปกติ` | Type with the normal keyboard. | `แทรก` | Insert. | `%@ ช่องที่ %lld จาก %lld` | {label}, field {n} of {total}. | 148 | ok |  |
| vi | `Gõ bằng bàn phím thường dùng` | Type with the keyboard you usually use. | `Chèn` | Insert. | `%@, chỗ trống %lld trên %lld` | {label}, blank {n} out of {total}. | 238 | see note | Round 2 announcement uses the app's own word for a blank (chỗ trống); its checker thought chỗ trống odd for a blank that already holds text. |
| id | `Ketik di Keyboard Biasa Anda` | Type on your regular keyboard | `Sisipkan` | Insert | `%@, kolom %lld dari %lld` | {label}, field n of total | 220 | see note | Anda, Keyboard and Title Case follow the app's existing strings (Uji Keyboard Anda); the checker names Papan Ketik as iOS's word. |
| ms | `Taip pada Papan Kekunci Biasa` | Type on the regular keyboard. | `Sisipkan` | Insert. | `%@, medan %lld daripada %lld` | {label}, field {n} of {total}. | 233 | ok | Round 2 announcement uses the app's own word for a blank (Medan); round 1 wrote ruangan. |
| fil | `I-type sa Karaniwang Keyboard` | Type on the regular keyboard. | `Ipasok` | Insert (put it in). | `%@, patlang %lld sa %lld` | {label}, field {n} of {total}. | 236 | see note | Title Case and patlang follow the app's existing strings; the checker calls Title Case an English habit in Filipino. |
| sw | `Andika kwa Kibodi ya Kawaida` | Type with the ordinary keyboard. The capitals make 'Kibodi ya Kawaida' look like the name of a product. | `Ingiza` | Enter (it) / put (it) in | `%@, %lld kati ya %lld` | {label}, {n} of {total} | 227 | see note | Title Case follows the app's existing buttons (Jaribu Kibodi Yako); the checker calls it an English habit. |
| ja | `いつものキーボードで入力` | Type with your usual keyboard | `挿入` | Insert | `%1$@、%3$lldか所中%2$lldか所目` | {label}, spot n of total | 177 | ok |  |
| ko | `평소 쓰는 키보드로 입력` | Type with the keyboard you normally use | `삽입` | Insert | `%@, %lld번 빈칸, 총 %lld개` | {label}, blank number n, n blanks in total | 150 | ok |  |
| zh-Hans | `改用常用键盘输入` | Switch to the usual keyboard to type. | `插入` | Insert. | `%@，第 %lld 项，共 %lld 项` | {label}, item {n} of {total}. | 117 | ok |  |
| zh-Hant | `改用常用鍵盤輸入` | Switch to typing with your usual keyboard. | `插入` | Insert | `%@，第 %lld 項，共 %lld 項` | {label}, item {n}, {total} items in all | 118 | ok |  |
| it | `Scrivi con la solita tastiera` | Type with your usual keyboard | `Inserisci` | Insert | `%@, %lld di %lld` | {label}, n of total | 198 | ok |  |
| ca | `Escriu amb el teclat habitual` | Type with your usual keyboard | `Insereix` | Insert | `%@, %lld de %lld` | {label}, n of total | 213 | ok |  |
| es, es-ES | `Escribir con tu teclado normal` | Type with your normal keyboard. | `Insertar` | Insert. | `%@, %lld de %lld` | {label}, {n} of {total}. | 226 | ok |  |
| es-MX | `Escribir con tu teclado normal` | Type with your normal keyboard. | `Insertar` | Insert | `%@, %lld de %lld` | {label}, {n} of {total} | 226 | ok |  |
| pt, pt-BR | `Digitar no seu teclado normal` | Type on your normal keyboard | `Inserir` | Insert | `%@, %lld de %lld` | {label}, n of total | 221 | ok |  |
| pt-PT | `Escrever no seu teclado normal` | Type on your normal keyboard | `Inserir` | Insert | `%@, %lld de %lld` | {label}, n of total | 237 | ok |  |
| fr, fr-FR | `Taper sur ton clavier habituel` | Type on your usual keyboard. | `Insérer` | Insert. | `%@, %lld sur %lld` | {label}, {n} of {total}. | 219 | ok | tu follows the app's existing strings (Teste ton clavier). |
| fr-CA | `Taper sur ton clavier habituel` | Type on your usual keyboard. | `Insérer` | Insert | `%@, %lld sur %lld` | {label}, {n} of {total} | 219 | see note | tu follows the app's existing strings (Teste ton clavier); the checker notes Quebec software usually says votre. |

## The editor's fill-in tip (board ASG91)

The one-time tip on the editor's Add Fill-in or Date row (iPhone and iPad), in `Cutling/<locale>.lproj/Localizable.strings`, written from [fill-ins-strings-brief.md](fill-ins-strings-brief.md) (T1, T2) and checked back on 2026-11-21.

| Brief key | `.strings` key | Where |
|---|---|---|
| T1 `tip-title` | `"Blanks and dates"` | bold title line of the tip |
| T2 `tip-message` | `"Add a blank you fill in each time you use this cutling, or today’s date."` | the tip's message |

Made the same way as the keyboard strings above: one writer per batch of up to four languages got the brief, the language and that locale's existing app words (the row, the menu items, its word for a cutling, its existing tips), never an English string; a separate reader per batch of about seven languages, told only each string's role, wrote what a native reader understands from it and whether it is natural. Round 1 covered every language; 27 lines a reader flagged went to fresh writers once the brief said two things more plainly (name the date as the menu item does, with no clause explaining it; "each time" belongs to filling the blank, and the date must never read as something used), and nine of those went round again with each reader's point in the brief. es-ES got its own line, since its menu item says rellenar where es says completar. es and es-MX went through four rounds and es-ES through two (rounds 4 and 5); the last round wrote all three together. Round is the round whose line ships (a title carried unchanged into a later round counts that round). "Read back as" for the message is the reader's literal rendering of the string as shipped. Title pt is the title's width at 17 pt semibold, the tip's headline font, measured with the system font on macOS; every title fits one line in the roughly 250-pt text column a tip has on a 375-pt iPhone. Lines is the message wrapped at 15 pt in that column and in a 268-pt column on a 393-pt iPhone; TipKit wraps rather than clips, so a fourth line makes the bubble taller.

Most readers noted that a bare "today's date" can be read as the date the snippet was edited rather than the day it is used. The menu item names it today's date in nearly every language, English included, and the menu's heading says each item fills in when used, so the lines keep the menu's name.

| Locale | Title | Read back as | Message | Read back as | Title pt | Lines 250 / 268 pt | Round | Check | Note |
|---|---|---|---|---|---|---|---|---|---|
| en, en-AU, en-CA, en-GB, en-IN | `Blanks and dates` |  | `Add a blank you fill in each time you use this cutling, or today’s date.` |  | 135 | 2 / 2 | given | given | Given in the card; not back-checked. |
| de, de-DE | `Eingabefelder und Datum` | Input fields and the date. | `Füge hier ein Eingabefeld ein, das du bei jeder Verwendung ausfüllst, oder das heutige Datum.` | Insert [imperative, familiar du] here an input-field in, that you at every use fill-in, or the today's date. | 201 | 3 / 3 | 1 | ok |  |
| nl, nl-NL | `Invoervelden en datum` | Input fields and the date. | `Voeg hier een invoerveld in dat je elke keer invult als je de cutling gebruikt, of de datum van vandaag.` | Insert [imperative, familiar je] here an input-field that you each time fill-in when you the cutling use, or the date of today. | 181 | 3 / 3 | 2 | ok | Round 2 says elke keer … als je de cutling gebruikt; round 1's bij elk gebruik read as stiff. |
| da | `Indtastningsfelter og dato` | Input fields and the date. | `Her kan du indsætte et indtastningsfelt, du udfylder, hver gang du bruger cutlingen, eller tilføje dagens dato.` | Here can you insert an input-field, [that] you fill-in, every time you use the-cutling, or add today's date. [informal 'du'] | 206 | 4 / 4 | 3 | ok | Round 3: a second verb, tilføje, keeps the date from reading as something used (round 2 did, for a moment); round 1's ved hver brug read as stiff. |
| sv | `Fält och datum` | Fields and the date. | `Tryck här för att infoga ett fält som du fyller i varje gång cutlingen används, eller dagens datum.` | Press [imperative] here for to insert a field that you fill in every time the-cutling is-used [passive], or today's date. | 118 | 3 / 3 | 1 | ok |  |
| nb | `Utfyllingsfelt og dato` | Fill-in field(s) and the date. | `Her kan du sette inn et felt du fyller ut hver gang du bruker cutlingen, eller legge til dagens dato.` | Here can you put in a field you fill out every time you use the-cutling, or add today's date. [informal 'du'] | 167 | 3 / 3 | 3 | ok | Round 2 title (round 1's Felt å fylle ut og dato read as covering the date too); round 3 message gives the date its own verb, legge til. |
| fi | `Kentät ja päivämäärät` | Fields and dates. | `Tästä voit lisätä kentän, jonka täytät joka kerta, kun käytät cutlingia, tai tämän päivän päivämäärän.` | From-here can-you add a-field[accusative], which you-fill every time, when you-use cutling[partitive], or this day's date[accusative]. | 172 | 3 / 3 | 2 | ok | Round 2 says tämän päivän päivämäärä; round 1's päivän päivämäärän, the menu item's own words, read as redundant inside a sentence. |
| et | `Väljad ja kuupäevad` | Fields and dates. | `Siit saad lisada cutlingisse välja, mille täidad igal kasutuskorral, või tänase kuupäeva.` | From-here you-can add into-cutling a-field, which you-fill at-every use-time, or today's date. | 157 | 3 / 3 | 1 | ok |  |
| lt | `Laukai ir datos` | Fields and dates. | `Čia gali įterpti į cutlingą lauką, kurį užpildysi kaskart naudojant, arba šiandienos datą.` | Here [you, familiar] can insert into cutling a field, which [you, familiar] will-fill each-time when-using, or today's date. | 115 | 3 / 3 | 1 | ok | Reader: naudojant (impersonal) after a second-person verb is a little loose but natural. |
| lv | `Lauki un datumi` | Fields and dates. | `Šeit vari cutlingā ievietot lauku, ko aizpildi katrā lietošanas reizē, vai šodienas datumu.` | Here [you, familiar] can into-cutling insert a field, which [you, familiar] fill [present] in-each use time, or today's date. | 126 | 3 / 3 | 1 | ok |  |
| pl | `Pola i daty` | Fields and dates. | `Stuknij tutaj, aby wstawić do cutlinga pole uzupełniane przy każdym użyciu lub dzisiejszą datę.` | Tap [imperative, familiar] here, in-order-to insert into cutling a field filled-in at every use or today's date. | 82 | 3 / 3 | 1 | see note | Reader names wypełniane as the more usual word; uzupełniane follows the app's menu item Pole do uzupełnienia. |
| cs | `Pole k vyplnění a datum` | Fields to fill in, and the date. | `Klepnutím sem můžeš do cutlingu vložit pole, které pokaždé vyplníš, nebo dnešní datum.` | By-tapping here [you, familiar] can into cutling insert a field, which every-time [you, familiar] fill-in, or today's date. | 188 | 3 / 3 | 1 | ok |  |
| sk | `Pole na vyplnenie a dátum` | Fields to fill in, and the date. | `Klepnutím sem môžeš do cutlingu vložiť pole, ktoré zakaždým vyplníš, alebo dnešný dátum.` | By-tapping here [you, familiar] can into cutling insert a field, which every-time [you, familiar] fill-in, or today's date. | 207 | 3 / 3 | 1 | ok |  |
| sl, sl-SI | `Polja za vnos in datumi` | Input fields and dates. | `Tukaj lahko v cutling vstaviš polje za vnos, ki ga izpolniš ob vsaki uporabi, ali današnji datum.` | Here can into cutling insert-you [2nd person singular, informal] a-field for input, which it you-fill at every use, or today's date. | 181 | 3 / 3 | 2 | ok | Round 2 (round 1's trailing ob uporabi dangled). |
| hr | `Polja za unos i datumi` | Input fields and dates. | `Ovdje u cutling možeš umetnuti polje za unos, koje popunjavaš pri svakom korištenju, ili današnji datum.` | Here into cutling you-can [2nd person singular, informal] insert a-field for input, which you-fill at every use, or today's date. | 171 | 4 / 3 | 2 | ok | Round 2 says možeš umetnuti; round 1's plain umećeš read as a description. |
| sr | `Поља и датуми` | Fields and dates. | `Овде у катлинг можеш да додаш поље, које попуњаваш при сваком коришћењу, или данашњи датум.` | Here into katling you-can [2nd person singular, informal] that you-add a-field, which you-fill at every use, or today's date. | 127 | 3 / 3 | 2 | ok | Round 2 (round 1's perfective попуниш was wrong for a repeated act). All Cyrillic. |
| bg | `Полета за попълване и дати` | Fill-in fields and dates. | `Оттук можеш да добавиш в кътлинга поле, което попълваш при всяко използване, или днешна дата.` | From-here you-can [2sg, informal] to add into the-cutling a field, which you-fill [2sg, informal, present] at every use, or today's date. | 233 | 4 / 3 | 2 | ok | Round 2 (round 1's днешната дата към деня на използване read as self-contradictory). |
| ru | `Поля и даты` | Fields and dates. | `Добавь в катлинг поле, которое заполняешь при каждом использовании, или сегодняшнюю дату.` | Add [imperative, 2sg familiar] into cutling field, which [you] fill-in at each use, or today's date. | 102 | 4 / 4 | 1 | see note | Reader: today's date may read as fixed; it is the menu item's own name, as in English. ты follows the app's tips (Нажми, Проведи). |
| uk | `Поля та дати` | Fields and dates. | `Додай у катлінг поле, яке заповнюєш щоразу під час використання, або сьогоднішню дату.` | Add [imperative, 2sg familiar] into cutling field, which [you] fill-in each-time during use, or today's date. | 107 | 4 / 4 | 1 | see note | Reader: today's date may read as fixed; it is the menu item's own name, as in English. ти follows the app's tips (Натисни, Проведи). |
| el | `Πεδία και ημερομηνίες` | Fields and dates. | `Πρόσθεσε στο cutling ένα πεδίο που συμπληρώνεις σε κάθε χρήση ή τη σημερινή ημερομηνία.` | Add [imperative, 2sg familiar] to-the cutling a field that [you] fill-in at each use or the today's date. | 182 | 3 / 3 | 1 | see note | Reader: today's date may read as fixed; it is the menu item's own name, as in English. |
| ro | `Câmpuri și data de azi` | Fields and today's date. | `Adaugă în cutling un câmp pe care îl completezi la fiecare utilizare sau data de azi.` | Add [imperative, 2sg familiar] into cutling a field which [it] [you] fill-in at each use or the-date of today. | 175 | 3 / 3 | 1 | see note | Reader: today's date may read as fixed; it is the menu item's own name, as in English. |
| hu | `Kitöltendő mezők és dátum` | Fill-in fields and a date. | `Innen a cutlingba tehetsz egy mezőt, amit minden használatkor kitöltesz, vagy az aznapi dátumot.` | From-here into-the-cutling [you] can-put [2sg informal] a field, which every use-at [you] fill-in, or the that-day's date. | 217 | 3 / 3 | 1 | ok | aznapi (that day's) points the date at the day of use. |
| tr | `Doldurulacak alan ve tarih` | A field you fill in, and the date. | `Buradan cutling’ine her kullanımda dolduracağın bir alan veya o günün tarihini ekleyebilirsin.` | From-here your-cutling-to at-every-use that-you-will-fill a field or that day's date-[accusative] you-can-add [informal 'sen', ability] | 205 | 3 / 3 | 1 | ok | Curly apostrophe as in the app's cutling’ini. |
| he | `שדות למילוי ותאריך` | Fields to fill in, and the date. | `הוסף מכאן לקאטלינג שדה שתמלא בכל שימוש, או את התאריך של יום השימוש.` | Add [imperative, masc. sing.] from-here to-(the-)cutling a-field that-you[masc.]-will-fill in-every use, or [def. object marker] the-date of day-of the-use. | 143 | 2 / 2 | 1 | ok |  |
| ar, ar-SA | `حقول للتعبئة والتاريخ` | Fields to fill in, and the date. | `أدرج من هنا في الكاتلينج حقلًا تملؤه عند كل استخدام، أو تاريخ يوم الاستخدام.` | Insert [imperative, masc. sing.] from here into the-cutling a-field you-fill-it at every use, or date-of day-of the-use. | 150 | 2 / 2 | 1 | ok |  |
| fa | `فیلد پرکردنی و تاریخ` | A fill-in field and a date. | `از اینجا فیلدی را که در هر استفاده پر می‌کنید یا تاریخ امروز را به متن این کاتلینگ اضافه کنید.` | From here a-field [object] that in every use you-fill [2pl, polite] or date of-today [object] to the text of this cutling add [imperative/subjunctive, polite]. | 138 | 3 / 3 | 2 | ok | Round 2: both objects carry را before one verb, and اضافه کنید replaces bookish بیفزایید. |
| ur, ur-PK | `خالی خانہ اور تاریخ` | Blank field and date, the usual way to say a blank on a form. | `کٹلنگ میں ایسا خانہ شامل کریں جسے آپ ہر بار استعمال کرتے وقت بھریں گے، یا آج کی تاریخ ڈالیں۔` | Cutling in such box add [imperative, polite 'aap'] which you every time using-while will-fill, or today's date put [imperative, polite]. | 133 | 3 / 3 | 3 | ok | Round 2 title خالی خانہ (round 1's خانے read as boxes); round 3 message uses a future verb in the relative clause so it cannot read as a separate command. |
| hi | `रिक्त स्थान और तिथि` | A blank (fill-in) space and a date. | `यहाँ से इस कटलिंग में हर उपयोग पर भरा जाने वाला रिक्त स्थान या आज की तिथि डालें।` | From here in this cutling on every use to-be-filled blank space or today's date insert [imperative, polite आप]. | 132 | 2 / 2 | 2 | ok | Round 2 puts both objects before the verb (round 1's date trailed after it). |
| mr, mr-IN | `भरायची जागा आणि तारीख` | A space to fill in, and the date. | `या कटलिंगमध्ये दर वेळी तुम्ही भराल अशी जागा, किंवा वापरण्याच्या दिवसाची तारीख घाला.` | This cutling-in every time you will-fill such space, or using-of day-of date insert [polite imperative]. | 168 | 3 / 2 | 1 | ok |  |
| bn, bn-BD | `শূন্যস্থান ও তারিখ` | A fill-in blank and a date. | `এখান থেকে এই কাটলিংয়ে প্রতিবার ব্যবহারের সময় পূরণ করার শূন্যস্থান বা আজকের তারিখ বসান।` | From here in this cutling at the time of every use for-filling blank-space or today's date place [imperative, polite আপনি]. | 120 | 3 / 3 | 2 | ok | Round 2: one clause (round 1 spliced on a second clause to explain the date, too long for a tip). |
| gu, gu-IN | `ભરવાની જગ્યા અને તારીખ` | A fill-in space and a date. | `અહીંથી આ કટલિંગમાં દરેક ઉપયોગ વખતે તમે ભરો તેવી જગ્યા કે આજની તારીખ ઉમેરો.` | From-here in this cutling at every use time you [polite] fill [subjunctive] such space or today's date add [imperative, polite તમે]. | 175 | 3 / 2 | 2 | ok | Round 2, as bn. |
| pa, pa-IN | `ਖਾਲੀ ਥਾਂ ਅਤੇ ਤਾਰੀਖ਼` | A blank space and a date. | `ਇੱਥੋਂ ਇਸ ਕਟਲਿੰਗ ਵਿੱਚ ਹਰ ਵਾਰੀ ਵਰਤਣ ਵੇਲੇ ਭਰੀ ਜਾਣ ਵਾਲੀ ਖਾਲੀ ਥਾਂ ਜਾਂ ਅੱਜ ਦੀ ਤਾਰੀਖ਼ ਜੋੜੋ।` | From-here in this cutling every time using at-the-time to-be-filled empty place or today's date add [imperative, polite ਤੁਸੀਂ]. | 128 | 3 / 2 | 2 | ok | Round 2, as bn. |
| or, or-IN | `ଶୂନ୍ୟସ୍ଥାନ ଓ ତାରିଖ` | Blanks and the date; the fill-in-the-blank word. | `ଏଠାରୁ ଏହି କଟ୍‌ଲିଂରେ ଆପଣ ପ୍ରତି ଥର ବ୍ୟବହାର ବେଳେ ପୂରଣ କରୁଥିବା ଶୂନ୍ୟସ୍ଥାନ ବା ଆଜିର ତାରିଖ ଯୋଡ଼ନ୍ତୁ।` | From-here this cutling-in you [honorific] each time use at-time fill-doing blank-space or today's date add [imperative, polite]. | 136 | 3 / 3 | 2 | see note | Round 2, as bn. Reader calls ଏଠାରୁ (from here) a slight calque. |
| ta, ta-IN | `புலங்களும் தேதிகளும்` | Fields and dates. | `இந்தக் கட்லிங்கில் ஒவ்வொரு முறை பயன்படுத்தும்போதும் நிரப்பிக்கொள்ளும் புலத்தையோ இன்றைய தேதியையோ இங்கிருந்து சேர்க்கலாம்.` | In-this cutling, each time using-when-also fill-in-for-oneself field-or today's date-or from-here [you] can-add. [neutral, no explicit person] | 175 | 5 / 4 | 3 | see note | Round 3 uses the neutral -லாம் form with no pronoun (round 1's நீ read as rude, round 2's bare சேர் as curt). Longest message: 5 lines at 250 pt, 4 on a 393-pt iPhone. |
| te, te-IN | `ఫీల్డ్‌లు మరియు తేదీలు` | Fields and dates. | `ఉపయోగించిన ప్రతిసారీ మీరు నింపే ఫీల్డ్‌ను గానీ, ఉపయోగించిన రోజు తేదీని గానీ ఈ కట్లింగ్‌లో జోడించవచ్చు.` | Used [past relative participle] every-time you [polite] fill-[relative] field-[acc] either, used [past] day's date-[acc] or, this cutling-in add-can. | 165 | 3 / 3 | 1 | see note | Reader: the past participle ఉపయోగించిన రోజు could suggest a past day. |
| kn, kn-IN | `ಫೀಲ್ಡ್‌ಗಳು ಮತ್ತು ದಿನಾಂಕಗಳು` | Fields and dates. | `ಬಳಸಿದಾಗಲೆಲ್ಲ ನೀವು ಭರ್ತಿ ಮಾಡುವ ಫೀಲ್ಡ್ ಅಥವಾ ಬಳಸಿದ ದಿನದ ದಿನಾಂಕವನ್ನು ಈ ಕಟ್ಲಿಂಗ್‌ಗೆ ಸೇರಿಸಬಹುದು.` | Used-when-all you [polite] fill do-[relative] field or used [past] day's date-[acc] this cutling-to add-may. | 211 | 4 / 3 | 1 | see note | Reader: the past participle ಬಳಸಿದ ದಿನದ is mildly unclear about which day. |
| ml, ml-IN | `ഫീൽഡുകളും തീയതികളും` | Fields and dates. | `ഉപയോഗിക്കുമ്പോഴെല്ലാം നിങ്ങൾ പൂരിപ്പിക്കുന്ന ഫീൽഡോ ഉപയോഗിക്കുന്ന ദിവസത്തെ തീയതിയോ ഈ കട്ട്‌ലിംഗിൽ ചേർക്കാം.` | whenever-using you fill-in field-or using day's date-or this cutling-in add-[can/may, neutral polite] | 195 | 4 / 4 | 1 | ok |  |
| th | `ช่องกรอกและวันที่` | Fill-in fields and the date. | `แตะที่นี่เพื่อใส่ช่องที่คุณกรอกเองทุกครั้งที่ใช้ หรือใส่วันที่ปัจจุบันลงในคัตลิงนี้` | Tap here in-order-to put field that you fill yourself every time that use, or put date current down-into cutling this | 126 | 2 / 2 | 2 | ok | Round 2 (round 1 said fill twice). No end punctuation, as the app's Thai tips. |
| vi | `Chỗ trống và ngày` | Blanks and date. | `Chèn vào cutling này chỗ trống để bạn điền mỗi lần dùng, hoặc ngày luôn khớp với hôm bạn dùng.` | Insert into cutling this blank-space so you fill each time use, or date always match with day you use. [imperative, neutral] | 144 | 3 / 3 | 1 | ok | Uses the app's word for a blank, chỗ trống. |
| id | `Isian dan tanggal` | Fill-ins and date. | `Sisipkan kolom isian yang Anda isi tiap kali cutling ini dipakai, atau tanggal hari pemakaiannya.` | Insert column fill-in that You[formal] fill each time cutling this is-used, or date day its-use | 135 | 3 / 3 | 1 | ok | Anda follows the app's existing strings. |
| ms | `Medan dan tarikh` | Fields and date. | `Sisipkan medan yang anda isi setiap kali cutling ini digunakan, atau tarikh hari ia digunakan.` | Insert field that you fill every time cutling this is-used, or date day it is-used | 138 | 3 / 3 | 1 | ok |  |
| fil | `Patlang at petsa` | Blanks and the date. | `I-tap dito para lagyan ang cutling ng patlang na pupunan mo tuwing gagamitin, o ng petsa ngayong araw.` | Tap here so-that put-on the cutling of blank that will-fill you [familiar 'mo'] every will-be-used, or of date this-day. | 128 | 4 / 3 | 2 | ok | Round 2 uses the menu's petsa ngayong araw; round 1's petsa ng araw na iyon read as vague. Patlang is the app's word; round 1's reader found it bookish. |
| sw | `Tarehe na nafasi za kujaza` | The date, and blanks to fill in. | `Gusa hapa kuongeza nafasi utakayoijaza kila unapotumia cutling hii, au kuongeza tarehe ya leo.` | Touch [imperative, singular] here to-add space you-will-fill-it every you-when-use cutling this, or to-add date of today. | 207 | 3 / 3 | 2 | ok | Round 2 title puts the date first; round 1's Nafasi za kujaza na tarehe read as 'spaces to fill with a date'. |
| ja | `入力項目と日付` | Input fields and dates. | `ここをタップすると、使うたびに入力する項目や、使った日の日付をカットリングに挿入できます。` | here [obj] tap-if, use-each-time input-[relative] item or, used day's date [obj] cutling-into insert-can [polite] | 110 | 3 / 3 | 1 | ok |  |
| ko | `입력란과 날짜` | Input fields and the date. | `이 컷링에 입력란을 넣으면 사용할 때마다 직접 채울 수 있고, 오늘 날짜도 넣을 수 있습니다.` | This cutling-in input-field [obj] put-if, use-when every-time directly fill can, and today date also put can [formal polite -습니다]. | 92 | 3 / 3 | 2 | see note | Round 2 (round 1's 여기를 눌러 쓸 때마다 misparsed). Reader calls -습니다 a bit stiff for a tip. |
| zh-Hans | `填写项和日期` | Fill-in items and date, the familiar word from forms. | `可在这个剪切片段中插入每次使用时再输入的填写项，或今天的日期。` | Can in this cut-snippet in insert each-time use when then input DE fill-in-item, or today's date. [no subject; neutral] | 94 | 2 / 2 | 3 | ok | Round 3 (round 1 was too long with a semicolon; round 2 said 填 twice). |
| zh-Hant | `待填欄位和日期` | Fields you fill in, and dates. | `可在這個剪切片段中插入每次使用時再輸入的填寫欄位，或今天的日期。` | [you] can in this cut-snippet insert each-time use-when then type-in [particle] fill-in field, or today's date. | 110 | 2 / 2 | 3 | see note | Round 3 title 待填欄位 (round 2's 填寫欄位和日期 read as a command). UNSURE: readers call 剪切片段 Mainland usage (Taiwan says 剪下); it is the app's existing zh-Hant word for a cutling, so changing it is an app-wide call. |
| it | `Campi da compilare e date` | Fields to be filled in, and dates. | `Da qui puoi aggiungere al cutling un campo che compili a ogni uso, oppure la data di oggi.` | From here [you, familiar] can add to-the cutling a field that [you] fill-in at each use, or-else the date of today. | 211 | 3 / 3 | 2 | ok | Round 2 (round 1's a ogni uso could attach to adding). |
| ca | `Camps per omplir i dates` | Fields to be filled in, and dates. | `Des d’aquí pots afegir al cutling un camp que omples cada vegada que l’uses, o bé la data d’avui.` | From here [you, familiar] can add to-the cutling a field that [you] fill each time that [you] it-use, or rather the date of today. | 198 | 3 / 3 | 2 | ok | Round 2 (round 1's a cada ús could attach to adding). |
| es | `Campos y fechas` | Fields and dates. | `Añade un campo que completes cada vez que uses este cutling o inserta la fecha de hoy.` | Add [imperative, familiar tú] a field that you-fill-in [subjunctive, tú] each time that you-use [subjunctive, tú] this cutling or insert [imperative, familiar tú] the date of today. | 136 | 3 / 3 | 5 | see note | Round 5, written with es-ES and es-MX after rounds 1 and 3 read the date as something used or split it with commas. Reader: today's date may read as fixed; it is the menu item's own name, as in English. |
| es-ES | `Campos y fechas` | Fields and dates. | `Añade un campo que rellenes cada vez que uses este cutling o inserta la fecha de hoy.` | Add [imperative, familiar tú] a field that you-fill-in [subjunctive, tú] each time that you-use [subjunctive, tú] this cutling or insert [imperative, familiar tú] the date of today. | 136 | 3 / 3 | 5 | see note | Its own line from round 4, since its menu item says rellenar where es says completar; round 5 as es. Reader: today's date may read as fixed; it is the menu item's own name, as in English. |
| es-MX | `Campos y fechas` | Fields and dates. | `Añade un campo que llenes cada vez que uses este cutling o inserta la fecha de hoy.` | Add [imperative, familiar tú] a field that you-fill [subjunctive, tú] each time that you-use [subjunctive, tú] this cutling or insert [imperative, familiar tú] the date of today. | 136 | 3 / 3 | 5 | see note | Round 5 as es. Reader names Agrega as the Mexican word; the app's es-MX strings say añadir 13 times and agregar twice, so Añade stays. |
| pt, pt-BR | `Campos e datas` | Fields and dates. | `Adicione aqui um campo para preencher a cada uso do cutling ou a data do dia em que ele for usado.` | Add [imperative, você] here a field to fill at each use of-the cutling or the date of-the day in which it [future subjunctive, passive] is used. | 128 | 3 / 3 | 1 | ok |  |
| pt-PT | `Campos e datas` | Fields and dates. | `Toque aqui para inserir neste cutling um campo a preencher em cada utilização, ou a data de hoje.` | Tap [imperative, formal você] here to insert in-this cutling a field to-fill in each use, or the date of today. | 128 | 3 / 3 | 3 | ok | Round 3 (rounds 1 and 2 let the date read as something used). |
| fr, fr-FR | `Champs à remplir et dates` | Fill-in fields and dates. | `Ajoutez à ce cutling un champ à remplir à chaque usage ou la date du jour où vous l’utilisez.` | Add [imperative, vous] to this cutling a field to fill at each use or the date of-the day where you it use. | 208 | 3 / 3 | 1 | ok | vous follows the app's tips (Touchez, Faites glisser). Reader: à chaque utilisation is more usual than à chaque usage. Apostrophe set to ’, as most of the app's French strings write it. |
| fr-CA | `Champs à remplir et dates` | Fill-in fields and dates. | `Ajoutez à ce cutling un champ à remplir à chaque usage ou la date du jour où vous l’utilisez.` | Add [imperative, vous] to this cutling a field to fill at each use or the date of-the day where you it use. | 208 | 3 / 3 | 1 | ok | As fr. |

## Naming a new blank: its choices (board ASG91)

The alert that names a new blank (iPhone, iPad and Mac) gained a second text field for the blank's choices, in `Cutling/<locale>.lproj/Localizable.strings`, written from [fill-ins-strings-brief.md](fill-ins-strings-brief.md) (C1, C2) and checked back on 2026-11-21.

| Brief key | `.strings` key | Where |
|---|---|---|
| C1 `choices-placeholder` | `"Choices (optional)"` | grey placeholder of the alert's second text field |
| C2 `choices-message` | `"Separate choices with commas."` | the alert's message line under its title |

Made as the strings above: one writer per batch of up to four languages got the brief, the language and that locale's existing app words (the alert's title and Name, Cancel and Done, the menu items, the fill-in tip, its other placeholders), never an English string; each writer and reader ran as a separate `claude -p` process with no tools, so none could open the repo. A separate reader per batch of about seven languages, told only where each string sits on the alert, wrote what a native user understands from it, whether it is natural, and which character they would type between values. Round 1 covered all 52 languages. Seven were flagged; the brief then said that the optional mark is written in full and native, that the values are offered for picking later (never a price, an alternative or "any values"), and that a locale's own word for comma names its own mark, so fresh writers wrote ru, uk, ar, bn, or, ko and fr again with each reader's point, and Bengali went round a third time. Serbian's and Malayalam's round 1 placeholders were cut off with an ellipsis in the rendered alert, so they, and Bulgarian at Serbian's width, were written again within the length budget and read again.

Cutling splits the choices only at the plain comma "," (U+002C). Locales whose own list mark differs (ar, fa, ur, ja, zh-Hans, zh-Hant, th) name the Latin, English or half-width comma and show the "," itself; Indic locales that already list with "," show it in brackets after its name. For every shipped line the reader named U+002C as the character to type, except Russian's round 2 reader, who left that answer blank and read the line as "separated by commas" (Russian lists with ",").

Fit is the alert rendered on the iOS 27.2 simulator (iPhone Duo, cover display) with the locale's language: a test app showing the same SwiftUI `.alert`, title, Name field, choices field, message and buttons, screenshotted per locale. C1 pt is the placeholder's width at 13 pt with the system font on macOS: in the rendered field Tamil's 197 pt fits and Serbian's round 1 at 206 pt did not. Lines is the message's line count in the rendered alert. The narrowest iPhones and the Mac alert were not rendered. Read back as for the message is the reader's literal rendering.

| Locale | Placeholder | Read back as | Message | Read back as | C1 pt / fit, lines | Round | Check | Note |
|---|---|---|---|---|---|---|---|---|
| en, en-AU, en-CA, en-GB, en-IN | `Choices (optional)` |  | `Separate choices with commas.` |  | 111 / fits, 1 | given | given | Given in the card; not back-checked. |
| de, de-DE | `Werte zur Auswahl (optional)` | Optionally enter the values a person can choose from. | `Trenne mehrere Werte durch Kommas.` | Separate [informal du imperative] several values by commas. | 175 / fits, 2 | 1 | ok |  |
| nl, nl-NL | `Keuzewaarden (optioneel)` | Optionally enter the values that can be chosen from. | `Scheid meerdere waarden met komma's.` | Separate [imperative] multiple values with commas. | 158 / fits, 2 | 1 | ok |  |
| da | `Mulige værdier (valgfrit)` | Optionally enter the values that are allowed or offered. | `Du kan skrive flere værdier adskilt med komma.` | You can write several values separated with comma. | 146 / fits, 2 | 1 | ok |  |
| sv | `Möjliga värden (valfritt)` | Optionally enter the values that are allowed or offered. | `Separera flera värden med kommatecken.` | Separate [imperative] several values with comma-signs. | 140 / fits, 2 | 1 | ok |  |
| nb | `Mulige verdier (valgfritt)` | Optionally enter the values that are allowed or offered. | `Du kan skrive inn flere verdier i feltet nederst, skilt med komma.` | You can write in several values in the-field at-the-bottom, separated with comma. | 146 / fits, 2 | 1 | ok | Names the lower field (i feltet nederst), as fi, et and lt do; both fields stack on iPhone and Mac. |
| fi | `Valittavat arvot (valinnainen)` | Optionally enter the values that can be picked. | `Voit kirjoittaa alempaan kenttään useita arvoja pilkulla erotettuina.` | You-can write into-the-lower field [illative] several values [partitive] with-comma [adessive] separated [essive plural]. | 172 / fits, 2 | 1 | ok |  |
| et | `Variandid (valikuline)` | Optionally enter the options a person can choose from. | `Alumisele väljale saad kirjutada mitu komaga eraldatud varianti.` | Onto-the-lower field [allative] you-can write several with-comma [comitative] separated variant [partitive singular after 'mitu']. | 126 / fits, 2 | 1 | ok |  |
| lt | `Variantai (neprivaloma)` | Type the choices for this field here; you can leave it empty. | `Apatiniame lauke gali įrašyti kelis variantus, atskirtus kableliais.` | In-the-lower [locative] field [you, informal singular] can write-in several options [accusative plural], separated [participle, accusative plural] by-commas [instrumental plural]. | 140 / fits, 2 | 1 | ok |  |
| lv | `Lauka vērtības (neobligāti)` | Enter the values this field can take; it is optional. | `Ja vērtības ir vairākas, atdali tās ar komatu.` | If values are several, separate [imperative, informal singular] them with comma [singular]. | 161 / fits, 2 | 1 | ok |  |
| pl | `Wartości pola (opcjonalnie)` | Enter the values this field can take; it is optional. | `Jeśli wartości jest kilka, oddziel je przecinkami.` | If values [genitive plural] is several, separate [imperative, informal singular] them with-commas [instrumental plural]. | 165 / fits, 2 | 1 | ok |  |
| cs | `Možné hodnoty (nepovinné)` | Enter the possible values for this field; it is optional. | `Pokud je hodnot víc, odděl je čárkou.` | If is of-values [genitive plural] more [colloquial 'víc'], separate [imperative, informal singular] them with-comma [instrumental singular]. | 170 / fits, 1 | 1 | ok |  |
| sk | `Možné hodnoty (nepovinné)` | Enter the possible values for this field; it is optional. | `Ak je hodnôt viac, oddeľ ich čiarkou.` | If is of-values [genitive plural] more, separate [imperative, informal singular] them with-comma [instrumental singular]. | 170 / fits, 1 | 1 | ok |  |
| sl, sl-SI | `Možne vrednosti (neobvezno)` | Enter the possible values for this field; it is optional. | `Več možnih vrednosti loči z vejico.` | Several possible values [genitive plural] separate [imperative, informal singular] with comma [instrumental singular]. | 180 / fits, 1 | 1 | ok |  |
| hr | `Moguće vrijednosti (po želji)` | Enter the possible values for this field if you want; it is optional. | `Više mogućih vrijednosti odvoji zarezom.` | Several possible values [genitive plural] separate [imperative, informal singular] with-comma [instrumental singular]. | 171 / fits, 2 | 1 | ok |  |
| sr | `Понуђени уноси (опционо)` | An optional field where you list the entries that will be offered as choices. | `Више понуђених уноса одвој зарезом.` | Several offered entries [gen. pl.] separate [imperative, 2nd sg. informal] with-comma [instr. sg.]. | 172 / fits, 2 | 2 | see note | Round 2 within the length budget: round 1's Могуће вредности (необавезно), 206 pt, was cut off in the rendered field. The writer's line ended with an example (нпр. Basic, Pro, Team) taken from the brief, which was cut before the reader read it. All Cyrillic, as the alert's title and the rest of the file; the reader flagged that the alert's existing Name, Cancel and Done (Naziv, Otkaži, Gotovo) are Latin, an older mix in the app's Serbian outside this card. |
| bg | `Варианти (по желание)` | An optional field for the choices to offer. | `Ако въвеждаш няколко варианта, отделяй ги със запетая.` | If you-enter [2nd sg. informal] several variants [count form], separate [imperfective imperative, 2nd sg.] them with comma. | 148 / fits, 2 | 2 | ok | Round 2 within the length budget, since round 1's Възможни стойности (по избор), 205 pt, sat at Serbian's width, which was cut off. |
| ru | `Варианты (необязательно)` | This field is for a set of options, and you can leave it empty. | `Если вариантов несколько, перечисли их через запятую.` | If options [gen. pl.] several, list [imperative, informal ты] them through comma [acc. sg.]. | 170 / fits, 2 | 2 | see note | Round 2 placeholder (round 1's abbreviated необяз. read clipped). ты follows the fill-in tip (Добавь); the reader notes iOS alerts usually say вы, and the app's Russian uses both about equally. |
| uk | `Варіанти (необов’язково)` | This field is for a set of options, and you can leave it empty. | `Якщо варіантів кілька, перелічи їх через кому.` | If options [gen. pl.] several, list [imperative, informal ти] them through comma [acc. sg.]. | 161 / fits, 2 | 2 | see note | Round 2 placeholder (round 1's опційно read as a borrowing). ти follows the fill-in tip (Додай); the reader notes iOS alerts usually say ви. |
| el | `Πιθανές τιμές (προαιρετικό)` | This field takes the possible values, and filling it is optional. | `Αν γράψεις πολλές τιμές, χώρισέ τες με κόμμα.` | If you-write [informal 2nd person singular] many values, separate-them [imperative + colloquial feminine plural clitic] with comma. | 171 / fits, 2 | 1 | ok |  |
| ro | `Valori posibile (opțional)` | This field takes the possible values, and filling it is optional. | `Dacă scrii mai multe valori, separă-le prin virgulă.` | If you-write [informal] more values, separate-them [imperative + clitic] by comma. | 146 / fits, 2 | 1 | ok |  |
| hu | `Értékek (nem kötelező)` | This field takes values, and filling it is optional. | `Ha több értéket adsz meg, vesszővel válaszd el őket.` | If several value [accusative singular] you-give [informal], with-comma separate [definite imperative] them. | 140 / fits, 2 | 1 | ok |  |
| tr | `Değerler (isteğe bağlı)` | A field for the values this blank can take. Filling it in is optional. | `Birden çok değeri virgülle ayırarak yazabilirsin.` | More-than-one value[accusative] comma-with separating you-can-write [informal 'sen' form] | 135 / fits, 2 | 1 | ok |  |
| he | `ערכים אפשריים (לא חובה)` | Optional: the possible values for this field. | `אם יש כמה ערכים, הפרד ביניהם בפסיק.` | if there-are several values, separate [imperative, masc. sg.] between-them with-comma. | 146 / fits, 1 | 1 | ok |  |
| ar, ar-SA | `قيم جاهزة (اختياري)` | Preset values to pick from go here, and the field can be left empty. | `افصل بين القيم الجاهزة بفاصلة إنجليزية «,» لا عربية «،».` | separate [imperative, masc. sg.] between the-values the-ready-made with-comma English [fem. adj.] «,» not Arabic [one] «،». | 104 / fits, 2 | 2 | ok | Round 2: says English comma and shows both marks. Round 1 said only the comma with «,», and its reader typed ، (U+060C). |
| fa | `گزینه‌ها (اختیاری)` | Optional: the choices offered for this field. | `گزینه‌ها را با ویرگول انگلیسی «,» از هم جدا کنید.` | options [object marker 'rā'] with comma English «,» from each-other separate do [polite/plural imperative]. | 89 / fits, 2 | 1 | ok | Names the English comma and shows «,», since the Persian keyboard's comma is ،. |
| ur, ur-PK | `ممکنہ قدریں (اختیاری)` | Optional: the possible values for this field. | `کئی قدریں ہوں تو انہیں انگریزی کاما (,) سے الگ کریں۔` | several values be [subjunctive] then them English comma (,) with separate do [polite imperative]۔ | 118 / fits, 1 | 1 | see note | Names the English comma and shows (,), since Urdu's list mark is ،. Reader: قدریں is the usual software word for values but bookish (it also means moral values). |
| hi | `संभावित मान (वैकल्पिक)` | Optional: the possible values for this blank. | `कई मान हों तो उन्हें अल्पविराम (,) से अलग करें।` | several values be [subjunctive] then them comma (,) with separate do [polite imperative]। | 121 / fits, 2 | 1 | ok |  |
| mr, mr-IN | `जागेचे पर्याय (ऐच्छिक)` | Optional: the choices for this blank. | `अनेक पर्याय असल्यास ते स्वल्पविरामाने (,) वेगळे करा.` | many options being-if [conditional], they comma-by (,) separate do [polite imperative]. | 110 / fits, 2 | 1 | ok |  |
| bn, bn-BD | `বেছে নেওয়ার তালিকা (ঐচ্ছিক)` | An optional field for a list of options to choose from. | `তালিকায় একাধিক মান লিখলে কমা (,) দিয়ে আলাদা করুন।` | In-the-list [locative] more-than-one value if-write [conditional participle] comma (,) with separate do [polite imperative]. | 165 / fits, 2 | 3 | ok | Round 3 placeholder, a list to pick from (round 1's পূরণের বিকল্প read as an alternative to filling in, round 2's বেছে নেওয়ার মান as the worth of choosing). |
| gu, gu-IN | `ભરવાના વિકલ્પ (મરજિયાત)` | Options to fill in with; you may leave it empty. | `એકથી વધુ વિકલ્પ હોય તો અલ્પવિરામ (,) વડે અલગ કરો.` | one-than more option be-if then comma (,) by separate do [imperative]. | 143 / fits, 2 | 1 | ok |  |
| pa, pa-IN | `ਚੁਣਨ ਲਈ ਮੁੱਲ (ਵਿਕਲਪਿਕ)` | Values to choose from; you may leave it empty. | `ਇੱਕ ਤੋਂ ਵੱਧ ਮੁੱਲ ਹੋਣ ਤਾਂ ਕਾਮੇ (,) ਨਾਲ ਵੱਖ ਕਰੋ।` | one than more values be-[subjunctive] then comma [oblique] (,) with separate do [imperative]. | 130 / fits, 1 | 1 | ok |  |
| or, or-IN | `ବାଛିବା ପାଇଁ ଉତ୍ତର (ଇଚ୍ଛାଧୀନ)` | Answers that can be picked to fill the blank go here, and the field can be left empty. | `ବାଛିବା ପାଇଁ ଏକାଧିକ ଉତ୍ତର ଦେଲେ ସେଗୁଡ଼ିକୁ କମା (,) ଦେଇ ଅଲଗା କରନ୍ତୁ।` | choosing for multiple answer if-[you]-give [conditional], them [acc.] comma (,) giving separate do [polite imperative]। | 170 / fits, 2 | 2 | ok | Round 2 (round 1's ସମ୍ଭାବ୍ୟ ମୂଲ୍ୟ read as estimated price). |
| ta, ta-IN | `புலத்தின் தேர்வுகள் (விரும்பினால்)` | Choices for this field; optional. | `பல தேர்வுகளைக் காற்புள்ளி (,) இட்டுப் பிரிக்கலாம்.` | many choices-[accusative] comma (,) put-having separate-may [permissive]. | 197 / fits, 2 | 1 | ok | Widest placeholder, 197 pt; it fits the rendered field with little to spare. |
| te, te-IN | `నింపేందుకు ఎంపికలు (ఐచ్ఛికం)` | Options to fill in with; optional. | `ఒకటి కంటే ఎక్కువ ఎంపికలు ఉంటే, వాటి మధ్య కామా (,) పెట్టండి.` | one than more options be-if, them between comma (,) put [polite imperative]. | 177 / fits, 2 | 1 | ok |  |
| kn, kn-IN | `ಭರ್ತಿ ಮಾಡಲು ಆಯ್ಕೆಗಳು (ಐಚ್ಛಿಕ)` | Options to fill in with; optional. | `ಒಂದಕ್ಕಿಂತ ಹೆಚ್ಚು ಆಯ್ಕೆಗಳಿದ್ದರೆ ಅವುಗಳ ನಡುವೆ ಅಲ್ಪವಿರಾಮ (,) ಹಾಕಿ.` | one-than more options-be-if [conditional] them-of between comma (,) put [polite imperative]. | 181 / fits, 2 | 1 | ok |  |
| ml, ml-IN | `ചോയ്‌സുകൾ (ഐച്ഛികം)` | This second box is for the list of choices for this field, and I can leave it empty. | `ഒന്നിലധികം ചോയ്‌സുകൾ കോമ (,) ഇട്ട് വേർതിരിക്കുക.` | more-than-one choices comma (,) put [conjunctive participle: 'having put'] separate [imperative/polite instruction form] | 140 / fits, 2 | 2 | ok | Round 2 within the length budget: round 1's പൂരിപ്പിക്കാനുള്ള ഓപ്ഷനുകൾ (നിർബന്ധമില്ല) measured 257 pt and was cut off with an ellipsis in the rendered field. |
| th | `ค่าให้เลือก (ไม่บังคับ)` | Values to choose from (optional). The user may list the choices for this field, or leave it empty. | `หากมีค่าให้เลือกหลายค่า ให้คั่นด้วยเครื่องหมายจุลภาค (,)` | if there-are value(s) for-to-choose many value(s) [classifier repeat], [polite imperative] separate with mark comma (,) | 116 / fits, 2 | 1 | ok | Thai lists with spaces, so the comma is named and shown as (,). No end punctuation, as the app's Thai tips. |
| vi | `Giá trị để chọn (nếu có)` | Values to choose from (if any). The user may type the choices, and the field can be left empty. | `Bạn có thể nhập nhiều giá trị để chọn, cách nhau bằng dấu phẩy.` | you can enter many value to choose, separate each-other by mark comma. | 143 / fits, 2 | 1 | ok |  |
| id | `Pilihan isian (opsional)` | Fill-in choices (optional). The user may type the options for this field, or leave it empty. | `Anda dapat menulis beberapa pilihan yang dipisahkan dengan koma.` | you [formal] can write several choice(s) which are-separated [passive] with comma. | 135 / fits, 2 | 1 | ok |  |
| ms | `Nilai pilihan (jika ada)` | Choice values (if any). The user may type the values that can be picked, or leave it empty. | `Anda boleh menulis beberapa nilai yang dipisahkan dengan koma.` | you [formal] can write several value(s) which are-separated [passive] with comma. | 129 / fits, 2 | 1 | ok |  |
| fil | `Mapipiling sagot (opsyonal)` | Answers that can be chosen (optional). The user may type the possible answers for this field, or leave it empty. | `Kung higit sa isa ang mapipiling sagot, paghiwalayin ng kuwit.` | if more than one [topic marker] can-be-chosen answer, separate [imperative, object focus] with [instrumental 'ng'] comma. | 167 / fits, 2 | 1 | ok |  |
| sw | `Majibu ya kuchagua (hiari)` | Answers to choose from (optional). The user may type the possible answers, or leave it empty. | `Ukiweka majibu zaidi ya moja, yatenganishe kwa koma.` | if-you-put [conditional] answers more of one, them-separate [imperative + object marker] by comma. | 159 / fits, 2 | 1 | ok |  |
| ja | `入力候補（任意）` | An optional field where you list the candidate values offered for this input item. 入力候補 is also the everyday word for autocomplete suggestions, which fits this meaning. | `候補を複数入れるときは、半角カンマ「,」で区切ってください。` | candidates [object] multiple put-in when [topic], half-width comma 「,」 with separate please [polite request ～てください]. | 88 / fits, 2 | 1 | ok | Names the half-width comma and shows 「,」, since Japanese lists with 、. Reader: 入力候補 is also the word for typing suggestions, which fits keys offered to tap. |
| ko | `골라 쓸 값 (선택 사항)` | Values to pick from go here, and the field is optional. | `골라 쓸 값은 쉼표(,)로 구분해 여러 개 넣을 수 있습니다.` | pick-and use [adnominal] value [topic] comma(,) with separate-[connective] several [counter] put can [formal -습니다]. | 114 / fits, 2 | 2 | ok | Round 2 (round 1's (선택) right after 고를 수 있는 read for a moment as choose). |
| zh-Hans | `候选内容（选填）` | An optional field for the candidate options of this item. | `可输入多个候选内容，用英文逗号「,」隔开。` | can input multiple candidate contents, use English comma 「,」 to separate. | 88 / fits, 2 | 1 | ok | Names the English comma and shows 「,」, since Chinese lists with 、 or ，. |
| zh-Hant | `候選內容（選填）` | An optional field for the candidate options of this item. | `可輸入多個候選內容，以半形逗號「,」分隔。` | can input multiple candidate contents, with half-width comma 「,」 separate [以…分隔 = 'separate by means of']. | 88 / fits, 2 | 1 | ok | Names the half-width comma and shows 「,」, since Chinese lists with 、 or ，. |
| it | `Valori proposti (opzionale)` | An optional field for the values that will be offered as suggestions. | `Puoi inserire più valori separandoli con una virgola.` | you-can [informal tu] insert several values separating-them [gerund + clitic] with a comma. | 159 / fits, 2 | 1 | ok |  |
| ca | `Valors proposats (opcional)` | An optional field for the values that will be suggested. | `Pots escriure diversos valors separant-los amb una coma.` | you-can [informal tu] write several values separating-them [gerund + enclitic -los] with a comma. | 166 / fits, 2 | 1 | ok |  |
| es, es-ES, es-MX | `Valores posibles (opcional)` | An optional field listing the possible values for this item. | `Puedes escribir varios valores separados por comas.` | you-can [informal tú] write several values separated by commas. | 163 / fits, 2 | 1 | ok |  |
| pt, pt-BR | `Valores possíveis (opcional)` | An optional field for the possible values this fill-in field can take, such as a list of options. | `Você pode digitar vários valores separados por vírgula.` | You can type several values separated [masc. plural, agrees with 'valores'] by comma [singular, no article, the usual Brazilian phrasing] | 169 / fits, 2 | 1 | ok |  |
| pt-PT | `Valores possíveis (opcional)` | An optional field for the possible values this fill-in field can take, such as a list of options. | `Pode escrever vários valores separados por vírgulas.` | [You, polite form implied by the verb] can write several values separated [masc. plural] by commas [plural, the usual European phrasing] | 169 / fits, 2 | 1 | ok |  |
| fr, fr-FR, fr-CA | `Liste de choix (facultatif)` | A list of choices goes here, and the field is optional. | `Séparez les choix de la liste par une virgule.` | Separate [imperative, vous] the choices of the list by a comma. | 151 / fits, 2 | 2 | ok | Round 2 (round 1's Valeurs au choix also read as any values you like). vous follows the fill-in tip (Ajoutez). |

## The editor's menu button (board ASG124)

The label of the editor's menu button that opens the fill-ins menu (iPhone, iPad and Mac), in `Cutling/<locale>.lproj/Localizable.strings`, written and checked back on 2026-11-21. It replaces `"Add Fill-in or Date"` in `placeholderMenu` (`Cutling/TextDetailView.swift`), since the menu now holds the blank, its choices, the date, the time, the cursor, the clipboard and more kinds behind its last item, not only blanks and dates. The old key stays in every file.

| Brief key | `.strings` key | Where |
|---|---|---|
| A1 `menu` (remade) | `"Add Fill-in"` | label of the menu button with the curly-braces icon, under Paste from Clipboard |

What the writers were told it must say: tapping it lets the person add a fill-in to the snippet's text; it names what the menu adds with the locale's existing word for a blank or fill-in and says nothing about a date; it starts from the locale's old label, keeps its verb and its word for the blank, and drops the date part (a label that named no date stays when it still fits); it follows the locale's button-label convention; at most about 28 Latin, Cyrillic or Greek characters, 14 CJK, 22 Indic, Thai, Arabic or Hebrew.

Made as the strings above: one writer per batch of up to four languages (14 batches, each a separate `claude -p` process with no tools) got that brief, the language and the locale's existing words on that screen (the old label, the menu's heading and items, the row above, another button, the tip title), never an English string. A separate reader per batch of about seven languages (8 batches), told where the button sits and shown the menu it opens in the same language but not what the label should say, wrote a literal rendering, what a native user expects the button to do, whether it reads as opening the whole menu or adding one item, and whether it is natural. Lines flagged for anything besides scope went to fresh writers with the reader's point: hi, bn, pa and or in round 2, since the bare blank word read as inserting empty space; sw, fil and vi in rounds 2 and 3, over Title Case and readings as "add space", "vacancies" or a gap. Each new line was read again by a fresh reader. Round is the round whose line ships.

Scope is the reader's answer. Where a locale's word for the blank is also item 1's noun (field, поле, campo, champ, रिक्त स्थान, 入力項目), 32 of 54 readers took the label as adding item 1 only, not as opening a menu of kinds. The card asked for each locale's existing blank word, so those lines keep it; Check "scope" means nothing else was wrong. The four locales whose old label said placeholder (de, nl, da, nb) were all read as covering the whole menu. English `Add Fill-in` beside `Fill-in Field` shares its noun the same way.

Width pt is the label at 17 pt regular, the iOS form row's body font, measured with the system font on macOS, with the old label's width in brackets. Three labels are wider than their old ones (hi, bn, or); the widest, Odia's 207 pt, is narrower than the old Filipino and Malayalam labels (237 pt) that already showed in the same row. On the Mac the button is fixed-size at 13 pt, where the widest new label is 162 pt and the widest old one was 188 pt. No locale was rendered on a device or simulator.

Readers' asides about other strings on that screen, outside this card: Serbian's row above, `Nalepi iz privremene memorije`, is Latin script among Cyrillic; zh-Hant's row above says 剪貼板 where Taiwan's iOS says 剪貼簿; Malayalam spells clipboard ക്ലിപ്ബോർഡ് in the row above and ക്ലിപ്പ്ബോർഡ് in the menu.

| Locale | Label | Read back as | Scope | Width pt (old) | Round | Check | Note |
|---|---|---|---|---|---|---|---|
| en, en-AU, en-CA, en-GB, en-IN | `Add Fill-in` |  |  | 77 (137) | given | given | Given in the card; not back-checked. |
| de, de-DE | `Platzhalter einfügen` | Placeholder [singular or plural, same form] insert [infinitive] | whole menu | 152 (152) | 1 | ok | Old label kept: it named no date, and its reader took Platzhalter as covering every item. |
| nl, nl-NL | `Voeg plaatshouder in` | Join [imperative, split from the separable verb 'invoegen'] place-holder in | whole menu | 161 (161) | 1 | ok | Old label kept, as de. |
| da | `Indsæt pladsholder` | Insert/paste [imperative] place-holder [singular, indefinite] | whole menu | 147 (147) | 1 | ok | Old label kept, as de. |
| sv | `Infoga fält` | Insert [imperative] field [singular or plural, same form] | item 1 | 76 (165) | 1 | scope | Reader: an everyday reader takes fält as item 1's box; only Word users count a date as a fält. |
| nb | `Sett inn plassholder` | Put [imperative] in place-holder [singular, indefinite] | whole menu | 151 (151) | 1 | ok | Old label kept, as de. |
| fi | `Lisää kenttä` | Add [imperative] field [singular, nominative total object] | item 1 | 91 (206) | 1 | scope | Reader: a date or the cursor spot is not a kenttä to a normal reader. |
| et | `Lisa väli` | Add [imperative, 2nd person singular] field [singular, nominative total object] | item 1 | 60 (155) | 1 | scope | As fi. |
| lt | `Įterpti lauką` | Insert [infinitive] field [accusative singular] | whole menu | 89 (165) | 1 | ok | Reader: same noun as item 1, a weak fit for the cursor position. |
| lv | `Ievietot lauku` | Insert [infinitive] field [accusative singular] | whole menu | 101 (189) | 1 | ok | Reader: same noun as item 1, so it points a little toward it. |
| pl | `Wstaw pole` | Insert [imperative, 2nd singular] field [accusative singular] | whole menu | 88 (154) | 1 | ok | Reader: as in Word's Wstaw pole; points a little toward item 1. |
| cs | `Vložit pole` | Insert [infinitive] field(s) [accusative; singular and plural are the same form] | whole menu | 80 (175) | 1 | ok | Reader: pole reads as singular or plural, which helps it cover the group. |
| sk | `Vložiť pole` | Insert [infinitive] field [accusative singular] | whole menu | 80 (179) | 1 | ok | Reader: points a little toward item 1. |
| sl, sl-SI | `Vstavi polje` | Insert [imperative, 2nd singular] field [accusative singular] | whole menu | 86 (160) | 1 | ok | Reader: as in Word's Vstavi polje; points a little toward item 1. |
| hr | `Umetni polje` | Insert [imperative, 2nd singular] field [accusative singular] | whole menu | 96 (164) | 1 | ok | Reader: points a little toward item 1. |
| sr | `Додај поље` | Add [imperative] field | item 1 | 92 (178) | 1 | scope | All Cyrillic. Reader also flagged the row above, Nalepi iz privremene memorije, as Latin script, outside this card. |
| bg | `Добави поле` | Add [imperative] field | item 1 | 102 (176) | 1 | scope | Reader: a date, the time, the cursor or the clipboard is not a поле to an ordinary user. |
| ru | `Добавить поле` | Add [infinitive] field | item 1 | 119 (193) | 1 | scope | As bg. |
| uk | `Додати поле` | Add [infinitive] field | item 1 | 102 (175) | 1 | scope | As bg. |
| el | `Προσθήκη πεδίου` | Addition [verbal noun] of-field [genitive singular] | item 1 | 136 (173) | 1 | scope | The old label was a verbless noun phrase, the tip title's own words (Πεδία και ημερομηνίες), so the writer made it an action noun like the row above, Επικόλληση από πρόχειρο. |
| ro | `Adaugă un câmp` | Add [imperative, 2nd person singular] a field | item 1 | 128 (197) | 1 | scope | Old label's words kept; reader finds the un slightly wordier than Adaugă câmp. |
| hu | `Mező beszúrása` | Field insertion [verbal noun] | item 1 | 125 (218) | 1 | scope | Reader: outside Word habits, mező promises only item 1. |
| tr | `Alan Ekle` | Field Add [imperative, 2sg] | whole menu | 69 (150) | 1 | ok | Title Case follows the old label and the row above (Panodan Yapıştır). |
| he | `הוסף שדה` | add [imperative, masc. sg.] field | whole menu | 74 (141) | 1 | ok | Reader: cursor position fits the word least well. |
| ar, ar-SA | `إدراج حقل` | inserting [verbal noun] (of) field [indefinite] | whole menu | 68 (120) | 1 | ok | Reader: cursor position is a stretch for حقل. |
| fa | `افزودن فیلد` | adding [infinitive] -of field | whole menu | 77 (127) | 1 | ok | Reader: cursor position fits فیلد loosely. |
| ur, ur-PK | `خانہ شامل کریں` | box/cell included do [polite imperative] | item 1 | 108 (158) | 1 | scope | Reader: خانہ is a concrete box, item 1's own noun. |
| hi | `भरने के लिए रिक्त स्थान डालें` | filling for blank space put-in [polite imperative] | item 1 | 175 (150) | 2 | scope | Round 2 adds भरने के लिए (to fill), since round 1's bare रिक्त स्थान डालें read as inserting a space. Reader calls it long for a button; 175 pt fits. |
| mr, mr-IN | `भरायची जागा घाला` | to-be-filled [gerundive, fem.] place put [imperative, polite pl.] | item 1 | 117 (196) | 1 | scope | Reader: it is item 1 word for word plus the verb. |
| bn, bn-BD | `পূরণের জন্য শূন্যস্থান বসান` | filling-of for blank-space place [polite imperative, apni form] | item 1 | 176 (157) | 2 | scope | Round 2 adds পূরণের জন্য (for filling), as hi. Reader calls it long for a button. |
| gu, gu-IN | `ભરવાની જગ્યા ઉમેરો` | to-fill [infinitive, genitive feminine] place add [imperative, polite/plural તમે form] | item 1 | 135 (195) | 1 | scope | Reader: it is item 1 word for word plus the verb. |
| pa, pa-IN | `ਭਰਨ ਲਈ ਖਾਲੀ ਥਾਂ ਜੋੜੋ` | filling for empty place add [imperative, tusi form] | item 1 | 142 (142) | 2 | scope | Round 2 is item 1's full phrase plus the verb, since round 1's bare ਖਾਲੀ ਥਾਂ ਜੋੜੋ read as adding empty space. |
| or, or-IN | `ପୂରଣ ପାଇଁ ଶୂନ୍ୟସ୍ଥାନ ଯୋଡ଼ନ୍ତୁ` | filling for blank-space add [polite imperative] | item 1 | 207 (197) | 2 | scope | Round 2 is item 1's full phrase plus the verb, as pa. Reader calls ପୂରଣ ପାଇଁ slightly clipped; it is item 1's existing wording. Widest label, 207 pt. |
| ta, ta-IN | `புலத்தைச் சேர்` | field-[accusative] add [imperative, informal singular] | whole menu | 107 (213) | 1 | ok | Reader: புலம் is slightly formal. |
| te, te-IN | `ఫీల్డ్ జోడించు` | field [English loanword] add [imperative, informal singular] | whole menu | 95 (165) | 1 | ok |  |
| kn, kn-IN | `ಫೀಲ್ಡ್ ಸೇರಿಸಿ` | field [English loanword] add [imperative, polite/plural] | whole menu | 90 (206) | 1 | ok |  |
| ml, ml-IN | `ഫീൽഡ് ചേർക്കുക` | field add[-uka form: the infinitive used as the polite command] | item 1 | 134 (237) | 1 | scope | Reader also noted the row above spells clipboard ക്ലിപ്ബോർഡ് and the menu ക്ലിപ്പ്ബോർഡ്, outside this card. |
| th | `แทรกช่องกรอก` | insert slot/box fill-in[verb] | item 1 | 107 (166) | 1 | scope |  |
| vi | `Chèn chỗ trống cần điền` | Insert[bare verb, command] place empty need fill-in | item 1 | 187 (209) | 3 | scope | Round 3: sentence case and item 1's full phrase. Round 1's Title Case (the old label's) read as an English habit; round 2's bare chỗ trống read as a gap. |
| id | `Sisipkan Isian` | Insert[imperative, -kan] Fill-in[noun: isi 'fill' + -an, 'thing filled in'] | whole menu | 102 (204) | 1 | ok | Title Case follows the old label and the row above (Tempel dari Papan Klip). Reader: Isian shares its root with the heading's Terisi. |
| ms | `Sisipkan Medan` | Insert[imperative, -kan] Field | item 1 | 120 (207) | 1 | scope | Reader calls Medan stiff; it is the app's word (item 1 Medan untuk Diisi). |
| fil | `Magdagdag ng patlang` | To-add[actor-focus mag- infinitive, used as a command] [marker 'a'] blank/space | item 1 | 176 (237) | 3 | see note | UNSURE. Round 3 is the old label without o petsa. Round 3's reader: patlang alone can read as an empty space; round 1's reader wanted the row above's object focus (Idagdag ang patlang); round 2's reader found ang odd for a new blank. Item 1's full phrase, Magdagdag ng patlang na pupunan, would end the gap reading. |
| sw | `Chomeka nafasi ya kujaza` | Insert[imperative] space/slot of to-fill[infinitive] | item 1 | 196 (198) | 3 | scope | Round 3. Round 1's Ongeza Nafasi ya Kujaza read as add space or make room, in English-style Title Case; round 2's verbless Nafasi za kujaza read as job vacancies. Chomeka is the usual Swahili word for insert; sentence case as the app's Ongeza kutoka Ubao wa Kunakili. Reader: ya kujaza mostly settles the space reading. |
| ja | `入力項目を挿入` | input-item [object particle を] insert [verbal noun, used as a command] | item 1 | 110 (157) | 1 | scope | Reader: it repeats item 1 word for word. |
| ko | `입력란 삽입` | input-field insertion [Sino-Korean verbal noun] | item 1 | 78 (112) | 1 | scope | Reader: 입력란 differs from item 1's 칸 (직접 입력하는 칸); the old label and the tip title say 입력란. |
| zh-Hans | `插入填写项` | insert [verb] fill-in [verb] item [noun] | item 1 | 78 (126) | 1 | scope | Reader: it repeats item 1 exactly. |
| zh-Hant | `插入填寫欄位` | insert [verb] fill-in [verb] field [noun] | item 1 | 94 (141) | 1 | scope | Reader: it repeats item 1 exactly. Reader also noted the row above says 剪貼板 where Taiwan's iOS says 剪貼簿, outside this card. |
| it | `Inserisci campo` | Insert [imperative, 2nd sg] field [no article] | whole menu | 119 (119) | 1 | ok | Old label kept: it named no date. |
| ca | `Insereix un camp` | Insert [imperative, 2nd sg] a field | whole menu | 129 (129) | 1 | ok | Old label kept, as it. |
| es, es-ES | `Insertar campo` | Insert [infinitive] field [no article] | whole menu | 115 (115) | 1 | ok | Old label kept, as it. es-ES shares the line (its item 1 says rellenar) and was not read on its own. |
| es-MX | `Insertar campo` | Insert [infinitive] field | item 1 | 115 (115) | 1 | scope | Old label kept. Reader: campo points to item 1, Campo para llenar. |
| pt, pt-BR | `Inserir campo` | Insert [infinitive] field | item 1 | 104 (104) | 1 | scope | Old label kept. Reader: campo points to item 1. |
| pt-PT | `Inserir campo` | Insert [infinitive] field | item 1 | 104 (104) | 1 | scope | Old label kept, as pt. |
| fr, fr-FR | `Insérer un champ` | Insert [infinitive] a field | item 1 | 132 (226) | 1 | scope | Reader: un champ points to item 1, Champ à remplir. |
| fr-CA | `Insérer un champ` | Insert [infinitive] a field | item 1 | 132 (226) | 1 | scope | As fr. |

## The Variables list, second batch (board ASG124)

The nine variables of commit c98f32ab (week number, time zone, greeting by hour, language, country, currency, link and email on the clipboard, counter), the three greetings the greeting variable types, the group headers, two grey hints the first batch missed, and the rows not built yet (they will show greyed with Soon once their engine lands), in `Cutling/<locale>.lproj/Localizable.strings`, written and checked back on 2026-11-22.

What each key had to say. The writers got this, never an English string. Budgets are in Latin characters; CJK takes half, Indic, Thai and Arabic script about three quarters.

| Brief key | `.strings` key | Role and meaning | Budget |
|---|---|---|---|
| G1 | `"Me and Contacts"` | group header: the person's own details and a contact they pick (hidden group) | 26 |
| G2 | `"Places"` | group header: city, weather now, sunset (hidden group) | 20 |
| G3 | `"Calendar"` | group header: calendar and reminders, named as iOS names the Calendar app (hidden group) | 20 |
| G4 | `"Device"` | group header: values read from the device's settings (language, region, currency) | 20 |
| G5 | `"Math and Other"` | group header: counter, number in words, a Shortcuts value | 26 |
| V1 | `"Week Number"` | variable and pill: the ISO week of the year (sample 47) | 22 |
| V2 | `"Time Zone"` | variable and pill: the current time zone's name | 22 |
| V3 | `"Greeting by Hour"` | variable and pill: types GR1, GR2 or GR3 by the hour; names the variable, not a greeting | 26 |
| V4 | `"Language"` | variable and pill: the device language's name | 18 |
| V5 | `"Country"` | variable and pill: the device region, written as a country name | 18 |
| V6 | `"Currency"` | variable and pill: the region's three-letter currency code | 18 |
| V7 | `"Link on Clipboard"` | variable and pill: the web link found in the clipboard's text | 26 |
| V8 | `"Email on Clipboard"` | variable and pill: the email address found in the clipboard's text | 26 |
| V9 | `"Counter"` | variable, and the pill of a counter with no name: goes up by one each use | 18 |
| S1 | `"What you copied"` | grey hint under the clipboard-text row: the text copied last | 24 |
| S2 | `"Where typing ends"` | grey hint under the cursor row: the cursor stays here after the cutling is typed | 24 |
| GR1 | `"Good morning"` | typed into the message as its first words, 05:00-11:59 | 20 |
| GR2 | `"Good afternoon"` | the same, 12:00-17:59 | 20 |
| GR3 | `"Good evening"` | the same, 18:00-04:59 (evening and late night) | 20 |
| R1, R1s | `"My Name"`, `"Your name"` | hidden row: my name; its hint | 20, 24 |
| R2, R2s | `"My Email"`, `"Your email"` | hidden row: my email address; its hint | 20, 24 |
| R3, R3s | `"My Phone"`, `"Your number"` | hidden row: my phone number; its hint | 20, 24 |
| R4, R4s | `"My Address"`, `"Your address"` | hidden row: my address; its hint | 20, 24 |
| R5, R5s | `"Saved Person"`, `"A contact you chose"` | hidden row: a contact chosen once and kept in the cutling; its hint | 22, 26 |
| R6, R6s | `"City"`, `"Where you are"` | hidden row: the city the person is in; its hint | 18, 24 |
| R7 | `"Weather Now"` | hidden row: the current weather (sample 21°) | 22 |
| R8 | `"Sunset"` | hidden row: today's sunset time | 18 |
| R9 | `"Next Event"` | hidden row: the next calendar event | 22 |
| R10 | `"Free Time Slots"` | hidden row: free slots in the calendar | 24 |
| R11, R11s | `"Today’s Agenda"`, `"Your events"` | hidden row: today's events; its hint | 22, 24 |
| R12, R12s | `"Reminders Due"`, `"Your reminders"` | hidden row: reminders that are due; its hint | 22, 24 |
| R13, R13s | `"Selected Text"`, `"Text you selected"` | hidden row: the selected text; its hint | 22, 26 |
| R14 | `"Number in Words"` | hidden row: a number written out (sample forty-two) | 24 |
| R15, R15s | `"Value from a Shortcut"`, `"A shortcut’s result"` | hidden row: a value a Shortcuts shortcut returns; its hint | 26, 26 |

How each line was made: one writer per language got the brief, the language and that locale's existing Variables-list words (its words for variables, the clipboard row, the cursor row, the date rows and their group headers), never an English string, and returned each string with its own back-translation. A separate reader per batch of seven or eight languages, told only each string's role, wrote what a native reader understands and whether it is natural. Each flagged key went back to a fresh writer of that language with the reader's objection and a clearer brief (round 2). The brief now says the greeting windows are fixed by the code, so a time-of-day greeting that is wrong or stiff for most of a window gives way to the everyday greeting people write at any hour; hints describe and never ask or command; nothing is abbreviated. The new line was read again. Seven keys flagged a second time took the round-2 reader's own wording or a third writer (round 3, marked). "Read back as" is the independent reading of the string as shipped. Width is measured at 17 pt (names) or 15 pt (hints) in the system font on macOS; the widest is 261 pt (Swahili V8), inside the roughly 290 pt a row has on a 375-pt iPhone.

English: the key is the line in en, en-AU, en-CA, en-GB and en-IN (identity lines were added so every key is in every file), except that en-GB, en-AU and en-IN read `"Math and Other"` as `Maths and Other`. Locales that share a language share one line: ar and ar-SA, bn and bn-BD, de and de-DE, es and es-ES, fr and fr-FR, gu and gu-IN, kn and kn-IN, ml and ml-IN, mr and mr-IN, nl and nl-NL, or and or-IN, pa and pa-IN, pt and pt-PT, sl and sl-SI, ta and ta-IN, te and te-IN, ur and ur-PK. The hidden rows are not on screen yet (FillInSheets.swift drops rows with no engine), so they were read back but never seen in a list.

### Shown keys

| Locale | Key | String | Read back as | Check | Note |
|---|---|---|---|---|---|
| ar | G4 | الجهاز | The device | ok |  |
| ar | G5 | الرياضيات وغيرها | Mathematics and other things | ok |  |
| ar | V1 | رقم الأسبوع | Week number | ok |  |
| ar | V2 | المنطقة الزمنية | Time zone | ok |  |
| ar | V3 | تحية حسب الوقت | Greeting based on the time | ok |  |
| ar | V4 | لغة الجهاز | Device language | ok |  |
| ar | V5 | البلد | The country | ok |  |
| ar | V6 | العملة | The currency | ok |  |
| ar | V7 | رابط من الحافظة | Link from the clipboard | ok |  |
| ar | V8 | بريد إلكتروني من الحافظة | An email (address) taken from the clipboard | ok | Round 2; round 1 wrote بريد من الحافظة (بريد on its own means 'mail' or 'post' and is also the name of the Mail app, so it can read as a mail message, not an email address. بريد إلكتروني من الحافظة or عنوان بريد من الحافظة is clear.) |
| ar | V9 | عدّاد | Counter | ok |  |
| ar | S1 | آخر نص نسخته | The last text you copied | ok |  |
| ar | S2 | تابع الكتابة من هنا | Continue writing from here (an instruction) | ok |  |
| ar | GR1 | صباح الخير | Good morning | ok |  |
| ar | GR2 | مساء الخير | Good afternoon/evening (used from noon onward) | ok |  |
| ar | GR3 | مساء الخير | Good evening | ok |  |
| bg | G4 | Устройство | Device | ok |  |
| bg | G5 | Математика и още | Maths and more | ok | Round 2; round 1 wrote Математика и други ('и други' left hanging as a header sounds unfinished, like the end of a list of people. 'Математика и още' or 'Математика и други' plus a noun reads naturally.) |
| bg | V1 | Номер на седмицата | Number of the week | ok |  |
| bg | V2 | Часова зона | Time zone | ok |  |
| bg | V3 | Поздрав според часа | Greeting depending on the hour | ok |  |
| bg | V4 | Език | Language | ok |  |
| bg | V5 | Регион | Region | ok |  |
| bg | V6 | Валута | Currency | ok |  |
| bg | V7 | Линк от клипборда | Link from the clipboard | ok |  |
| bg | V8 | Имейл от клипборда | Email from the clipboard | ok |  |
| bg | V9 | Брояч | Counter | ok |  |
| bg | S1 | Последният копиран текст | The last copied text | ok |  |
| bg | S2 | Продължете да пишете тук | Continue typing here (polite instruction) | ok |  |
| bg | GR1 | Добро утро | Good morning | ok |  |
| bg | GR2 | Добър ден | Good day | ok |  |
| bg | GR3 | Добър вечер | Good evening | ok |  |
| bn | G4 | ডিভাইস | Device | ok |  |
| bn | G5 | গণিত ও অন্যান্য | Maths and others | ok |  |
| bn | V1 | সপ্তাহের নম্বর | Week's number | ok |  |
| bn | V2 | সময় অঞ্চল | Time zone | ok |  |
| bn | V3 | সময় অনুযায়ী শুভেচ্ছা | Greeting according to the time | ok |  |
| bn | V4 | ডিভাইসের ভাষা | Device's language | ok |  |
| bn | V5 | অঞ্চল | Region | ok |  |
| bn | V6 | মুদ্রা | Currency | ok |  |
| bn | V7 | ক্লিপবোর্ডের লিংক | Clipboard's link | ok |  |
| bn | V8 | ক্লিপবোর্ডের ইমেল | Clipboard's email | ok |  |
| bn | V9 | কাউন্টার | Counter | ok |  |
| bn | S1 | আপনার শেষ কপি করা টেক্সট | Your last copied text | ok |  |
| bn | S2 | এখান থেকেই লিখতে থাকুন | Keep writing from right here | ok |  |
| bn | GR1 | শুভ সকাল | Good morning | ok |  |
| bn | GR2 | হ্যালো | Hello (English loanword, casual and neutral at any hour) | ok | Round 2; round 1 wrote শুভ দুপুর (শুভ দুপুর is a calque that people rarely write. দুপুর also ends around 3–4 pm, and 4–6 pm is বিকেল, so for most of this window it names the wrong part of the day.) |
| bn | GR3 | হ্যালো | Hello | ok | Round 2; round 1 wrote শুভ সন্ধ্যা (সন্ধ্যা means dusk to early evening, roughly until 8 pm. Late at night (22:00–04:59) it is the wrong part of the day, and the night word শুভ রাত্রি is a goodnight farewell, not a greeting.) |
| ca | G4 | Dispositiu | Device | ok |  |
| ca | G5 | Matemàtiques i més | Maths and more | ok | Round 2; round 1 wrote Matemàtiques i altres ('i altres' left hanging sounds unfinished (others what?). 'Matemàtiques i més' or 'Matemàtiques i altres coses' reads naturally.) |
| ca | V1 | Número de setmana | Week number | ok |  |
| ca | V2 | Zona horària | Time zone | ok |  |
| ca | V3 | Salutació segons l’hora | Greeting depending on the time | ok |  |
| ca | V4 | Idioma | Language | ok |  |
| ca | V5 | Regió | Region | ok |  |
| ca | V6 | Moneda | Currency | ok |  |
| ca | V7 | Enllaç del porta-retalls | Link from the clipboard | ok |  |
| ca | V8 | Correu del porta-retalls | Email from the clipboard | ok |  |
| ca | V9 | Comptador | Counter | ok |  |
| ca | S1 | El text que has copiat | The text you've copied | ok |  |
| ca | S2 | Continues escrivint aquí | You keep writing here | ok |  |
| ca | GR1 | Bon dia | Good morning / good day | ok |  |
| ca | GR2 | Bona tarda | Good afternoon | see note | Kept: Bona tarda covers most of 12:00-17:59; both readers say Bon dia is usual until about 14:00. |
| ca | GR3 | Bon vespre | Good evening | ok | Round 2; round 1 wrote Bona nit (From 18:00 until about 20:00–21:00 people still say 'bona tarda' (or 'bon vespre'). 'Bona nit' that early is wrong, and it can also read as a goodnight farewell.) |
| cs | G4 | Zařízení | Device | ok |  |
| cs | G5 | Matematika a další | Maths and more | ok |  |
| cs | V1 | Číslo týdne | Week number | ok |  |
| cs | V2 | Časové pásmo | Time zone | ok |  |
| cs | V3 | Pozdrav podle denní doby | Greeting by time of day | ok |  |
| cs | V4 | Jazyk zařízení | Device language | ok |  |
| cs | V5 | Oblast zařízení | Device region | ok |  |
| cs | V6 | Měna oblasti | Currency of the region | ok |  |
| cs | V7 | Odkaz ze schránky | Link from the clipboard | ok |  |
| cs | V8 | E-mail ze schránky | Email from the clipboard | ok |  |
| cs | V9 | Počítadlo | Counter | ok |  |
| cs | S1 | Váš zkopírovaný text | Your copied text | ok |  |
| cs | S2 | Tady budete psát dál | Here you'll keep writing | ok |  |
| cs | GR1 | Dobrý den | Hello / Good day (the standard written greeting, fine in the morning) | ok | Round 2; round 1 wrote Dobré ráno ('Dobré ráno' fits the early morning, up to about 9–10. Later in the morning Czechs write 'Dobrý den', so opening a message with 'Dobré ráno' at 10:00–11:59 sounds off.) |
| cs | GR2 | Dobrý den | Good day / hello | ok |  |
| cs | GR3 | Dobrý večer | Good evening | ok |  |
| da | G4 | Enhed | Device | ok |  |
| da | G5 | Matematik og andet | Maths and other things | ok |  |
| da | V1 | Ugenummer | Week number | ok |  |
| da | V2 | Tidszone | Time zone | ok |  |
| da | V3 | Hilsen efter tidspunkt | Greeting by time of day | ok |  |
| da | V4 | Sprog | Language | ok |  |
| da | V5 | Land | Country | ok |  |
| da | V6 | Valuta | Currency | ok |  |
| da | V7 | Link i udklipsholderen | Link in the clipboard | ok | Round 2; round 1 wrote Link i udklipsholder (Without the definite form it sounds telegraphic. Danish says 'i udklipsholderen': 'Link i udklipsholderen'.) |
| da | V8 | E-mail i udklipsholderen | Email (address) in the clipboard | ok | Round 2; round 1 wrote E-mail i udklipsholder (Same as V7: it should be 'i udklipsholderen'.) |
| da | V9 | Tæller | Counter | ok |  |
| da | S1 | Det du sidst kopierede | What you last copied | ok |  |
| da | S2 | Du skriver videre her | You keep writing here | ok |  |
| da | GR1 | Godmorgen | Good morning | ok | Round 2; round 1 wrote God morgen (changed with a flagged key) |
| da | GR2 | Goddag | Good day (a little formal in a written message, but correct) | ok | Round 2; round 1 wrote God eftermiddag ('God eftermiddag' is stiff and rarely written at the start of a message, especially around 12–13. Danes write 'Goddag' or 'Hej'.) |
| da | GR3 | Godaften | Good evening | ok | Round 2; round 1 wrote God aften (changed with a flagged key) |
| de | G4 | Gerät | Device | ok |  |
| de | G5 | Mathe und Sonstiges | Maths and miscellaneous | ok |  |
| de | V1 | Kalenderwoche | Calendar week (number) | ok |  |
| de | V2 | Zeitzone | Time zone | ok |  |
| de | V3 | Gruß nach Tageszeit | Greeting by time of day | ok |  |
| de | V4 | Sprache | Language | ok |  |
| de | V5 | Region | Region | ok |  |
| de | V6 | Währung | Currency | ok |  |
| de | V7 | Link aus Zwischenablage | Link from clipboard (no article, normal for a UI label) | ok | Round 2 kept the round-1 string after a reader flag: It drops the article, which sounds clipped. German and Apple's German UI say 'aus der Zwischenablage'. |
| de | V8 | E-Mail aus Zwischenablage | Email (address) from clipboard | ok | Round 2 kept the round-1 string after a reader flag: Same as V7: 'E-Mail aus der Zwischenablage'. |
| de | V9 | Zähler | Counter | ok |  |
| de | S1 | Zuletzt kopierter Text | Last copied text | ok |  |
| de | S2 | Hier schreibst du weiter | You carry on writing here | ok |  |
| de | GR1 | Guten Morgen | Good morning | ok |  |
| de | GR2 | Guten Tag | Good day / hello | ok |  |
| de | GR3 | Guten Abend | Good evening | ok |  |
| el | G4 | Συσκευή | Device | ok |  |
| el | G5 | Αριθμοί και άλλα | Numbers and more | ok |  |
| el | V1 | Αριθμός εβδομάδας | Week number | ok |  |
| el | V2 | Ζώνη ώρας | Time zone | ok |  |
| el | V3 | Χαιρετισμός βάσει ώρας | Greeting based on the time (a bit formal, fine for a label) | ok | Round 2; round 1 wrote Χαιρετισμός της ώρας ('της ώρας' is an idiom for 'of the moment' or 'topical' (as in 'το θέμα της ώρας'), so this reads as 'the trendy greeting' rather than 'greeting that depends on the time'. 'Χαιρετισμός ανάλογα με την ώρα' says it clearly.) |
| el | V4 | Γλώσσα συσκευής | Device language | ok |  |
| el | V5 | Περιοχή συσκευής | Device region | ok |  |
| el | V6 | Νόμισμα περιοχής | Region's currency | ok |  |
| el | V7 | Σύνδεσμος προχείρου | Clipboard link | ok |  |
| el | V8 | Email προχείρου | Clipboard email | ok |  |
| el | V9 | Μετρητής | Counter | ok |  |
| el | S1 | Ό,τι αντιγράψατε | Whatever you copied | ok |  |
| el | S2 | Συνεχίζετε από εδώ | You continue from here / continue from here | ok |  |
| el | GR1 | Καλημέρα | Good morning | ok |  |
| el | GR2 | Καλησπέρα | Good afternoon/evening (the standard greeting after midday) | ok |  |
| el | GR3 | Καλησπέρα | Good evening | ok |  |
| es-MX | G4 | Dispositivo | Device | ok |  |
| es-MX | G5 | Matemáticas y más | Math and more | ok |  |
| es-MX | V1 | Número de semana | Week number | ok |  |
| es-MX | V2 | Zona horaria | Time zone | ok |  |
| es-MX | V3 | Saludo según la hora | Greeting based on the time | ok |  |
| es-MX | V4 | Idioma | Language | ok |  |
| es-MX | V5 | Región | Region | ok |  |
| es-MX | V6 | Moneda | Currency | ok |  |
| es-MX | V7 | Enlace del portapapeles | Clipboard link | ok |  |
| es-MX | V8 | Correo del portapapeles | Clipboard email | ok |  |
| es-MX | V9 | Contador | Counter | ok |  |
| es-MX | S1 | Lo último que copiaste | The last thing you copied | ok |  |
| es-MX | S2 | Sigues escribiendo aquí | You keep writing here | ok |  |
| es-MX | GR1 | Buenos días | Good morning | ok |  |
| es-MX | GR2 | Buenas tardes | Good afternoon | ok |  |
| es-MX | GR3 | Buenas noches | Good evening / good night | ok |  |
| es | G4 | Dispositivo | Device | ok |  |
| es | G5 | Matemáticas y más | Maths and more | ok |  |
| es | V1 | Número de semana | Week number | ok |  |
| es | V2 | Zona horaria | Time zone | ok |  |
| es | V3 | Saludo según la hora | Greeting based on the time | ok |  |
| es | V4 | Idioma | Language | ok |  |
| es | V5 | Región | Region | ok |  |
| es | V6 | Moneda | Currency | ok |  |
| es | V7 | Enlace del portapapeles | Clipboard link | ok |  |
| es | V8 | Correo del portapapeles | Clipboard email | ok |  |
| es | V9 | Contador | Counter | ok |  |
| es | S1 | Último texto copiado | The last text you copied. | ok | Round 2; round 1 wrote Lo último que copiaste (In Spain the perfect tense is the norm for something just done, and R5s/R13s already use it. 'Lo último que has copiado' matches.) |
| es | S2 | Donde sigues escribiendo |  | see note | Round 3: the round-2 reader's own suggested wording, set by the orchestrator; not read again. |
| es | GR1 | Buenos días | Good morning | ok |  |
| es | GR2 | Hola | Hi. | ok | Round 2; round 1 wrote Buenas tardes (In Spain 'buenos días' lasts until lunch, around 14:00. A message starting 'Buenas tardes' at 12:00–13:59 sounds wrong.) |
| es | GR3 | Hola | Hi. | ok | Round 2; round 1 wrote Buenas noches (In Spain 'buenas tardes' runs until roughly 20:00–21:00 (dark or dinnertime). 'Buenas noches' at 18:00–20:00 is early and can sound like a sign-off.) |
| et | G4 | Seade | Device | ok |  |
| et | G5 | Matemaatika ja muu | Maths and other stuff | ok |  |
| et | V1 | Nädala number | Week number | ok |  |
| et | V2 | Ajavöönd | Time zone | ok |  |
| et | V3 | Tervitus kellaaja järgi | Greeting by time of day | ok |  |
| et | V4 | Seadme keel | Device language | ok |  |
| et | V5 | Seadme piirkond | Device region | ok |  |
| et | V6 | Valuuta | Currency | ok |  |
| et | V7 | Lõikelaua link | Clipboard link | ok |  |
| et | V8 | Lõikelaua e-post | Clipboard email | ok |  |
| et | V9 | Loendur | Counter | ok |  |
| et | S1 | Tekst, mille kopeerisid | The text you copied | ok |  |
| et | S2 | Jätkad kirjutamist siit | You continue writing from here | ok |  |
| et | GR1 | Tere hommikust | Good morning | ok |  |
| et | GR2 | Tere päevast | Good day / good afternoon | ok |  |
| et | GR3 | Tere õhtust | Good evening | ok |  |
| fa | G4 | دستگاه | Device | ok |  |
| fa | G5 | ریاضی و موارد دیگر | Math and other items | ok |  |
| fa | V1 | شماره هفته | Week number | ok |  |
| fa | V2 | منطقه زمانی | Time zone | ok |  |
| fa | V3 | سلام متناسب با ساعت | Greeting suited to the hour | ok |  |
| fa | V4 | زبان دستگاه | Device language | ok |  |
| fa | V5 | کشور | Country | ok |  |
| fa | V6 | واحد پول | Currency | ok |  |
| fa | V7 | پیوند در کلیپ‌بورد | Link on the clipboard | ok |  |
| fa | V8 | ایمیل در کلیپ‌بورد | Email on the clipboard | ok |  |
| fa | V9 | شمارنده | Counter | ok |  |
| fa | S1 | آخرین متنی که کپی کردید | The last text you copied | ok |  |
| fa | S2 | از همین‌جا ادامه دهید | Continue from right here | ok |  |
| fa | GR1 | صبح بخیر | Good morning. | ok |  |
| fa | GR2 | وقت بخیر | Good day, a neutral polite greeting that works at any hour. | ok | Round 2; round 1 wrote روز بخیر (changed with a flagged key) |
| fa | GR3 | وقت بخیر | Good day, a neutral polite greeting that works at any hour. It is used in the evening as well. | ok | Round 2; round 1 wrote شب بخیر ('شب بخیر' is mostly said when parting or going to bed, so it reads like a sign-off at the start of a message, especially at 18:00–20:00 when people say 'عصر بخیر'. 'شبتون بخیر' or 'عصر بخیر' (early evening) works better as an opener.) |
| fi | G4 | Laite | Device | ok |  |
| fi | G5 | Matematiikka ja muuta | Maths and other things. | ok | Round 2; round 1 wrote Matematiikka ja muut (Nominative plural 'muut' means 'the others' (other people or items). 'And more' is the partitive: 'Matematiikka ja muuta'.) |
| fi | V1 | Viikkonumero | Week number | ok |  |
| fi | V2 | Aikavyöhyke | Time zone | ok |  |
| fi | V3 | Vuorokaudenajan tervehdys | Time-of-day greeting | ok |  |
| fi | V4 | Laitteen kieli | Device language | ok |  |
| fi | V5 | Laitteen alue | Device region | ok |  |
| fi | V6 | Alueen valuutta | Region's currency | ok |  |
| fi | V7 | Leikepöydän linkki | Clipboard link | ok |  |
| fi | V8 | Leikepöydän sähköposti | Clipboard email | ok |  |
| fi | V9 | Laskuri | Counter | ok |  |
| fi | S1 | Kopioimasi teksti | The text you copied | ok |  |
| fi | S2 | Jatka kirjoitusta tästä | Continue writing from here (a command) | ok |  |
| fi | GR1 | Hyvää huomenta | Good morning | ok |  |
| fi | GR2 | Hyvää päivää | Good day (fairly formal) | ok |  |
| fi | GR3 | Hyvää iltaa | Good evening | ok |  |
| fil | G4 | Device | Device | ok |  |
| fil | G5 | Math at iba pa | Math and more | ok |  |
| fil | V1 | Numero ng linggo | Week number | ok |  |
| fil | V2 | Time zone | Time zone | ok |  |
| fil | V3 | Bati ayon sa oras | Greeting according to the time | ok |  |
| fil | V4 | Wika | Language | ok |  |
| fil | V5 | Rehiyon | Region | ok |  |
| fil | V6 | Currency | Currency | ok |  |
| fil | V7 | Link sa clipboard | Link on the clipboard | ok |  |
| fil | V8 | Email sa clipboard | Email on the clipboard | ok |  |
| fil | V9 | Counter | Counter | ok |  |
| fil | S1 | Ang huli mong kinopya | The last thing you copied | ok |  |
| fil | S2 | Dito ka magta-type | This is where you'll type | ok |  |
| fil | GR1 | Magandang umaga | Good morning | ok |  |
| fil | GR2 | Magandang hapon | Good afternoon | ok |  |
| fil | GR3 | Magandang gabi | Good evening | ok |  |
| fr-CA | G4 | Appareil | Device | ok |  |
| fr-CA | G5 | Maths et divers | Math and miscellaneous | ok |  |
| fr-CA | V1 | Numéro de semaine | Week number | ok |  |
| fr-CA | V2 | Fuseau horaire | Time zone | ok |  |
| fr-CA | V3 | Salutation selon l’heure | Greeting based on the time of day. | ok | Round 2; round 1 wrote Salutation du moment ('du moment' usually means 'currently popular' (la chanson du moment), so a reader may not see that the greeting depends on the hour. 'Salutation selon l'heure' is clear.) |
| fr-CA | V4 | Langue | Language | ok |  |
| fr-CA | V5 | Pays | Country | ok |  |
| fr-CA | V6 | Devise | Currency | ok |  |
| fr-CA | V7 | Lien du presse-papiers | Link from the clipboard | ok |  |
| fr-CA | V8 | Courriel du presse-papiers | Email (address) from the clipboard | ok |  |
| fr-CA | V9 | Compteur | Counter | ok |  |
| fr-CA | S1 | Ce que vous avez copié | What you copied | ok |  |
| fr-CA | S2 | Vous tapez la suite ici | You type the rest here | ok |  |
| fr-CA | GR1 | Bonjour | Hello / good morning | ok |  |
| fr-CA | GR2 | Bonjour | Hello. In Quebec it is used all afternoon. | ok | Round 2; round 1 wrote Bon après-midi (In French 'Bon après-midi' is said when leaving, not to open a message. As an opener it is a calque of English 'Good afternoon'. Quebec speakers write 'Bonjour' all afternoon.) |
| fr-CA | GR3 | Bonsoir | Good evening | ok |  |
| fr | G4 | Appareil | Device | ok |  |
| fr | G5 | Maths et divers | Maths and miscellaneous | ok |  |
| fr | V1 | Numéro de semaine | Week number | ok |  |
| fr | V2 | Fuseau horaire | Time zone | ok |  |
| fr | V3 | Salutation selon l’heure | Greeting based on the time | ok |  |
| fr | V4 | Langue | Language | ok |  |
| fr | V5 | Région | Region | ok |  |
| fr | V6 | Devise | Currency | ok |  |
| fr | V7 | Lien du presse-papiers | Link from the clipboard | ok |  |
| fr | V8 | E-mail du presse-papiers | Email from the clipboard | ok |  |
| fr | V9 | Compteur | Counter | ok |  |
| fr | S1 | Ce que vous avez copié | What you copied | ok |  |
| fr | S2 | Vous tapez la suite ici | You type the rest here | ok |  |
| fr | GR1 | Bonjour | Hello / good morning | ok |  |
| fr | GR2 | Bonjour | Hello | ok |  |
| fr | GR3 | Bonsoir | Good evening | ok |  |
| gu | G4 | ડિવાઇસ | Device | ok |  |
| gu | G5 | ગણિત અને અન્ય | Math and other | ok |  |
| gu | V1 | અઠવાડિયાનો નંબર | Week's number | ok |  |
| gu | V2 | સમય ઝોન | Time zone | ok |  |
| gu | V3 | સમય મુજબ શુભેચ્છા | Greeting/wish according to the time | ok |  |
| gu | V4 | ભાષા | Language | ok |  |
| gu | V5 | પ્રદેશ | Region | ok |  |
| gu | V6 | ચલણ | Currency | ok |  |
| gu | V7 | ક્લિપબોર્ડની લિંક | Clipboard's link | ok |  |
| gu | V8 | ક્લિપબોર્ડનો ઇમેઇલ | Clipboard's email | ok |  |
| gu | V9 | કાઉન્ટર | Counter | ok |  |
| gu | S1 | તમે છેલ્લે કૉપિ કરેલું ટેક્સ્ટ | The text you last copied | ok |  |
| gu | S2 | તમે અહીંથી આગળ લખો | You write on from here | ok |  |
| gu | GR1 | શુભ સવાર | Good morning | ok |  |
| gu | GR2 | નમસ્તે | Namaste, hello. It works at any hour. | ok | Round 2; round 1 wrote શુભ બપોર ('શુભ બપોર' is a rare calque of English that people hardly ever write. An afternoon message opens with 'નમસ્તે'.) |
| gu | GR3 | નમસ્તે | Namaste, hello. It works at any hour. | ok | Round 2; round 1 wrote શુભ સાંજ (changed with a flagged key) |
| he | G4 | מכשיר | Device | ok |  |
| he | G5 | מספרים ועוד | Numbers and more | ok |  |
| he | V1 | מספר השבוע | The week number | ok |  |
| he | V2 | אזור הזמן | The time zone | ok |  |
| he | V3 | ברכה לפי השעה | Greeting by the hour | ok |  |
| he | V4 | שפת המכשיר | Device language | ok |  |
| he | V5 | מדינה | Country | ok |  |
| he | V6 | מטבע | Currency | ok |  |
| he | V7 | קישור מלוח הגזירים | Link from the clipboard | ok |  |
| he | V8 | דוא״ל מלוח הגזירים | Email from the clipboard | ok |  |
| he | V9 | מונה | Counter | ok |  |
| he | S1 | הטקסט האחרון שהעתקת | The last text you copied | ok |  |
| he | S2 | הסמן יחכה לך כאן | The cursor will wait for you here | ok |  |
| he | GR1 | בוקר טוב | Good morning | ok |  |
| he | GR2 | צהריים טובים | Good afternoon (midday) | ok |  |
| he | GR3 | ערב טוב | Good evening | ok |  |
| hi | G4 | डिवाइस | Device | ok |  |
| hi | G5 | गणित और अन्य | Math and other | ok |  |
| hi | V1 | सप्ताह संख्या | Week number | ok |  |
| hi | V2 | समय ज़ोन | Time zone | ok |  |
| hi | V3 | समय के अनुसार अभिवादन | Greeting according to the time | ok |  |
| hi | V4 | भाषा | Language | ok |  |
| hi | V5 | क्षेत्र | Region | ok |  |
| hi | V6 | मुद्रा | Currency | ok |  |
| hi | V7 | क्लिपबोर्ड का लिंक | Clipboard's link | ok |  |
| hi | V8 | क्लिपबोर्ड का ईमेल | Clipboard's email | ok |  |
| hi | V9 | काउंटर | Counter | ok |  |
| hi | S1 | हाल में कॉपी किया टेक्स्ट | Recently copied text | ok |  |
| hi | S2 | यहीं से आगे टाइप करें | Type onward from right here | ok |  |
| hi | GR1 | सुप्रभात | Good morning | ok |  |
| hi | GR2 | नमस्ते | Hello | ok |  |
| hi | GR3 | शुभ संध्या | Good evening | ok |  |
| hr | G4 | Uređaj | Device | ok |  |
| hr | G5 | Matematika i ostalo | Maths and other | ok |  |
| hr | V1 | Broj tjedna | Week number | ok |  |
| hr | V2 | Vremenska zona | Time zone | ok |  |
| hr | V3 | Pozdrav prema dobu dana | Greeting by time of day | ok |  |
| hr | V4 | Jezik uređaja | Device language | ok |  |
| hr | V5 | Regija uređaja | Device region | ok |  |
| hr | V6 | Valuta regije | Region's currency | ok |  |
| hr | V7 | Poveznica iz međuspremnika | Link from the clipboard | ok |  |
| hr | V8 | E-mail iz međuspremnika | Email from the clipboard | ok |  |
| hr | V9 | Brojač | Counter | ok |  |
| hr | S1 | Zadnje što ste kopirali | The last thing you copied | ok |  |
| hr | S2 | Ovdje nastavljate pisati | You continue writing here | ok |  |
| hr | GR1 | Dobro jutro | Good morning | ok |  |
| hr | GR2 | Dobar dan | Good day / hello | ok |  |
| hr | GR3 | Dobra večer | Good evening | ok |  |
| hu | G4 | Eszköz | Device | ok |  |
| hu | G5 | Számok és egyebek | Numbers and other things | ok |  |
| hu | V1 | Hét sorszáma | Week's ordinal number | ok |  |
| hu | V2 | Időzóna | Time zone | ok |  |
| hu | V3 | Napszakos köszönés | Time-of-day greeting | ok |  |
| hu | V4 | Eszköz nyelve | Device language | ok |  |
| hu | V5 | Eszköz régiója | Device region | ok |  |
| hu | V6 | Régió pénzneme | Region's currency | ok |  |
| hu | V7 | Link a vágólapról | Link from the clipboard | ok |  |
| hu | V8 | E-mail-cím a vágólapról | Email address from the clipboard | ok |  |
| hu | V9 | Számláló | Counter | ok |  |
| hu | S1 | Amit legutóbb másoltál | What you last copied | ok |  |
| hu | S2 | Itt gépelhetsz tovább | You can keep typing here | ok |  |
| hu | GR1 | Jó napot | Good day (polite all-day greeting) | ok | Round 2; round 1 wrote Jó reggelt (Hungarians say 'Jó reggelt' only until about 9 or 10. From then until noon the normal opener is 'Jó napot', so 'Jó reggelt' reads wrong late in the morning.) |
| hu | GR2 | Jó napot | Good day | ok |  |
| hu | GR3 | Jó estét | Good evening | ok |  |
| id | G4 | Perangkat | Device | ok |  |
| id | G5 | Matematika dan lainnya | Math and other things | ok |  |
| id | V1 | Nomor minggu | Week number | ok |  |
| id | V2 | Zona waktu | Time zone | ok |  |
| id | V3 | Salam sesuai waktu | Greeting that fits the time | ok |  |
| id | V4 | Bahasa | Language | ok |  |
| id | V5 | Wilayah | Region | ok |  |
| id | V6 | Mata uang | Currency | ok |  |
| id | V7 | Tautan di papan klip | Link on the clipboard | ok |  |
| id | V8 | Email di papan klip | Email on the clipboard | ok |  |
| id | V9 | Penghitung | Counter | ok |  |
| id | S1 | Yang terakhir Anda salin | What you last copied | ok |  |
| id | S2 | Lanjut mengetik di sini | Continue typing here | ok |  |
| id | GR1 | Selamat pagi | Good morning | ok |  |
| id | GR2 | Halo | Hello / Hi (neutral, any time) | ok | Round 2; round 1 wrote Selamat siang ('Siang' covers roughly 11:00–15:00. From about 15:00 to 18:00 Indonesians write 'Selamat sore', so 'Selamat siang' at 16:00–17:59 reads wrong.) |
| id | GR3 | Selamat malam | Good evening / good night | ok |  |
| it | G4 | Dispositivo | Device | ok |  |
| it | G5 | Matematica e altro | Math and more | ok |  |
| it | V1 | Numero settimana | Week number | ok |  |
| it | V2 | Fuso orario | Time zone | ok |  |
| it | V3 | Saluto in base all'ora | Greeting based on the time of day | ok | Round 2; round 1 wrote Saluto del momento ('Del momento' is the everyday idiom for 'trendy, in fashion' ('il cantante del momento'), so it reads like a fashionable greeting. 'Saluto in base all'ora' is unambiguous.) |
| it | V4 | Lingua | Language | ok |  |
| it | V5 | Paese | Country | ok |  |
| it | V6 | Valuta | Currency | ok |  |
| it | V7 | Link negli Appunti | Link on the Clipboard | ok |  |
| it | V8 | Email negli Appunti | Email on the Clipboard | ok |  |
| it | V9 | Contatore | Counter | ok |  |
| it | S1 | Il testo che hai copiato | The text you copied | ok |  |
| it | S2 | Riprendi a scrivere qui | Resume typing here | ok |  |
| it | GR1 | Buongiorno | Good morning | ok |  |
| it | GR2 | Buongiorno | Good morning / Good day | see note | UNSURE: readers disagree (round 1 found Buon pomeriggio odd as an opener, round 2 finds Buongiorno wrong after about 16:00). |
| it | GR3 | Buonasera | Good evening | ok |  |
| ja | G4 | デバイス | Device | ok |  |
| ja | G5 | 数値とその他 | Numbers and other | ok |  |
| ja | V1 | 週番号 | Week number | ok |  |
| ja | V2 | タイムゾーン | Time zone | ok | Round 2; round 1 wrote 時間帯 (Apple's settings use it for time zone, but most readers first take '時間帯' as 'time of day' (朝の時間帯), and here it sits next to a time-of-day greeting. 'タイムゾーン' is unambiguous.) |
| ja | V3 | 時刻に合わせたあいさつ | Greeting matched to the time | ok |  |
| ja | V4 | 言語 | Language | ok |  |
| ja | V5 | 地域 | Region | ok |  |
| ja | V6 | 通貨 | Currency | ok |  |
| ja | V7 | クリップボードのURL | URL on the clipboard | ok |  |
| ja | V8 | クリップボードのメールアドレス | The email address on the clipboard | ok | Round 2; round 1 wrote クリップボードのメール ('メール' on its own means an email message. An address is 'メールアドレス'.) |
| ja | V9 | 連番 | Sequential number | ok |  |
| ja | S1 | 最後にコピーしたテキスト | Text you copied last | ok |  |
| ja | S2 | ここから続けて入力 | Continue typing from here | ok |  |
| ja | GR1 | おはようございます | Good morning (polite) | ok |  |
| ja | GR2 | こんにちは | Hello / good afternoon | ok |  |
| ja | GR3 | こんばんは | Good evening | ok |  |
| kn | G4 | ಸಾಧನ | Device | ok |  |
| kn | G5 | ಗಣಿತ, ಇತರೆ | Math, others | ok |  |
| kn | V1 | ವಾರದ ಸಂಖ್ಯೆ | Week number | ok |  |
| kn | V2 | ಸಮಯ ವಲಯ | Time zone | ok |  |
| kn | V3 | ಸಮಯಕ್ಕೆ ತಕ್ಕ ಶುಭಾಶಯ | A greeting that suits the time | ok | Round 2; round 1 wrote ಸಮಯದ ಶುಭಾಶಯ ('ಸಮಯದ ಶುಭಾಶಯ' reads vaguely as 'the time's greeting'. 'ಸಮಯಕ್ಕೆ ತಕ್ಕ ಶುಭಾಶಯ' says a greeting that fits the time.) |
| kn | V4 | ಭಾಷೆ | Language | ok |  |
| kn | V5 | ಪ್ರದೇಶ | Region | ok |  |
| kn | V6 | ಕರೆನ್ಸಿ | Currency | ok |  |
| kn | V7 | ಕ್ಲಿಪ್‌ಬೋರ್ಡ್ ಲಿಂಕ್ | Clipboard link | ok |  |
| kn | V8 | ಕ್ಲಿಪ್‌ಬೋರ್ಡ್ ಇಮೇಲ್ | Clipboard email | ok |  |
| kn | V9 | ಎಣಿಕೆ | Count | ok |  |
| kn | S1 | ನೀವು ಕೊನೆಗೆ ನಕಲಿಸಿದ ಪಠ್ಯ | The text you copied last | ok |  |
| kn | S2 | ಇಲ್ಲಿಂದ ಟೈಪ್ ಮುಂದುವರಿಸಿ | Continue typing from here | ok |  |
| kn | GR1 | ನಮಸ್ಕಾರ | Hello / Greetings (respectful, any time of day) | ok | Round 2; round 1 wrote ಶುಭೋದಯ (changed with a flagged key) |
| kn | GR2 | ನಮಸ್ಕಾರ | Hello / Greetings (respectful, any time of day) | ok | Round 2; round 1 wrote ಶುಭ ಮಧ್ಯಾಹ್ನ (This is a calque of 'good afternoon' that nobody says or writes. Kannadigas open with 'ನಮಸ್ಕಾರ' at this hour.) |
| kn | GR3 | ನಮಸ್ಕಾರ | Hello / Greetings (respectful, any time of day) | ok | Round 2; round 1 wrote ಶುಭ ಸಂಜೆ ('ಸಂಜೆ' means early evening. From late night to 04:59 it is plainly wrong ('ರಾತ್ರಿ'), and the phrase is a calque that is rarely used outside greeting cards. 'ನಮಸ್ಕಾರ' is what people write.) |
| ko | G4 | 기기 | Device | ok |  |
| ko | G5 | 숫자 및 기타 | Numbers and other | ok |  |
| ko | V1 | 주 번호 | Week number | ok |  |
| ko | V2 | 시간대 | Time zone | ok |  |
| ko | V3 | 시간에 맞는 인사말 | Greeting that fits the time | ok |  |
| ko | V4 | 기기 언어 | Device language | ok |  |
| ko | V5 | 기기 지역 | Device region | ok |  |
| ko | V6 | 지역 통화 | Local/regional currency | ok |  |
| ko | V7 | 클립보드 링크 | Clipboard link | ok |  |
| ko | V8 | 클립보드 이메일 주소 | Clipboard email address | ok |  |
| ko | V9 | 카운터 | Counter | ok |  |
| ko | S1 | 최근에 복사한 텍스트 | Text you copied recently | ok |  |
| ko | S2 | 여기서 이어서 입력 | Continue typing here | ok |  |
| ko | GR1 | 좋은 아침입니다 | Good morning (polite) | ok |  |
| ko | GR2 | 안녕하세요 | Hello | ok |  |
| ko | GR3 | 안녕하세요 | Hello (polite, any time of day) | ok | Round 2; round 1 wrote 좋은 저녁입니다 ('좋은 저녁입니다' is a calque Koreans almost never write, and at 01:00–04:59 it makes no sense. '안녕하세요' works at any hour.) |
| lt | G4 | Įrenginys | Device | ok |  |
| lt | G5 | Matematika ir kita | Math and other | ok |  |
| lt | V1 | Savaitės numeris | Week number | ok |  |
| lt | V2 | Laiko juosta | Time zone | ok |  |
| lt | V3 | Pasisveikinimas | Greeting | ok |  |
| lt | V4 | Kalba | Language | ok |  |
| lt | V5 | Regionas | Region | ok |  |
| lt | V6 | Regiono valiuta | Region's currency | ok |  |
| lt | V7 | Nuoroda iš iškarpinės | Link from the clipboard | ok |  |
| lt | V8 | El. paštas iš iškarpinės | Email from the clipboard | ok |  |
| lt | V9 | Skaitiklis | Counter | ok |  |
| lt | S1 | Tai, ką nukopijavote | What you copied | ok | Round 2; round 1 wrote Ką ką tik nukopijavote ('Ką ką' looks like a typo at first glance, even though it is grammatical. 'Ką paskutinį nukopijavote' or 'Paskutinis nukopijuotas tekstas' reads cleanly.) |
| lt | S2 | Čia rašysite toliau | Here you will continue writing | ok |  |
| lt | GR1 | Labas rytas | Good morning | ok |  |
| lt | GR2 | Laba diena | Good day | ok |  |
| lt | GR3 | Labas vakaras | Good evening | ok |  |
| lv | G4 | Ierīce | Device | ok |  |
| lv | G5 | Matemātika un pārējais | Math and the rest | ok |  |
| lv | V1 | Nedēļas numurs | Week number | ok |  |
| lv | V2 | Laika josla | Time zone | ok |  |
| lv | V3 | Dienas laika sveiciens | Time-of-day greeting | ok |  |
| lv | V4 | Ierīces valoda | Device language | ok |  |
| lv | V5 | Ierīces reģions | Device region | ok |  |
| lv | V6 | Reģiona valūta | Region's currency | ok |  |
| lv | V7 | Starpliktuves saite | Clipboard link | ok |  |
| lv | V8 | Starpliktuves e-pasts | Clipboard email | ok |  |
| lv | V9 | Skaitītājs | Counter | ok |  |
| lv | S1 | Teksts, ko nokopējāt | Text you copied | ok |  |
| lv | S2 | Šeit turpināsiet rakstīt | Here you will continue writing | ok |  |
| lv | GR1 | Labrīt | Good morning | ok |  |
| lv | GR2 | Labdien | Good day | ok |  |
| lv | GR3 | Labvakar | Good evening | ok |  |
| ml | G4 | ഉപകരണം | Device | ok |  |
| ml | G5 | ഗണിതവും മറ്റുള്ളവയും | Maths and others | ok |  |
| ml | V1 | ആഴ്ച നമ്പർ | Week number | ok |  |
| ml | V2 | സമയമേഖല | Time zone | ok |  |
| ml | V3 | സമയത്തിനൊത്ത ആശംസ | Greeting that fits the time | ok |  |
| ml | V4 | ഭാഷ | Language | ok |  |
| ml | V5 | പ്രദേശം | Region / area | ok |  |
| ml | V6 | കറൻസി | Currency | ok |  |
| ml | V7 | ക്ലിപ്പ്ബോർഡിലെ ലിങ്ക് | Link on the clipboard | ok |  |
| ml | V8 | ക്ലിപ്പ്ബോർഡിലെ ഇമെയിൽ | Email on the clipboard | ok |  |
| ml | V9 | ക്രമനമ്പർ | Serial number: a running number for counting items one after another. | ok | Round 2; round 1 wrote കൗണ്ടർ (In everyday Malayalam, കൗണ്ടർ first means a shop, ticket or service counter, not a running count, so the label is ambiguous.) |
| ml | S1 | നിങ്ങൾ ഒടുവിൽ പകർത്തിയത് | What you copied last | ok |  |
| ml | S2 | ഇവിടെനിന്ന് ടൈപ്പ് തുടരാം | You can carry on typing from here | ok |  |
| ml | GR1 | സുപ്രഭാതം | Good morning (formal, written) | ok |  |
| ml | GR2 | നമസ്കാരം | Hello / greetings (works at any hour) | ok |  |
| ml | GR3 | ശുഭസായാഹ്നം | Good evening (formal) | ok |  |
| mr | G4 | डिव्हाइस | Device | ok |  |
| mr | G5 | गणित आणि इतर | Maths and other | ok |  |
| mr | V1 | आठवड्याचा क्रमांक | Week's number | ok |  |
| mr | V2 | टाइम झोन | Time zone | ok |  |
| mr | V3 | वेळेनुसार अभिवादन | Greeting according to the time | ok |  |
| mr | V4 | भाषा | Language | ok |  |
| mr | V5 | प्रदेश | Region | ok |  |
| mr | V6 | चलन | Currency | ok |  |
| mr | V7 | क्लिपबोर्डवरील लिंक | Link on the clipboard | ok |  |
| mr | V8 | क्लिपबोर्डवरील ईमेल | Email on the clipboard | ok |  |
| mr | V9 | वाढता क्रमांक | Increasing number: a number that goes up each time. It is clear, though 'अनुक्रमांक' is the more usual word for a serial number. | ok | Round 2; round 1 wrote काउंटर (In Marathi, काउंटर first suggests a shop or ticket counter, not a running count, so the label is ambiguous.) |
| mr | S1 | तुम्ही शेवटचे कॉपी केलेले | What you copied last | ok |  |
| mr | S2 | येथूनच पुढे टाइप करा | Keep typing right from here | ok |  |
| mr | GR1 | सुप्रभात | Good morning | ok |  |
| mr | GR2 | नमस्कार | Hello / greetings | ok |  |
| mr | GR3 | नमस्कार | Hello / greetings | ok |  |
| ms | G4 | Peranti | Device | ok |  |
| ms | G5 | Matematik dan lain-lain | Maths and others | ok |  |
| ms | V1 | Nombor Minggu | Week Number | ok |  |
| ms | V2 | Zon Waktu | Time Zone | ok |  |
| ms | V3 | Ucapan Mengikut Waktu | Greeting Based on the Time | ok |  |
| ms | V4 | Bahasa Peranti | Device Language | ok |  |
| ms | V5 | Rantau Peranti | Device Region | ok |  |
| ms | V6 | Mata Wang Peranti | Device Currency | ok |  |
| ms | V7 | Pautan Papan Keratan | Clipboard Link | ok |  |
| ms | V8 | E-mel Papan Keratan | Clipboard Email | ok |  |
| ms | V9 | Nombor Berturutan | Sequential number: a number that follows on in order, one after another. | ok | Round 2; round 1 wrote Pembilang (In maths, Pembilang is the everyday word for a fraction's numerator, so it is ambiguous next to the 'Matematik' group. A running count would read more clearly another way.) |
| ms | S1 | Teks terakhir yang anda salin |  | see note | Round 3: adds 'yang' as the round-2 reader asked; not read again. |
| ms | S2 | Sambung menaip di sini | Continue typing here | ok |  |
| ms | GR1 | Selamat pagi | Good morning | ok |  |
| ms | GR2 | Selamat petang | Good afternoon. | ok | Round 2 kept the round-1 string after a reader flag: In Malaysia, people write 'Selamat tengah hari' around midday. 'Selamat petang' fits from about 14:00, so it reads slightly off at 12:00 to 13:59. |
| ms | GR3 | Selamat malam | Good evening / good night | ok |  |
| nb | G4 | Enhet | Device | ok |  |
| nb | G5 | Matte og annet | Maths and other stuff (casual) | ok |  |
| nb | V1 | Ukenummer | Week number | ok |  |
| nb | V2 | Tidssone | Time zone | ok |  |
| nb | V3 | Hilsen etter tid på døgnet | Greeting by time of day | ok |  |
| nb | V4 | Språk | Language | ok |  |
| nb | V5 | Region | Region | ok |  |
| nb | V6 | Valuta | Currency | ok |  |
| nb | V7 | Lenke på utklippstavlen | Link on the clipboard | ok |  |
| nb | V8 | E-post på utklippstavlen | Email on the clipboard | ok |  |
| nb | V9 | Teller | Counter | ok |  |
| nb | S1 | Det du kopierte sist | What you copied last | ok |  |
| nb | S2 | Du skriver videre her | You carry on writing here | ok |  |
| nb | GR1 | God morgen | Good morning | ok |  |
| nb | GR2 | God ettermiddag | Good afternoon | ok |  |
| nb | GR3 | God kveld | Good evening | ok |  |
| nl | G4 | Apparaat | Device | ok |  |
| nl | G5 | Rekenen en overig | Arithmetic and other | ok |  |
| nl | V1 | Weeknummer | Week number | ok |  |
| nl | V2 | Tijdzone | Time zone | ok |  |
| nl | V3 | Groet per dagdeel | Greeting by part of the day | ok |  |
| nl | V4 | Taal | Language | ok |  |
| nl | V5 | Regio | Region | ok |  |
| nl | V6 | Valuta | Currency | ok |  |
| nl | V7 | Link uit klembord | Link from clipboard | ok |  |
| nl | V8 | E-mailadres uit klembord | Email address from clipboard | ok |  |
| nl | V9 | Teller | Counter | ok |  |
| nl | S1 | Wat je laatst kopieerde | What you copied last | ok |  |
| nl | S2 | Hier typ je verder | Here you carry on typing | ok |  |
| nl | GR1 | Goedemorgen | Good morning | ok |  |
| nl | GR2 | Goedemiddag | Good afternoon | ok |  |
| nl | GR3 | Goedenavond | Good evening | ok |  |
| or | G4 | ଡିଭାଇସ | Device | ok |  |
| or | G5 | ଗଣିତ ଓ ଅନ୍ୟାନ୍ୟ | Maths and others | ok |  |
| or | V1 | ସପ୍ତାହ ସଂଖ୍ୟା | Week number | ok |  |
| or | V2 | ସମୟ ଅଞ୍ଚଳ | Time zone | ok |  |
| or | V3 | ସମୟ ଅନୁସାରେ ଅଭିବାଦନ | Greeting according to the time | ok |  |
| or | V4 | ଭାଷା | Language | ok |  |
| or | V5 | ଦେଶ | Country | ok |  |
| or | V6 | ମୁଦ୍ରା | Currency | ok |  |
| or | V7 | କ୍ଲିପବୋର୍ଡର ଲିଙ୍କ | Clipboard's link | ok |  |
| or | V8 | କ୍ଲିପବୋର୍ଡର ଇମେଲ | Clipboard's email | ok |  |
| or | V9 | କ୍ରମିକ ସଂଖ୍ୟା | Serial number: a sequential count number. | ok | Round 2; round 1 wrote କାଉଣ୍ଟର (In Odia, କାଉଣ୍ଟର first suggests a shop or ticket counter, not a running count, so the label is ambiguous.) |
| or | S1 | ଆପଣ ଶେଷରେ କପି କରିଥିବା ଟେକ୍ସଟ | The text you copied last | ok |  |
| or | S2 | ଏଠାରୁ ଲେଖିବା ଜାରି ରଖନ୍ତୁ | Keep on writing from here | ok |  |
| or | GR1 | ସୁପ୍ରଭାତ | Good morning (formal) | ok |  |
| or | GR2 | ନମସ୍କାର | Namaskar / greetings | ok |  |
| or | GR3 | ଶୁଭ ସନ୍ଧ୍ୟା | Good evening (formal) | ok |  |
| pa | G4 | ਡਿਵਾਈਸ | Device | ok |  |
| pa | G5 | ਗਣਿਤ ਅਤੇ ਹੋਰ | Maths and more | ok |  |
| pa | V1 | ਹਫ਼ਤਾ ਨੰਬਰ | Week number | ok |  |
| pa | V2 | ਸਮਾਂ ਖੇਤਰ | Time zone | ok |  |
| pa | V3 | ਸਮੇਂ ਅਨੁਸਾਰ ਅਭਿਵਾਦਨ |  | see note | Round 3: a fresh writer replaced two rejected names (greeting according to the time); not read again. |
| pa | V4 | ਭਾਸ਼ਾ | Language | ok |  |
| pa | V5 | ਦੇਸ਼ | Country | ok |  |
| pa | V6 | ਮੁਦਰਾ | Currency | ok |  |
| pa | V7 | ਕਲਿੱਪਬੋਰਡ ਦਾ ਲਿੰਕ | The clipboard's link | ok |  |
| pa | V8 | ਕਲਿੱਪਬੋਰਡ ਦੀ ਈਮੇਲ | The clipboard's email | ok |  |
| pa | V9 | ਗਿਣਤੀ | Count / counting | ok |  |
| pa | S1 | ਜੋ ਤੁਸੀਂ ਹੁਣੇ ਕਾਪੀ ਕੀਤਾ | What you just copied | ok |  |
| pa | S2 | ਤੁਸੀਂ ਇੱਥੋਂ ਲਿਖਦੇ ਰਹੋ | You keep writing from here | ok |  |
| pa | GR1 | ਸਤ ਸ੍ਰੀ ਅਕਾਲ | Sat Sri Akal: the standard Punjabi hello, used at any hour. | ok | Round 2; round 1 wrote ਸ਼ੁਭ ਸਵੇਰ (changed with a flagged key) |
| pa | GR2 | ਸਤ ਸ੍ਰੀ ਅਕਾਲ | Sat Sri Akal: the standard Punjabi hello, used at any hour. | ok | Round 2; round 1 wrote ਸ਼ੁਭ ਦੁਪਹਿਰ (A calque of 'good afternoon' that Punjabi speakers almost never write. People use ਸਤ ਸ੍ਰੀ ਅਕਾਲ or another all-day greeting.) |
| pa | GR3 | ਸਤ ਸ੍ਰੀ ਅਕਾਲ | Sat Sri Akal: the standard Punjabi hello, used at any hour. | ok | Round 2; round 1 wrote ਸ਼ੁਭ ਸ਼ਾਮ (A rarely written calque, seen mostly in forwarded greeting images. It also reads wrong late at night, after midnight.) |
| pl | G4 | Urządzenie | Device | ok |  |
| pl | G5 | Matematyka i inne | Maths and other things | ok |  |
| pl | V1 | Numer tygodnia | Week number | ok |  |
| pl | V2 | Strefa czasowa | Time zone | ok |  |
| pl | V3 | Powitanie zależne od pory | A greeting that depends on the time of day | ok |  |
| pl | V4 | Język urządzenia | The device's language | ok |  |
| pl | V5 | Region urządzenia | The device's region | ok |  |
| pl | V6 | Waluta regionu | The region's currency | ok |  |
| pl | V7 | Link ze schowka | A link from the clipboard | ok |  |
| pl | V8 | Adres e-mail ze schowka | An email address from the clipboard | ok |  |
| pl | V9 | Licznik | Counter | ok |  |
| pl | S1 | Ostatni skopiowany tekst | The last text you copied | ok |  |
| pl | S2 | Tutaj piszesz dalej | You keep writing here | ok |  |
| pl | GR1 | Dzień dobry | Good day / hello (the standard Polish morning greeting) | ok |  |
| pl | GR2 | Dzień dobry | Good day / hello | ok |  |
| pl | GR3 | Dobry wieczór | Good evening | ok |  |
| pt-BR | G4 | Dispositivo | Device | ok |  |
| pt-BR | G5 | Matemática e outros | Maths and others | ok |  |
| pt-BR | V1 | Número da semana | Week number | ok |  |
| pt-BR | V2 | Fuso horário | Time zone | ok |  |
| pt-BR | V3 | Saudação por horário | A greeting based on the time | ok |  |
| pt-BR | V4 | Idioma | Language | ok |  |
| pt-BR | V5 | Região | Region | ok |  |
| pt-BR | V6 | Moeda | Currency | ok |  |
| pt-BR | V7 | Link copiado | Copied link: the link you copied. | ok | Round 2; round 1 wrote Link da Área de transf. ('Área de transf.' is a truncated abbreviation that looks broken in a pill. iOS pt-BR writes 'Área de Transferência' in full.) |
| pt-BR | V8 | E-mail copiado | Copied e-mail: the email address you copied. In context it is understood as the address, not an email message. | ok | Round 2; round 1 wrote E-mail da Área de transf. (Same truncated 'Área de transf.' abbreviation; it reads cramped and unfinished.) |
| pt-BR | V9 | Contador | Counter | ok |  |
| pt-BR | S1 | Seu último texto copiado | The last text you copied | ok |  |
| pt-BR | S2 | Continue digitando aqui | Keep typing here | ok |  |
| pt-BR | GR1 | Bom dia | Good morning | ok |  |
| pt-BR | GR2 | Boa tarde | Good afternoon | ok |  |
| pt-BR | GR3 | Boa noite | Good evening / good night (used as a greeting after dark) | ok |  |
| pt | G4 | Dispositivo | Device | ok |  |
| pt | G5 | Matemática e outros | Maths and others | ok |  |
| pt | V1 | Número da semana | Week number | ok |  |
| pt | V2 | Fuso horário | Time zone | ok |  |
| pt | V3 | Saudação | Greeting (nothing says it depends on the time) | ok |  |
| pt | V4 | Idioma | Language | ok |  |
| pt | V5 | Região | Region | ok |  |
| pt | V6 | Moeda | Currency | ok |  |
| pt | V7 | URL da área de transferência | URL from the clipboard. | ok | Round 2; round 1 wrote URL da Área de transf. ('Área de transf.' is a truncated abbreviation that looks broken in a pill. Write 'área de transferência' in full.) |
| pt | V8 | E-mail da área de transferência | E-mail from the clipboard: the email address currently copied. | ok | Round 2; round 1 wrote E-mail da Área de transf. (Same truncated 'Área de transf.' abbreviation.) |
| pt | V9 | Contador | Counter | ok |  |
| pt | S1 | O que copiou por último | What you copied last | ok |  |
| pt | S2 | Continue a escrever aqui | Keep writing here | ok |  |
| pt | GR1 | Bom dia | Good morning | ok |  |
| pt | GR2 | Boa tarde | Good afternoon | ok |  |
| pt | GR3 | Boa noite | Good evening / good night (used as a greeting after dark) | ok |  |
| ro | G4 | Dispozitiv | Device | ok |  |
| ro | G5 | Matematică și altele | Maths and other things | ok |  |
| ro | V1 | Numărul săptămânii | The week number | ok |  |
| ro | V2 | Fusul orar | The time zone | ok |  |
| ro | V3 | Salutul potrivit orei | The greeting that fits the hour | ok |  |
| ro | V4 | Limba | The language | ok |  |
| ro | V5 | Regiunea | The region | ok |  |
| ro | V6 | Moneda | The currency | ok |  |
| ro | V7 | Linkul din clipboard | The link from the clipboard | ok |  |
| ro | V8 | E-mailul din clipboard | The email from the clipboard | ok |  |
| ro | V9 | Contor | Counter | ok |  |
| ro | S1 | Ce ai copiat ultima dată | What you copied last | ok |  |
| ro | S2 | Aici continui să scrii | Here is where you keep writing | ok |  |
| ro | GR1 | Bună dimineața | Good morning | ok |  |
| ro | GR2 | Bună ziua | Good day / good afternoon | ok |  |
| ro | GR3 | Bună seara | Good evening | ok |  |
| ru | G4 | Устройство | Device | ok |  |
| ru | G5 | Числа и другое | Numbers and other things | ok |  |
| ru | V1 | Номер недели | Week number | ok |  |
| ru | V2 | Часовой пояс | Time zone | ok |  |
| ru | V3 | Приветствие по времени | A greeting by time of day | ok |  |
| ru | V4 | Язык устройства | Device language | ok |  |
| ru | V5 | Страна | Country | ok |  |
| ru | V6 | Валюта | Currency | ok |  |
| ru | V7 | Ссылка из буфера обмена | Link from the clipboard | ok |  |
| ru | V8 | E-mail из буфера обмена | Email from the clipboard | ok |  |
| ru | V9 | Счетчик | Counter | ok |  |
| ru | S1 | Скопированный вами текст | Text you copied | ok |  |
| ru | S2 | Здесь вы продолжите ввод | This is where you'll keep typing | ok |  |
| ru | GR1 | Доброе утро | Good morning | ok |  |
| ru | GR2 | Добрый день | Good afternoon | ok |  |
| ru | GR3 | Добрый вечер | Good evening | ok |  |
| sk | G4 | Zariadenie | Device | ok |  |
| sk | G5 | Matematika a iné | Maths and other | ok |  |
| sk | V1 | Číslo týždňa | Week number | ok |  |
| sk | V2 | Časové pásmo | Time zone | ok |  |
| sk | V3 | Pozdrav podľa času | A greeting by time | ok |  |
| sk | V4 | Jazyk zariadenia | Device language | ok |  |
| sk | V5 | Oblasť zariadenia | Device region | ok |  |
| sk | V6 | Mena | Currency | ok |  |
| sk | V7 | Odkaz zo schránky | Link from the clipboard | ok |  |
| sk | V8 | E-mail zo schránky | Email from the clipboard | ok |  |
| sk | V9 | Počítadlo | Counter | ok |  |
| sk | S1 | Čo ste skopírovali | What you copied | ok |  |
| sk | S2 | Tu budete písať ďalej | This is where you'll keep writing | ok |  |
| sk | GR1 | Dobrý deň | Good day / Hello: the standard polite greeting in Slovak, used in written messages at any time of day, morning included. | ok | Round 2; round 1 wrote Dobré ráno ('Dobré ráno' fits roughly 05:00–09:00. From about 10:00 to noon, Slovaks write 'Dobrý deň', so it sounds off late in the morning.) |
| sk | GR2 | Dobrý deň | Good day / hello | ok |  |
| sk | GR3 | Dobrý večer | Good evening | ok |  |
| sl | G4 | Naprava | Device | ok |  |
| sl | G5 | Matematika in drugo | Maths and other | ok |  |
| sl | V1 | Številka tedna | Week number | ok |  |
| sl | V2 | Časovni pas | Time zone | ok |  |
| sl | V3 | Pozdrav glede na čas | A greeting based on the time | ok |  |
| sl | V4 | Jezik naprave | Device language | ok |  |
| sl | V5 | Regija naprave | Device region | ok |  |
| sl | V6 | Valuta regije | The region's currency | ok |  |
| sl | V7 | Povezava iz odložišča | Link from the clipboard | ok |  |
| sl | V8 | E-pošta iz odložišča | Email from the clipboard | ok |  |
| sl | V9 | Števec | Counter | ok |  |
| sl | S1 | Zadnje, kar ste kopirali | The last thing you copied | ok |  |
| sl | S2 | Tu nadaljujete pisanje | This is where you continue writing | ok |  |
| sl | GR1 | Dober dan | Good day / Hello: the normal polite opening of a written Slovenian message, including in the morning. | ok | Round 2; round 1 wrote Dobro jutro ('Dobro jutro' fits roughly 05:00–09:00. From about 10:00 to noon, Slovenians write 'Dober dan', so it sounds off late in the morning.) |
| sl | GR2 | Dober dan | Good day / hello | ok |  |
| sl | GR3 | Dober večer | Good evening | ok |  |
| sr | G4 | Уређај | Device | ok |  |
| sr | G5 | Математика и остало | Maths and other things | ok |  |
| sr | V1 | Број недеље | Week number | ok |  |
| sr | V2 | Временска зона | Time zone | ok |  |
| sr | V3 | Поздрав за доба дана | Greeting for the time of day | ok |  |
| sr | V4 | Језик уређаја | Device language | ok |  |
| sr | V5 | Регион | Region | ok |  |
| sr | V6 | Валута | Currency | ok |  |
| sr | V7 | Линк из клипборда | Link from the clipboard | ok |  |
| sr | V8 | Имејл из клипборда | Email (address) from the clipboard | ok |  |
| sr | V9 | Бројач | Counter | ok |  |
| sr | S1 | Текст који сте копирали | Text you copied | ok |  |
| sr | S2 | Овде настављате куцање | You carry on typing here | ok |  |
| sr | GR1 | Добро јутро | Good morning | ok |  |
| sr | GR2 | Добар дан | Good day / hello (the normal daytime greeting) | ok |  |
| sr | GR3 | Добро вече | Good evening | ok |  |
| sv | G4 | Enhet | Device | ok |  |
| sv | G5 | Matematik och övrigt | Mathematics and other things | ok |  |
| sv | V1 | Veckonummer | Week number | ok |  |
| sv | V2 | Tidszon | Time zone | ok |  |
| sv | V3 | Tidsanpassad hälsning | Greeting adjusted to the time | ok |  |
| sv | V4 | Språk | Language | ok |  |
| sv | V5 | Region | Region | ok |  |
| sv | V6 | Valuta | Currency | ok |  |
| sv | V7 | Länk från urklipp | Link from the clipboard | ok |  |
| sv | V8 | E-postadress från urklipp | Email address from the clipboard | ok |  |
| sv | V9 | Räknare | Counter | ok |  |
| sv | S1 | Det du kopierade senast | What you copied most recently | ok |  |
| sv | S2 | Du fortsätter skriva här | You keep writing here | ok |  |
| sv | GR1 | God morgon | Good morning | ok |  |
| sv | GR2 | Hej | Hi / Hello: the everyday Swedish greeting, fine in both casual and work messages in the afternoon. | ok | Round 2; round 1 wrote God eftermiddag (Correct, but stiff and formal in a written message, like a radio host. Swedes rarely open a text or email with it.) |
| sv | GR3 | God kväll | Good evening | ok |  |
| sw | G4 | Kifaa | Device | ok |  |
| sw | G5 | Hesabu na mengineyo | Arithmetic and other things | ok |  |
| sw | V1 | Namba ya wiki | Week number | ok |  |
| sw | V2 | Saa za eneo | Time zone (literally 'hours of the area') | ok |  |
| sw | V3 | Salamu kulingana na saa | Greeting according to the time (of day): clear as the name of a greeting that changes with the hour. | ok | Round 2; round 1 wrote Salamu ya wakati (Vague: it doesn't say the greeting changes with the time of day. 'Salamu kulingana na wakati' would make that clear.) |
| sw | V4 | Lugha ya kifaa | Device language | ok |  |
| sw | V5 | Nchi ya kifaa | The device's country | ok |  |
| sw | V6 | Sarafu ya kifaa | The device's currency | ok |  |
| sw | V7 | Kiungo kilichonakiliwa | The copied link: reads naturally as the link that was copied to the clipboard. | ok | Round 2; round 1 wrote Kiungo kutoka ubaoni ('Ubaoni' alone means 'on the board/blackboard'. The usual term for clipboard is 'ubao wa kunakili', so on its own this doesn't read as clipboard.) |
| sw | V8 | Anwani ya barua pepe iliyonakiliwa |  | see note | Round 3: the round-2 reader's own wording (an address, not a message); over budget at 261 pt, still fits. |
| sw | V9 | Kihesabu | Counter | ok |  |
| sw | S1 | Ulichonakili mwisho | What you copied last | ok |  |
| sw | S2 | Utaendelea kuandika hapa | You'll continue writing here | ok |  |
| sw | GR1 | Habari za asubuhi | Good morning (literally 'news of the morning?', the standard morning greeting) | ok |  |
| sw | GR2 | Habari za mchana | Good afternoon (standard midday greeting) | ok |  |
| sw | GR3 | Habari za jioni | Good evening (standard evening greeting) | ok |  |
| ta | G4 | சாதனம் | Device | ok |  |
| ta | G5 | கணிதமும் மற்றவையும் | Math and the others / Math and the rest: a header for a group made of math plus other assorted items. | ok | Round 2; round 1 wrote கணக்கும் மற்றவையும் (கணக்கு means both arithmetic and an (bank/user) account, so a header can read as 'Account and others'. கணிதமும் மற்றவையும் is unambiguous.) |
| ta | V1 | வார எண் | Week number | ok |  |
| ta | V2 | நேர மண்டலம் | Time zone | ok |  |
| ta | V3 | நேரத்திற்கேற்ற வாழ்த்து | Greeting suited to the time | ok |  |
| ta | V4 | மொழி | Language | ok |  |
| ta | V5 | பிராந்தியம் | Region | ok |  |
| ta | V6 | நாணயம் | Currency | ok |  |
| ta | V7 | கிளிப்போர்டு இணைப்பு | Clipboard link | ok |  |
| ta | V8 | கிளிப்போர்டு மின்னஞ்சல் | Clipboard email | ok |  |
| ta | V9 | வரிசை எண் | Serial / sequence number | ok |  |
| ta | S1 | நீங்கள் கடைசியாக நகலெடுத்தது | What you copied last | ok |  |
| ta | S2 | இங்கே தொடர்ந்து தட்டச்சிடலாம் | You can keep typing here | ok |  |
| ta | GR1 | காலை வணக்கம் | Good morning | ok |  |
| ta | GR2 | வணக்கம் | Vanakkam, the general Tamil greeting (hello) that fits any time of day, so it is natural in the afternoon. | ok | Round 2; round 1 wrote மதிய வணக்கம் (A calque of English 'good afternoon'. You see it in forwarded images, but people rarely write it themselves; a plain வணக்கம் is what's normally written.) |
| ta | GR3 | மாலை வணக்கம் | Good evening | ok |  |
| te | G4 | పరికరం | Device | ok |  |
| te | G5 | గణితం, ఇతరాలు | Mathematics, others | ok |  |
| te | V1 | వారం సంఖ్య | Week number | ok |  |
| te | V2 | టైమ్ జోన్ | Time zone | ok |  |
| te | V3 | సమయానికి తగ్గ పలకరింపు | Greeting suited to the time | ok |  |
| te | V4 | పరికర భాష | Device language | ok |  |
| te | V5 | ప్రాంతం | Region | ok |  |
| te | V6 | కరెన్సీ | Currency | ok |  |
| te | V7 | క్లిప్‌బోర్డ్ లింక్ | Clipboard link | ok |  |
| te | V8 | క్లిప్‌బోర్డ్ ఇమెయిల్ | Clipboard email | ok |  |
| te | V9 | కౌంటర్ | Counter | ok |  |
| te | S1 | మీరు చివరగా కాపీ చేసింది | What you copied last | ok |  |
| te | S2 | మీరు ఇక్కడి నుంచి టైప్ చేస్తారు | You will type from here / You type from here on: a reader takes it to mean their typing continues from this spot, which works as a hint for where the cursor lands. | ok | Round 2; round 1 wrote ఇక్కడి నుంచి టైప్ చేయండి (It's an imperative, so it reads as a prompt telling the person to type now, not as a description of what the variable does. A hint should describe, e.g. 'మీరు ఇక్కడి నుంచి టైప్ కొనసాగిస్తారు'.) |
| te | GR1 | శుభోదయం | Good morning | ok |  |
| te | GR2 | నమస్కారం | Hello / greetings (neutral) | ok |  |
| te | GR3 | శుభ సాయంత్రం | Good evening | ok |  |
| th | G4 | อุปกรณ์ | Device | ok |  |
| th | G5 | ตัวเลขและอื่นๆ | Numbers and others | ok |  |
| th | V1 | หมายเลขสัปดาห์ | Week number | ok |  |
| th | V2 | เขตเวลา | Time zone | ok |  |
| th | V3 | คำทักทายตามเวลา | Greeting by time | ok |  |
| th | V4 | ภาษา | Language | ok |  |
| th | V5 | ภูมิภาค | Region | ok |  |
| th | V6 | สกุลเงิน | Currency | ok |  |
| th | V7 | ลิงก์ในคลิปบอร์ด | Link on the clipboard | ok |  |
| th | V8 | อีเมลในคลิปบอร์ด | Email on the clipboard | ok |  |
| th | V9 | ตัวนับ | Counter | ok |  |
| th | S1 | ข้อความที่คุณคัดลอกล่าสุด | Text you copied last | ok |  |
| th | S2 | คุณพิมพ์ต่อได้จากตรงนี้ | You can keep typing from here | ok |  |
| th | GR1 | สวัสดีตอนเช้า | Good morning | ok |  |
| th | GR2 | สวัสดี | Sawasdee (hello), the general Thai greeting for any time of day. It is natural in the afternoon; 'สวัสดีตอนบ่าย' would be an English calque. | ok | Round 2; round 1 wrote สวัสดีตอนบ่าย (Sounds translated. You see it on stickers, but people seldom type it; a plain สวัสดีครับ/ค่ะ is normal.) |
| th | GR3 | สวัสดี | Sawasdee (hello), the general Thai greeting. It is natural in the evening and at night; 'สวัสดีตอนเย็น' is rarely written. | ok | Round 2; round 1 wrote สวัสดีตอนเย็น (ตอนเย็น covers roughly 16:00–19:00. Typed at 22:00 or 02:00 it names the wrong part of the day, since that is ตอนค่ำ/กลางคืน.) |
| tr | G4 | Aygıt | Device | ok |  |
| tr | G5 | Matematik ve diğerleri | Mathematics and others | ok |  |
| tr | V1 | Hafta Numarası | Week Number | ok |  |
| tr | V2 | Saat Dilimi | Time Zone | ok |  |
| tr | V3 | Saate Göre Selamlama | Greeting by Time of Day | ok |  |
| tr | V4 | Dil | Language | ok |  |
| tr | V5 | Bölge | Region | ok |  |
| tr | V6 | Para Birimi | Currency | ok |  |
| tr | V7 | Panodaki Bağlantı | Link on the Clipboard | ok |  |
| tr | V8 | Panodaki E-posta | Email on the Clipboard | ok |  |
| tr | V9 | Sayaç | Counter | ok |  |
| tr | S1 | Son kopyaladığınız metin | The text you copied last | ok |  |
| tr | S2 | Buradan devam edersiniz | You continue from here | ok |  |
| tr | GR1 | Günaydın | Good morning | ok |  |
| tr | GR2 | İyi günler | Good day | ok |  |
| tr | GR3 | İyi akşamlar | Good evening | ok |  |
| uk | G4 | Пристрій | Device | ok |  |
| uk | G5 | Математика та інше | Maths and other things | ok |  |
| uk | V1 | Номер тижня | Week number | ok |  |
| uk | V2 | Часовий пояс | Time zone | ok |  |
| uk | V3 | Привітання за часом доби | Greeting for the time of day | ok |  |
| uk | V4 | Мова пристрою | Device language | ok |  |
| uk | V5 | Регіон пристрою | Device region | ok |  |
| uk | V6 | Валюта регіону | The region's currency | ok |  |
| uk | V7 | Посилання з буфера обміну | Link from the clipboard | ok |  |
| uk | V8 | Е-пошта з буфера обміну | Email from the clipboard | ok |  |
| uk | V9 | Лічильник | Counter | ok |  |
| uk | S1 | Те, що ви скопіювали | What you copied | ok |  |
| uk | S2 | Ви продовжите писати тут | You will carry on writing here | ok |  |
| uk | GR1 | Доброго ранку | Good morning | ok |  |
| uk | GR2 | Добрий день | Good day / hello | ok |  |
| uk | GR3 | Добрий вечір | Good evening | ok |  |
| ur | G4 | ڈیوائس | Device | ok |  |
| ur | G5 | حساب اور دیگر | Calculation and other | ok |  |
| ur | V1 | ہفتے کا نمبر | Week number | ok |  |
| ur | V2 | ٹائم زون | Time zone | ok |  |
| ur | V3 | وقت کے مطابق سلام | Greeting according to the time | ok |  |
| ur | V4 | زبان | Language | ok |  |
| ur | V5 | علاقہ | Region | ok |  |
| ur | V6 | کرنسی | Currency | ok |  |
| ur | V7 | کلپ بورڈ کا لنک | Clipboard's link | ok |  |
| ur | V8 | کلپ بورڈ کا ای میل پتہ | Clipboard's email address | ok |  |
| ur | V9 | گنتی | Counting / the count | ok |  |
| ur | S1 | آپ کا آخری کاپی کردہ متن | The text you copied last | ok |  |
| ur | S2 | ٹائپنگ یہیں سے جاری رکھیں | Continue typing from right here (an instruction) | ok |  |
| ur | GR1 | صبح بخیر | Good morning | ok |  |
| ur | GR2 | السلام علیکم | Peace be upon you (the standard all-day greeting) | ok |  |
| ur | GR3 | شام بخیر | Good evening | ok |  |
| vi | G4 | Thiết bị | Device | ok |  |
| vi | G5 | Tính toán và mục khác | Calculations and other items | ok |  |
| vi | V1 | Số tuần | Week number | ok |  |
| vi | V2 | Múi giờ | Time zone | ok |  |
| vi | V3 | Lời chào theo giờ | Greeting by the hour | ok |  |
| vi | V4 | Ngôn ngữ | Language | ok |  |
| vi | V5 | Vùng | Region | ok |  |
| vi | V6 | Tiền tệ | Currency | ok |  |
| vi | V7 | Liên kết trong bộ nhớ tạm | Link in the clipboard | ok |  |
| vi | V8 | Email trong bộ nhớ tạm | Email in the clipboard | ok |  |
| vi | V9 | Bộ đếm | Counter | ok |  |
| vi | S1 | Văn bản bạn vừa chép | The text you just copied | ok |  |
| vi | S2 | Bạn gõ tiếp tại đây | You keep typing here | ok |  |
| vi | GR1 | Chào buổi sáng | "Good morning". A normal way to open a message in the morning. | ok |  |
| vi | GR2 | Xin chào | "Hello". A neutral, polite greeting that works at any hour. It fits the afternoon because Vietnamese has no common afternoon greeting. | ok | Round 2; round 1 wrote Chào buổi chiều (Sounds like a textbook phrase. Vietnamese people rarely open a real message with 'Chào buổi chiều'. They write 'Chào anh/chị' or just 'Chào bạn'. 'Chào buổi sáng' and 'Chào buổi tối' are used far more.) |
| vi | GR3 | Chào buổi tối | "Good evening". Normal for an evening message. People also use it loosely late at night. | ok |  |
| zh-Hans | G4 | 设备 | Device | ok |  |
| zh-Hans | G5 | 数字与其他 | Numbers and other | ok |  |
| zh-Hans | V1 | 周数 | Week number | ok |  |
| zh-Hans | V2 | 时区 | Time zone | ok |  |
| zh-Hans | V3 | 问候语 | Greeting | ok |  |
| zh-Hans | V4 | 语言 | Language | ok |  |
| zh-Hans | V5 | 地区 | Region | ok |  |
| zh-Hans | V6 | 货币 | Currency | ok |  |
| zh-Hans | V7 | 剪贴板中的链接 | Link in the clipboard | ok |  |
| zh-Hans | V8 | 剪贴板中的电子邮件 | Email in the clipboard | ok |  |
| zh-Hans | V9 | 计数器 | Counter | ok |  |
| zh-Hans | S1 | 你最近拷贝的文本 | The text you copied most recently | ok |  |
| zh-Hans | S2 | 插入后在此处继续输入 | After inserting, keep typing here | ok |  |
| zh-Hans | GR1 | 早上好 | Good morning | ok |  |
| zh-Hans | GR2 | 下午好 | Good afternoon | ok |  |
| zh-Hans | GR3 | 晚上好 | Good evening | ok |  |
| zh-Hant | G4 | 裝置 | Device | ok |  |
| zh-Hant | G5 | 數學與其他 | Mathematics and other | ok |  |
| zh-Hant | V1 | 週數 | Week number | ok |  |
| zh-Hant | V2 | 時區 | Time zone | ok |  |
| zh-Hant | V3 | 問候語 | Greeting | ok |  |
| zh-Hant | V4 | 裝置語言 | Device language | ok |  |
| zh-Hant | V5 | 裝置地區 | Device region | ok |  |
| zh-Hant | V6 | 地區貨幣 | Regional currency | ok |  |
| zh-Hant | V7 | 剪貼板中的網址 | URL in the clipboard | ok |  |
| zh-Hant | V8 | 剪貼板中的電子郵件 | Email in the clipboard | ok |  |
| zh-Hant | V9 | 計數器 | Counter | ok |  |
| zh-Hant | S1 | 你最近拷貝的文字 | The text you copied most recently | ok |  |
| zh-Hant | S2 | 貼上後從這裡繼續輸入 | After pasting, keep typing from here | ok |  |
| zh-Hant | GR1 | 早安 | Good morning | ok |  |
| zh-Hant | GR2 | 午安 | Good afternoon (most natural around midday) | ok |  |
| zh-Hant | GR3 | 晚上好 | "Good evening". Understood, but it reads as Mainland or textbook phrasing. | see note | UNSURE: round 1 read 晚安 as a goodnight sign-off, round 2 prefers 晚安 as the Taiwan set with 早安 and 午安; 晚上好 never reads as leaving. |

### Hidden rows and group headers (not on screen yet)

One row per locale: each key's string, then any change or reader note. Every other hidden string read back as its brief meaning.

| Locale | Strings | Notes |
|---|---|---|
| ar | G1 أنا وجهات اتصالي · G2 الأماكن · G3 التقويم · R1 اسمي · R1s اسمك · R2 بريدي الإلكتروني · R2s بريدك الإلكتروني · R3 رقم هاتفي · R3s رقم هاتفك · R4 عنواني · R4s عنوانك · R5 جهة اتصال · R5s جهة اتصال اخترتها · R6 المدينة · R6s مكانك الآن · R7 الطقس الحالي · R8 غروب الشمس · R9 الحدث التالي · R10 الأوقات المتاحة · R11 أحداث اليوم · R11s أحداثك · R12 تذكيرات مستحقة · R12s تذكيراتك · R13 النص المحدد · R13s النص الذي حددته · R14 رقم بالحروف · R15 نتيجة اختصار · R15s ناتج تشغيل الاختصار |  |
| bg | G1 Аз и моите контакти · G2 Места · G3 Календар · R1 Моето име · R1s Вашето име · R2 Моят имейл · R2s Вашият имейл адрес · R3 Моят телефон · R3s Вашият телефонен номер · R4 Моят адрес · R4s Вашият адрес · R5 Избран контакт · R5s Контакт, който избрахте · R6 Текущ град · R6s Вашето местоположение · R7 Времето навън · R8 Залез днес · R9 Следващо събитие · R10 Свободни часове · R11 Програма за деня · R11s Вашите събития · R12 Предстоящи напомняния · R12s Вашите напомняния · R13 Избран текст · R13s Текстът, който избрахте · R14 Число с думи · R15 Резултат от бърза команда · R15s Каквото връща командата | R6s: Round 2; round 1 wrote Където се намирате (Standing alone, 'Където' is a relative word and the hint reads like half a sentence ('…where you are'). 'Мястото, където се намирате' or 'Къде се намирате' reads as a complete hint.) |
| bn | G1 আমি ও আমার কন্টাক্ট · G2 স্থান · G3 ক্যালেন্ডার · R1 আমার নাম · R1s আপনার নাম · R2 আমার ইমেল · R2s আপনার ইমেল ঠিকানা · R3 আমার ফোন নম্বর · R3s আপনার ফোন নম্বর · R4 আমার ঠিকানা · R4s আপনার ঠিকানা · R5 কন্টাক্ট · R5s আপনার বেছে নেওয়া কন্টাক্ট · R6 বর্তমান শহর · R6s আপনি এখন যেখানে আছেন · R7 এখনকার আবহাওয়া · R8 আজকের সূর্যাস্ত · R9 পরবর্তী ইভেন্ট · R10 ফাঁকা সময় · R11 আজকের সূচি · R11s আপনার ইভেন্টগুলো · R12 বাকি রিমাইন্ডার · R12s আপনার রিমাইন্ডারগুলো · R13 নির্বাচিত টেক্সট · R13s আপনার নির্বাচন করা টেক্সট · R14 সংখ্যা কথায় · R15 শর্টকাটের ফলাফল · R15s শর্টকাট চালানোর ফলাফল | G1: Round 2; round 1 wrote আমি ও আমার পরিচিতি (In everyday Bengali পরিচিতি mostly means introduction or profile, so the header can read as 'Me and my introduction'. It reads as contacts only to people used to Apple's word for it. 'আমি ও আমার কন্টাক্ট' or 'আমি ও আমার পরিচিতজন' removes the doubt.) R5: Round 2; round 1 wrote পরিচিতি (On its own, পরিচিতি most readily reads as 'introduction' or 'profile', not 'a contact'. Without context the label is ambiguous.) R5s: Round 2; round 1 wrote আপনার বেছে নেওয়া পরিচিতি (changed with a flagged key) |
| ca | G1 Jo i els meus contactes · G2 Llocs · G3 Calendari · R1 El meu nom · R1s El teu nom · R2 El meu correu · R2s La teva adreça de correu · R3 El meu telèfon · R3s El teu número de telèfon · R4 La meva adreça · R4s La teva adreça · R5 Contacte · R5s Un contacte que has triat · R6 Ciutat actual · R6s On ets ara · R7 El temps que fa · R8 Posta de sol · R9 Proper esdeveniment · R10 Hores lliures · R11 Agenda d’avui · R11s Els teus esdeveniments · R12 Recordatoris pendents · R12s Els teus recordatoris · R13 Text seleccionat · R13s El que has seleccionat · R14 Número en lletres · R15 Resultat de drecera · R15s El que retorna una drecera | R7: Round 2; round 1 wrote Temps actual ('Temps' means both weather and time, so 'Temps actual' easily reads as 'current time'. 'El temps que fa' or 'Temps meteorològic' is clear.) R13s: Round 2; round 1 wrote Text que has seleccionat (It is missing the article, which sounds clipped next to S1's 'El text que has copiat'. 'El text que has seleccionat' reads naturally.) |
| cs | G1 Já a moje kontakty · G2 Místa · G3 Kalendář · R1 Moje jméno · R1s Vaše jméno · R2 Můj e-mail · R2s Vaše e-mailová adresa · R3 Můj telefon · R3s Vaše telefonní číslo · R4 Moje adresa · R4s Vaše adresa · R5 Vybraný kontakt · R5s Vámi vybraný kontakt · R6 Aktuální město · R6s Kde se právě nacházíte · R7 Aktuální počasí · R8 Západ slunce · R9 Další událost · R10 Volné termíny · R11 Dnešní události · R11s Vaše události · R12 Připomínky k vyřízení · R12s Vaše připomínky · R13 Vybraný text · R13s Text, který jste vybrali · R14 Číslo slovy · R15 Výsledek zkratky · R15s Co vrátí vaše zkratka |  |
| da | G1 Mig og mine kontakter · G2 Steder · G3 Kalender · R1 Mit navn · R1s Dit navn · R2 Min e-mail · R2s Din e-mailadresse · R3 Mit telefonnummer · R3s Dit telefonnummer · R4 Min adresse · R4s Din adresse · R5 Kontakt · R5s En kontakt du har valgt · R6 Nuværende by · R6s Hvor du er nu · R7 Vejret nu · R8 Solnedgang · R9 Næste begivenhed · R10 Ledige tider · R11 Dagens begivenheder · R11s Dine begivenheder · R12 Forfaldne påmindelser · R12s Dine påmindelser · R13 Markeret tekst · R13s Teksten du har markeret · R14 Tal med bogstaver · R15 Resultat fra genvej · R15s Resultatet af din genvej |  |
| de | G1 Ich und meine Kontakte · G2 Orte · G3 Kalender · R1 Mein Name · R1s Dein Name · R2 Meine E-Mail-Adresse · R2s Deine E-Mail-Adresse · R3 Meine Telefonnummer · R3s Deine Telefonnummer · R4 Meine Adresse · R4s Deine Adresse · R5 Kontakt · R5s Dein gewählter Kontakt · R6 Aktuelle Stadt · R6s Wo du gerade bist · R7 Aktuelles Wetter · R8 Sonnenuntergang · R9 Nächstes Ereignis · R10 Freie Zeitfenster · R11 Heutige Ereignisse · R11s Deine Ereignisse · R12 Fällige Erinnerungen · R12s Deine Erinnerungen · R13 Ausgewählter Text · R13s Dein ausgewählter Text · R14 Zahl in Worten · R15 Kurzbefehl-Ergebnis · R15s Was der Kurzbefehl liefert |  |
| el | G1 Εγώ και οι επαφές μου · G2 Τοποθεσία · G3 Ημερολόγιο · R1 Το όνομά μου · R1s Το όνομά σας · R2 Το email μου · R2s Το email σας · R3 Το τηλέφωνό μου · R3s Το τηλέφωνό σας · R4 Η διεύθυνσή μου · R4s Η διεύθυνσή σας · R5 Επιλεγμένη επαφή · R5s Μια επαφή που επιλέξατε · R6 Τρέχουσα πόλη · R6s Η πόλη όπου βρίσκεστε · R7 Τρέχων καιρός · R8 Δύση ηλίου · R9 Επόμενο συμβάν · R10 Ελεύθερες ώρες · R11 Σημερινό πρόγραμμα · R11s Τα συμβάντα σας · R12 Εκκρεμείς υπομνήσεις · R12s Οι υπομνήσεις σας · R13 Επιλεγμένο κείμενο · R13s Το κείμενο που επιλέξατε · R14 Αριθμός ολογράφως · R15 Αποτέλεσμα συντόμευσης · R15s Ό,τι δίνει η συντόμευση | R6s: Round 2; round 1 wrote Πού βρίσκεστε τώρα (Accented 'Πού' is the question word, so on its own this reads as a direct question to the user, not a description of the value. 'Η πόλη όπου βρίσκεστε' or 'Η τοποθεσία σας τώρα' reads as a hint.) |
| es-MX | G1 Mis datos y contactos · G2 Lugares · G3 Calendario · R1 Mi nombre · R1s Tu nombre · R2 Mi correo · R2s Tu correo electrónico · R3 Mi teléfono · R3s Tu número de teléfono · R4 Mi dirección · R4s Tu dirección · R5 Contacto · R5s Un contacto que elegiste · R6 Ciudad actual · R6s Donde estás ahora · R7 Clima actual · R8 Puesta del sol · R9 Próximo evento · R10 Horarios libres · R11 Agenda de hoy · R11s Tus eventos · R12 Recordatorios · R12s Tus recordatorios · R13 Texto seleccionado · R13s El texto que seleccionaste · R14 Número con letra · R15 Resultado del atajo · R15s Lo que devuelve un atajo |  |
| es | G1 Mis datos y contactos · G2 Lugares · G3 Calendario · R1 Mi nombre · R1s Tu nombre · R2 Mi correo · R2s Tu correo electrónico · R3 Mi teléfono · R3s Tu número de teléfono · R4 Mi dirección · R4s Tu dirección · R5 Contacto · R5s Contacto que has elegido · R6 Ciudad actual · R6s Donde estás ahora · R7 Tiempo actual · R8 Puesta de sol · R9 Próximo evento · R10 Huecos libres · R11 Agenda de hoy · R11s Tus eventos · R12 Recordatorios de hoy · R12s Tus recordatorios · R13 Texto seleccionado · R13s Lo que has seleccionado · R14 Número en letra · R15 Resultado de un atajo · R15s Lo que devuelve un atajo |  |
| et | G1 Mina ja minu kontaktid · G2 Kohad · G3 Kalender · R1 Minu nimi · R1s Sinu nimi · R2 Minu e-post · R2s Sinu e-posti aadress · R3 Minu telefon · R3s Sinu telefoninumber · R4 Minu aadress · R4s Sinu aadress · R5 Kontakt · R5s Sinu valitud kontakt · R6 Praegune linn · R6s Kus sa praegu oled · R7 Ilm praegu · R8 Päikeseloojang · R9 Järgmine sündmus · R10 Vabad ajad · R11 Tänane päevakava · R11s Sinu sündmused · R12 Meeldetuletused · R12s Sinu meeldetuletused · R13 Valitud tekst · R13s Tekst, mille valisid · R14 Arv sõnadega · R15 Otsetee tulemus · R15s Mida otsetee tagastab |  |
| fa | G1 من و مخاطبینم · G2 مکان‌ها · G3 تقویم · R1 نام من · R1s نام شما · R2 ایمیل من · R2s نشانی ایمیل شما · R3 شماره تلفن من · R3s شماره تلفن شما · R4 نشانی من · R4s نشانی شما · R5 مخاطب انتخابی · R5s مخاطبی که انتخاب کردید · R6 شهر فعلی · R6s جایی که الان هستید · R7 آب‌وهوای فعلی · R8 ساعت غروب · R9 رویداد بعدی · R10 زمان‌های آزاد · R11 برنامه امروز · R11s رویدادهای شما · R12 یادآورهای سررسیدشده · R12s یادآورهای شما · R13 متن انتخاب‌شده · R13s متنی که انتخاب کردید · R14 عدد به حروف · R15 نتیجه میان‌بر · R15s نتیجه اجرای میان‌بر | R12: Round 2; round 1 wrote یادآورهای سررسید (With the ezafe, 'یادآورهای سررسید' reads as 'reminders of the due date' (like a cheque's maturity), not 'reminders that are due'. 'یادآورهای سررسیدشده' or 'یادآورهای موعددار' is clear.) |
| fi | G1 Minä ja yhteystietoni · G2 Sijainti · G3 Kalenteri · R1 Oma nimi · R1s Nimesi · R2 Oma sähköposti · R2s Sähköpostiosoitteesi · R3 Oma puhelinnumero · R3s Puhelinnumerosi · R4 Oma osoite · R4s Osoitteesi · R5 Yhteystieto · R5s Valitsemasi yhteystieto · R6 Nykyinen kaupunki · R6s Kaupunki, jossa olet · R7 Nykyinen sää · R8 Auringonlasku · R9 Seuraava tapahtuma · R10 Vapaat ajat · R11 Päivän tapahtumat · R11s Tapahtumasi · R12 Ajoitetut muistutukset · R12s Muistutuksesi · R13 Valittu teksti · R13s Valitsemasi teksti · R14 Luku sanoina · R15 Pikakomennon tulos · R15s Pikakomennon antama tulos | R6s: Round 2; round 1 wrote Missä olet nyt ('Missä' is only a question word ('jossa' is the relative), so on its own this reads as a question. 'Nykyinen sijaintisi' reads as a hint.) R15s: Round 2; round 1 wrote Mitä pikakomento palauttaa (On its own, 'Mitä … palauttaa' reads as a question. 'Pikakomennon palauttama arvo' or 'Pikakomennon tulos' describes the value.) |
| fil | G1 Ako at mga contact ko · G2 Mga lugar · G3 Kalendaryo · R1 Pangalan ko · R1s Ang pangalan mo · R2 Email ko · R2s Ang email mo · R3 Telepono ko · R3s Numero ng telepono mo · R4 Address ko · R4s Ang address mo · R5 Isang contact · R5s Contact na pinili mo · R6 Lungsod · R6s Kung nasaan ka ngayon · R7 Panahon ngayon · R8 Paglubog ng araw · R9 Susunod na event · R10 Mga bakanteng oras · R11 Agenda ngayong araw · R11s Ang mga event mo · R12 Mga takdang paalala · R12s Ang mga paalala mo · R13 Napiling text · R13s Ang text na pinili mo · R14 Numero sa salita · R15 Resulta ng shortcut · R15s Ang ibinabalik ng shortcut | R15s: Round 2; round 1 wrote Ibinabalik ng shortcut (Without 'Ang' this reads as a bare verb clause, not a noun phrase. 'Ang ibinabalik ng shortcut' ('what the shortcut returns') matches the other hints.) |
| fr-CA | G1 Moi et mes contacts · G2 Lieux · G3 Calendrier · R1 Mon nom · R1s Votre nom · R2 Mon courriel · R2s Votre adresse courriel · R3 Mon téléphone · R3s Votre téléphone · R4 Mon adresse · R4s Votre adresse · R5 Contact · R5s Un contact de votre choix · R6 Ville · R6s Là où vous êtes · R7 Météo actuelle · R8 Coucher du soleil · R9 Prochain événement · R10 Disponibilités · R11 Agenda du jour · R11s Vos événements · R12 Rappels en attente · R12s Vos rappels · R13 Texte sélectionné · R13s Le texte sélectionné · R14 Nombre en lettres · R15 Résultat de raccourci · R15s Le résultat du raccourci | R12: Round 2; round 1 wrote Rappels à faire ('faire un rappel' also means making a callback or sending a reminder, so it can read as reminders the user still has to send. 'Rappels en attente' or 'Rappels à venir' reads as pending reminders.) |
| fr | G1 Moi et mes contacts · G2 Lieux · G3 Calendrier · R1 Mon nom · R1s Votre nom · R2 Mon adresse e-mail · R2s Votre adresse e-mail · R3 Mon téléphone · R3s Votre numéro · R4 Mon adresse · R4s Votre adresse · R5 Contact · R5s Un contact de votre choix · R6 Ville actuelle · R6s Là où vous êtes · R7 Météo actuelle · R8 Coucher du soleil · R9 Prochain événement · R10 Créneaux libres · R11 Agenda du jour · R11s Vos événements · R12 Rappels en attente · R12s Vos rappels · R13 Texte sélectionné · R13s Votre sélection · R14 Nombre en toutes lettres · R15 Résultat du raccourci · R15s Valeur renvoyée | R12: Round 2; round 1 wrote Rappels à faire ('faire un rappel' also means making a callback or sending a reminder, so it can read as reminders the user still has to send. 'Rappels en attente' reads as pending reminders.) |
| gu | G1 હું અને મારા સંપર્કો · G2 સ્થળો · G3 કેલેન્ડર · R1 મારું નામ · R1s તમારું નામ · R2 મારો ઇમેઇલ · R2s તમારો ઇમેઇલ · R3 મારો ફોન નંબર · R3s તમારો ફોન નંબર · R4 મારું સરનામું · R4s તમારું સરનામું · R5 સંપર્ક · R5s તમે પસંદ કરેલો સંપર્ક · R6 શહેર · R6s તમે અત્યારે જ્યાં છો · R7 હવામાન · R8 સૂર્યાસ્ત · R9 આગામી ઇવેન્ટ · R10 ખાલી સમય · R11 આજનો કાર્યક્રમ · R11s તમારી ઇવેન્ટ્સ · R12 બાકી રિમાઇન્ડર · R12s તમારા રિમાઇન્ડર · R13 પસંદ કરેલું ટેક્સ્ટ · R13s તમે પસંદ કરેલું ટેક્સ્ટ · R14 શબ્દોમાં સંખ્યા · R15 શૉર્ટકટનું પરિણામ · R15s શૉર્ટકટ જે આપે તે |  |
| he | G1 אני ואנשי הקשר שלי · G2 מקומות · G3 לוח שנה · R1 השם שלי · R1s השם שלך · R2 הדוא״ל שלי · R2s כתובת הדוא״ל שלך · R3 הטלפון שלי · R3s מספר הטלפון שלך · R4 הכתובת שלי · R4s הכתובת שלך · R5 איש קשר · R5s איש קשר שבחרת · R6 העיר הנוכחית · R6s המיקום הנוכחי שלך · R7 מזג האוויר · R8 שעת השקיעה · R9 האירוע הבא · R10 שעות פנויות · R11 אירועי היום · R11s האירועים שלך · R12 תזכורות לביצוע · R12s התזכורות שלך · R13 הטקסט שנבחר · R13s הטקסט שבחרת · R14 מספר במילים · R15 תוצאת קיצור הדרך · R15s מה שקיצור הדרך מחזיר | R15: Round 2; round 1 wrote תוצאת קיצור (On its own 'קיצור' first reads as 'abbreviation'. Apple's Hebrew term is 'קיצור דרך' (app 'קיצורים'), so 'תוצאת קיצור הדרך' says it plainly. R15s 'הקיצור' has the same weaker ambiguity.) R15s: Round 2; round 1 wrote מה שהקיצור מחזיר (changed with a flagged key) |
| hi | G1 मैं और मेरे संपर्क · G2 स्थान · G3 कैलेंडर · R1 मेरा नाम · R1s आपका नाम · R2 मेरा ईमेल · R2s आपका ईमेल पता · R3 मेरा फ़ोन नंबर · R3s आपका फ़ोन नंबर · R4 मेरा पता · R4s आपका पता · R5 संपर्क · R5s आपका चुना हुआ संपर्क · R6 शहर · R6s आप अभी जहाँ हैं · R7 मौसम · R8 सूर्यास्त · R9 अगला इवेंट · R10 खाली समय · R11 आज का कार्यक्रम · R11s आपके इवेंट · R12 बाकी रिमाइंडर · R12s आपके रिमाइंडर · R13 चुना गया टेक्स्ट · R13s आपने जो टेक्स्ट चुना · R14 शब्दों में संख्या · R15 शॉर्टकट का परिणाम · R15s शॉर्टकट से मिला परिणाम |  |
| hr | G1 Ja i moji kontakti · G2 Mjesta · G3 Kalendar · R1 Moje ime · R1s Vaše ime · R2 Moj e-mail · R2s Vaša e-mail adresa · R3 Moj broj telefona · R3s Vaš broj telefona · R4 Moja adresa · R4s Vaša adresa · R5 Odabrani kontakt · R5s Kontakt koji ste odabrali · R6 Trenutni grad · R6s Gdje ste sada · R7 Vremenske prilike · R8 Zalazak sunca · R9 Sljedeći događaj · R10 Slobodni termini · R11 Današnji raspored · R11s Vaši događaji · R12 Dospjeli podsjetnici · R12s Vaši podsjetnici · R13 Odabrani tekst · R13s Tekst koji ste odabrali · R14 Broj riječima · R15 Rezultat prečaca · R15s Ono što prečac vrati |  |
| hu | G1 Saját adatok és kontaktok · G2 Helyek · G3 Naptár · R1 Saját név · R1s A neved · R2 Saját e-mail-cím · R2s Az e-mail-címed · R3 Saját telefonszám · R3s A telefonszámod · R4 Saját cím · R4s A címed · R5 Kiválasztott kontakt · R5s A kiválasztott kontaktod · R6 Jelenlegi város · R6s Ahol most vagy · R7 Jelenlegi időjárás · R8 Mai napnyugta · R9 Következő esemény · R10 Szabad időpontok · R11 Mai napirend · R11s Az eseményeid · R12 Esedékes emlékeztetők · R12s Az emlékeztetőid · R13 Kijelölt szöveg · R13s Amit kijelöltél · R14 Szám betűvel · R15 Parancs eredménye · R15s Amit a parancs visszaad |  |
| id | G1 Saya dan kontak saya · G2 Lokasi · G3 Kalender · R1 Nama saya · R1s Nama Anda · R2 Email saya · R2s Alamat email Anda · R3 Nomor telepon saya · R3s Nomor telepon Anda · R4 Alamat saya · R4s Alamat Anda · R5 Kontak yang dipilih · R5s Kontak yang Anda pilih · R6 Kota saat ini · R6s Lokasi Anda sekarang · R7 Cuaca sekarang · R8 Matahari terbenam · R9 Acara berikutnya · R10 Waktu luang · R11 Agenda hari ini · R11s Acara Anda · R12 Pengingat jatuh tempo · R12s Pengingat Anda · R13 Teks terpilih · R13s Teks yang Anda pilih · R14 Angka terbilang · R15 Hasil pintasan · R15s Hasil pintasan Anda | R5: Round 2; round 1 wrote Kontak pilihan ('pilihan' as an adjective usually means 'featured' or 'preferred' (as in 'produk pilihan'), so the label reads like a favourite contact, not one you pick each time. 'Kontak yang dipilih' or 'Pilih kontak' would be clear.) |
| it | G1 Io e i miei contatti · G2 Luoghi · G3 Calendario · R1 Il mio nome · R1s Il tuo nome · R2 La mia email · R2s Il tuo indirizzo email · R3 Il mio telefono · R3s Il tuo numero · R4 Il mio indirizzo · R4s Il tuo indirizzo · R5 Contatto · R5s Un contatto che hai scelto · R6 Città attuale · R6s Dove ti trovi ora · R7 Meteo attuale · R8 Ora del tramonto · R9 Prossimo evento · R10 Orari liberi · R11 Agenda di oggi · R11s I tuoi eventi · R12 Promemoria in scadenza · R12s I tuoi promemoria · R13 Testo selezionato · R13s Testo che hai selezionato · R14 Numero in lettere · R15 Risultato comando rapido · R15s Il risultato del comando |  |
| ja | G1 自分と連絡先 · G2 場所 · G3 カレンダー · R1 自分の名前 · R1s あなたの名前 · R2 自分のメールアドレス · R2s あなたのメールアドレス · R3 自分の電話番号 · R3s あなたの電話番号 · R4 自分の住所 · R4s あなたの住所 · R5 連絡先 · R5s 選択した連絡先 · R6 現在の都市 · R6s 今いる場所 · R7 現在の天気 · R8 今日の日の入り · R9 次の予定 · R10 空き時間 · R11 今日の予定 · R11s あなたの予定 · R12 期限が来たリマインダー · R12s あなたのリマインダー · R13 選択中のテキスト · R13s 選択したテキスト · R14 漢数字 · R15 ショートカットの結果 · R15s ショートカットが返す値 | R12: Round 2; round 1 wrote 期限のリマインダー (The 'の' links these words unnaturally, so it reads like 'a deadline's reminder'. Natives would write '期限が来たリマインダー' or '期限切れのリマインダー'.) |
| kn | G1 ನಾನು, ನನ್ನ ಸಂಪರ್ಕಗಳು · G2 ಸ್ಥಳಗಳು · G3 ಕ್ಯಾಲೆಂಡರ್ · R1 ನನ್ನ ಹೆಸರು · R1s ನಿಮ್ಮ ಹೆಸರು · R2 ನನ್ನ ಇಮೇಲ್ · R2s ನಿಮ್ಮ ಇಮೇಲ್ ವಿಳಾಸ · R3 ನನ್ನ ಫೋನ್ ಸಂಖ್ಯೆ · R3s ನಿಮ್ಮ ಫೋನ್ ಸಂಖ್ಯೆ · R4 ನನ್ನ ವಿಳಾಸ · R4s ನಿಮ್ಮ ವಿಳಾಸ · R5 ಸಂಪರ್ಕ · R5s ನೀವು ಆರಿಸಿದ ಸಂಪರ್ಕ · R6 ಈಗಿನ ನಗರ · R6s ನೀವು ಈಗ ಇರುವ ಸ್ಥಳ · R7 ಈಗಿನ ಹವಾಮಾನ · R8 ಇಂದಿನ ಸೂರ್ಯಾಸ್ತ · R9 ಮುಂದಿನ ಈವೆಂಟ್ · R10 ಬಿಡುವಿನ ಸಮಯ · R11 ಇಂದಿನ ಕಾರ್ಯಸೂಚಿ · R11s ನಿಮ್ಮ ಈವೆಂಟ್‌ಗಳು · R12 ಬಾಕಿ ಜ್ಞಾಪನೆಗಳು · R12s ನಿಮ್ಮ ಜ್ಞಾಪನೆಗಳು · R13 ಆಯ್ದ ಪಠ್ಯ · R13s ನೀವು ಆಯ್ದ ಪಠ್ಯ · R14 ಸಂಖ್ಯೆ ಅಕ್ಷರಗಳಲ್ಲಿ · R15 ಶಾರ್ಟ್‌ಕಟ್ ಫಲಿತಾಂಶ · R15s ಶಾರ್ಟ್‌ಕಟ್ ನೀಡುವ ಫಲಿತಾಂಶ |  |
| ko | G1 내 정보 및 연락처 · G2 위치 · G3 캘린더 · R1 내 이름 · R1s 내 카드의 이름 · R2 내 이메일 · R2s 내 카드의 이메일 · R3 내 전화번호 · R3s 내 카드의 전화번호 · R4 내 주소 · R4s 내 카드의 주소 · R5 연락처 · R5s 직접 선택한 연락처 · R6 현재 도시 · R6s 지금 있는 곳 · R7 현재 날씨 · R8 오늘 일몰 시간 · R9 다음 이벤트 · R10 빈 시간 · R11 오늘 일정 · R11s 오늘의 이벤트 목록 · R12 기한이 된 미리 알림 · R12s 내 미리 알림 · R13 선택한 텍스트 · R13s 지금 선택된 텍스트 · R14 한글로 쓴 숫자 · R15 단축어 결과 · R15s 단축어가 돌려준 값 |  |
| lt | G1 Aš ir mano kontaktai · G2 Vietos · G3 Kalendorius · R1 Mano vardas · R1s Jūsų vardas · R2 Mano el. paštas · R2s Jūsų el. pašto adresas · R3 Mano telefonas · R3s Jūsų telefono numeris · R4 Mano adresas · R4s Jūsų adresas · R5 Kontaktas · R5s Jūsų pasirinktas kontaktas · R6 Dabartinis miestas · R6s Kur esate dabar · R7 Orai dabar · R8 Saulėlydis · R9 Kitas įvykis · R10 Laisvas laikas · R11 Šiandienos įvykiai · R11s Jūsų įvykiai · R12 Priminimai · R12s Jūsų priminimai · R13 Pažymėtas tekstas · R13s Jūsų pažymėtas tekstas · R14 Skaičius žodžiais · R15 Shortcuts rezultatas · R15s Shortcuts pateiktas rezultatas | R15: Round 3: the genitive-first form the round-2 reader named; not read again. R15s: UNSURE: round 3 set by the orchestrator to avoid komanda (also 'team'); not read again. |
| lv | G1 Es un mani kontakti · G2 Vietas · G3 Kalendārs · R1 Mans vārds · R1s Jūsu vārds · R2 Mans e-pasts · R2s Jūsu e-pasta adrese · R3 Mans tālrunis · R3s Jūsu tālruņa numurs · R4 Mana adrese · R4s Jūsu adrese · R5 Izvēlētais kontakts · R5s Jūsu izvēlētais kontakts · R6 Pašreizējā pilsēta · R6s Jūsu atrašanās vieta · R7 Laikapstākļi · R8 Šodienas saulriets · R9 Nākamais notikums · R10 Brīvais laiks · R11 Šodienas notikumi · R11s Jūsu notikumi · R12 Aktuālie atgādinājumi · R12s Jūsu atgādinājumi · R13 Atlasītais teksts · R13s Teksts, ko atlasījāt · R14 Skaitlis vārdiem · R15 Īsceļa rezultāts · R15s Jūsu īsceļa rezultāts | R5s: Round 2; round 1 wrote Jūsu izvēlēts kontakts (The indefinite 'izvēlēts' reads as 'some contact you chose'. For a specific contact natives use the definite form: 'Jūsu izvēlētais kontakts'.) R6s: Round 2; round 1 wrote Kur jūs esat tagad ('jūs' is lowercase here, while every other hint capitalises the polite 'Jūsu', so the list is inconsistent.) |
| ml | G1 ഞാനും കോൺടാക്റ്റുകളും · G2 സ്ഥലങ്ങൾ · G3 കലണ്ടർ · R1 എന്റെ പേര് · R1s നിങ്ങളുടെ പേര് · R2 എന്റെ ഇമെയിൽ · R2s നിങ്ങളുടെ ഇമെയിൽ വിലാസം · R3 എന്റെ ഫോൺ നമ്പർ · R3s നിങ്ങളുടെ ഫോൺ നമ്പർ · R4 എന്റെ വിലാസം · R4s നിങ്ങളുടെ വിലാസം · R5 കോൺടാക്റ്റ് · R5s നിങ്ങൾ തിരഞ്ഞെടുത്ത കോൺടാക്റ്റ് · R6 നിലവിലെ നഗരം · R6s നിങ്ങൾ ഇപ്പോഴുള്ള സ്ഥലം · R7 നിലവിലെ കാലാവസ്ഥ · R8 സൂര്യാസ്തമയം · R9 അടുത്ത ഇവന്റ് · R10 ഒഴിവുള്ള സമയം · R11 ഇന്നത്തെ ഇവന്റുകൾ · R11s നിങ്ങളുടെ ഇവന്റുകൾ · R12 സമയമായ ഓർമ്മപ്പെടുത്തലുകൾ · R12s നിങ്ങളുടെ ഓർമ്മപ്പെടുത്തലുകൾ · R13 തിരഞ്ഞെടുത്ത വാചകം · R13s നിങ്ങൾ തിരഞ്ഞെടുത്ത വാചകം · R14 സംഖ്യ അക്ഷരത്തിൽ · R15 കുറുക്കുവഴിയുടെ ഫലം · R15s കുറുക്കുവഴി നൽകുന്ന ഫലം |  |
| mr | G1 मी आणि माझे संपर्क · G2 ठिकाणे · G3 कॅलेंडर · R1 माझे नाव · R1s तुमचे नाव · R2 माझा ईमेल · R2s तुमचा ईमेल पत्ता · R3 माझा फोन नंबर · R3s तुमचा फोन नंबर · R4 माझा पत्ता · R4s तुमचा पत्ता · R5 निवडलेला संपर्क · R5s तुम्ही निवडलेला संपर्क · R6 सध्याचे शहर · R6s तुम्ही आता जिथे आहात · R7 सध्याचे हवामान · R8 सूर्यास्त · R9 पुढील इव्हेंट · R10 मोकळा वेळ · R11 आजचे इव्हेंट · R11s तुमचे इव्हेंट · R12 बाकी रिमाइंडर · R12s तुमचे रिमाइंडर · R13 निवडलेला मजकूर · R13s तुम्ही निवडलेला मजकूर · R14 अक्षरी संख्या · R15 शॉर्टकटचा निकाल · R15s शॉर्टकट जे परत देतो ते |  |
| ms | G1 Saya dan kenalan saya · G2 Tempat · G3 Kalendar · R1 Nama Saya · R1s Nama anda · R2 E-mel Saya · R2s Alamat e-mel anda · R3 Nombor Telefon Saya · R3s Nombor telefon anda · R4 Alamat Saya · R4s Alamat anda · R5 Kenalan · R5s Kenalan yang anda pilih · R6 Bandar Semasa · R6s Lokasi anda sekarang · R7 Cuaca Semasa · R8 Matahari Terbenam · R9 Acara Seterusnya · R10 Slot Masa Lapang · R11 Agenda Hari Ini · R11s Acara anda · R12 Peringatan Hari Ini · R12s Peringatan anda · R13 Teks Dipilih · R13s Teks yang anda pilih · R14 Nombor dalam Perkataan · R15 Hasil Pintasan · R15s Hasil daripada pintasan |  |
| nb | G1 Meg og kontaktene mine · G2 Steder · G3 Kalender · R1 Mitt navn · R1s Navnet ditt · R2 Min e-postadresse · R2s E-postadressen din · R3 Mitt telefonnummer · R3s Telefonnummeret ditt · R4 Min adresse · R4s Adressen din · R5 Kontakt · R5s En kontakt du har valgt · R6 By · R6s Der du er nå · R7 Været nå · R8 Solnedgang · R9 Neste hendelse · R10 Ledig tid · R11 Dagens hendelser · R11s Hendelsene dine · R12 Påminnelser · R12s Påminnelsene dine · R13 Markert tekst · R13s Teksten du markerte · R14 Tall med bokstaver · R15 Resultat fra snarvei · R15s Resultatet av en snarvei |  |
| nl | G1 Mijn gegevens en contacten · G2 Locatie · G3 Agenda · R1 Mijn naam · R1s Je naam · R2 Mijn e-mailadres · R2s Je e-mailadres · R3 Mijn telefoonnummer · R3s Je telefoonnummer · R4 Mijn adres · R4s Je adres · R5 Gekozen contact · R5s Een contact dat je koos · R6 Huidige stad · R6s Waar je nu bent · R7 Huidig weer · R8 Zonsondergang · R9 Volgende activiteit · R10 Vrije momenten · R11 Agenda van vandaag · R11s Je activiteiten · R12 Open herinneringen · R12s Je herinneringen · R13 Geselecteerde tekst · R13s Tekst die je selecteerde · R14 Getal in woorden · R15 Resultaat van opdracht · R15s Wat je opdracht teruggeeft |  |
| or | G1 ମୁଁ ଓ ମୋ ଯୋଗାଯୋଗ · G2 ସ୍ଥାନ · G3 କ୍ୟାଲେଣ୍ଡର · R1 ମୋ ନାମ · R1s ଆପଣଙ୍କ ନାମ · R2 ମୋ ଇମେଲ · R2s ଆପଣଙ୍କ ଇମେଲ ଠିକଣା · R3 ମୋ ଫୋନ ନମ୍ବର · R3s ଆପଣଙ୍କ ଫୋନ ନମ୍ବର · R4 ମୋ ଠିକଣା · R4s ଆପଣଙ୍କ ଠିକଣା · R5 ଯୋଗାଯୋଗ · R5s ଆପଣ ବାଛିଥିବା ଯୋଗାଯୋଗ · R6 ସହର · R6s ଆପଣ ଏବେ ଯେଉଁଠି ଅଛନ୍ତି · R7 ପାଣିପାଗ · R8 ସୂର୍ଯ୍ୟାସ୍ତ · R9 ପରବର୍ତ୍ତୀ ଇଭେଣ୍ଟ · R10 ଖାଲି ସମୟ · R11 ଆଜିର କାର୍ଯ୍ୟସୂଚୀ · R11s ଆପଣଙ୍କ ଇଭେଣ୍ଟ · R12 ବାକି ରିମାଇଣ୍ଡର · R12s ଆପଣଙ୍କ ରିମାଇଣ୍ଡର · R13 ଚୟନିତ ଟେକ୍ସଟ · R13s ଆପଣ ଚୟନ କରିଥିବା ଟେକ୍ସଟ · R14 ଶବ୍ଦରେ ସଂଖ୍ୟା · R15 ସର୍ଟକଟର ଫଳାଫଳ · R15s ଆପଣଙ୍କ ସର୍ଟକଟର ଫଳାଫଳ |  |
| pa | G1 ਮੈਂ ਅਤੇ ਮੇਰੇ ਸੰਪਰਕ · G2 ਥਾਵਾਂ · G3 ਕੈਲੰਡਰ · R1 ਮੇਰਾ ਨਾਮ · R1s ਤੁਹਾਡਾ ਨਾਮ · R2 ਮੇਰੀ ਈਮੇਲ · R2s ਤੁਹਾਡੀ ਈਮੇਲ · R3 ਮੇਰਾ ਫ਼ੋਨ ਨੰਬਰ · R3s ਤੁਹਾਡਾ ਫ਼ੋਨ ਨੰਬਰ · R4 ਮੇਰਾ ਪਤਾ · R4s ਤੁਹਾਡਾ ਪਤਾ · R5 ਸੰਪਰਕ · R5s ਤੁਹਾਡਾ ਚੁਣਿਆ ਸੰਪਰਕ · R6 ਸ਼ਹਿਰ · R6s ਤੁਸੀਂ ਹੁਣ ਜਿੱਥੇ ਹੋ · R7 ਮੌਸਮ · R8 ਸੂਰਜ ਡੁੱਬਣ ਦਾ ਸਮਾਂ · R9 ਅਗਲਾ ਇਵੈਂਟ · R10 ਖ਼ਾਲੀ ਸਮਾਂ · R11 ਅੱਜ ਦੇ ਇਵੈਂਟ · R11s ਤੁਹਾਡੇ ਇਵੈਂਟ · R12 ਬਕਾਇਆ ਰਿਮਾਈਂਡਰ · R12s ਤੁਹਾਡੇ ਰਿਮਾਈਂਡਰ · R13 ਚੁਣਿਆ ਟੈਕਸਟ · R13s ਤੁਹਾਡਾ ਚੁਣਿਆ ਟੈਕਸਟ · R14 ਸ਼ਬਦਾਂ ਵਿੱਚ ਨੰਬਰ · R15 ਸ਼ਾਰਟਕੱਟ ਦਾ ਨਤੀਜਾ · R15s ਸ਼ਾਰਟਕੱਟ ਤੋਂ ਮਿਲਿਆ ਨਤੀਜਾ | R15s: Round 2; round 1 wrote ਸ਼ਾਰਟਕੱਟ ਜੋ ਵਾਪਸ ਦੇਵੇ (The head noun is 'shortcut', so it reads as 'a shortcut which returns', not as the value the shortcut returns. 'ਜੋ ਸ਼ਾਰਟਕੱਟ ਵਾਪਸ ਦੇਵੇ' would read as 'what the shortcut returns'.) |
| pl | G1 Ja i moje kontakty · G2 Miejsca · G3 Kalendarz · R1 Moje imię i nazwisko · R1s Twoje imię i nazwisko · R2 Mój adres e-mail · R2s Twój adres e-mail · R3 Mój numer telefonu · R3s Twój numer telefonu · R4 Mój adres · R4s Twój adres · R5 Kontakt · R5s Wybrany kontakt · R6 Obecne miasto · R6s Tam, gdzie teraz jesteś · R7 Aktualna pogoda · R8 Zachód słońca · R9 Następne wydarzenie · R10 Wolne terminy · R11 Dzisiejsze wydarzenia · R11s Twoje wydarzenia · R12 Przypomnienia na dziś · R12s Twoje przypomnienia · R13 Zaznaczony tekst · R13s Twój zaznaczony tekst · R14 Liczba słownie · R15 Wynik skrótu · R15s To, co zwraca skrót |  |
| pt-BR | G1 Eu e meus contatos · G2 Lugares · G3 Calendário · R1 Meu nome · R1s Seu nome · R2 Meu e-mail · R2s Seu e-mail · R3 Meu telefone · R3s Seu número de telefone · R4 Meu endereço · R4s Seu endereço · R5 Contato · R5s Contato que você escolheu · R6 Cidade atual · R6s Onde você está agora · R7 Clima atual · R8 Pôr do sol · R9 Próximo evento · R10 Horários livres · R11 Agenda de hoje · R11s Seus eventos · R12 Lembretes pendentes · R12s Seus lembretes · R13 Texto selecionado · R13s Texto que você selecionou · R14 Número por extenso · R15 Resultado do atalho · R15s O que o atalho retorna |  |
| pt | G1 Eu e os meus contactos · G2 Locais · G3 Calendário · R1 O meu nome · R1s O seu nome · R2 O meu e-mail · R2s O seu e-mail · R3 O meu telefone · R3s O seu número de telefone · R4 A minha morada · R4s A sua morada · R5 Contacto · R5s Um contacto que escolheu · R6 Cidade atual · R6s Onde está agora · R7 Meteorologia · R8 Pôr do sol · R9 Próximo evento · R10 Horários livres · R11 Agenda de hoje · R11s Os seus eventos · R12 Lembretes pendentes · R12s Os seus lembretes · R13 Texto selecionado · R13s O texto que selecionou · R14 Número por extenso · R15 Resultado do atalho · R15s O que o atalho devolve |  |
| ro | G1 Eu și contactele mele · G2 Locuri · G3 Calendar · R1 Numele meu · R1s Numele tău · R2 E-mailul meu · R2s Adresa ta de e-mail · R3 Telefonul meu · R3s Numărul tău de telefon · R4 Adresa mea · R4s Adresa ta · R5 Contact ales · R5s Un contact ales de tine · R6 Orașul curent · R6s Unde te afli acum · R7 Vremea acum · R8 Apusul de azi · R9 Următorul eveniment · R10 Intervale libere · R11 Agenda de azi · R11s Evenimentele tale · R12 Mementouri scadente · R12s Mementourile tale · R13 Textul selectat · R13s Ce ai selectat · R14 Număr în litere · R15 Rezultatul scurtăturii · R15s Ce returnează scurtătura |  |
| ru | G1 Я и мои контакты · G2 Места · G3 Календарь · R1 Мое имя · R1s Ваше имя · R2 Мой e-mail · R2s Ваш e-mail · R3 Мой телефон · R3s Ваш номер телефона · R4 Мой адрес · R4s Ваш адрес · R5 Контакт · R5s Выбранный вами контакт · R6 Город · R6s Где вы сейчас · R7 Текущая погода · R8 Время заката · R9 Следующее событие · R10 Свободные окна · R11 События на сегодня · R11s Ваши события · R12 Напоминания · R12s Ваши напоминания · R13 Выделенный текст · R13s Текст, который вы выделили · R14 Число прописью · R15 Результат быстрой команды · R15s Что выдаст быстрая команда | R10: Round 2; round 1 wrote Свободное время ('Свободное время' first reads as leisure time, not open slots in a calendar. 'Свободные окна' or 'Свободные слоты' says that clearly.) |
| sk | G1 Ja a moje kontakty · G2 Miesta · G3 Kalendár · R1 Moje meno · R1s Vaše meno · R2 Môj e-mail · R2s Vaša e-mailová adresa · R3 Môj telefón · R3s Vaše telefónne číslo · R4 Moja adresa · R4s Vaša adresa · R5 Kontakt · R5s Kontakt, ktorý ste vybrali · R6 Aktuálne mesto · R6s Kde sa práve nachádzate · R7 Aktuálne počasie · R8 Západ slnka · R9 Ďalšia udalosť · R10 Voľné termíny · R11 Dnešné udalosti · R11s Vaše udalosti · R12 Aktuálne pripomienky · R12s Vaše pripomienky · R13 Označený text · R13s Text, ktorý ste označili · R14 Číslo slovom · R15 Výsledok skratky · R15s Čo vráti skratka |  |
| sl | G1 Jaz in moji stiki · G2 Kraji · G3 Koledar · R1 Moje ime · R1s Vaše ime · R2 Moj e-poštni naslov · R2s Vaš e-poštni naslov · R3 Moj telefon · R3s Vaša telefonska številka · R4 Moj naslov · R4s Vaš naslov · R5 Izbrani stik · R5s Stik, ki ste ga izbrali · R6 Trenutno mesto · R6s Kraj, kjer ste zdaj · R7 Trenutno vreme · R8 Sončni zahod · R9 Naslednji dogodek · R10 Prosti termini · R11 Današnji razpored · R11s Vaši dogodki · R12 Zapadli opomniki · R12s Vaši opomniki · R13 Izbrano besedilo · R13s Kar ste izbrali · R14 Število z besedami · R15 Rezultat bližnjice · R15s Kar vrne bližnjica |  |
| sr | G1 Ја и моји контакти · G2 Места · G3 Календар · R1 Моје име · R1s Ваше име · R2 Мој имејл · R2s Ваша имејл адреса · R3 Мој број телефона · R3s Ваш број телефона · R4 Моја адреса · R4s Ваша адреса · R5 Изабрани контакт · R5s Контакт који сте изабрали · R6 Тренутни град · R6s Где се сада налазите · R7 Временски услови · R8 Залазак сунца · R9 Следећи догађај · R10 Слободни термини · R11 Данашњи распоред · R11s Ваши догађаји · R12 Доспели подсетници · R12s Ваши подсетници · R13 Изабрани текст · R13s Текст који сте изабрали · R14 Број словима · R15 Резултат пречице · R15s Оно што пречица врати |  |
| sv | G1 Jag och mina kontakter · G2 Platser · G3 Kalender · R1 Mitt namn · R1s Ditt namn · R2 Min e-postadress · R2s Din e-postadress · R3 Mitt telefonnummer · R3s Ditt telefonnummer · R4 Min adress · R4s Din adress · R5 Kontakt · R5s En kontakt du valt · R6 Aktuell stad · R6s Där du är nu · R7 Aktuellt väder · R8 Solnedgång · R9 Nästa händelse · R10 Lediga tider · R11 Dagens händelser · R11s Dina händelser · R12 Aktuella påminnelser · R12s Dina påminnelser · R13 Markerad text · R13s Texten du markerat · R14 Tal med bokstäver · R15 Resultat från genväg · R15s Det genvägen returnerar |  |
| sw | G1 Mimi na waasiliani wangu · G2 Maeneo · G3 Kalenda · R1 Jina langu · R1s Jina lako · R2 Barua pepe yangu · R2s Barua pepe yako · R3 Namba yangu ya simu · R3s Namba yako ya simu · R4 Anwani yangu · R4s Anwani yako · R5 Mwasiliani · R5s Mwasiliani uliyemchagua · R6 Mji nilipo · R6s Mahali ulipo sasa · R7 Hali ya hewa · R8 Saa ya machweo · R9 Tukio linalofuata · R10 Muda ulio wazi · R11 Ratiba ya leo · R11s Matukio yako · R12 Vikumbusho vilivyofika · R12s Vikumbusho vyako · R13 Maneno yaliyochaguliwa · R13s Maandishi uliyochagua · R14 Namba kwa maneno · R15 Matokeo ya njia ya mkato · R15s Kile njia ya mkato inatoa |  |
| ta | G1 நானும் என் தொடர்புகளும் · G2 இடங்கள் · G3 கேலெண்டர் · R1 என் பெயர் · R1s உங்கள் பெயர் · R2 என் மின்னஞ்சல் · R2s உங்கள் மின்னஞ்சல் முகவரி · R3 என் ஃபோன் எண் · R3s உங்கள் ஃபோன் எண் · R4 என் முகவரி · R4s உங்கள் முகவரி · R5 தொடர்பு · R5s நீங்கள் தேர்ந்தெடுத்த தொடர்பு · R6 தற்போதைய நகரம் · R6s நீங்கள் இருக்கும் இடம் · R7 தற்போதைய வானிலை · R8 சூரிய அஸ்தமனம் · R9 அடுத்த நிகழ்வு · R10 காலியான நேரங்கள் · R11 இன்றைய நிகழ்வுகள் · R11s உங்கள் நிகழ்வுகள் · R12 நிலுவை நினைவூட்டல்கள் · R12s உங்கள் நினைவூட்டல்கள் · R13 தேர்ந்தெடுத்த உரை · R13s நீங்கள் தேர்ந்தெடுத்த உரை · R14 எழுத்தில் எண் · R15 ஷார்ட்கட் முடிவு · R15s ஷார்ட்கட் தரும் முடிவு |  |
| te | G1 నేను, నా కాంటాక్ట్‌లు · G2 స్థలాలు · G3 క్యాలెండర్ · R1 నా పేరు · R1s మీ పేరు · R2 నా ఇమెయిల్ · R2s మీ ఇమెయిల్ చిరునామా · R3 నా ఫోన్ నంబర్ · R3s మీ ఫోన్ నంబర్ · R4 నా చిరునామా · R4s మీ చిరునామా · R5 కాంటాక్ట్ · R5s మీరు ఎంచుకున్న కాంటాక్ట్ · R6 ప్రస్తుత నగరం · R6s మీరు ఇప్పుడున్న చోటు · R7 ప్రస్తుత వాతావరణం · R8 సూర్యాస్తమయం · R9 తదుపరి ఈవెంట్ · R10 ఖాళీ సమయాలు · R11 ఈరోజు ఈవెంట్‌లు · R11s మీ ఈవెంట్‌లు · R12 గడువైన రిమైండర్‌లు · R12s మీ రిమైండర్‌లు · R13 ఎంచుకున్న టెక్స్ట్ · R13s మీరు ఎంచుకున్న టెక్స్ట్ · R14 అక్షరాల్లో సంఖ్య · R15 షార్ట్‌కట్ ఫలితం · R15s షార్ట్‌కట్ ఇచ్చే ఫలితం |  |
| th | G1 ฉันและรายชื่อ · G2 สถานที่ · G3 ปฏิทิน · R1 ชื่อของฉัน · R1s ชื่อของคุณ · R2 อีเมลของฉัน · R2s อีเมลของคุณ · R3 เบอร์โทรของฉัน · R3s เบอร์โทรของคุณ · R4 ที่อยู่ของฉัน · R4s ที่อยู่ของคุณ · R5 รายชื่อ · R5s รายชื่อที่คุณเลือกไว้ · R6 เมืองปัจจุบัน · R6s ที่ที่คุณอยู่ตอนนี้ · R7 สภาพอากาศ · R8 พระอาทิตย์ตก · R9 เหตุการณ์ถัดไป · R10 ช่วงเวลาว่าง · R11 กำหนดการวันนี้ · R11s เหตุการณ์ของคุณ · R12 เตือนความจำที่ถึงกำหนด · R12s เตือนความจำของคุณ · R13 ข้อความที่เลือก · R13s ข้อความที่คุณเลือกไว้ · R14 ตัวเลขเป็นตัวอักษร · R15 ผลลัพธ์คำสั่งลัด · R15s สิ่งที่คำสั่งลัดส่งกลับมา |  |
| tr | G1 Ben ve kişilerim · G2 Konum · G3 Takvim · R1 Ad Soyadım · R1s Ad soyadınız · R2 E-posta Adresim · R2s E-posta adresiniz · R3 Telefon Numaram · R3s Telefon numaranız · R4 Adresim · R4s Adresiniz · R5 Kişi · R5s Seçtiğiniz bir kişi · R6 Şehir · R6s Şu an bulunduğunuz yer · R7 Hava Durumu · R8 Gün Batımı · R9 Sonraki Etkinlik · R10 Müsait Saatler · R11 Bugünün Programı · R11s Etkinlikleriniz · R12 Bekleyen Anımsatıcılar · R12s Anımsatıcılarınız · R13 Seçili Metin · R13s Seçtiğiniz metin · R14 Yazıyla Sayı · R15 Kestirme Sonucu · R15s Bir kestirmenin sonucu | R1: Round 2; round 1 wrote Adım ('Adım' is first read as the noun 'step', and only from context as 'my name'. In a list row or a pill it's ambiguous. 'Ad Soyadım' or 'Benim Adım' avoids this.) R1s: Round 2; round 1 wrote Adınız (changed with a flagged key) |
| uk | G1 Я та мої контакти · G2 Місця · G3 Календар · R1 Моє ім’я · R1s Ваше ім’я · R2 Моя е-пошта · R2s Ваша адреса е-пошти · R3 Мій номер телефону · R3s Ваш номер телефону · R4 Моя адреса · R4s Ваша адреса · R5 Вибраний контакт · R5s Контакт, який ви вибрали · R6 Поточне місто · R6s Місто, де ви зараз · R7 Поточна погода · R8 Захід сонця · R9 Наступна подія · R10 Вільні вікна · R11 Події на сьогодні · R11s Ваші події · R12 Поточні нагадування · R12s Ваші нагадування · R13 Виділений текст · R13s Текст, який ви виділили · R14 Число словами · R15 Результат швидкої команди · R15s Що поверне швидка команда | R10: Round 3: the round-2 reader's own wording (free windows), as in Russian; not read again. |
| ur | G1 میں اور میرے رابطے · G2 مقامات · G3 کیلنڈر · R1 میرا نام · R1s آپ کا نام · R2 میرا ای میل · R2s آپ کا ای میل پتہ · R3 میرا فون نمبر · R3s آپ کا فون نمبر · R4 میرا پتہ · R4s آپ کا پتہ · R5 رابطہ · R5s آپ کا منتخب کردہ رابطہ · R6 شہر · R6s آپ کا موجودہ شہر · R7 ابھی کا موسم · R8 غروب کا وقت · R9 اگلا ایونٹ · R10 خالی اوقات · R11 آج کے ایونٹس · R11s آپ کے ایونٹس · R12 زیرِ التوا یاد دہانیاں · R12s آپ کی یاد دہانیاں · R13 منتخب متن · R13s جو متن آپ نے منتخب کیا · R14 عدد لفظوں میں · R15 شارٹ کٹ کا نتیجہ · R15s شارٹ کٹ سے ملنے والا نتیجہ | R6s: Round 2; round 1 wrote آپ ابھی جہاں ہیں (A clause with no head noun, so it reads as unfinished ('where you are now' what?). 'جس شہر میں آپ ابھی ہیں' or 'آپ کا موجودہ شہر' completes it.) R7: Round 2; round 1 wrote موجودہ موسم ('موسم' means both weather and season, and 'موجودہ موسم' easily reads as 'the current season'. 'آج کا موسم' or 'ابھی کا موسم' reads as weather.) |
| vi | G1 Tôi và danh bạ · G2 Địa điểm · G3 Lịch · R1 Tên của tôi · R1s Tên của bạn · R2 Email của tôi · R2s Email của bạn · R3 Số điện thoại của tôi · R3s Số điện thoại của bạn · R4 Địa chỉ của tôi · R4s Địa chỉ của bạn · R5 Liên hệ đã chọn · R5s Liên hệ bạn đã chọn · R6 Thành phố · R6s Nơi bạn đang ở · R7 Thời tiết hiện tại · R8 Giờ mặt trời lặn · R9 Sự kiện tiếp theo · R10 Khung giờ trống · R11 Lịch trình hôm nay · R11s Các sự kiện của bạn · R12 Lời nhắc đến hạn · R12s Lời nhắc của bạn · R13 Văn bản đã chọn · R13s Văn bản bạn đã chọn · R14 Số viết bằng chữ · R15 Kết quả từ phím tắt · R15s Giá trị phím tắt trả về | R3: Round 2; round 1 wrote Điện thoại của tôi ('Điện thoại của tôi' means the handset, not the number. The hint says 'Số điện thoại của bạn', so the name should be 'Số điện thoại của tôi'.) |
| zh-Hans | G1 我与联系人 · G2 位置 · G3 日历 · R1 我的姓名 · R1s 你的姓名 · R2 我的电子邮件 · R2s 你的电子邮件地址 · R3 我的电话号码 · R3s 你的电话号码 · R4 我的地址 · R4s 你的地址 · R5 联系人 · R5s 你选择的联系人 · R6 当前城市 · R6s 你现在所在的地方 · R7 当前天气 · R8 日落时间 · R9 下一个日程 · R10 空闲时间 · R11 今日日程 · R11s 你的日程 · R12 到期的提醒事项 · R12s 你的提醒事项 · R13 所选文本 · R13s 你选中的文本 · R14 中文数字 · R15 快捷指令结果 · R15s 快捷指令返回的结果 |  |
| zh-Hant | G1 我與聯絡人 · G2 地點 · G3 行事曆 · R1 我的姓名 · R1s 你的姓名 · R2 我的電子郵件 · R2s 你的電子郵件 · R3 我的電話號碼 · R3s 你的電話號碼 · R4 我的地址 · R4s 你的地址 · R5 聯絡人 · R5s 你選擇的聯絡人 · R6 目前城市 · R6s 你目前所在的地方 · R7 目前天氣 · R8 日落時間 · R9 下一個行程 · R10 空閒時段 · R11 今日行程 · R11s 你的行程 · R12 到期提醒事項 · R12s 你的提醒事項 · R13 選取的文字 · R13s 你選取的文字 · R14 中文數字 · R15 捷徑結果 · R15s 捷徑回傳的結果 |  |
