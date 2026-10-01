# Keyword measurements, 2026-10-01

What people type on the App Store for a clipboard and snippet keyboard, how crowded each query is, and where Cutling (id 6759476314) ranks. Every number was fetched on 2026-10-01 from the three endpoints below. Raw probe output and the scripts are in [data/](data/README.md); the merged table is [data/keyword-measurements.json](data/keyword-measurements.json).

## Method

| probe | endpoint | cap | pacing |
|---|---|---|---|
| Type-ahead | `https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints?clientApplication=Software&term=<t>` with header `X-Apple-Store-Front: <id>-1,29` | about 10 suggestions | 6 threads |
| Live App Store search | `https://search.itunes.apple.com/WebObjects/MZStore.woa/wa/search?clientApplication=Software&media=software&term=<t>` with the same header | 250 results (the endpoint returned `n`=250 for broad terms) | 1.2 s |
| iTunes Search API | `https://itunes.apple.com/search?term=<t>&country=<cc>&entity=software&limit=200` | 200 (Apple: "1 to 200", [documentation](https://performance-partners.apple.com/search-api)); real counts are 150 to 190 because duplicates collapse | 3.3 s (Apple: "approximately 20 calls per minute") |

- The Search API cannot reach 250 results. The live-store endpoint can, so the **Cutling rank (top 250)** column comes from it and the **Search API rank (top 200)** column is a second opinion. The two orderings differ: for `clipboard` in the US Cutling is 237 on the live store and 135 on the Search API, and for `clipboard keyboard` it is 12 against 94. Treat the live-store rank as the one users see.
- Type-ahead returns suggestion text and a URL and nothing else: no priority or popularity number. The only signal is the order. **Type-ahead pos** is the term's position in the suggestions for its own query; `p@"x"` means the term appeared at position p when the query was the prefix `x`; `-` means it was never suggested. A term that is never suggested is not proof of zero demand, only that it is not a completion of a common prefix.
- Storefront ids were verified live: the live search returns `meta.storefront.cc` and `id`, and all 46 ids used matched their country. Bangladesh (143490) returned an empty page and `country=bd` returns 0 Search API results, so BD has no usable live search. Iran has no storefront, so the `fa` locale cannot be tested.
- `lang` was not passed to the Search API. Result order is per storefront, and ratings are per storefront too, so a median of 0 means the top 10 have no ratings in that country, which is a weak field.
- **relevant top 10** counts how many of the top 10 apps mention clipboard, paste, snippet, text expander, canned reply, template, autofill or keyboard (in 40 languages) in the name, subtitle or the first 300 characters of the description; the number in brackets is the stricter count that leaves out the word keyboard. It is a regex heuristic, not a human read. **median ratings** is the median `userRatingCount` of the top 10 (live store: rating count of the lockup), a difficulty proxy.
- Seeds are the words a local would type (brief's list), the English core set in every storefront, the 4 to 6 most important current keywords of each of the 60 locale folders in `fastlane/metadata` (brand names, `iCloud` and `emoji` left out), and one level of expansion: up to 8 suggestions per storefront (app-name style suggestions with " - " or ": " dropped) from the seeds and their prefixes. Total 1109 storefront and term pairs.

### What went wrong (read before trusting a gap)

- Type-ahead: 1517 queries, 1235 answered with suggestions, 282 answered empty (no suggestions exist), 0 failed. 277 queries first failed with `429` after the live-search burst below and were rerun once the limit lifted (about 11:00 UTC); the file holds the rerun answers.
- Live-store coverage is **partial**: 565 of 1109 pairs. Running three `rank.py` processes at once got the IP a `403` on the live search and `429` with `retry-after: 1559` on type-ahead at about 17:05 WIB; the live search was still `403` more than an hour later. Pairs the live search did not reach fall back to the Search API (cap 200) and carry a **†** in the tables. Coverage per storefront (live/total): US 35/35, GB 35/35, DE 33/33, JP 34/34, FR 32/32, BR 33/33, KR 32/32, CN 31/31, ID 28/32, IN 66/66, ES 7/34, IT 8/29, NL 8/29, RU 8/29, MX 8/30, CA 8/41, AU 8/34, TR 8/30, PL 1/29, TH 0/28, VN 0/30, TW 0/28, SA 0/29, SE 0/29, UA 0/29, IL 0/28, CZ 0/28, PT 0/29, PH 0/36, MY 7/28, KE 9/9, GR 9/9, HU 9/9, RO 9/9, FI 9/9, DK 7/9, NO 7/9, HR 9/9, SK 8/8, SI 9/9, EE 8/8, LV 9/9, LT 8/8, BG 9/9, RS 8/8, PK 8/8. Rerun `rank.py` from [data/README.md](data/README.md) to fill the gaps; the run resumes where it stopped.

## Where Cutling ranks today

Pairs where Cutling appears in the top 250 (live store) or top 200 (Search API); every other measured pair is "not in the top N". Sorted by live-store rank.

| storefront | term | live store rank (of 250) | Search API rank (of 200) |
|---|---|---|---|
| KR | 정형문 | 6 | 6 |
| HR | lijepljenje | 7 | 7 |
| MX | portapapeles teclado | 11 | 32 |
| CN | 剪贴板输入法 | 12 | 40 |
| US | clipboard keyboard | 12 | 94 |
| ID | canned responses | 16 | 13 |
| US | clipboard keyboard manager | 16 | 138 |
| ID | canned response | 16 | >200 |
| CN | 自动填充 | 18 | 59 |
| ID | catatan keyboard | 19 | 18 |
| CN | canned responses | 20 | 21 |
| CN | canned response | 20 | >200 |
| US | canned response | 21 | >200 |
| BR | canned responses | 22 | 23 |
| CN | 剪贴板管理 | 22 | 77 |
| BR | canned response | 22 | >200 |
| DE | canned responses | 23 | 23 |
| JP | canned responses | 23 | 23 |
| JP | canned response | 23 | >200 |
| FR | canned responses | 24 | 24 |
| HR | kopiranje | 24 | 24 |
| KR | canned responses | 24 | 26 |
| US | canned responses | 24 | 36 |
| MX | portapapeles teclado pegar | 24 | 44 |
| DE | canned response | 24 | >200 |
| KR | canned response | 24 | >200 |
| CN | 常用文字 | 25 | 17 |
| IN | canned responses | 25 | 26 |
| NO | utklippstavle | 25 | 30 |
| US | text snippets | 25 | 157 |
| FR | canned response | 25 | >200 |
| IN | canned response | 25 | >200 |
| NL | klembord+ | 31 | 31 |
| JP | クリップボード履歴 | 31 | 86 |
| SI | clipboard keyboard | 32 | 32 |
| DK | udklipsholder | 33 | 33 |
| LV | clipboard keyboard | 33 | 33 |
| JP | クリップボード管理アプリ | 33 | 74 |
| GB | canned response | 33 | >200 |
| CN | 复制粘贴 | 33 | >200 |
| JP | クリップボード | 35 | >200 |
| ES | portapapeles teclado pegar | 38 | 38 |
| FI | täyttö | 39 | 39 |
| HR | clipboard keyboard | 39 | 39 |
| BG | clipboard keyboard | 39 | 39 |
| ID | salin tempel | 39 | 45 |
| LT | clipboard keyboard | 40 | 40 |
| SK | clipboard keyboard | 42 | 42 |
| EE | clipboard keyboard | 43 | 43 |
| GB | canned responses | 43 | 46 |
| JP | コピペ | 43 | >200 |
| GR | επικόλληση | 44 | 44 |
| GR | clipboard keyboard | 44 | 44 |
| HU | clipboard keyboard | 44 | 44 |
| RO | clipboard keyboard | 47 | 47 |
| KR | 복붙키보드 | 48 | 45 |
| KR | 복붙 | 48 | 47 |
| FI | clipboard keyboard | 48 | 48 |
| DE | Schnellantworten | 50 | >200 |
| DE | Zwischenablage Tastatur | 53 | 53 |
| HR | adresa | 55 | 55 |
| JP | clipboard | 55 | >200 |
| KR | 스니펫 | 56 | 69 |
| JP | コピペ キーボード | 57 | >200 |
| FR | clavier copier coller | 59 | 59 |
| FR | clavier presse-papiers | 61 | 60 |
| ID | teks cepat | 61 | 66 |
| US | snippet | 62 | >200 |
| CN | clipboard keyboard | 63 | 52 |
| BR | respostas rápidas | 63 | 67 |
| DE | Notizen Tastatur | 64 | 64 |
| JP | 定型文 キーボード | 66 | 71 |
| JP | clipboard keyboard | 68 | 34 |
| US | snippets | 69 | >200 |
| ES | clipboard keyboard | 70 | 70 |
| SK | adresa | 72 | 73 |
| RO | adresă | 75 | 76 |
| FI | osoite | 77 | 77 |
| FR | clipboard keyboard | 78 | 78 |
| BR | atalhos de texto | 82 | 90 |
| ID | text snippets | 88 | 96 |
| CN | clipboard | 88 | >200 |
| ID | alamat | 89 | 86 |
| US | custom keyboard | 89 | >200 |
| FR | raccourcis texte | 94 | 94 |
| FR | presse-papiers copier-coller | 97 | 93 |
| CN | 剪贴板（粘贴板）管理器 | 99 | 81 |
| RO | clipboard manager | 101 | 101 |
| KR | 자동입력 | 103 | 96 |
| US | clipboard dental | 106 | >200 |
| DK | clipboard keyboard | 107 | 107 |
| BG | clipboard manager | 109 | 109 |
| DE | Kopieren Einfügen | 110 | 110 |
| IN | clipboard manager keyboard | 111 | 109 |
| HR | clipboard manager | 116 | 116 |
| CN | text snippets | 116 | 141 |
| SK | clipboard manager | 117 | 117 |
| EE | clipboard manager | 117 | 117 |
| LT | clipboard manager | 117 | 117 |
| CN | clipboard manager | 118 | 151 |
| HU | clipboard manager | 119 | 119 |
| SI | clipboard manager | 123 | 123 |
| FI | clipboard manager | 124 | 124 |
| HR | bilješka | 130 | 130 |
| FR | extrait | 132 | 134 |
| JP | text snippets | 133 | 147 |
| HR | predložak | 135 | 135 |
| KR | 메모 키보드 | 139 | 121 |
| ID | clipboard keyboard | 140 | 112 |
| GR | σημείωση | 140 | 141 |
| JP | メモ キーボード | 144 | 106 |
| JP | 定型文 | 161 | >200 |
| DE | Zwischenablage | 170 | >200 |
| DE | zwischenablage | 170 | >200 |
| DK | clipboard manager | 171 | 171 |
| DE | zwischenablage+ | 173 | >200 |
| FR | copier coller | 173 | >200 |
| DE | clipboard keyboard | 174 | 174 |
| KR | 복사 붙여넣기 | 174 | >200 |
| KR | clipboard 클립보드 키보드 | 178 | 58 |
| FR | presse-papiers+ | 179 | 166 |
| FR | presse-papiers | 180 | >200 |
| US | clipboard manager one tap | 181 | >200 |
| BR | endereço | 181 | >200 |
| HU | sablon | 183 | 184 |
| GB | clipboard keyboard | 188 | 130 |
| LV | clipboard manager | 190 | >200 |
| PK | autofill | 190 | >200 |
| DK | clipboard | 192 | >200 |
| GR | πρότυπο | 195 | >200 |
| ID | clipboard | 196 | 156 |
| ES | clipboard manager | 197 | >200 |
| US | clipboard manager | 207 | >200 |
| BR | copiar colar | 210 | >200 |
| SK | poznámka | 213 | >200 |
| BR | text snippets | 215 | >200 |
| CN | 剪贴板+ | 220 | 134 |
| KR | text snippets | 222 | >200 |
| GB | garmin clipboard™ | 223 | >200 |
| BR | atalho | 226 | >200 |
| PK | clipboard manager | 230 | >200 |
| SK | šablóna | 231 | >200 |
| CN | 剪贴板 | 232 | >200 |
| US | autofill | 235 | >200 |
| NO | clipboard keyboard | 236 | 57 |
| US | clipboard | 237 | 135 |
| RS | clipboard keyboard | 241 | 37 |
| MX | teclado google | 241 | >200 |
| US | text shortcuts | 243 | >200 |
| MY | keyboard clipboard | 244 | >200 |
| ES | autorellenar | >250 | 2 |
| MX | autorellenar | >250 | 2 |
| SE | autofyll | >250 | 9 |
| CZ | schránka | >250 | 10 |
| IT | canned responses | >250 | 12 |
| SE | anteckningar tangentbord | >250 | 12 |
| IT | tastiera appunti | >250 | 14 |
| TW | 自動填寫 | >250 | 15 |
| NL | canned responses | >250 | 17 |
| MX | canned responses | >250 | 17 |
| IL | העתק הדבק | >250 | 17 |
| TR | hızlı yanıt | >250 | 18 |
| TW | clipboard 剪貼簿 鍵盤 | >250 | 18 |
| SE | urklipp | >250 | 18 |
| TW | canned responses | >250 | 19 |
| CZ | kopírovat vložit | >250 | 19 |
| PL | schowek | >250 | 20 |
| PT | canned responses | >250 | 20 |
| IT | risposte rapide | >250 | 21 |
| IL | canned responses | >250 | 21 |
| CZ | canned responses | >250 | 21 |
| PL | canned responses | >250 | 22 |
| SE | canned responses | >250 | 22 |
| ES | canned responses | >250 | 23 |
| TR | canned responses | >250 | 23 |
| TW | 常用文字 | >250 | 23 |
| IL | קטע | >250 | 23 |
| ES | drecera | >250 | 24 |
| NL | klembord | >250 | 24 |
| VN | canned responses | >250 | 24 |
| UA | canned responses | >250 | 24 |
| RU | canned responses | >250 | 25 |
| TH | canned responses | >250 | 25 |
| UA | копіювати вставити | >250 | 25 |
| MY | canned responses | >250 | 25 |
| NL | kopiëren plakken | >250 | 26 |
| SA | canned responses | >250 | 26 |
| PH | canned responses | >250 | 26 |
| SA | قصاصة | >250 | 31 |
| MY | salin tampal | >250 | 33 |
| PL | kopiuj wklej | >250 | 35 |
| PT | respostas rápidas | >250 | 35 |
| ES | adreça | >250 | 37 |
| RU | заметки клавиатура | >250 | 39 |
| KR | clipboard keyboard | >250 | 45 |
| CA | canned responses | >250 | 45 |
| CZ | clipboard keyboard | >250 | 45 |
| KE | clipboard keyboard | >250 | 45 |
| AU | canned responses | >250 | 46 |
| TW | 剪貼簿：鍵盤快速鍵 | >250 | 46 |
| PT | clipboard keyboard | >250 | 46 |
| IL | clipboard keyboard | >250 | 48 |
| MY | teks pantas | >250 | 48 |
| TH | คลิปบอร์ด | >250 | 49 |
| PL | clipboard keyboard | >250 | 54 |
| PT | atalhos de texto | >250 | 54 |
| TW | clipboard keyboard | >250 | 56 |
| TW | cp複製-複製貼上剪貼簿 | >250 | 59 |
| MX | portapapeles | >250 | 60 |
| AU | clipboard keyboard | >250 | 60 |
| IT | clipboard keyboard | >250 | 61 |
| ES | portapapeles | >250 | 65 |
| SE | clipboard keyboard | >250 | 65 |
| UA | clipboard keyboard | >250 | 72 |
| BR | clipboard keyboard | >250 | 73 |
| VN | clipboard keyboard | >250 | 73 |
| MY | clipboard keyboard | >250 | 73 |
| IT | copia incolla | >250 | 75 |
| TR | clipboard keyboard | >250 | 75 |
| TH | คัดลอกวาง | >250 | 75 |
| RU | clipboard keyboard | >250 | 76 |
| IL | כתובת | >250 | 77 |
| MX | clipboard keyboard | >250 | 79 |
| SA | clipboard keyboard | >250 | 85 |
| VN | tin nhắn mẫu | >250 | 86 |
| CZ | adresa | >250 | 89 |
| MY | alamat | >250 | 92 |
| SA | الحافظة | >250 | 95 |
| PL | adres | >250 | 97 |
| CA | clipboard keyboard | >250 | 98 |
| MX | copiar pegar | >250 | 101 |
| TW | 複製貼上 | >250 | 103 |
| PK | clipboard keyboard | >250 | 104 |
| TH | clipboard keyboard | >250 | 107 |
| MX | text snippets | >250 | 111 |
| IT | text snippets | >250 | 112 |
| TR | kopyala yapıştır | >250 | 114 |
| CA | extrait | >250 | 116 |
| PT | copiar colar | >250 | 117 |
| CZ | clipboard manager | >250 | 118 |
| RS | clipboard manager | >250 | 120 |
| VN | sao chép văn bản | >250 | 121 |
| TW | text snippets | >250 | 122 |
| CZ | clipboard++ | >250 | 124 |
| PT | clipboard manager | >250 | 124 |
| IL | הערה | >250 | 125 |
| IL | clipboard manager | >250 | 129 |
| ES | copiar pegar | >250 | 131 |
| IT | testi rapidi | >250 | 133 |
| NL | text snippets | >250 | 135 |
| PL | clipboard manager | >250 | 135 |
| CZ | text snippets | >250 | 138 |
| PH | clipboard keyboard | >250 | 138 |
| PT | text snippets | >250 | 141 |
| FI | pohja | >250 | 145 |
| IL | תבנית | >250 | 147 |
| IL | clipboard | >250 | 147 |
| PL | text snippets | >250 | 152 |
| PH | clipboard paste keyboard | >250 | 153 |
| NO | clipboard manager | >250 | 159 |
| IT | clipboard | >250 | 160 |
| IL | text snippets | >250 | 166 |
| MX | clipboard manager | >250 | 168 |
| TW | clipboard | >250 | 169 |
| JP | clipboard manager | >250 | 172 |
| KR | clipboard | >250 | 176 |
| IT | clipboard manager | >250 | 177 |
| ID | clipboard manager | >250 | 192 |

## Best low-competition relevant terms per storefront

Terms with at least 6 relevant apps in the top 10 (at least 3 on the strict count), suggested terms first, then by lowest median ratings. ta = type-ahead position. † = Search API fallback.

| storefront | lowest-median relevant terms |
|---|---|
| US | autofill (med 0, rel 8, ta 3, rank 235); clipboard dental (med 0, rel 10, ta 1, rank 106); clipboard manager one tap (med 0, rel 10, ta 1, rank 181); text expander (med 1, rel 8, ta 1, rank >250); snippet (med 2, rel 10, ta 1, rank 62) |
| GB | snippets! (med 0, rel 10, ta 1, rank >250); paste (med 1, rel 10, ta 3, rank >250); clipboard ++ (med 1, rel 10, ta 7, rank >250); clipboard history (med 1, rel 10, ta 1, rank >250); snippet (med 2, rel 10, ta 3, rank >250) |
| DE | zwischenablage+ (med 0, rel 9, ta 7, rank 173); textbausteine tastatur kürzel (med 0, rel 9, ta 1, rank >250); Zwischenablage (med 7, rel 10, ta 1, rank 170); zwischenablage (med 7, rel 10, ta 1, rank 170); clipboard keyboard (med 14, rel 10, ta 1, rank 174) |
| JP | スニペット (med 1, rel 10, ta 1, rank >250); コピペ帳〜 素早くコピー＆ペースト (med 1, rel 6, ta 1, rank >250); クリップボード履歴 (med 5, rel 10, ta 1, rank 31); clipboard manager (med 6, rel 10, ta 3, rank >250); clipboard (med 11, rel 10, ta 2, rank 55) |
| FR | presse-papiers+ (med 0, rel 10, ta 4, rank 179); snippet (med 1, rel 10, ta 2, rank >250); presse-papiers copier-coller (med 4, rel 9, ta 1, rank 97); auto copier coller, text spam (med 7, rel 9, ta 1, rank >250); clipboard manager (med 9, rel 10, ta 1, rank >250) |
| BR | text expander (med 0, rel 9, ta 1, rank >250); snippet (med 0, rel 10, ta 3, rank >250); clipboard manager (med 4, rel 10, ta 1, rank >250); clipboard (med 5, rel 10, ta 2, rank >250); copy paste (med 7, rel 9, ta 1, rank >250) |
| KR | clipboard manager (med 1, rel 10, ta 4, rank >250); 아이폰 클립보드 (med 1, rel 10, ta 1, rank >250); 복붙 (med 2, rel 10, ta 2, rank 48); clipboard 클립보드 키보드 (med 9, rel 10, ta 1, rank 178); clipboard++ (med 14, rel 10, ta 5, rank >250) |
| CN | 剪贴板管理器 (med 0, rel 10, ta 1, rank >250); 剪贴板清理器 (med 0, rel 7, ta 1, rank >250); clipboard manager (med 1, rel 10, ta 3, rank 118); 常用语 (med 1, rel 8, ta 1, rank >250); clipboard (med 2, rel 9, ta 1, rank 88) |
| ID | clipboard manager (med 0, rel 10, ta 1, rank >250); keyboard papan klip (med 0, rel 10, ta 1, rank >250); clipboard keyboard (med 1, rel 10, ta 1, rank 140); copy paste (med 29, rel 9, ta 2, rank >250); paste (med 29, rel 9, ta 7, rank >200†) |
| IN | clipboard keyboard (med 0, rel 10, ta 1, rank >250); keyboard with clipboard (med 0, rel 10, ta 1, rank >250); snippets! (med 0, rel 10, ta 1, rank >250); snippet (med 1, rel 10, ta 3, rank >250); ai text expander (med 4, rel 6, ta 1, rank >250) |
| ES | portapapeles teclado pegar (med 1, rel 10, ta 1, rank 38); snippet (med 2, rel 10, ta 2, rank >200†); clipboard manager (med 4, rel 10, ta 1, rank 197); clipboard (med 12, rel 10, ta 2, rank >250); portapapeles (med 12, rel 9, ta 1, rank 65†) |
| IT | clipboard manager (med 5, rel 10, ta 1, rank 177†); copia incolla (med 13, rel 10, ta 2, rank 75†); clipboard (med 33, rel 10, ta 1, rank 160†); copy paste (med 42, rel 8, ta 1, rank >200†); appunti ai (med 322, rel 6, ta 1, rank >250) |
| NL | klembord+ (med 0, rel 10, ta 3, rank 31); klembord (med 1, rel 10, ta 1, rank 24†); clipboard manager (med 2, rel 10, ta 1, rank >200†); snippet (med 2, rel 10, ta 2, rank >200†); clipboard (med 7, rel 10, ta 1, rank >200†) |
| RU | буфер обмена+ (med 0, rel 10, ta 6, rank >250); буфер обмена клавиатура (med 1, rel 10, ta 1, rank >250); text expander (med 1, rel 10, ta 1, rank >200†); clipboard manager (med 2, rel 10, ta 4, rank >200†); копировать вставить клавиатуру (med 7, rel 10, ta 1, rank >250) |
| MX | portapapeles teclado pegar (med 1, rel 10, ta 1, rank 24); snippet (med 1, rel 10, ta 3, rank >200†); portapapeles teclado (med 2, rel 10, ta 1, rank 11); teclado con portapapeles (med 3, rel 6, ta 1, rank >250); clipboard manager (med 6, rel 10, ta 1, rank 168†) |
| CA | clipboard history+ (med 0, rel 10, ta 1, rank >250); snippets! (med 1, rel 10, ta 1, rank >250); snippet (med 2, rel 10, ta 3, rank >200†); clipboard health (med 3, rel 7, ta 1, rank >250); autofill (med 5, rel 7, ta 1, rank >200†) |
| AU | clipboard school (med 0, rel 10, ta 1, rank >250); snippet (med 1, rel 10, ta 3, rank >200†); snippets! (med 2, rel 10, ta 1, rank >250); clipboard manager (med 5, rel 10, ta 1, rank >200†); autofill (med 6, rel 6, ta 1, rank >200†) |
| TR | panocut (med 0, rel 7, ta 1, rank >250); snippet (med 1, rel 10, ta 3, rank >200†); panorama 360 (med 4, rel 6, ta 1, rank >250); panorama crop (med 6, rel 6, ta 1, rank >250); panorama (med 6, rel 6, ta 5, rank >250) |
| PL | snippet (med 1, rel 10, ta 3, rank >200†); clipboard manager (med 2, rel 10, ta 1, rank 135†); clipboard (med 5, rel 10, ta 2, rank >200†); schowek (med 7, rel 10, ta 1, rank 20†); copy paste (med 27, rel 8, ta 1, rank >200†) |
| TH | คัดลอกวาง (med 1, rel 9, ta 1, rank 75†); clipboard manager (med 12, rel 10, ta 2, rank >200†); clipboard (med 46, rel 10, ta 2, rank >200†); clipboard keyboard (med 95, rel 10, ta 1, rank 107†); คลิปบอร์ด (med 109, rel 10, ta 1, rank 49†) |
| VN | snippet (med 0, rel 10, ta 5, rank >200†); clipboard manager (med 3, rel 10, ta 1, rank >200†); paste (med 10, rel 8, ta 5, rank >200†); clipboard (med 14, rel 10, ta 2, rank >200†); copy paste (med 75, rel 8, ta 1, rank >200†) |
| TW | clipboard (med 1, rel 9, ta 2, rank 169†); copy paste (med 6, rel 8, ta 1, rank >200†); cp複製-複製貼上剪貼簿 (med 19, rel 10, ta 1, rank 59†); 複製貼上 (med 22, rel 10, ta 1, rank 103†); 剪貼簿：鍵盤快速鍵 (med 22, rel 9, ta 1, rank 46†) |
| SA | clipboard manager (med 9, rel 10, ta 1, rank >200†); نسخ ولصق (med 12, rel 10, ta 1, rank >200†); لوحة مفاتيح ترجمة (med 43, rel 10, ta 1, rank >200†); clipboard (med 50, rel 10, ta 1, rank >200†); copy paste (med 255, rel 8, ta 1, rank >200†) |
| SE | snippet (med 0, rel 10, ta 2, rank >200†); clipboard manager (med 0, rel 10, ta 4, rank >200†); clipboard (med 9, rel 10, ta 1, rank >200†); copy paste (med 171, rel 8, ta 1, rank >200†); text snippets (med 0, rel 8, ta -, rank >200†) |
| UA | буфер обміну (med 0, rel 10, ta 1, rank >200†); clipboard manager (med 3, rel 10, ta 7, rank >200†); clipboard (med 9, rel 10, ta 1, rank >200†); copy paste (med 19, rel 8, ta 1, rank >200†); canned responses (med 0, rel 10, ta -, rank 24†) |
| IL | clipboard manager (med 1, rel 10, ta 7, rank 129†); clipboard (med 20, rel 10, ta 1, rank 147†); copy paste (med 59, rel 8, ta 1, rank >200†); text snippets (med 0, rel 9, ta -, rank 166†); canned responses (med 0, rel 10, ta -, rank 21†) |
| CZ | clipboard manager (med 1, rel 10, ta 6, rank 118†); clipboard (med 1, rel 10, ta 1, rank >200†); paste keyboard (med 2, rel 10, ta 1, rank >200†); clipboard++ (med 2, rel 10, ta 8, rank 124†); copy paste (med 8, rel 8, ta 1, rank >200†) |
| PT | área de transferência+ (med 0, rel 8, ta 1@"área de transferência", rank >200†); snippet (med 0, rel 10, ta 2, rank >200†); clipboard (med 1, rel 10, ta 1, rank >200†); clipboard manager (med 1, rel 10, ta 5, rank 124†); copy paste (med 14, rel 8, ta 1, rank >200†) |
| PH | snippets! (med 0, rel 10, ta 1, rank >200†); ai text expander (med 0, rel 6, ta 1, rank >200†); dev snippets (med 0, rel 9, ta 1, rank >200†); snippets studio (med 0, rel 8, ta 1, rank >200†); text expander (med 0, rel 10, ta 1, rank >200†) |
| MY | keyboard clipboard (med 0, rel 10, ta 1, rank 244); snippet (med 0, rel 10, ta 3, rank >200†); paste keyboard (med 1, rel 10, ta 1, rank >250); paste (med 6, rel 10, ta 3, rank >250); clipboard manager (med 8, rel 10, ta 1, rank >200†) |

## Dead keywords in current fields, per locale

For each ASC locale folder: the 4 to 6 leading keywords from `keywords.txt` tested in the locale's main storefront. **DEAD** = zero results or at most 1 relevant app in the top 10; **weak** = 2 to 4; **live** = 5 or more. A single generic word (address, quick, auto, text) lands DEAD because the store ranks other things for it; Apple combines keyword-field words with name and subtitle words into phrases, so a DEAD single word is worth dropping only when no useful phrase can be built from it. Locales sharing a storefront (ten Indian locales on IN, en-AU/CA/GB/IN/US each on their own) repeat the same measurement.

| locale | storefront | name | subtitle | keyword | results | relevant top 10 | median ratings | Cutling rank | verdict |
|---|---|---|---|---|---|---|---|---|---|
| ar-SA | SA | كاتلينج - حافظة كيبورد | نسخ ولصق النصوص والمقتطفات | قصاصة | 37† | 3 (3) | 19 | 31 | weak |
| ar-SA | SA |  |  | نموذج | 182† | 0 (0) | 317 | >200† | DEAD |
| ar-SA | SA |  |  | سريع | 177† | 0 (0) | 834 | >200† | DEAD |
| ar-SA | SA |  |  | نص | 183† | 1 (0) | 19735 | >200† | DEAD |
| ar-SA | SA |  |  | قالب | 178† | 0 (0) | 81755 | >200† | DEAD |
| ar-SA | SA |  |  | عنوان | 176† | 0 (0) | 1495 | >200† | DEAD |
| bg | BG | Cutling - Клипборд Клавиатура | Копиране, Поставяне, Фрагменти | шаблон | 21 | 7 (7) | 30 | >250 | live |
| bg | BG |  |  | адрес | 20 | 0 (0) | 0 | >250 | DEAD |
| bg | BG |  |  | автоматично | 0 | 0 (0) | 0 | >250 | DEAD |
| bg | BG |  |  | бързо | 6 | 0 (0) | 1 | >250 | DEAD |
| bg | BG |  |  | текст | 209 | 4 (1) | 82 | >250 | weak |
| bg | BG |  |  | бележка | 2 | 0 (0) | 121 | >250 | DEAD |
| bn-BD | BD | Cutling - ক্লিপবোর্ড কীবোর্ড | কপি ও পেস্ট স্নিপেট সংরক্ষণ | clipboard | 0† | 0 (0) | 0 | >200† | DEAD |
| bn-BD | BD |  |  | snippet | 0† | 0 (0) | 0 | >200† | DEAD |
| bn-BD | BD |  |  | autofill | 0† | 0 (0) | 0 | >200† | DEAD |
| bn-BD | BD |  |  | টেক্সট | 0† | 0 (0) | 0 | >200† | DEAD |
| bn-BD | BD |  |  | নোট | 0† | 0 (0) | 0 | >200† | DEAD |
| bn-BD | BD |  |  | টেমপ্লেট | 0† | 0 (0) | 0 | >200† | DEAD |
| bn-IN | IN | Cutling - ক্লিপবোর্ড কীবোর্ড | কপি ও পেস্ট স্নিপেট সংরক্ষণ | clipboard | 249 | 9 (8) | 61 | >250 | live |
| bn-IN | IN |  |  | snippet | 250 | 10 (10) | 1 | >250 | live |
| bn-IN | IN |  |  | autofill | 249 | 8 (8) | 0 | >250 | live |
| bn-IN | IN |  |  | টেক্সট | 0 | 0 (0) | 0 | >250 | DEAD |
| bn-IN | IN |  |  | নোট | 2 | 2 (0) | 1 | >250 | weak |
| bn-IN | IN |  |  | টেমপ্লেট | 0 | 0 (0) | 0 | >250 | DEAD |
| ca | ES | Cutling - Porta-Retalls Teclat | Copiar, Enganxar i Fragments | adreça | 46† | 0 (0) | 0 | 37 | DEAD |
| ca | ES |  |  | plantilla | 180† | 0 (0) | 2245 | >200† | DEAD |
| ca | ES |  |  | text | 152† | 3 (0) | 936 | >200† | weak |
| ca | ES |  |  | ràpid | 168† | 0 (0) | 18 | >200† | DEAD |
| ca | ES |  |  | nota | 179† | 0 (0) | 556 | >200† | DEAD |
| ca | ES |  |  | drecera | 28† | 0 (0) | 1 | 24 | DEAD |
| cs | CZ | Cutling - Schránka Klávesnice | Kopírovat, Vložit a Úryvky | šablona | 193† | 0 (0) | 0 | >200† | DEAD |
| cs | CZ |  |  | adresa | 141† | 0 (0) | 4 | 89 | DEAD |
| cs | CZ |  |  | text | 159† | 6 (1) | 369 | >200† | live |
| cs | CZ |  |  | rychle | 189† | 0 (0) | 5 | >200† | DEAD |
| cs | CZ |  |  | poznámka | 184† | 0 (0) | 0 | >200† | DEAD |
| cs | CZ |  |  | clipboard | 186† | 10 (9) | 1 | >200† | live |
| da | DK | Cutling - Clipboard Tastatur | Kopiér, Indsæt og Uddrag | udklipsholder | 47 | 10 (10) | 0 | 33 | live |
| da | DK |  |  | tekst | 239 | 6 (2) | 251 | >250 | live |
| da | DK |  |  | snippet | 202 | 9 (9) | 0 | >250 | live |
| da | DK |  |  | adresse | 185 | 0 (0) | 0 | >250 | DEAD |
| da | DK |  |  | skabelon | 173† | 0 (0) | 148 | >200† | DEAD |
| da | DK |  |  | hurtig | 166† | 0 (0) | 90 | >200† | DEAD |
| de-DE | DE | Cutling - Clipboard Tastatur | Kopieren, Einfügen & Snippets | zwischenablage | 183 | 10 (10) | 7 | 170 | live |
| de-DE | DE |  |  | vorlage | 235 | 3 (3) | 6573 | >250 | weak |
| de-DE | DE |  |  | adresse | 207 | 0 (0) | 11 | >250 | DEAD |
| de-DE | DE |  |  | schnell | 240 | 0 (0) | 426 | >250 | DEAD |
| de-DE | DE |  |  | text | 242 | 5 (1) | 4803 | >250 | live |
| de-DE | DE |  |  | notiz | 242 | 4 (4) | 2556 | >250 | weak |
| el | GR | Cutling - Πρόχειρο & Κείμενο | Αντιγραφή & Αποσπάσματα | πληκτρολόγιο | 233 | 10 (0) | 481 | >250 | live |
| el | GR |  |  | επικόλληση | 60 | 10 (10) | 0 | 44 | live |
| el | GR |  |  | snippet | 201 | 10 (10) | 0 | >250 | live |
| el | GR |  |  | πρότυπο | 233 | 1 (1) | 0 | 195 | DEAD |
| el | GR |  |  | γρήγορο | 227 | 0 (0) | 6 | >250 | DEAD |
| el | GR |  |  | σημείωση | 223 | 0 (0) | 0 | 140 | DEAD |
| en-AU | AU | Cutling - Clipboard Keyboard | Save & Paste Text Snippets | copy | 187† | 6 (6) | 74 | >200† | live |
| en-AU | AU |  |  | clip | 170† | 0 (0) | 10277 | >200† | DEAD |
| en-AU | AU |  |  | autofill | 163† | 6 (6) | 6 | >200† | live |
| en-AU | AU |  |  | quick | 186† | 0 (0) | 565 | >200† | DEAD |
| en-AU | AU |  |  | template | 191† | 0 (0) | 9084 | >200† | DEAD |
| en-AU | AU |  |  | address | 142† | 0 (0) | 0 | >200† | DEAD |
| en-CA | CA | Cutling - Clipboard Keyboard | Save & Paste Text Snippets | copy | 187† | 4 (4) | 193 | >200† | weak |
| en-CA | CA |  |  | clip | 171† | 0 (0) | 11513 | >200† | DEAD |
| en-CA | CA |  |  | autofill | 165† | 7 (7) | 5 | >200† | live |
| en-CA | CA |  |  | quick | 185† | 0 (0) | 1910 | >200† | DEAD |
| en-CA | CA |  |  | template | 191† | 0 (0) | 14840 | >200† | DEAD |
| en-CA | CA |  |  | address | 146† | 0 (0) | 16 | >200† | DEAD |
| en-GB | GB | Cutling - Clipboard Keyboard | Save & Paste Text Snippets | copy | 250 | 5 (5) | 131 | >250 | live |
| en-GB | GB |  |  | clip | 250 | 0 (0) | 2908 | >250 | DEAD |
| en-GB | GB |  |  | autofill | 248 | 7 (7) | 4 | >250 | live |
| en-GB | GB |  |  | quick | 247 | 0 (0) | 2 | >250 | DEAD |
| en-GB | GB |  |  | template | 248 | 1 (1) | 12732 | >250 | DEAD |
| en-GB | GB |  |  | address | 244 | 0 (0) | 8 | >250 | DEAD |
| en-IN | IN | Cutling - Clipboard Keyboard | Save & Paste Text Snippets | copy | 249 | 3 (3) | 3 | >250 | weak |
| en-IN | IN |  |  | clip | 248 | 0 (0) | 486 | >250 | DEAD |
| en-IN | IN |  |  | autofill | 249 | 8 (8) | 0 | >250 | live |
| en-IN | IN |  |  | quick | 250 | 0 (0) | 20 | >250 | DEAD |
| en-IN | IN |  |  | template | 249 | 2 (2) | 2274 | >250 | weak |
| en-IN | IN |  |  | address | 250 | 0 (0) | 0 | >250 | DEAD |
| en-US | US | Cutling - Clipboard Keyboard | Save & Paste Text Snippets | copy | 246 | 6 (6) | 2634 | >250 | live |
| en-US | US |  |  | clip | 250 | 0 (0) | 14251 | >250 | DEAD |
| en-US | US |  |  | autofill | 249 | 8 (8) | 0 | 235 | live |
| en-US | US |  |  | quick | 250 | 0 (0) | 26876 | >250 | DEAD |
| en-US | US |  |  | template | 250 | 3 (3) | 11608 | >250 | weak |
| en-US | US |  |  | address | 241 | 1 (1) | 1173 | >250 | DEAD |
| es-ES | ES | Cutling - Teclado Portapapeles | Copiar, Pegar y Guardar Texto | snippet | 170† | 10 (9) | 2 | >200† | live |
| es-ES | ES |  |  | plantilla | 180† | 0 (0) | 2245 | >200† | DEAD |
| es-ES | ES |  |  | dirección | 159† | 0 (0) | 433 | >200† | DEAD |
| es-ES | ES |  |  | autorellenar | 2† | 1 (1) | 0 | 2 | DEAD |
| es-ES | ES |  |  | nota | 179† | 0 (0) | 556 | >200† | DEAD |
| es-ES | ES |  |  | mensaje | 183† | 0 (0) | 42534 | >200† | DEAD |
| es-MX | MX | Cutling - Teclado Portapapeles | Copiar, Pegar y Guardar Texto | snippet | 167† | 10 (9) | 1 | >200† | live |
| es-MX | MX |  |  | plantilla | 176† | 1 (1) | 3733 | >200† | DEAD |
| es-MX | MX |  |  | dirección | 163† | 0 (0) | 1 | >200† | DEAD |
| es-MX | MX |  |  | autorellenar | 2† | 1 (1) | 0 | 2 | DEAD |
| es-MX | MX |  |  | nota | 183† | 0 (0) | 8002 | >200† | DEAD |
| es-MX | MX |  |  | mensaje | 180† | 0 (0) | 53473 | >200† | DEAD |
| et | EE | Cutling - Lõikelaud Klaviatuur | Kopeeri, Kleebi ja Lõigud | mall | 228 | 0 (0) | 4 | >250 | DEAD |
| et | EE |  |  | aadress | 166 | 0 (0) | 0 | >250 | DEAD |
| et | EE |  |  | automaatne | 1 | 0 (0) | 0 | >250 | DEAD |
| et | EE |  |  | kiire | 196 | 0 (0) | 110 | >250 | DEAD |
| et | EE |  |  | katkend | 0 | 0 (0) | 0 | >250 | DEAD |
| et | EE |  |  | clipboard | 211 | 10 (9) | 0 | >250 | live |
| fa | none (no Iran storefront) | Cutling - کلیپ‌بورد کیبورد | کپی و چسباندن قطعات متنی | - | - | - | - | - | cannot test |
| fi | FI | Cutling - Leikepöytä & Teksti | Kopioi, Liitä ja Katkelmat | näppäimistö | 214 | 10 (0) | 87 | >250 | live |
| fi | FI |  |  | snippet | 203 | 10 (10) | 0 | >250 | live |
| fi | FI |  |  | osoite | 121 | 0 (0) | 0 | 77 | DEAD |
| fi | FI |  |  | pohja | 230 | 0 (0) | 1 | >250 | DEAD |
| fi | FI |  |  | nopea | 214 | 0 (0) | 101 | >250 | DEAD |
| fi | FI |  |  | täyttö | 66 | 2 (2) | 0 | 39 | weak |
| fil | PH | Cutling - Clipboard Keyboard | Kopya, Paste at mga Snippet | template | 183† | 0 (0) | 22109 | >200† | DEAD |
| fil | PH |  |  | address | 176† | 0 (0) | 0 | >200† | DEAD |
| fil | PH |  |  | mabilis | 171† | 0 (0) | 35130 | >200† | DEAD |
| fil | PH |  |  | auto | 187† | 0 (0) | 183 | >200† | DEAD |
| fil | PH |  |  | text | 168† | 1 (0) | 2121 | >200† | DEAD |
| fil | PH |  |  | notes | 178† | 1 (1) | 1755 | >200† | DEAD |
| fr-CA | CA | Cutling - Clavier & Clipboard | Presse-Papiers & Texte Rapide | copier | 174† | 3 (3) | 32 | >200† | weak |
| fr-CA | CA |  |  | coller | 189† | 1 (1) | 14648 | >200† | DEAD |
| fr-CA | CA |  |  | extrait | 159† | 2 (2) | 156 | 116 | weak |
| fr-CA | CA |  |  | snippet | 170† | 10 (10) | 2 | >200† | live |
| fr-CA | CA |  |  | modèle | 196† | 0 (0) | 360 | >200† | DEAD |
| fr-CA | CA |  |  | adresse | 176† | 0 (0) | 414 | >200† | DEAD |
| fr-FR | FR | Cutling - Clavier & Clipboard | Presse-Papiers & Texte Rapide | copier | 217 | 4 (4) | 42 | >250 | weak |
| fr-FR | FR |  |  | coller | 248 | 3 (3) | 2214 | >250 | weak |
| fr-FR | FR |  |  | extrait | 149 | 1 (1) | 119 | 132 | DEAD |
| fr-FR | FR |  |  | snippet | 221 | 10 (9) | 1 | >250 | live |
| fr-FR | FR |  |  | modèle | 235 | 0 (0) | 157 | >250 | DEAD |
| fr-FR | FR |  |  | adresse | 208 | 0 (0) | 1809 | >250 | DEAD |
| gu-IN | IN | Cutling - ક્લિપબોર્ડ કીબોર્ડ | કૉપી, પેસ્ટ અને સ્નિપેટ્સ | clipboard | 249 | 9 (8) | 61 | >250 | live |
| gu-IN | IN |  |  | snippet | 250 | 10 (10) | 1 | >250 | live |
| gu-IN | IN |  |  | ટેક્સ્ટ | 0 | 0 (0) | 0 | >250 | DEAD |
| gu-IN | IN |  |  | નોંધ | 1 | 1 (0) | 1 | >250 | DEAD |
| gu-IN | IN |  |  | ઝડપી | 0 | 0 (0) | 0 | >250 | DEAD |
| gu-IN | IN |  |  | ટેમ્પલેટ | 0 | 0 (0) | 0 | >250 | DEAD |
| he | IL | קאטלינג - לוח מקלדת | העתק, הדבק ופרגמנטים | קטע | 26† | 2 (2) | 0 | 23 | weak |
| he | IL |  |  | תבנית | 193† | 0 (0) | 3 | 147 | DEAD |
| he | IL |  |  | מהיר | 187† | 1 (1) | 108 | >200† | DEAD |
| he | IL |  |  | כתובת | 92† | 1 (1) | 0 | 77 | DEAD |
| he | IL |  |  | טקסט | 193† | 0 (0) | 19 | >200† | DEAD |
| he | IL |  |  | הערה | 143† | 1 (1) | 0 | 125 | DEAD |
| hi | IN | कटलिंग - क्लिपबोर्ड कीबोर्ड | कॉपी, पेस्ट और स्निपेट सहेजें | clipboard | 249 | 9 (8) | 61 | >250 | live |
| hi | IN |  |  | snippet | 250 | 10 (10) | 1 | >250 | live |
| hi | IN |  |  | टेक्स्ट | 246 | 3 (1) | 857 | >250 | weak |
| hi | IN |  |  | नोट | 250 | 0 (0) | 6 | >250 | DEAD |
| hi | IN |  |  | टेम्पलेट | 246 | 1 (1) | 141 | >250 | DEAD |
| hi | IN |  |  | पता | 248 | 0 (0) | 62 | >250 | DEAD |
| hr | HR | Cutling - Clipboard Tipkovnica | Međuspremnik, Isječci i Tekst | kopiranje | 35 | 5 (4) | 0 | 24 | live |
| hr | HR |  |  | lijepljenje | 11 | 8 (8) | 0 | 7 | live |
| hr | HR |  |  | adresa | 149 | 0 (0) | 0 | 55 | DEAD |
| hr | HR |  |  | predložak | 211 | 1 (1) | 0 | 135 | DEAD |
| hr | HR |  |  | brzo | 240 | 0 (0) | 1 | >250 | DEAD |
| hr | HR |  |  | bilješka | 205 | 1 (1) | 0 | 130 | DEAD |
| hu | HU | Cutling - Vágólap Billentyűzet | Másolás és Beillesztés Szöveg | sablon | 237 | 2 (2) | 0 | 183 | weak |
| hu | HU |  |  | cím | 124 | 0 (0) | 0 | >250 | DEAD |
| hu | HU |  |  | gyors | 236 | 0 (0) | 3 | >250 | DEAD |
| hu | HU |  |  | mentés | 228 | 1 (1) | 12 | >250 | DEAD |
| hu | HU |  |  | jegyzet | 236 | 6 (6) | 226 | >250 | live |
| hu | HU |  |  | üzenet | 244 | 0 (0) | 3276 | >250 | DEAD |
| id | ID | Cutling - Clipboard Keyboard | Salin, Tempel & Snippet Teks | copy | 184† | 3 (3) | 152 | >200† | weak |
| id | ID |  |  | paste | 186† | 9 (9) | 29 | >200† | live |
| id | ID |  |  | template | 185† | 0 (0) | 7442 | >200† | DEAD |
| id | ID |  |  | alamat | 154 | 1 (1) | 0 | 89 | DEAD |
| id | ID |  |  | catatan | 250 | 2 (2) | 552 | >250 | weak |
| id | ID |  |  | cepat | 248 | 0 (0) | 38122 | >250 | DEAD |
| it | IT | Cutling - Appunti Tastiera | Copiare, Incollare & Snippet | clipboard | 181† | 10 (9) | 33 | 160 | live |
| it | IT |  |  | modello | 174† | 0 (0) | 4 | >200† | DEAD |
| it | IT |  |  | indirizzo | 135† | 2 (2) | 0 | >200† | weak |
| it | IT |  |  | testo | 177† | 4 (1) | 2643 | >200† | weak |
| it | IT |  |  | rapido | 184† | 0 (0) | 6684 | >200† | DEAD |
| it | IT |  |  | nota | 173† | 4 (4) | 351 | >200† | weak |
| ja | JP | カットリング - クリップボード キーボード | 定型文 & テキストスニペット管理 | コピペ | 244 | 10 (10) | 38 | 43 | live |
| ja | JP |  |  | テンプレート | 242 | 0 (0) | 91229 | >250 | DEAD |
| ja | JP |  |  | コピー | 250 | 0 (0) | 38367 | >250 | DEAD |
| ja | JP |  |  | ペースト | 240 | 10 (10) | 86 | >250 | live |
| ja | JP |  |  | 保存 | 239 | 0 (0) | 27565 | >250 | DEAD |
| ja | JP |  |  | メモ | 249 | 2 (2) | 26126 | >250 | weak |
| kn-IN | IN | Cutling - Clipboard Keyboard | ಕಾಪಿ & ಪೇಸ್ಟ್ ಸ್ನಿಪೆಟ್‌ಗಳು | ಕ್ಲಿಪ್‌ಬೋರ್ಡ್ | 0 | 0 (0) | 0 | >250 | DEAD |
| kn-IN | IN |  |  | snippet | 250 | 10 (10) | 1 | >250 | live |
| kn-IN | IN |  |  | ಕೀಬೋರ್ಡ್ | 0 | 0 (0) | 0 | >250 | DEAD |
| kn-IN | IN |  |  | autofill | 249 | 8 (8) | 0 | >250 | live |
| kn-IN | IN |  |  | ಟೆಕ್ಸ್ಟ್ | 0 | 0 (0) | 0 | >250 | DEAD |
| kn-IN | IN |  |  | ಟೆಂಪ್ಲೇಟ್ | 0 | 0 (0) | 0 | >250 | DEAD |
| ko | KR | 컷링 - 클립보드 키보드 | 복사 붙여넣기 & 텍스트 스니펫 | 복붙 | 50 | 10 (10) | 2 | 48 | live |
| ko | KR |  |  | 템플릿 | 245 | 0 (0) | 6752 | >250 | DEAD |
| ko | KR |  |  | 정형문 | 6 | 6 (5) | 0 | 6 | live |
| ko | KR |  |  | 자동입력 | 114 | 1 (1) | 2 | 103 | DEAD |
| ko | KR |  |  | 메모 | 250 | 1 (1) | 5459 | >250 | DEAD |
| ko | KR |  |  | 저장 | 249 | 0 (0) | 7826 | >250 | DEAD |
| lt | LT | Cutling - Iškarpinė Klaviatūra | Kopijuoti ir Įklijuoti Tekstą | šablonas | 2 | 0 (0) | 0 | >250 | DEAD |
| lt | LT |  |  | adresas | 200 | 0 (0) | 3 | >250 | DEAD |
| lt | LT |  |  | greitas | 6 | 0 (0) | 4 | >250 | DEAD |
| lt | LT |  |  | auto | 243 | 0 (0) | 370 | >250 | DEAD |
| lt | LT |  |  | fragmentas | 4 | 0 (0) | 0 | >250 | DEAD |
| lt | LT |  |  | clipboard | 224 | 10 (10) | 1 | >250 | live |
| lv | LV | Cutling - Clipboard Tastatūra | Kopēt, Ielīmēt un Fragmenti | starpliktuve | 0 | 0 (0) | 0 | >250 | DEAD |
| lv | LV |  |  | veidne | 0 | 0 (0) | 0 | >250 | DEAD |
| lv | LV |  |  | adrese | 165 | 0 (0) | 0 | >250 | DEAD |
| lv | LV |  |  | ātri | 34 | 0 (0) | 3 | >250 | DEAD |
| lv | LV |  |  | auto | 232 | 0 (0) | 271 | >250 | DEAD |
| lv | LV |  |  | piezīme | 2 | 0 (0) | 3 | >250 | DEAD |
| ml-IN | IN | Cutling - ക്ലിപ്ബോർഡ് കീബോർഡ് | കോപ്പി & പേസ്റ്റ് സ്നിപ്പറ്റ് | clipboard | 249 | 9 (8) | 61 | >250 | live |
| ml-IN | IN |  |  | snippet | 250 | 10 (10) | 1 | >250 | live |
| ml-IN | IN |  |  | keyboard | 250 | 10 (1) | 12836 | >250 | live |
| ml-IN | IN |  |  | autofill | 249 | 8 (8) | 0 | >250 | live |
| ml-IN | IN |  |  | ടെക്സ്റ്റ് | 246 | 2 (1) | 387 | >250 | weak |
| ml-IN | IN |  |  | ടെംപ്ലേറ്റ് | 0 | 0 (0) | 0 | >250 | DEAD |
| mr-IN | IN | Cutling - क्लिपबोर्ड कीबोर्ड | कॉपी, पेस्ट आणि स्निपेट | clipboard | 249 | 9 (8) | 61 | >250 | live |
| mr-IN | IN |  |  | snippet | 250 | 10 (10) | 1 | >250 | live |
| mr-IN | IN |  |  | keyboard | 250 | 10 (1) | 12836 | >250 | live |
| mr-IN | IN |  |  | autofill | 249 | 8 (8) | 0 | >250 | live |
| mr-IN | IN |  |  | टेक्स्ट | 246 | 3 (1) | 857 | >250 | weak |
| mr-IN | IN |  |  | टेम्पलेट | 246 | 1 (1) | 141 | >250 | DEAD |
| ms | MY | Cutling - Papan Klip Keyboard | Salin, Tampal & Petikan Teks | clipboard | 189† | 10 (9) | 23 | >200† | live |
| ms | MY |  |  | snippet | 168† | 10 (10) | 0 | >200† | live |
| ms | MY |  |  | template | 183† | 0 (0) | 7972 | >200† | DEAD |
| ms | MY |  |  | alamat | 111† | 0 (0) | 0 | 92 | DEAD |
| ms | MY |  |  | pantas | 187† | 0 (0) | 13 | >200† | DEAD |
| ms | MY |  |  | nota | 177† | 1 (1) | 716 | >200† | DEAD |
| nl-NL | NL | Cutling - Klembord Toetsenbord | Kopiëren, Plakken & Fragmenten | tekst | 191† | 6 (3) | 2116 | >200† | live |
| nl-NL | NL |  |  | snippet | 166† | 10 (9) | 2 | >200† | live |
| nl-NL | NL |  |  | adres | 122† | 0 (0) | 13 | >200† | DEAD |
| nl-NL | NL |  |  | sjabloon | 185† | 1 (1) | 0 | >200† | DEAD |
| nl-NL | NL |  |  | snel | 189† | 0 (0) | 6455 | >200† | DEAD |
| nl-NL | NL |  |  | notitie | 188† | 0 (0) | 335 | >200† | DEAD |
| no | NO | Cutling - Utklipp Tastatur | Kopier, Lim Inn og Utdrag | utklippstavle | 45 | 10 (10) | 0 | 25 | live |
| no | NO |  |  | tekst | 249 | 6 (2) | 562 | >250 | live |
| no | NO |  |  | snippet | 248 | 10 (10) | 0 | >250 | live |
| no | NO |  |  | adresse | 247 | 0 (0) | 16 | >250 | DEAD |
| no | NO |  |  | mal | 250 | 0 (0) | 1 | >250 | DEAD |
| no | NO |  |  | rask | 246 | 0 (0) | 882 | >250 | DEAD |
| or-IN | IN | Cutling - କ୍ଲିପବୋର୍ଡ କୀବୋର୍ଡ | କପି, ପେଷ୍ଟ ଏବଂ ସ୍ନିପେଟ | clipboard | 249 | 9 (8) | 61 | >250 | live |
| or-IN | IN |  |  | snippet | 250 | 10 (10) | 1 | >250 | live |
| or-IN | IN |  |  | autofill | 249 | 8 (8) | 0 | >250 | live |
| or-IN | IN |  |  | keyboard | 250 | 10 (1) | 12836 | >250 | live |
| or-IN | IN |  |  | ଟେକ୍ସଟ | 0 | 0 (0) | 0 | >250 | DEAD |
| or-IN | IN |  |  | ଟେମ୍ପଲେଟ | 0 | 0 (0) | 0 | >250 | DEAD |
| pa-IN | IN | Cutling - ਕਲਿੱਪਬੋਰਡ ਕੀਬੋਰਡ | ਕਾਪੀ, ਪੇਸਟ ਅਤੇ ਸਨਿੱਪਟ | clipboard | 249 | 9 (8) | 61 | >250 | live |
| pa-IN | IN |  |  | snippet | 250 | 10 (10) | 1 | >250 | live |
| pa-IN | IN |  |  | autofill | 249 | 8 (8) | 0 | >250 | live |
| pa-IN | IN |  |  | keyboard | 250 | 10 (1) | 12836 | >250 | live |
| pa-IN | IN |  |  | ਟੈਕਸਟ | 1 | 0 (0) | 1 | >250 | DEAD |
| pa-IN | IN |  |  | ਟੈਂਪਲੇਟ | 0 | 0 (0) | 0 | >250 | DEAD |
| pl | PL | Cutling - Schowek Klawiatura | Kopiuj, Wklej i Wycinki Tekst | snippet | 162† | 10 (10) | 1 | >200† | live |
| pl | PL |  |  | adres | 151† | 0 (0) | 3 | 97 | DEAD |
| pl | PL |  |  | szablon | 189† | 0 (0) | 1 | >200† | DEAD |
| pl | PL |  |  | szybko | 184† | 0 (0) | 2 | >200† | DEAD |
| pl | PL |  |  | notatka | 194† | 1 (1) | 966 | >200† | DEAD |
| pl | PL |  |  | zapisz | 180† | 0 (0) | 4 | >200† | DEAD |
| pt-BR | BR | Cutling - Clipboard Teclado | Copiar, Colar & Trechos Texto | snippet | 250 | 10 (9) | 0 | >250 | live |
| pt-BR | BR |  |  | modelo | 247 | 0 (0) | 4635 | >250 | DEAD |
| pt-BR | BR |  |  | endereço | 210 | 2 (2) | 0 | 181 | weak |
| pt-BR | BR |  |  | atalho | 248 | 1 (1) | 16570 | 226 | DEAD |
| pt-BR | BR |  |  | notas | 250 | 3 (3) | 7292 | >250 | weak |
| pt-BR | BR |  |  | salvar | 250 | 0 (0) | 277 | >250 | DEAD |
| pt-PT | PT | Cutling - Clipboard Teclado | Copiar, Colar & Excertos Texto | snippet | 153† | 10 (9) | 0 | >200† | live |
| pt-PT | PT |  |  | modelo | 180† | 0 (0) | 470 | >200† | DEAD |
| pt-PT | PT |  |  | morada | 162† | 0 (0) | 8 | >200† | DEAD |
| pt-PT | PT |  |  | atalho | 179† | 0 (0) | 649 | >200† | DEAD |
| pt-PT | PT |  |  | notas | 185† | 0 (0) | 773 | >200† | DEAD |
| pt-PT | PT |  |  | guardar | 192† | 0 (0) | 1480 | >200† | DEAD |
| ro | RO | Cutling - Clipboard Tastatură | Copiere, Lipire și Fragmente | text | 247 | 6 (0) | 410 | >250 | live |
| ro | RO |  |  | adresă | 150 | 0 (0) | 0 | 75 | DEAD |
| ro | RO |  |  | șablon | 234 | 1 (1) | 0 | >250 | DEAD |
| ro | RO |  |  | rapid | 246 | 0 (0) | 4 | >250 | DEAD |
| ro | RO |  |  | notă | 245 | 3 (3) | 29 | >250 | weak |
| ro | RO |  |  | salvare | 225 | 0 (0) | 7 | >250 | DEAD |
| ru | RU | Катлинг - Буфер Клавиатура | Копирование и Вставка Текста | шаблон | 164† | 8 (8) | 1069 | >200† | live |
| ru | RU |  |  | адрес | 151† | 0 (0) | 8 | >200† | DEAD |
| ru | RU |  |  | быстро | 161† | 0 (0) | 2583 | >200† | DEAD |
| ru | RU |  |  | заметка | 195† | 1 (1) | 5903 | >200† | DEAD |
| ru | RU |  |  | сохранить | 159† | 1 (1) | 71 | >200† | DEAD |
| ru | RU |  |  | сообщение | 145† | 0 (0) | 11342 | >200† | DEAD |
| sk | SK | Cutling - Schránka Klávesnica | Kopírovať, Vložiť a Úryvky | šablóna | 244 | 1 (1) | 0 | 231 | DEAD |
| sk | SK |  |  | adresa | 139 | 0 (0) | 0 | 72 | DEAD |
| sk | SK |  |  | text | 248 | 5 (1) | 96 | >250 | live |
| sk | SK |  |  | rýchlo | 236 | 2 (1) | 0 | >250 | weak |
| sk | SK |  |  | poznámka | 228 | 0 (0) | 0 | 213 | DEAD |
| sk | SK |  |  | clipboard | 215 | 10 (9) | 2 | >250 | live |
| sl-SI | SI | Cutling - Odložišče Tipkovnica | Kopiraj, Prilepi in Fragmenti | delček | 0 | 0 (0) | 0 | >250 | DEAD |
| sl-SI | SI |  |  | predloga | 0 | 0 (0) | 0 | >250 | DEAD |
| sl-SI | SI |  |  | naslov | 1 | 0 (0) | 0 | >250 | DEAD |
| sl-SI | SI |  |  | hitro | 0 | 0 (0) | 0 | >250 | DEAD |
| sl-SI | SI |  |  | besedilo | 1 | 0 (0) | 0 | >250 | DEAD |
| sl-SI | SI |  |  | opomba | 0 | 0 (0) | 0 | >250 | DEAD |
| sr | RS | Cutling - Клипборд Тастатура | Копирај, Налепи и Исечци | исечак | 0 | 0 (0) | 0 | >250 | DEAD |
| sr | RS |  |  | шаблон | 50 | 6 (6) | 46 | >250 | live |
| sr | RS |  |  | адреса | 23 | 0 (0) | 0 | >250 | DEAD |
| sr | RS |  |  | брзо | 2 | 0 (0) | 0 | >250 | DEAD |
| sr | RS |  |  | ауто | 250 | 0 (0) | 27 | >250 | DEAD |
| sr | RS |  |  | clipboard | 249 | 10 (10) | 0 | >250 | live |
| sv | SE | Cutling - Urklipp Tangentbord | Kopiera, Klistra & Utdrag Text | snippet | 164† | 10 (9) | 0 | >200† | live |
| sv | SE |  |  | adress | 153† | 0 (0) | 14 | >200† | DEAD |
| sv | SE |  |  | mall | 176† | 0 (0) | 76 | >200† | DEAD |
| sv | SE |  |  | snabb | 178† | 0 (0) | 13248 | >200† | DEAD |
| sv | SE |  |  | autofyll | 11† | 1 (1) | 0 | 9 | DEAD |
| sv | SE |  |  | genväg | 166† | 0 (0) | 1217 | >200† | DEAD |
| sw | KE | Cutling - Clipboard Kibodi | Nakili, Bandika na Vipande | kipande | 0 | 0 (0) | 0 | >250 | DEAD |
| sw | KE |  |  | kiolezo | 0 | 0 (0) | 0 | >250 | DEAD |
| sw | KE |  |  | anwani | 1 | 0 (0) | 0 | >250 | DEAD |
| sw | KE |  |  | haraka | 69 | 0 (0) | 275 | >250 | DEAD |
| sw | KE |  |  | auto | 249 | 0 (0) | 4 | >250 | DEAD |
| sw | KE |  |  | maandishi | 0 | 0 (0) | 0 | >250 | DEAD |
| ta-IN | IN | Cutling - Clipboard Keyboard | காப்பி, பேஸ்ட் & துணுக்குகள் | கிளிப்போர்டு | 0 | 0 (0) | 0 | >250 | DEAD |
| ta-IN | IN |  |  | snippet | 250 | 10 (10) | 1 | >250 | live |
| ta-IN | IN |  |  | autofill | 249 | 8 (8) | 0 | >250 | live |
| ta-IN | IN |  |  | கீபோர்டு | 0 | 0 (0) | 0 | >250 | DEAD |
| ta-IN | IN |  |  | டெக்ஸ்ட் | 246 | 3 (1) | 857 | >250 | weak |
| ta-IN | IN |  |  | டெம்ப்ளேட் | 0 | 0 (0) | 0 | >250 | DEAD |
| te-IN | IN | Cutling - Clipboard Keyboard | కాపీ, పేస్ట్ & స్నిప్పెట్లు | క్లిప్‌బోర్డ్ | 0 | 0 (0) | 0 | >250 | DEAD |
| te-IN | IN |  |  | snippet | 250 | 10 (10) | 1 | >250 | live |
| te-IN | IN |  |  | కీబోర్డ్ | 250 | 10 (1) | 12836 | >250 | live |
| te-IN | IN |  |  | autofill | 249 | 8 (8) | 0 | >250 | live |
| te-IN | IN |  |  | టెక్స్ట్ | 0 | 0 (0) | 0 | >250 | DEAD |
| te-IN | IN |  |  | టెంప్లేట్ | 0 | 0 (0) | 0 | >250 | DEAD |
| th | TH | คัตลิง - คลิปบอร์ด คีย์บอร์ด | คัดลอก วาง และสนิปเปต | แม่แบบ | 166† | 0 (0) | 1807702 | >200† | DEAD |
| th | TH |  |  | ที่อยู่ | 162† | 0 (0) | 78 | >200† | DEAD |
| th | TH |  |  | เร็ว | 191† | 0 (0) | 4 | >200† | DEAD |
| th | TH |  |  | อัตโนมัติ | 184† | 0 (0) | 28 | >200† | DEAD |
| th | TH |  |  | บันทึก | 188† | 1 (1) | 1871 | >200† | DEAD |
| th | TH |  |  | ข้อความ | 180† | 0 (0) | 149468 | >200† | DEAD |
| tr | TR | Cutling - Pano Klavye & Metin | Kopyala, Yapıştır, Parçacıklar | snippet | 174† | 10 (10) | 1 | >200† | live |
| tr | TR |  |  | adres | 167† | 0 (0) | 12 | >200† | DEAD |
| tr | TR |  |  | banka | 187† | 0 (0) | 448920 | >200† | DEAD |
| tr | TR |  |  | şablon | 193† | 1 (1) | 1938 | >200† | DEAD |
| tr | TR |  |  | hızlı | 196† | 0 (0) | 2556 | >200† | DEAD |
| tr | TR |  |  | not | 176† | 1 (1) | 4465 | >200† | DEAD |
| uk | UA | Катлінг - Буфер Клавіатура | Копіювати і Вставити Текст | шаблон | 167† | 1 (1) | 986 | >200† | DEAD |
| uk | UA |  |  | адреса | 163† | 0 (0) | 0 | >200† | DEAD |
| uk | UA |  |  | швидко | 193† | 0 (0) | 2790 | >200† | DEAD |
| uk | UA |  |  | нотатка | 197† | 1 (1) | 609 | >200† | DEAD |
| uk | UA |  |  | зберегти | 174† | 0 (0) | 0 | >200† | DEAD |
| uk | UA |  |  | повідомлення | 173† | 0 (0) | 41729 | >200† | DEAD |
| ur-PK | PK | Cutling - کلپ بورڈ کیبورڈ | کاپی, پیسٹ اور اقتباسات | clipboard | 248 | 10 (9) | 14 | >250 | live |
| ur-PK | PK |  |  | snippet | 250 | 9 (9) | 0 | >250 | live |
| ur-PK | PK |  |  | autofill | 245 | 6 (6) | 1288 | 190 | live |
| ur-PK | PK |  |  | ٹیمپلیٹ | 249 | 0 (0) | 34 | >250 | DEAD |
| ur-PK | PK |  |  | پتہ | 248 | 1 (0) | 16 | >250 | DEAD |
| ur-PK | PK |  |  | تیز | 244 | 0 (0) | 16 | >250 | DEAD |
| vi | VN | Cutling - Clipboard Bàn Phím | Sao Chép, Dán và Đoạn Trích | copy | 188† | 2 (2) | 91 | >200† | weak |
| vi | VN |  |  | paste | 188† | 8 (8) | 10 | >200† | live |
| vi | VN |  |  | snippet | 176† | 10 (10) | 0 | >200† | live |
| vi | VN |  |  | địa chỉ | 163† | 1 (1) | 2149 | >200† | DEAD |
| vi | VN |  |  | ngân hàng | 180† | 0 (0) | 62025 | >200† | DEAD |
| vi | VN |  |  | ghi chú | 172† | 2 (1) | 2526 | >200† | weak |
| zh-Hans | CN | Cutling - 剪贴板键盘 | 复制粘贴 & 文本片段快捷管理 | 模板 | 246 | 0 (0) | 11417 | >250 | DEAD |
| zh-Hans | CN |  |  | 自动填充 | 86 | 6 (4) | 37 | 18 | live |
| zh-Hans | CN |  |  | 地址 | 250 | 0 (0) | 26339 | >250 | DEAD |
| zh-Hans | CN |  |  | 常用文字 | 34 | 6 (6) | 2 | 25 | live |
| zh-Hans | CN |  |  | clipboard | 243 | 9 (9) | 2 | 88 | live |
| zh-Hans | CN |  |  | keyboard | 247 | 10 (1) | 173 | >250 | live |
| zh-Hant | TW | Cutling - 剪貼簿鍵盤 | 複製貼上 & 文字片段快速管理 | 範本 | 183† | 1 (1) | 107 | >200† | DEAD |
| zh-Hant | TW |  |  | 自動填寫 | 26† | 2 (2) | 2 | 15 | weak |
| zh-Hant | TW |  |  | 地址 | 173† | 0 (0) | 2596 | >200† | DEAD |
| zh-Hant | TW |  |  | 常用文字 | 69† | 9 (9) | 34 | 23 | live |
| zh-Hant | TW |  |  | clipboard | 191† | 9 (9) | 1 | 169 | live |
| zh-Hant | TW |  |  | keyboard | 186† | 10 (3) | 1223 | >200† | live |

## Per-storefront tables

Columns: term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200). `>250` and `>200` = not found.

### US (storefront id 143441)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard | 2 | 250 | 7 (7) | 950 | 237 | 135 |
| clipboard manager | 2 | 247 | 10 (10) | 61 | 207 | >200 |
| clipboard keyboard | 2 | 250 | 10 (9) | 235 | 12 | 94 |
| copy paste | 3 | 249 | 10 (10) | 6333 | >250 | >200 |
| paste | 2 | 247 | 10 (9) | 1585 | >250 | >200 |
| snippet | 1 | 249 | 10 (10) | 2 | 62 | >200 |
| snippets | 1 | 246 | 10 (10) | 2 | 69 | >200 |
| text snippets | - | 239 | 10 (10) | 1 | 25 | 157 |
| text expander | 1 | 249 | 8 (7) | 1 | >250 | >200 |
| text replacement | 1 | 249 | 3 (3) | 393 | >250 | >200 |
| keyboard | 1 | 248 | 10 (2) | 147900 | >250 | >200 |
| custom keyboard | 2 | 248 | 10 (1) | 13486 | 89 | >200 |
| quick reply | - | 245 | 9 (8) | 1 | >250 | >200 |
| canned responses | - | 51 | 9 (9) | 3 | 24 | 36 |
| templates | 5 | 247 | 4 (4) | 11608 | >250 | >200 |
| autofill | 3 | 249 | 8 (8) | 0 | 235 | >200 |
| save text | - | 247 | 3 (3) | 2 | >250 | >200 |
| phrases | - | 249 | 1 (1) | 106 | >250 | >200 |
| notes keyboard | - | 245 | 10 (2) | 12 | >250 | >200 |
| text shortcuts | - | 246 | 8 (6) | 0 | 243 | >200 |
| autotext | - | 247 | 8 (8) | 498 | >250 | >200 |
| copy | - | 246 | 6 (6) | 2634 | >250 | >200 |
| clip | - | 250 | 0 (0) | 14251 | >250 | >200 |
| quick | - | 250 | 0 (0) | 26876 | >250 | >200 |
| template | 6 | 250 | 3 (3) | 11608 | >250 | >200 |
| address | 7 | 241 | 1 (1) | 1173 | >250 | >200 |
| canned response | - | 41 | 9 (9) | 3 | 21 | - |
| clipboard health app | 1 | 250 | 2 (2) | 2567 | >250 | >200 |
| clipboard workplace | 1 | 250 | 5 (5) | 11 | >250 | >200 |
| clipboard workers | 1 | 250 | 2 (2) | 31660 | >250 | >200 |
| clipboard dental | 1 | 248 | 10 (10) | 0 | 106 | >200 |
| clipboard history | 1 | 248 | 10 (10) | 3 | >250 | >200 |
| clipboard manager one tap | 1 | 250 | 10 (10) | 0 | 181 | >200 |
| clipboard keyboard manager | 1 | 250 | 10 (10) | 5 | 16 | 138 |
| ai text expander | 1 | 247 | 4 (4) | 1 | >250 | >200 |

### GB (storefront id 143444)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard | 1 | 248 | 10 (10) | 16 | >250 | >200 |
| clipboard manager | 1 | 249 | 10 (10) | 15 | >250 | >200 |
| clipboard keyboard | 1 | 250 | 10 (9) | 35 | 188 | 130 |
| copy paste | 2 | 250 | 10 (10) | 622 | >250 | >200 |
| paste | 3 | 250 | 10 (10) | 1 | >250 | >200 |
| snippet | 3 | 249 | 10 (10) | 2 | >250 | >200 |
| snippets | - | 248 | 10 (10) | 2 | >250 | >200 |
| text snippets | - | 243 | 10 (10) | 0 | >250 | >200 |
| text expander | - | 247 | 9 (9) | 0 | >250 | >200 |
| text replacement | - | 250 | 4 (4) | 9 | >250 | >200 |
| keyboard | 1 | 250 | 10 (2) | 4373 | >250 | >200 |
| custom keyboard | 2 | 247 | 10 (2) | 1782 | >250 | >200 |
| quick reply | - | 178 | 8 (8) | 0 | >250 | >200 |
| canned responses | - | 50 | 9 (7) | 2 | 43 | 46 |
| templates | 2 | 247 | 4 (4) | 16970 | >250 | >200 |
| autofill | 2 | 248 | 7 (7) | 4 | >250 | >200 |
| save text | - | 243 | 0 (0) | 4 | >250 | >200 |
| phrases | - | 249 | 0 (0) | 4 | >250 | >200 |
| notes keyboard | - | 245 | 10 (2) | 2 | >250 | >200 |
| text shortcuts | - | 246 | 7 (6) | 0 | >250 | >200 |
| autotext | - | 248 | 8 (8) | 61 | >250 | >200 |
| copy | - | 250 | 5 (5) | 131 | >250 | >200 |
| clip | - | 250 | 0 (0) | 2908 | >250 | >200 |
| quick | 6 | 247 | 0 (0) | 2 | >250 | >200 |
| template | 4 | 248 | 1 (1) | 12732 | >250 | >200 |
| address | - | 244 | 0 (0) | 8 | >250 | >200 |
| canned response | - | 40 | 9 (8) | 2 | 33 | - |
| clipboard ++ | 7 | 250 | 10 (10) | 1 | >250 | >200 |
| clipboard history | 1 | 250 | 10 (10) | 1 | >250 | >200 |
| clipboard free | 1 | 250 | 10 (10) | 5 | >250 | >200 |
| garmin clipboard™ | 1 | 250 | 6 (6) | 69 | 223 | >200 |
| clipboardvault smart keyboard | 1 | 1 | 1 (1) | 0 | >250 | >200 |
| ai text expander | 1 | 245 | 4 (4) | 1 | >250 | >200 |
| snippets studio | 1 | 248 | 5 (3) | 0 | >250 | >200 |
| snippets! | 1 | 235 | 10 (10) | 0 | >250 | >200 |

### DE (storefront id 143443)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard | 2 | 235 | 10 (9) | 18 | >250 | >200 |
| clipboard manager | 1 | 210 | 10 (10) | 18 | >250 | >200 |
| clipboard keyboard | 1 | 228 | 10 (9) | 14 | 174 | 174 |
| copy paste | 2 | 209 | 9 (9) | 159 | >250 | >200 |
| text snippets | - | 222 | 8 (8) | 0 | >250 | >200 |
| text expander | - | 125 | 9 (9) | 0 | >250 | >200 |
| custom keyboard | 1 | 239 | 10 (1) | 677 | >250 | >200 |
| canned responses | - | 30 | 10 (8) | 1 | 23 | 23 |
| Zwischenablage | 1 | 183 | 10 (10) | 7 | 170 | >200 |
| Textbausteine | - | 59 | 9 (9) | 0 | >250 | >200 |
| Tastatur | 2 | 226 | 9 (1) | 7468 | >250 | >200 |
| Kopieren Einfügen | - | 135 | 9 (9) | 1 | 110 | 110 |
| Zwischenablage Tastatur | - | 62 | 10 (9) | 5 | 53 | 53 |
| Vorlagen | 1 | 232 | 4 (4) | 226 | >250 | >200 |
| Textersetzung | - | 4 | 3 (2) | 2 | >250 | >200 |
| Schnellantworten | - | 55 | 8 (7) | 1 | 50 | >200 |
| Notizen Tastatur | - | 75 | 10 (3) | 9 | 64 | 64 |
| zwischenablage | 1 | 183 | 10 (10) | 7 | 170 | >200 |
| vorlage | 3 | 235 | 3 (3) | 6573 | >250 | >200 |
| adresse | - | 207 | 0 (0) | 11 | >250 | >200 |
| schnell | - | 240 | 0 (0) | 426 | >250 | >200 |
| text | 7 | 242 | 5 (1) | 4803 | >250 | >200 |
| notiz | 4 | 242 | 4 (4) | 2556 | >250 | >200 |
| quick reply | - | 236 | 6 (4) | 1 | >250 | - |
| canned response | - | 30 | 10 (8) | 1 | 24 | - |
| zwischenablage-cleaner | 1 | 3 | 3 (3) | 1 | >250 | >200 |
| zwischenablage+ | 7 | 183 | 9 (9) | 0 | 173 | >200 |
| zwischenablage-rechner | 1 | 2 | 1 (1) | 0 | >250 | >200 |
| textbausteine tastatur kürzel | 1 | 9 | 9 (8) | 0 | >250 | >200 |
| tastatur iphone kostenlos | 1 | 246 | 9 (0) | 5174 | >250 | >200 |
| tastatur schrift kostenlos | 1 | 153 | 10 (1) | 4761 | >250 | >200 |
| tastatur hintergrund | 2 | 212 | 9 (1) | 638 | >250 | >200 |
| tastatur übersetzer | 1 | 152 | 8 (0) | 4 | >250 | >200 |

### JP (storefront id 143462)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard | 2 | 247 | 10 (10) | 11 | 55 | >200 |
| clipboard manager | 3 | 248 | 10 (10) | 6 | >250 | 172 |
| clipboard keyboard | - | 244 | 10 (9) | 79 | 68 | 34 |
| copy paste | - | 247 | 10 (10) | 216 | >250 | >200 |
| text snippets | - | 242 | 10 (10) | 11 | 133 | 147 |
| text expander | - | 127 | 9 (9) | 0 | >250 | >200 |
| custom keyboard | 1 | 248 | 10 (1) | 16 | >250 | >200 |
| canned responses | - | 30 | 10 (9) | 1 | 23 | 23 |
| クリップボード | 1 | 249 | 8 (8) | 168 | 35 | >200 |
| コピペ | 5 | 244 | 10 (10) | 38 | 43 | >200 |
| 定型文 | 1 | 235 | 9 (9) | 24 | 161 | >200 |
| 辞書 | 1 | 250 | 2 (0) | 6080 | >250 | >200 |
| ユーザー辞書 | 1 | 41 | 8 (4) | 16 | >250 | >200 |
| キーボード | 1 | 249 | 9 (2) | 3830 | >250 | >200 |
| 定型文 キーボード | - | 122 | 10 (10) | 3 | 66 | 71 |
| スニペット | 1 | 250 | 10 (10) | 1 | >250 | >200 |
| テンプレート | 2 | 242 | 0 (0) | 91229 | >250 | >200 |
| 貼り付け | 3 | 247 | 4 (4) | 47833 | >250 | >200 |
| 返信 テンプレ | - | 20 | 9 (8) | 0 | >250 | >200 |
| メモ キーボード | - | 222 | 7 (5) | 105 | 144 | 106 |
| コピー | 1 | 250 | 0 (0) | 38367 | >250 | >200 |
| ペースト | 2 | 240 | 10 (10) | 86 | >250 | >200 |
| 保存 | 1 | 239 | 0 (0) | 27565 | >250 | >200 |
| メモ | 1 | 249 | 2 (2) | 26126 | >250 | >200 |
| quick reply | - | 158 | 7 (6) | 1 | >250 | - |
| canned response | - | 30 | 10 (9) | 1 | 23 | - |
| クリップボード管理アプリ | 1 | 115 | 9 (9) | 42 | 33 | 74 |
| クリップボード履歴 | 1 | 250 | 10 (10) | 5 | 31 | 86 |
| クリップボードクリーナー | 1 | 22 | 6 (6) | 218 | >250 | >200 |
| クリップボード・ビューアー | 1 | 24 | 5 (5) | 4 | >250 | >200 |
| クリップボード手帳 | 1 | 5 | 4 (4) | 3 | >250 | >200 |
| コピペ帳 | 1 | 62 | 10 (10) | 32 | >250 | >200 |
| コピペ帳〜 素早くコピー＆ペースト | 1 | 7 | 6 (6) | 1 | >250 | >200 |
| コピペ キーボード | 1 | 250 | 9 (9) | 19 | 57 | >200 |

### FR (storefront id 143442)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard | 1 | 234 | 9 (9) | 24 | >250 | >200 |
| clipboard manager | 1 | 222 | 10 (10) | 9 | >250 | >200 |
| clipboard keyboard | 1 | 219 | 10 (9) | 16 | 78 | 78 |
| copy paste | 1 | 218 | 10 (10) | 126 | >250 | >200 |
| text snippets | - | 219 | 8 (8) | 0 | >250 | >200 |
| text expander | - | 125 | 9 (8) | 0 | >250 | >200 |
| custom keyboard | 1 | 240 | 10 (3) | 711 | >250 | >200 |
| canned responses | - | 29 | 9 (6) | 0 | 24 | 24 |
| presse-papiers | - | 182 | 10 (10) | 0 | 180 | >200 |
| copier coller | 1 | 177 | 8 (8) | 32 | 173 | >200 |
| clavier | 4 | 232 | 10 (1) | 8968 | >250 | >200 |
| raccourcis texte | - | 97 | 7 (5) | 19 | 94 | 94 |
| clavier presse-papiers | - | 64 | 10 (10) | 4 | 61 | 60 |
| réponses rapides | - | 26 | 7 (6) | 0 | >250 | >200 |
| modèles de texte | - | 109 | 5 (5) | 107 | >250 | >200 |
| remplissage automatique | - | 5 | 4 (4) | 37 | >250 | >200 |
| copier | - | 217 | 4 (4) | 42 | >250 | >200 |
| coller | - | 248 | 3 (3) | 2214 | >250 | >200 |
| extrait | - | 149 | 1 (1) | 119 | 132 | 134 |
| snippet | 2 | 221 | 10 (9) | 1 | >250 | >200 |
| modèle | - | 235 | 0 (0) | 157 | >250 | >200 |
| adresse | 2 | 208 | 0 (0) | 1809 | >250 | >200 |
| quick reply | - | 147 | 5 (3) | 0 | >250 | - |
| canned response | - | 29 | 9 (6) | 0 | 25 | - |
| presse-papiers+ | 4 | 182 | 10 (9) | 0 | 179 | 166 |
| presse-papiers copier-coller | 1 | 97 | 9 (9) | 4 | 97 | 93 |
| presse-papiers pastin | 1 | 1 | 1 (1) | 0 | >250 | >200 |
| calculatrice presse-papiers | 1 | 1 | 1 (1) | 0 | >250 | >200 |
| copier coller photo | 1 | 134 | 3 (3) | 4945 | >250 | >200 |
| clavier copier coller | 1 | 64 | 10 (9) | 18 | 59 | 59 |
| copier-coller facile | 1 | 4 | 3 (3) | 0 | >250 | >200 |
| auto copier coller, text spam | 1 | 13 | 9 (9) | 7 | >250 | >200 |

### BR (storefront id 143503)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard | 2 | 248 | 10 (10) | 5 | >250 | >200 |
| clipboard manager | 1 | 248 | 10 (10) | 4 | >250 | >200 |
| clipboard keyboard | 1 | 249 | 10 (9) | 18 | >250 | 73 |
| copy paste | 1 | 249 | 9 (9) | 7 | >250 | >200 |
| text snippets | - | 237 | 9 (9) | 0 | 215 | >200 |
| text expander | 1 | 130 | 9 (8) | 0 | >250 | >200 |
| custom keyboard | - | 246 | 10 (1) | 14 | >250 | >200 |
| canned responses | - | 31 | 10 (7) | 0 | 22 | 23 |
| área de transferência | - | 107 | 10 (9) | 10 | >250 | >200 |
| copiar colar | - | 249 | 8 (8) | 0 | 210 | >200 |
| teclado | 6 | 249 | 10 (1) | 12480 | >250 | >200 |
| frases prontas | 1 | 40 | 0 (0) | 40 | >250 | >200 |
| respostas rápidas | - | 66 | 5 (4) | 0 | 63 | 67 |
| teclado personalizado | 3 | 249 | 9 (1) | 3630 | >250 | >200 |
| mensagens prontas | 1 | 116 | 0 (0) | 30 | >250 | >200 |
| atalhos de texto | - | 93 | 2 (2) | 604225 | 82 | 90 |
| preenchimento automático | - | 8 | 3 (3) | 1 | >250 | >200 |
| snippet | 3 | 250 | 10 (9) | 0 | >250 | >200 |
| modelo | 2 | 247 | 0 (0) | 4635 | >250 | >200 |
| endereço | 1 | 210 | 2 (2) | 0 | 181 | >200 |
| atalho | - | 248 | 1 (1) | 16570 | 226 | >200 |
| notas | 1 | 250 | 3 (3) | 7292 | >250 | >200 |
| salvar | - | 250 | 0 (0) | 277 | >250 | >200 |
| quick reply | - | 162 | 8 (7) | 0 | >250 | - |
| canned response | - | 31 | 10 (7) | 0 | 22 | - |
| área de transferência+ | 3@"área de transferência" | 106 | 10 (8) | 29 | >250 | >200 |
| teclado musical | 1 | 249 | 6 (0) | 2345 | >250 | >200 |
| teclado google | 1 | 250 | 7 (0) | 8136 | >250 | >200 |
| teclado swiftkey | 1 | 249 | 10 (1) | 539 | >250 | >200 |
| teclado microsoft swiftkey | 1 | 10 | 9 (1) | 2 | >250 | >200 |
| teclado bluetooth | 2 | 250 | 10 (0) | 1 | >250 | >200 |
| teclado desenhado | 1 | 248 | 10 (2) | 832 | >250 | >200 |
| teclado com design | 1 | 35 | 9 (1) | 2521 | >250 | >200 |

### KR (storefront id 143466)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard | 1 | 249 | 10 (9) | 42 | >250 | 176 |
| clipboard manager | 4 | 244 | 10 (10) | 1 | >250 | >200 |
| clipboard keyboard | - | 248 | 10 (9) | 21 | >250 | 45 |
| copy paste | - | 244 | 9 (9) | 9 | >250 | >200 |
| text snippets | - | 235 | 8 (8) | 0 | 222 | >200 |
| text expander | - | 128 | 9 (8) | 0 | >250 | >200 |
| custom keyboard | - | 249 | 9 (0) | 152 | >250 | >200 |
| canned responses | - | 30 | 10 (9) | 0 | 24 | 26 |
| 클립보드 | 4 | 249 | 9 (8) | 42 | >250 | >200 |
| 복붙 | 2 | 50 | 10 (10) | 2 | 48 | 47 |
| 상용구 | - | 250 | 0 (0) | 3001 | >250 | >200 |
| 자주쓰는문구 | - | 31 | 9 (7) | 0 | >250 | >200 |
| 키보드 | 2 | 246 | 10 (1) | 1019 | >250 | >200 |
| 복사 붙여넣기 | - | 201 | 10 (10) | 0 | 174 | >200 |
| 스니펫 | - | 71 | 10 (9) | 0 | 56 | 69 |
| 템플릿 | 1 | 245 | 0 (0) | 6752 | >250 | >200 |
| 문구 저장 | - | 33 | 7 (7) | 0 | >250 | >200 |
| 메모 키보드 | - | 170 | 7 (4) | 459 | 139 | 121 |
| 정형문 | - | 6 | 6 (5) | 0 | 6 | 6 |
| 자동입력 | - | 114 | 1 (1) | 2 | 103 | 96 |
| 메모 | 1 | 250 | 1 (1) | 5459 | >250 | >200 |
| 저장 | 6 | 249 | 0 (0) | 7826 | >250 | >200 |
| quick reply | - | 159 | 7 (6) | 0 | >250 | - |
| canned response | - | 30 | 10 (9) | 0 | 24 | - |
| 아이폰 클립보드 | 1 | 249 | 10 (8) | 1 | >250 | >200 |
| 네이버 클립보드 | 1 | 4 | 2 (1) | 1558 | >250 | >200 |
| 클립보드 관리자, quickpaste keyboard | 1 | 1 | 1 (1) | 1 | >250 | >200 |
| 복붙키보드 | 1 | 50 | 10 (9) | 18 | 48 | 45 |
| 복붙이지 | 1 | 1 | 1 (1) | 5 | >250 | >200 |
| clipboardvault smart keyboard | 1 | 1 | 1 (1) | 0 | >250 | >200 |
| clipboard++ | 5 | 247 | 10 (10) | 14 | >250 | >200 |
| clipboard 클립보드 키보드 | 1 | 246 | 10 (10) | 9 | 178 | 58 |

### CN (storefront id 143465)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard | 1 | 243 | 9 (9) | 2 | 88 | >200 |
| clipboard manager | 3 | 246 | 10 (10) | 1 | 118 | 151 |
| clipboard keyboard | - | 239 | 10 (9) | 40 | 63 | 52 |
| copy paste | - | 237 | 9 (9) | 1 | >250 | >200 |
| text snippets | - | 236 | 8 (8) | 7 | 116 | 141 |
| text expander | - | 117 | 7 (7) | 0 | >250 | >200 |
| custom keyboard | - | 231 | 10 (2) | 1 | >250 | >200 |
| canned responses | - | 26 | 10 (10) | 0 | 20 | 21 |
| 剪贴板 | 1 | 245 | 10 (10) | 21 | 232 | >200 |
| 复制粘贴 | 1 | 242 | 10 (10) | 26 | 33 | >200 |
| 输入法 | 3 | 242 | 10 (3) | 35586 | >250 | >200 |
| 常用语 | 1 | 120 | 8 (8) | 1 | >250 | >200 |
| 快捷短语 | 1 | 80 | 8 (6) | 47 | >250 | >200 |
| 键盘 | 7 | 247 | 10 (3) | 53052 | >250 | >200 |
| 文本替换 | 1 | 248 | 2 (2) | 15 | >250 | >200 |
| 模板 | 1 | 246 | 0 (0) | 11417 | >250 | >200 |
| 自动填充 | - | 86 | 6 (4) | 37 | 18 | 59 |
| 备忘录 | 1 | 249 | 2 (1) | 74227 | >250 | >200 |
| 地址 | 3 | 250 | 0 (0) | 26339 | >250 | >200 |
| 常用文字 | - | 34 | 6 (6) | 2 | 25 | 17 |
| keyboard | 1 | 247 | 10 (1) | 173 | >250 | >200 |
| quick reply | - | 133 | 8 (6) | 5 | >250 | - |
| canned response | - | 26 | 10 (10) | 0 | 20 | - |
| 剪贴板输入法 | 1 | 56 | 10 (8) | 18 | 12 | 40 |
| 剪贴板管理 | 1 | 117 | 10 (10) | 6 | 22 | 77 |
| 剪贴板管理器 | 1 | 67 | 10 (10) | 0 | >250 | >200 |
| 剪贴板+ | 2 | 246 | 9 (9) | 29 | 220 | 134 |
| 剪贴板查看器编辑器 | 1 | 5 | 5 (5) | 0 | >250 | >200 |
| 剪贴板清理器 | 1 | 9 | 7 (7) | 0 | >250 | >200 |
| 剪贴板（粘贴板）管理器 | 1 | 198 | 10 (10) | 12 | 99 | 81 |
| braniac 复制粘贴剪贴板 | 1 | 1 | 1 (1) | 0 | >250 | >200 |

### ID (storefront id 143476)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard | 3 | 249 | 10 (9) | 30 | 196 | 156 |
| clipboard manager | 1 | 248 | 10 (10) | 0 | >250 | 192 |
| clipboard keyboard | 1 | 248 | 10 (9) | 1 | 140 | 112 |
| copy paste | 2 | 249 | 9 (9) | 29 | >250 | >200 |
| text snippets | - | 243 | 9 (9) | 0 | 88 | 96 |
| text expander | - | 130 | 8 (8) | 0 | >250 | >200 |
| custom keyboard | - | 249 | 10 (1) | 417 | >250 | >200 |
| canned responses | - | 31 | 10 (9) | 1 | 16 | 13 |
| papan klip | 2 | 75 | 10 (9) | 36 | >250 | >200 |
| salin tempel | - | 80 | 9 (8) | 0 | 39 | 45 |
| keyboard | 4 | 248 | 9 (1) | 5096 | >250 | >200 |
| template chat | - | 136 | 1 (1) | 138991 | >250 | >200 |
| balasan cepat | - | 16 | 8 (7) | 0 | >250 | >200 |
| teks cepat | - | 121 | 5 (4) | 0 | 61 | 66 |
| catatan keyboard | - | 34 | 8 (2) | 1 | 19 | 18 |
| alamat | - | 154 | 1 (1) | 0 | 89 | 86 |
| catatan | 2 | 250 | 2 (2) | 552 | >250 | >200 |
| cepat | 10 | 248 | 0 (0) | 38122 | >250 | >200 |
| quick reply | - | 161 | 8 (6) | 1 | >250 | - |
| canned response | - | 31 | 10 (9) | 1 | 16 | - |
| keyboard papan klip | 1 | 23 | 10 (10) | 0 | >250 | >200 |
| keyboard for iphone | 4 | 248 | 8 (1) | 5096 | >250 | >200 |
| keyboard facemoji | 1 | 144 | 8 (2) | 6842 | >250 | >200 |
| keyboard music | 1 | 250 | 7 (0) | 291 | >250 | >200 |
| keyboard translator | 1 | 250 | 10 (0) | 64 | >250 | >200 |
| keyboard jepang | 1 | 27 | 10 (1) | 1 | >250 | >200 |
| keyboard bluetooth | 1 | 250 | 10 (0) | 1 | >250 | >200 |
| keyboard arab | 7@"keyb" | 109 | 9 (1) | 4 | >250 | >200 |
| copy | - | 184† | 3 (3) | 152 | >200† | >200 |
| paste | 7 | 186† | 9 (9) | 29 | >200† | >200 |
| template | 6 | 185† | 0 (0) | 7442 | >200† | >200 |
| isi otomatis | - | 12† | 6 (6) | 0 | >200† | >200 |

### IN (storefront id 143467)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard | 1 | 249 | 9 (8) | 61 | >250 | >200 |
| clipboard manager | 1 | 249 | 10 (10) | 39 | >250 | >200 |
| clipboard keyboard | 1 | 249 | 10 (9) | 0 | >250 | >200 |
| copy paste | 2 | 249 | 8 (8) | 24 | >250 | >200 |
| paste | 1 | 249 | 9 (9) | 30 | >250 | >200 |
| snippet | 3 | 250 | 10 (10) | 1 | >250 | >200 |
| snippets | - | 248 | 10 (10) | 0 | >250 | >200 |
| text snippets | - | 240 | 9 (8) | 1 | >250 | >200 |
| text expander | - | 129 | 9 (9) | 0 | >250 | >200 |
| text replacement | 1 | 98 | 2 (2) | 4 | >250 | >200 |
| keyboard | 2 | 250 | 10 (1) | 12836 | >250 | >200 |
| custom keyboard | 1 | 248 | 10 (1) | 718 | >250 | >200 |
| quick reply | - | 162 | 8 (7) | 4 | >250 | >200 |
| canned responses | - | 31 | 10 (9) | 1 | 25 | 26 |
| templates | 7 | 247 | 5 (5) | 2548 | >250 | >200 |
| autofill | - | 249 | 8 (8) | 0 | >250 | >200 |
| save text | - | 247 | 0 (0) | 29327 | >250 | >200 |
| phrases | 4 | 250 | 0 (0) | 7 | >250 | >200 |
| notes keyboard | - | 246 | 5 (1) | 21473 | >250 | >200 |
| क्लिपबोर्ड | - | 54 | 10 (8) | 3 | >250 | >200 |
| कॉपी पेस्ट | - | 5 | 3 (3) | 0 | >250 | >200 |
| कीबोर्ड | - | 248 | 7 (0) | 141 | >250 | >200 |
| टेम्पलेट | - | 246 | 1 (1) | 141 | >250 | >200 |
| संदेश टेम्पलेट | - | 0 | 0 (0) | 0 | >250 | >200 |
| টেক্সট | - | 0 | 0 (0) | 0 | >250 | >200 |
| নোট | - | 2 | 2 (0) | 1 | >250 | >200 |
| টেমপ্লেট | - | 0 | 0 (0) | 0 | >250 | >200 |
| copy | - | 249 | 3 (3) | 3 | >250 | >200 |
| clip | - | 248 | 0 (0) | 486 | >250 | >200 |
| quick | 6 | 250 | 0 (0) | 20 | >250 | >200 |
| template | 5 | 249 | 2 (2) | 2274 | >250 | >200 |
| address | - | 250 | 0 (0) | 0 | >250 | >200 |
| ટેક્સ્ટ | - | 0 | 0 (0) | 0 | >250 | >200 |
| નોંધ | - | 1 | 1 (0) | 1 | >250 | >200 |
| ઝડપી | - | 0 | 0 (0) | 0 | >250 | >200 |
| ટેમ્પલેટ | - | 0 | 0 (0) | 0 | >250 | >200 |
| टेक्स्ट | - | 246 | 3 (1) | 857 | >250 | >200 |
| नोट | - | 250 | 0 (0) | 6 | >250 | >200 |
| पता | - | 248 | 0 (0) | 62 | >250 | >200 |
| ಕ್ಲಿಪ್‌ಬೋರ್ಡ್ | - | 0 | 0 (0) | 0 | >250 | >200 |
| ಕೀಬೋರ್ಡ್ | - | 0 | 0 (0) | 0 | >250 | >200 |
| ಟೆಕ್ಸ್ಟ್ | - | 0 | 0 (0) | 0 | >250 | >200 |
| ಟೆಂಪ್ಲೇಟ್ | - | 0 | 0 (0) | 0 | >250 | >200 |
| ടെക്സ്റ്റ് | - | 246 | 2 (1) | 387 | >250 | >200 |
| ടെംപ്ലേറ്റ് | - | 0 | 0 (0) | 0 | >250 | >200 |
| ଟେକ୍ସଟ | - | 0 | 0 (0) | 0 | >250 | >200 |
| ଟେମ୍ପଲେଟ | - | 0 | 0 (0) | 0 | >250 | >200 |
| ਟੈਕਸਟ | - | 1 | 0 (0) | 1 | >250 | >200 |
| ਟੈਂਪਲੇਟ | - | 0 | 0 (0) | 0 | >250 | >200 |
| கிளிப்போர்டு | - | 0 | 0 (0) | 0 | >250 | >200 |
| கீபோர்டு | - | 0 | 0 (0) | 0 | >250 | >200 |
| டெக்ஸ்ட் | - | 246 | 3 (1) | 857 | >250 | >200 |
| டெம்ப்ளேட் | - | 0 | 0 (0) | 0 | >250 | >200 |
| క్లిప్‌బోర్డ్ | - | 0 | 0 (0) | 0 | >250 | >200 |
| కీబోర్డ్ | - | 250 | 10 (1) | 12836 | >250 | >200 |
| టెక్స్ట్ | - | 0 | 0 (0) | 0 | >250 | >200 |
| టెంప్లేట్ | - | 0 | 0 (0) | 0 | >250 | >200 |
| canned response | - | 31 | 10 (9) | 1 | 25 | - |
| clipboard ++ | 5 | 247 | 9 (9) | 24 | >250 | >200 |
| clipboard history | 1 | 249 | 10 (10) | 9 | >250 | >200 |
| keyboard with clipboard | 1 | 10 | 10 (7) | 0 | >250 | >200 |
| clipboardvault smart keyboard | 1 | 1 | 1 (1) | 0 | >250 | >200 |
| ai text expander | 1 | 36 | 6 (6) | 4 | >250 | >200 |
| snippets! | 1 | 244 | 10 (10) | 0 | >250 | >200 |
| clipboard manager keyboard | 1 | 138 | 10 (10) | 10 | 111 | 109 |
| clipboard free | 1 | 249 | 10 (9) | 28 | >250 | >200 |

### ES (storefront id 143454)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard | 2 | 232 | 10 (9) | 12 | >250 | >200 |
| clipboard manager | 1 | 231 | 10 (10) | 4 | 197 | >200 |
| clipboard keyboard | - | 222 | 10 (9) | 4 | 70 | 70 |
| teclado con portapapeles | 1 | 3 | 3 (2) | 1 | >250 | >200 |
| portapapeles teclado pegar | 1 | 51 | 10 (10) | 1 | 38 | 38 |
| teclado de diseño | 1@"teclado" | 107 | 9 (1) | 562 | >250 | >200 |
| teclado diseñado | 2 | 107 | 8 (0) | 2455 | >250 | >200 |
| plantillas | 7 | 185† | 1 (1) | 17306 | >200† | >200 |
| teclado de diseñado | 1 | 65† | 10 (0) | 161 | >200† | >200 |
| snippet | 2 | 170† | 10 (9) | 2 | >200† | >200 |
| teclado personalizado | 1 | 178† | 9 (1) | 2455 | >200† | >200 |
| canned responses | - | 30† | 9 (4) | 0 | 23† | 23 |
| custom keyboard | 1 | 186† | 9 (1) | 1852 | >200† | >200 |
| respuestas rápidas | - | 21† | 6 (2) | 1 | >200† | >200 |
| text snippets | - | 172† | 8 (7) | 0 | >200† | >200 |
| teclado iphone gratis | 1 | 189† | 10 (0) | 2618 | >200† | >200 |
| mensaje | - | 183† | 0 (0) | 42534 | >200† | >200 |
| textos rápidos | - | 186† | 0 (0) | 7645 | >200† | >200 |
| plantilla | - | 180† | 0 (0) | 2245 | >200† | >200 |
| autorrellenar | - | 4† | 0 (0) | 11146 | >200† | >200 |
| autorellenar | - | 2† | 1 (1) | 0 | 2† | 2 |
| adreça | - | 46† | 0 (0) | 0 | 37† | 37 |
| nota | - | 179† | 0 (0) | 556 | >200† | >200 |
| text expander | - | 128† | 8 (6) | 3 | >200† | >200 |
| drecera | - | 28† | 0 (0) | 1 | 24† | 24 |
| teclado diseñado -tema, emoji | 1@"teclado diseñado" | 74† | 9 (0) | 1514 | >200† | >200 |
| text | - | 152† | 3 (0) | 936 | >200† | >200 |
| dirección | - | 159† | 0 (0) | 433 | >200† | >200 |
| copy paste | 1 | 173† | 8 (8) | 95 | >200† | >200 |
| teclados para iphone gratis | 1 | 184† | 9 (1) | 2455 | >200† | >200 |
| teclado | 3 | 169† | 10 (1) | 3081 | >200† | >200 |
| portapapeles | 1 | 167† | 9 (8) | 12 | 65† | 65 |
| copiar pegar | - | 158† | 8 (8) | 6 | 131† | 131 |
| ràpid | - | 168† | 0 (0) | 18 | >200† | >200 |

### IT (storefront id 143450)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| appunti + | 1 | 235 | 5 (5) | 9585 | >250 | >200 |
| appunti gratis | 3 | 134 | 5 (5) | 4953 | >250 | >200 |
| appunti università | 1 | 157 | 7 (7) | 1690 | >250 | >200 |
| appunti scuola | 1 | 140 | 6 (6) | 8157 | >250 | >200 |
| appunti ai | 1 | 247 | 6 (6) | 322 | >250 | >200 |
| appunti calendario | 1 | 232 | 3 (3) | 1702 | >250 | >200 |
| appunti plus | 1 | 84 | 8 (8) | 8157 | >250 | >200 |
| appunti telefono | 1 | 14 | 4 (3) | 10 | >250 | >200 |
| tastiera appunti | - | 47† | 10 (10) | 1 | 14† | 14 |
| rapido | 1 | 184† | 0 (0) | 6684 | >200† | >200 |
| copy paste | 1 | 171† | 8 (8) | 42 | >200† | >200 |
| tastiera | 8 | 182† | 10 (0) | 3202 | >200† | >200 |
| clipboard | 1 | 181† | 10 (9) | 33 | 160† | 160 |
| risposte rapide | - | 27† | 4 (4) | 4 | 21† | 21 |
| nota | 3 | 173† | 4 (4) | 351 | >200† | >200 |
| text expander | - | 158† | 5 (5) | 63 | >200† | >200 |
| clipboard manager | 1 | 185† | 10 (10) | 5 | 177† | 177 |
| text snippets | - | 175† | 9 (9) | 0 | 112† | 112 |
| modello | - | 174† | 0 (0) | 4 | >200† | >200 |
| testo | 2 | 177† | 4 (1) | 2643 | >200† | >200 |
| clipboard keyboard | - | 178† | 10 (9) | 8 | 61† | 61 |
| modelli | - | 180† | 1 (1) | 244 | >200† | >200 |
| canned responses | - | 30† | 9 (7) | 0 | 12† | 12 |
| riempimento automatico | - | 5† | 0 (0) | 0 | >200† | >200 |
| appunti | 2 | 191† | 6 (6) | 9514 | >200† | >200 |
| custom keyboard | 1 | 186† | 10 (1) | 929 | >200† | >200 |
| copia incolla | 2 | 115† | 10 (10) | 13 | 75† | 75 |
| testi rapidi | - | 154† | 1 (1) | 8 | 133† | 133 |
| indirizzo | - | 135† | 2 (2) | 0 | >200† | >200 |

### NL (storefront id 143452)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| klembordviewer-editor | 1 | 1 | 1 (1) | 0 | >250 | >200 |
| klembord+ | 3 | 75 | 10 (10) | 0 | 31 | 31 |
| cliphub klembord | 1 | 2 | 2 (2) | 1 | >250 | >200 |
| *wachtwoorde* kopiëren plakken | 1 | 3 | 2 (2) | 1 | >250 | >200 |
| toetsenbord voor iphone | 1 | 237 | 10 (0) | 1626 | >250 | >200 |
| toetsenbord gratis | 1 | 116 | 10 (0) | 1500 | >250 | >200 |
| toetsenbord thema | 1 | 234 | 10 (1) | 534 | >250 | >200 |
| toetsenbord achtergrond | 1 | 228 | 9 (1) | 101 | >250 | >200 |
| toetsenbord | 7 | 176† | 10 (1) | 2628 | >200† | >200 |
| copy paste | 1 | 157† | 8 (8) | 67 | >200† | >200 |
| sjablonen | - | 163† | 0 (0) | 0 | >200† | >200 |
| sjabloon | - | 185† | 1 (1) | 0 | >200† | >200 |
| klembord | 1 | 73† | 10 (10) | 1 | 24† | 24 |
| kopiëren plakken | - | 47† | 10 (10) | 0 | 26† | 26 |
| text expander | - | 125† | 8 (8) | 1 | >200† | >200 |
| clipboard manager | 1 | 172† | 10 (10) | 2 | >200† | >200 |
| clipboard | 1 | 183† | 10 (9) | 7 | >200† | >200 |
| clipboard keyboard | - | 173† | 10 (8) | 13 | >200† | >200 |
| canned responses | - | 30† | 9 (8) | 0 | 17† | 17 |
| standaard antwoorden | - | 0† | 0 (0) | 0 | >200† | >200 |
| custom keyboard | 1 | 186† | 10 (2) | 4595 | >200† | >200 |
| text snippets | - | 164† | 8 (8) | 0 | 135† | 135 |
| tekstvervanging | - | 2† | 2 (1) | 0 | >200† | >200 |
| notitie | - | 188† | 0 (0) | 335 | >200† | >200 |
| adres | - | 122† | 0 (0) | 13 | >200† | >200 |
| snippet | 2 | 166† | 10 (9) | 2 | >200† | >200 |
| tekst | 8 | 191† | 6 (3) | 2116 | >200† | >200 |
| snel | - | 189† | 0 (0) | 6455 | >200† | >200 |
| sneltekst | - | 1† | 0 (0) | 0 | >200† | >200 |

### RU (storefront id 143469)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| буфер обмена на айфон | 1 | 94 | 10 (10) | 41 | >250 | >200 |
| буфер обмена+ | 6 | 96 | 10 (10) | 0 | >250 | >200 |
| буфер обмена клавиатура | 1 | 40 | 10 (10) | 1 | >250 | >200 |
| копировать вставить клавиатуру | 1 | 30 | 10 (10) | 7 | >250 | >200 |
| *пароли* копировать &amp; вставить | 3@"копировать вставить" | 1 | 1 (1) | 3 | >250 | >200 |
| клавиатура на айфон | 2 | 250 | 9 (2) | 6860 | >250 | >200 |
| клавиатура яндекса | 1 | 24 | 6 (0) | 6860 | >250 | >200 |
| клавиатура на айфон бесплатно | 1 | 249 | 9 (2) | 2424 | >250 | >200 |
| шаблоны | 7 | 168† | 7 (7) | 3640 | >200† | >200 |
| text expander | 1 | 129† | 10 (10) | 1 | >200† | >200 |
| clipboard manager | 4 | 183† | 10 (10) | 2 | >200† | >200 |
| clipboard | 1 | 186† | 10 (9) | 12 | >200† | >200 |
| быстрые ответы | - | 27† | 6 (3) | 0 | >200† | >200 |
| буфер обмена | 2 | 97† | 10 (10) | 71 | >200† | >200 |
| клавиатура | 3 | 176† | 10 (1) | 4852 | >200† | >200 |
| copy paste | - | 169† | 8 (8) | 91 | >200† | >200 |
| адрес | - | 151† | 0 (0) | 8 | >200† | >200 |
| сохранить | - | 159† | 1 (1) | 71 | >200† | >200 |
| заметка | 1 | 195† | 1 (1) | 5903 | >200† | >200 |
| копировать вставить | - | 60† | 10 (10) | 4 | >200† | >200 |
| сообщение | 1 | 145† | 0 (0) | 11342 | >200† | >200 |
| шаблон | 1 | 164† | 8 (8) | 1069 | >200† | >200 |
| автозаполнение | - | 27† | 2 (1) | 11 | >200† | >200 |
| быстро | - | 161† | 0 (0) | 2583 | >200† | >200 |
| clipboard keyboard | - | 186† | 10 (9) | 13 | 76† | 76 |
| canned responses | - | 32† | 10 (9) | 2 | 25† | 25 |
| custom keyboard | - | 186† | 10 (1) | 4655 | >200† | >200 |
| заметки клавиатура | - | 43† | 8 (2) | 1 | 39† | 39 |
| text snippets | - | 175† | 9 (9) | 0 | >200† | >200 |

### MX (storefront id 143468)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| portapapeles teclado | 1 | 68 | 10 (9) | 2 | 11 | 32 |
| teclado con portapapeles | 1 | 9 | 6 (5) | 3 | >250 | >200 |
| portapapeles teclado pegar | 1 | 72 | 10 (10) | 1 | 24 | 44 |
| calculadora portapapeles | 1 | 2 | 1 (1) | 0 | >250 | >200 |
| teclado diseñado | 4 | 119 | 10 (1) | 7224 | >250 | >200 |
| teclados para iphone gratis | 1 | 250 | 8 (1) | 3883 | >250 | >200 |
| teclado google | 1 | 248 | 7 (0) | 1310 | 241 | >200 |
| teclado musical | 2 | 246 | 5 (0) | 713 | >250 | >200 |
| custom keyboard | - | 189† | 10 (0) | 2684 | >200† | >200 |
| clipboard keyboard | 1 | 184† | 10 (8) | 34 | 79† | 79 |
| teclado personalizado | 1 | 174† | 9 (0) | 3464 | >200† | >200 |
| canned responses | - | 31† | 10 (5) | 1 | 17† | 17 |
| textos rápidos | - | 188† | 1 (1) | 2275 | >200† | >200 |
| mensaje | - | 180† | 0 (0) | 53473 | >200† | >200 |
| autorellenar | - | 2† | 1 (1) | 0 | 2† | 2 |
| plantilla | - | 176† | 1 (1) | 3733 | >200† | >200 |
| autorrellenar | - | 6† | 0 (0) | 6 | >200† | >200 |
| text snippets | - | 179† | 7 (7) | 0 | 111† | 111 |
| respuestas rápidas | - | 22† | 4 (1) | 5 | >200† | >200 |
| plantillas | 6 | 185† | 1 (1) | 18781 | >200† | >200 |
| snippet | 3 | 167† | 10 (9) | 1 | >200† | >200 |
| copy paste | 1 | 183† | 9 (9) | 80 | >200† | >200 |
| dirección | - | 163† | 0 (0) | 1 | >200† | >200 |
| copiar pegar | - | 168† | 8 (8) | 22 | 101† | 101 |
| portapapeles | 2 | 180† | 9 (8) | 37 | 60† | 60 |
| teclado | 5 | 176† | 9 (0) | 16848 | >200† | >200 |
| text expander | - | 134† | 8 (7) | 2 | >200† | >200 |
| clipboard manager | 1 | 172† | 10 (10) | 6 | 168† | 168 |
| nota | - | 183† | 0 (0) | 8002 | >200† | >200 |
| clipboard | 3 | 192† | 10 (9) | 50 | >200† | >200 |

### CA (storefront id 143455)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| copy paste keyboard clipboard | 1 | 250 | 10 (10) | 68 | >250 | >200 |
| clipboard history+ | 1 | 250 | 10 (10) | 0 | >250 | >200 |
| clipboardvault smart keyboard | 1 | 1 | 1 (1) | 0 | >250 | >200 |
| clipboard health | 1 | 250 | 7 (7) | 3 | >250 | >200 |
| basketball clipboard | 1 | 249 | 3 (3) | 3 | >250 | >200 |
| ai text expander | 1 | 247 | 3 (3) | 30 | >250 | >200 |
| snippets studio | 1 | 249 | 5 (3) | 4 | >250 | >200 |
| snippets! | 1 | 239 | 10 (10) | 1 | >250 | >200 |
| extrait | - | 159† | 2 (2) | 156 | 116† | 116 |
| clipboard | 1 | 185† | 10 (10) | 34 | >200† | >200 |
| autofill | 1 | 165† | 7 (7) | 5 | >200† | >200 |
| text expander | - | 172† | 10 (10) | 0 | >200† | >200 |
| clipboard manager | 1 | 186† | 10 (10) | 25 | >200† | >200 |
| copier | - | 174† | 3 (3) | 32 | >200† | >200 |
| paste | 2 | 178† | 10 (10) | 109 | >200† | >200 |
| template | - | 191† | 0 (0) | 14840 | >200† | >200 |
| copy | - | 187† | 4 (4) | 193 | >200† | >200 |
| address | - | 146† | 0 (0) | 16 | >200† | >200 |
| snippets | - | 165† | 10 (10) | 1 | >200† | >200 |
| quick reply | - | 173† | 9 (5) | 0 | >200† | >200 |
| quick | - | 185† | 0 (0) | 1910 | >200† | >200 |
| copy paste | 2 | 175† | 10 (10) | 293 | >200† | >200 |
| keyboard | 4 | 191† | 10 (1) | 11639 | >200† | >200 |
| text replacement | - | 182† | 4 (4) | 2 | >200† | >200 |
| snippet | 3 | 170† | 10 (10) | 2 | >200† | >200 |
| adresse | - | 176† | 0 (0) | 414 | >200† | >200 |
| templates | 4 | 184† | 0 (0) | 2573 | >200† | >200 |
| coller | - | 189† | 1 (1) | 14648 | >200† | >200 |
| modèle | - | 196† | 0 (0) | 360 | >200† | >200 |
| text snippets | - | 172† | 8 (8) | 0 | >200† | >200 |
| phrases | - | 179† | 0 (0) | 16 | >200† | >200 |
| notes keyboard | - | 187† | 10 (2) | 41 | >200† | >200 |
| clipboard keyboard | - | 193† | 10 (9) | 45 | 98† | 98 |
| clip | - | 171† | 0 (0) | 11513 | >200† | >200 |
| presse-papiers | - | 175† | 10 (10) | 1 | >200† | >200 |
| canned responses | - | 50† | 10 (7) | 2 | 45† | 45 |
| clavier | 2 | 175† | 10 (0) | 11639 | >200† | >200 |
| save text | - | 179† | 0 (0) | 54 | >200† | >200 |
| custom keyboard | 2 | 190† | 10 (1) | 1693 | >200† | >200 |
| réponses rapides | - | 58† | 7 (6) | 1 | >200† | >200 |
| copier coller | - | 162† | 10 (10) | 9 | >200† | >200 |

### AU (storefront id 143460)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard school | 1 | 249 | 10 (10) | 0 | >250 | >200 |
| copy paste clipboard keyboard | 1 | 250 | 10 (10) | 17 | >250 | >200 |
| clipboard compass | 1 | 250 | 3 (3) | 12 | >250 | >200 |
| clipboard extracurricular | 1 | 250 | 1 (1) | 0 | >250 | >200 |
| clipboardvault smart keyboard | 1 | 1 | 1 (1) | 0 | >250 | >200 |
| ai text expander | 1 | 245 | 4 (4) | 36 | >250 | >200 |
| snippets studio | 1 | 248 | 2 (1) | 4 | >250 | >200 |
| snippets! | 1 | 238 | 10 (10) | 2 | >250 | >200 |
| text shortcuts | - | 172† | 6 (4) | 3 | >200† | >200 |
| clipboard | 1 | 174† | 10 (10) | 11 | >200† | >200 |
| autofill | 1 | 163† | 6 (6) | 6 | >200† | >200 |
| text expander | - | 165† | 10 (10) | 1 | >200† | >200 |
| clipboard manager | 1 | 183† | 10 (10) | 5 | >200† | >200 |
| paste | 1 | 182† | 10 (10) | 104 | >200† | >200 |
| template | 6 | 191† | 0 (0) | 9084 | >200† | >200 |
| quick reply | - | 173† | 8 (4) | 1 | >200† | >200 |
| snippets | - | 167† | 10 (10) | 1 | >200† | >200 |
| address | - | 142† | 0 (0) | 0 | >200† | >200 |
| copy | - | 187† | 6 (6) | 74 | >200† | >200 |
| quick | 9 | 186† | 0 (0) | 565 | >200† | >200 |
| copy paste | 1 | 172† | 8 (8) | 406 | >200† | >200 |
| text replacement | - | 177† | 5 (5) | 2 | >200† | >200 |
| keyboard | 2 | 187† | 10 (1) | 5570 | >200† | >200 |
| snippet | 3 | 167† | 10 (10) | 1 | >200† | >200 |
| autotext | - | 192† | 8 (7) | 84 | >200† | >200 |
| templates | 1 | 183† | 1 (1) | 6228 | >200† | >200 |
| text snippets | - | 172† | 9 (9) | 0 | >200† | >200 |
| phrases | - | 180† | 0 (0) | 31 | >200† | >200 |
| clipboard keyboard | - | 193† | 10 (9) | 18 | 60† | 60 |
| clip | - | 170† | 0 (0) | 10277 | >200† | >200 |
| notes keyboard | - | 187† | 10 (1) | 37 | >200† | >200 |
| canned responses | - | 52† | 9 (5) | 1 | 46† | 46 |
| custom keyboard | 1 | 189† | 10 (1) | 5142 | >200† | >200 |
| save text | - | 175† | 0 (0) | 3 | >200† | >200 |

### TR (storefront id 143480)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| pano tuner | 1 | 250 | 2 (2) | 76 | >250 | >200 |
| panocut | 1 | 10 | 7 (7) | 0 | >250 | >200 |
| panorama crop | 1 | 119 | 6 (6) | 6 | >250 | >200 |
| panorasplit | 1 | 1 | 1 (1) | 66 | >250 | >200 |
| panorama crop for insta | 1 | 26 | 9 (9) | 29 | >250 | >200 |
| panoslice | 1 | 4 | 2 (2) | 3 | >250 | >200 |
| panorama | 5 | 250 | 6 (6) | 6 | >250 | >200 |
| panorama 360 | 1 | 250 | 6 (6) | 4 | >250 | >200 |
| custom keyboard | - | 188† | 10 (1) | 739 | >200† | >200 |
| şablonlar | - | 112† | 0 (0) | 45 | >200† | >200 |
| şablon | 4 | 193† | 1 (1) | 1938 | >200† | >200 |
| not | 5 | 176† | 1 (1) | 4465 | >200† | >200 |
| canned responses | - | 31† | 9 (8) | 0 | 23† | 23 |
| clipboard keyboard | - | 186† | 10 (9) | 15 | 75† | 75 |
| banka | 2 | 187† | 0 (0) | 448920 | >200† | >200 |
| text snippets | - | 183† | 9 (9) | 0 | >200† | >200 |
| adres | 3 | 167† | 0 (0) | 12 | >200† | >200 |
| hızlı | - | 196† | 0 (0) | 2556 | >200† | >200 |
| hazır mesaj | - | 177† | 0 (0) | 7 | >200† | >200 |
| pano | 6 | 177† | 7 (5) | 718 | >200† | >200 |
| klavye | 1 | 175† | 9 (0) | 3327 | >200† | >200 |
| snippet | 3 | 174† | 10 (10) | 1 | >200† | >200 |
| metin kısayolu | - | 30† | 8 (8) | 1 | >200† | >200 |
| copy paste | 1 | 182† | 8 (8) | 160 | >200† | >200 |
| kopyala yapıştır | 1 | 116† | 9 (9) | 20 | 114† | 114 |
| hızlı yanıt | - | 23† | 9 (8) | 0 | 18† | 18 |
| clipboard manager | 1 | 190† | 10 (10) | 6 | >200† | >200 |
| text expander | - | 129† | 10 (10) | 0 | >200† | >200 |
| otomatik doldur | - | 5† | 2 (2) | 0 | >200† | >200 |
| clipboard | 1 | 192† | 10 (9) | 17 | >200† | >200 |

### PL (storefront id 143478)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| schowek24 | 1 | 1 | 1 (1) | 4 | >250 | >200 |
| klawiatura iphone | 1 | 173† | 9 (0) | 2398 | >200† | >200 |
| snippet | 3 | 162† | 10 (10) | 1 | >200† | >200 |
| schowek | 1 | 101† | 10 (8) | 7 | 20† | 20 |
| klawiatura za darmo | 1 | 34† | 10 (0) | 557 | >200† | >200 |
| skróty tekstowe | - | 3† | 3 (3) | 0 | >200† | >200 |
| adres | - | 151† | 0 (0) | 3 | 97† | 97 |
| szablon | - | 189† | 0 (0) | 1 | >200† | >200 |
| klawiatura google | 1 | 175† | 3 (0) | 14008 | >200† | >200 |
| klawiatura gboard | 1 | 55† | 5 (1) | 2408 | >200† | >200 |
| text snippets | - | 166† | 9 (9) | 0 | 152† | 152 |
| zapisz | - | 180† | 0 (0) | 4 | >200† | >200 |
| notatka | 1 | 194† | 1 (1) | 966 | >200† | >200 |
| custom keyboard | 1 | 188† | 10 (1) | 2161 | >200† | >200 |
| szablony | 2 | 169† | 1 (1) | 1155 | >200† | >200 |
| clipboard keyboard | - | 173† | 10 (9) | 2 | 54† | 54 |
| klawiatura bluetooth | 1 | 9† | 7 (0) | 0 | >200† | >200 |
| canned responses | - | 30† | 10 (9) | 0 | 22† | 22 |
| clipboard | 2 | 186† | 10 (9) | 5 | >200† | >200 |
| kopiuj wklej | - | 48† | 10 (10) | 1 | 35† | 35 |
| text expander | - | 172† | 5 (5) | 29 | >200† | >200 |
| clipboard manager | 1 | 183† | 10 (10) | 2 | 135† | 135 |
| szybkie odpowiedzi | - | 12† | 4 (3) | 0 | >200† | >200 |
| szybko | - | 184† | 0 (0) | 2 | >200† | >200 |
| sprytny schowek self storage | 1 | 1† | 1 (1) | 0 | >200† | >200 |
| copy paste | 1 | 166† | 8 (8) | 27 | >200† | >200 |
| klawiatura tlumacz | 1 | 61† | 9 (1) | 2 | >200† | >200 |
| klawiatura | 4 | 177† | 10 (0) | 2282 | >200† | >200 |
| autouzupełnianie | - | 10† | 3 (3) | 0 | >200† | >200 |

### TH (storefront id 143475)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| ที่อยู่ | 1 | 162† | 0 (0) | 78 | >200† | >200 |
| คีย์บอร์ดดนตรี | 1 | 182† | 9 (0) | 2887 | >200† | >200 |
| คีย์บอร์ดแปลภาษา | 1 | 82† | 7 (0) | 18 | >200† | >200 |
| คลิปบอร์ด | 1 | 95† | 10 (9) | 109 | 49† | 49 |
| คัดลอกวาง | 1 | 75† | 9 (8) | 1 | 75† | 75 |
| text snippets | - | 180† | 9 (9) | 0 | >200† | >200 |
| บันทึกข้อความ | 1 | 191† | 1 (1) | 1495 | >200† | >200 |
| คีย์บอร์ดไฟฟ้า | 1 | 181† | 10 (0) | 1911 | >200† | >200 |
| custom keyboard | - | 186† | 10 (2) | 1832 | >200† | >200 |
| canned responses | - | 31† | 10 (8) | 0 | 25† | 25 |
| เร็ว | - | 191† | 0 (0) | 4 | >200† | >200 |
| clipboard keyboard | 1 | 189† | 10 (9) | 95 | 107† | 107 |
| คีย์บอร์ด | 6 | 183† | 10 (2) | 2610 | >200† | >200 |
| clipboard | 2 | 189† | 10 (9) | 46 | >200† | >200 |
| ตอบกลับด่วน | - | 7† | 7 (5) | 0 | >200† | >200 |
| clipboard manager | 2 | 179† | 10 (10) | 12 | >200† | >200 |
| text expander | - | 130† | 10 (9) | 1 | >200† | >200 |
| คีย์บอร์ดแม่นแม่น | 1 | 25† | 2 (0) | 748431 | >200† | >200 |
| คีย์บอร์ดแป้นพิมพ์ | 1 | 145† | 10 (1) | 1683 | >200† | >200 |
| บันทึก | - | 188† | 1 (1) | 1871 | >200† | >200 |
| คีย์บอร์ดไอโฟน | 1 | 195† | 10 (2) | 5179 | >200† | >200 |
| ข้อความสำเร็จรูป | - | 14† | 10 (8) | 0 | >200† | >200 |
| อัตโนมัติ | 1 | 184† | 0 (0) | 28 | >200† | >200 |
| copy paste | 1 | 180† | 8 (8) | 112 | >200† | >200 |
| คีย์บอร์ด เปียโน | 1 | 174† | 8 (0) | 1472 | >200† | >200 |
| google คีย์บอร์ด | 1 | 183† | 4 (0) | 177591 | >200† | >200 |
| ข้อความ | 1 | 180† | 0 (0) | 149468 | >200† | >200 |
| แม่แบบ | 1 | 166† | 0 (0) | 1807702 | >200† | >200 |

### VN (storefront id 143471)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| địa chỉ | 1 | 163† | 1 (1) | 2149 | >200† | >200 |
| sao chép dữ liệu honor | 1 | 3† | 0 (0) | 342223 | >200† | >200 |
| paste | 5 | 188† | 8 (8) | 10 | >200† | >200 |
| sao chép văn bản | 1 | 127† | 1 (1) | 43 | 121† | 121 |
| copy | 10 | 188† | 2 (2) | 91 | >200† | >200 |
| sao chép dữ liệu | 2 | 153† | 0 (0) | 81 | >200† | >200 |
| sao chép danh bạ sang sim | 1 | 12† | 0 (0) | 46 | >200† | >200 |
| copy paste | 1 | 183† | 8 (8) | 75 | >200† | >200 |
| ghi chú | 1 | 172† | 2 (1) | 2526 | >200† | >200 |
| trả lời nhanh | - | 83† | 3 (3) | 1791 | >200† | >200 |
| bàn phím | 5 | 179† | 8 (1) | 5426 | >200† | >200 |
| ngân hàng | 2 | 180† | 0 (0) | 62025 | >200† | >200 |
| clipboard | 2 | 190† | 10 (9) | 14 | >200† | >200 |
| text expander | - | 130† | 10 (10) | 1 | >200† | >200 |
| clipboard manager | 1 | 185† | 10 (10) | 3 | >200† | >200 |
| mẫu văn bản | - | 171† | 3 (2) | 3381 | >200† | >200 |
| tự động điền | - | 175† | 0 (0) | 850 | >200† | >200 |
| text snippets | - | 181† | 9 (9) | 0 | >200† | >200 |
| sao chép dữ liệu của tôi | 1 | 11† | 1 (1) | 39 | >200† | >200 |
| sao chép điện thoại oppo | 1 | 183† | 0 (0) | 52 | >200† | >200 |
| clipboard keyboard | - | 190† | 10 (9) | 35 | 73† | 73 |
| bộ nhớ tạm | - | 43† | 6 (6) | 0 | >200† | >200 |
| sao chép | 10 | 176† | 1 (1) | 27 | >200† | >200 |
| canned responses | - | 31† | 10 (7) | 1 | 24† | 24 |
| sao chép danh bạ | 1 | 174† | 0 (0) | 178 | >200† | >200 |
| custom keyboard | 1 | 184† | 9 (2) | 2084 | >200† | >200 |
| snippet | 5 | 176† | 10 (10) | 0 | >200† | >200 |
| dán văn bản | - | 169† | 1 (1) | 2623 | >200† | >200 |
| tin nhắn mẫu | - | 94† | 3 (1) | 589 | 86† | 86 |
| sao chép điện thoại | 1 | 34† | 0 (0) | 95 | >200† | >200 |

### TW (storefront id 143470)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| 自動填寫 | - | 26† | 2 (2) | 2 | 15† | 15 |
| custom keyboard | - | 186† | 10 (1) | 438 | >200† | >200 |
| clipboard keyboard | - | 187† | 9 (8) | 50 | 56† | 56 |
| canned responses | - | 30† | 10 (9) | 2 | 19† | 19 |
| 文字取代 | - | 8† | 5 (4) | 0 | >200† | >200 |
| clipstack 剪貼簿 複製貼上 常用語 | 1 | 1† | 1 (1) | 0 | >200† | >200 |
| 複製貼上 | 1 | 142† | 10 (10) | 22 | 103† | 103 |
| text snippets | - | 179† | 9 (9) | 9 | 122† | 122 |
| 範本 | - | 183† | 1 (1) | 107 | >200† | >200 |
| 剪貼簿 | 1 | 179† | 9 (8) | 31 | >200† | >200 |
| 常用語 | - | 176† | 10 (10) | 1 | >200† | >200 |
| 剪貼簿：鍵盤快速鍵 | 1 | 60† | 9 (9) | 22 | 46† | 46 |
| 剪貼簿清理器 | 1 | 3† | 3 (3) | 0 | >200† | >200 |
| clipboardvault smart keyboard | 1 | 1† | 1 (1) | 0 | >200† | >200 |
| cannedtext 複製貼上・常用句・剪貼簿鍵盤 | 1 | 1† | 1 (1) | 40 | >200† | >200 |
| 輸入法 | 1 | 166† | 10 (3) | 119 | >200† | >200 |
| copy paste | 1 | 173† | 8 (8) | 6 | >200† | >200 |
| cp複製-複製貼上剪貼簿 | 1 | 84† | 10 (10) | 19 | 59† | 59 |
| keyboard | 1 | 186† | 10 (3) | 1223 | >200† | >200 |
| 鍵盤 | 8 | 179† | 9 (1) | 2546 | >200† | >200 |
| 常用文字 | - | 69† | 9 (9) | 34 | 23† | 23 |
| 地址 | - | 173† | 0 (0) | 2596 | >200† | >200 |
| clipboard 剪貼簿 鍵盤 | 1 | 25† | 9 (9) | 31 | 18† | 18 |
| text expander | - | 129† | 10 (10) | 18 | >200† | >200 |
| clipboard manager | 1 | 183† | 9 (9) | 35 | >200† | >200 |
| clipboard | 2 | 191† | 9 (9) | 1 | 169† | 169 |
| 快捷短語 | - | 46† | 8 (6) | 8 | >200† | >200 |
| 剪貼簿相框 | 1 | 15† | 4 (4) | 0 | >200† | >200 |

### SA (storefront id 143479)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| لوحة مفاتيح العربية | 1 | 83† | 10 (0) | 960 | >200† | >200 |
| قالب | 3 | 178† | 0 (0) | 81755 | >200† | >200 |
| لوحة مفاتيح عربي | 3 | 182† | 9 (0) | 3226 | >200† | >200 |
| ردود سريعة | - | 47† | 5 (4) | 0 | >200† | >200 |
| نص | 7 | 183† | 1 (0) | 19735 | >200† | >200 |
| عنوان | 6 | 176† | 0 (0) | 1495 | >200† | >200 |
| لوحة مفاتيح مزخرفه | 1 | 183† | 8 (2) | 1006 | >200† | >200 |
| نسخ ولصق | 1 | 191† | 10 (10) | 12 | >200† | >200 |
| text snippets | - | 181† | 9 (9) | 0 | >200† | >200 |
| قصاصة | - | 37† | 3 (3) | 19 | 31† | 31 |
| custom keyboard | 1 | 187† | 9 (0) | 6882 | >200† | >200 |
| لوحة مفاتيح العربيه | 1 | 83† | 10 (0) | 67 | >200† | >200 |
| canned responses | - | 32† | 10 (9) | 1 | 26† | 26 |
| لوحة مفاتيح قوقل | 1 | 73† | 8 (1) | 5354 | >200† | >200 |
| قوالب | 6 | 187† | 1 (1) | 39340 | >200† | >200 |
| clipboard keyboard | - | 193† | 10 (9) | 79 | 85† | 85 |
| clipboard | 1 | 188† | 10 (9) | 50 | >200† | >200 |
| نموذج | 2 | 182† | 0 (0) | 317 | >200† | >200 |
| سريع | 3 | 177† | 0 (0) | 834 | >200† | >200 |
| clipboard manager | 1 | 198† | 10 (10) | 9 | >200† | >200 |
| text expander | - | 130† | 10 (10) | 0 | >200† | >200 |
| لوحة مفاتيح ترجمة | 1 | 68† | 10 (3) | 43 | >200† | >200 |
| لوحة مفاتيح ايفون | 1 | 186† | 9 (0) | 4701 | >200† | >200 |
| لوحة مفاتيح جوجل | 1 | 68† | 4 (0) | 23899 | >200† | >200 |
| نصوص جاهزة | - | 14† | 7 (6) | 0 | >200† | >200 |
| لوحة مفاتيح | 6 | 177† | 9 (0) | 4388 | >200† | >200 |
| copy paste | 1 | 181† | 8 (8) | 255 | >200† | >200 |
| الحافظة | 1 | 184† | 5 (5) | 84 | 95† | 95 |
| الملء التلقائي | - | 6† | 1 (1) | 14 | >200† | >200 |

### SE (storefront id 143456)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| pastin urklippshanterare | 1 | 1† | 1 (1) | 0 | >200† | >200 |
| text snippets | - | 172† | 8 (8) | 0 | >200† | >200 |
| tangentbord | 1 | 178† | 9 (0) | 3933 | >200† | >200 |
| clipboard keyboard | - | 180† | 10 (8) | 12 | 65† | 65 |
| canned responses | - | 30† | 9 (7) | 0 | 22† | 22 |
| custom keyboard | 1 | 183† | 10 (1) | 2321 | >200† | >200 |
| urklipp | - | 78† | 9 (9) | 0 | 18† | 18 |
| urklipp hanterare historik | 1 | 5† | 5 (5) | 0 | >200† | >200 |
| adress | - | 153† | 0 (0) | 14 | >200† | >200 |
| snippet | 2 | 164† | 10 (9) | 0 | >200† | >200 |
| clipboardvault smart keyboard | 1 | 1† | 1 (1) | 0 | >200† | >200 |
| textgenvägar | - | 3† | 3 (3) | 0 | >200† | >200 |
| anteckningar tangentbord | - | 21† | 9 (3) | 0 | 12† | 12 |
| typsnitt &amp; tangentbord-app | 4@"tangentbord" | 44† | 10 (0) | 326 | >200† | >200 |
| snabb | 5 | 178† | 0 (0) | 13248 | >200† | >200 |
| urklippshanterare och historik | 1 | 4† | 4 (4) | 0 | >200† | >200 |
| genväg | - | 166† | 0 (0) | 1217 | >200† | >200 |
| tangentbord gratis | 1 | 75† | 9 (0) | 4339 | >200† | >200 |
| kopiera klistra in | - | 31† | 10 (10) | 0 | >200† | >200 |
| copy paste | 1 | 164† | 8 (8) | 171 | >200† | >200 |
| typsnitt skrivstil tangentbord | 1 | 47† | 10 (0) | 326 | >200† | >200 |
| snabbsvar | - | 5† | 5 (5) | 0 | >200† | >200 |
| tangentbord för symboler | 1 | 68† | 9 (0) | 641 | >200† | >200 |
| mall | 9 | 176† | 0 (0) | 76 | >200† | >200 |
| clipboard | 1 | 187† | 10 (9) | 9 | >200† | >200 |
| autofyll | - | 11† | 1 (1) | 0 | 9† | 9 |
| mallar | 1 | 180† | 0 (0) | 11 | >200† | >200 |
| clipboard manager | 4 | 180† | 10 (10) | 0 | >200† | >200 |
| text expander | - | 126† | 9 (9) | 0 | >200† | >200 |

### UA (storefront id 143492)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard keyboard | - | 190† | 10 (9) | 12 | 72† | 72 |
| canned responses | - | 32† | 10 (9) | 0 | 24† | 24 |
| швидко | 4 | 193† | 0 (0) | 2790 | >200† | >200 |
| custom keyboard | - | 193† | 10 (1) | 557 | >200† | >200 |
| google клавіатура | 1 | 63† | 3 (0) | 74914 | >200† | >200 |
| text snippets | - | 181† | 9 (9) | 0 | >200† | >200 |
| клавіатура перекладач | 1 | 51† | 7 (1) | 3 | >200† | >200 |
| повідомлення | 1 | 173† | 0 (0) | 41729 | >200† | >200 |
| адреса | - | 163† | 0 (0) | 0 | >200† | >200 |
| зберегти | - | 174† | 0 (0) | 0 | >200† | >200 |
| клавіатура фортепіано | 1 | 92† | 6 (0) | 27 | >200† | >200 |
| клавіатура | 2 | 169† | 10 (1) | 1345 | >200† | >200 |
| шаблон | 4 | 167† | 1 (1) | 986 | >200† | >200 |
| автозаповнення | - | 6† | 3 (3) | 0 | >200† | >200 |
| шрифт клавіатура | 1 | 59† | 9 (0) | 236 | >200† | >200 |
| нотатка | 1 | 197† | 1 (1) | 609 | >200† | >200 |
| буфер обміну | 1 | 41† | 10 (10) | 0 | >200† | >200 |
| клавіатура на айфон | 1 | 54† | 10 (2) | 841 | >200† | >200 |
| copy paste | 1 | 175† | 8 (8) | 19 | >200† | >200 |
| нотатки | 1 | 181† | 1 (1) | 387 | >200† | >200 |
| клавіатура піаніно | 1 | 24† | 8 (0) | 117 | >200† | >200 |
| гугл клавіатура | 1 | 79† | 5 (0) | 2822 | >200† | >200 |
| копіювати вставити | - | 32† | 8 (8) | 0 | 25† | 25 |
| швидкі відповіді | - | 10† | 7 (6) | 0 | >200† | >200 |
| clipboard manager | 7 | 183† | 10 (10) | 3 | >200† | >200 |
| text expander | - | 132† | 9 (9) | 0 | >200† | >200 |
| шаблони | 6 | 184† | 1 (1) | 2078 | >200† | >200 |
| clipboard | 1 | 191† | 10 (9) | 9 | >200† | >200 |
| клавіатура для айфона | 1 | 27† | 9 (0) | 151 | >200† | >200 |

### IL (storefront id 143491)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| מקלדת תרגום | 1 | 171† | 8 (1) | 0 | >200† | >200 |
| מקלדת ניקוד | 1 | 24† | 7 (0) | 69 | >200† | >200 |
| כתובת | - | 92† | 1 (1) | 0 | 77† | 77 |
| תבנית | - | 193† | 0 (0) | 3 | 147† | 147 |
| תשובות מהירות | - | 6† | 2 (2) | 0 | >200† | >200 |
| מקלדת | 7 | 175† | 9 (0) | 1640 | >200† | >200 |
| מקלדת בעברית | 1 | 187† | 7 (1) | 41 | >200† | >200 |
| text snippets | - | 172† | 9 (9) | 0 | 166† | 166 |
| canned responses | - | 30† | 10 (8) | 0 | 21† | 21 |
| clipboard keyboard | - | 164† | 10 (9) | 20 | 48† | 48 |
| טקסט | - | 193† | 0 (0) | 19 | >200† | >200 |
| custom keyboard | - | 181† | 10 (1) | 251 | >200† | >200 |
| מהיר | - | 187† | 1 (1) | 108 | >200† | >200 |
| הערה | - | 143† | 1 (1) | 0 | 125† | 125 |
| מקלדת לאייפון | 1 | 177† | 9 (0) | 51 | >200† | >200 |
| קיצורי טקסט | - | 5† | 5 (5) | 0 | >200† | >200 |
| clipboard | 1 | 189† | 10 (9) | 20 | 147† | 147 |
| מקלדת אותיות | 1 | 13† | 6 (1) | 13 | >200† | >200 |
| מקלדת עברית | 1 | 186† | 9 (0) | 22 | >200† | >200 |
| לוח גזירים | - | 6† | 5 (5) | 0 | >200† | >200 |
| text expander | - | 129† | 8 (8) | 2 | >200† | >200 |
| clipboard manager | 7 | 176† | 10 (10) | 1 | 129† | 129 |
| מקלדת יפה | 1 | 187† | 9 (0) | 628 | >200† | >200 |
| תבניות | 1 | 181† | 0 (0) | 6 | >200† | >200 |
| מקלדת גוגל | 1 | 77† | 5 (1) | 4240 | >200† | >200 |
| העתק הדבק | - | 25† | 5 (5) | 0 | 17† | 17 |
| קטע | - | 26† | 2 (2) | 0 | 23† | 23 |
| copy paste | 1 | 178† | 8 (8) | 59 | >200† | >200 |

### CZ (storefront id 143489)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| clipboard manager | 6 | 179† | 10 (10) | 1 | 118† | 118 |
| text expander | - | 126† | 9 (9) | 0 | >200† | >200 |
| rychle | - | 189† | 0 (0) | 5 | >200† | >200 |
| adresa | - | 141† | 0 (0) | 4 | 89† | 89 |
| clipboard | 1 | 186† | 10 (9) | 1 | >200† | >200 |
| rychlé odpovědi | - | 9† | 4 (3) | 0 | >200† | >200 |
| copy paste | 1 | 168† | 8 (8) | 8 | >200† | >200 |
| cut &amp; paste photos | 4@"paste" | 0† | 0 (0) | 0 | >200† | >200 |
| text | 9 | 159† | 6 (1) | 369 | >200† | >200 |
| klávesnice | - | 184† | 10 (1) | 1007 | >200† | >200 |
| automatické vyplňování | - | 3† | 3 (3) | 6514 | >200† | >200 |
| poznámka | - | 184† | 0 (0) | 0 | >200† | >200 |
| paste | 3 | 178† | 10 (10) | 9 | >200† | >200 |
| česká klávesnice | 1 | 186† | 9 (2) | 211 | >200† | >200 |
| textové zkratky | - | 3† | 3 (3) | 0 | >200† | >200 |
| ai text expander | 1 | 36† | 4 (4) | 0 | >200† | >200 |
| kopírovat vložit | - | 35† | 10 (10) | 0 | 19† | 19 |
| šablona | - | 193† | 0 (0) | 0 | >200† | >200 |
| clipboardvault smart keyboard | 1 | 1† | 1 (1) | 0 | >200† | >200 |
| custom keyboard | 1 | 184† | 10 (1) | 134 | >200† | >200 |
| clipboard keyboard | - | 173† | 10 (9) | 2 | 45† | 45 |
| paste keyboard | 1 | 170† | 10 (9) | 2 | >200† | >200 |
| pastel | 1 | 164† | 4 (4) | 80 | >200† | >200 |
| canned responses | - | 30† | 9 (7) | 0 | 21† | 21 |
| clipboard++ | 8 | 171† | 10 (9) | 2 | 124† | 124 |
| schránka | - | 84† | 7 (7) | 103 | 10† | 10 |
| šablony | 1 | 175† | 0 (0) | 3 | >200† | >200 |
| text snippets | - | 166† | 9 (9) | 0 | 138† | 138 |

### PT (storefront id 143453)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| teclado | 5 | 182† | 9 (0) | 852 | >200† | >200 |
| copiar colar | - | 156† | 5 (5) | 7 | 117† | 117 |
| teclado com tradutor | 1 | 13† | 8 (2) | 141 | >200† | >200 |
| área de transferência+ | 1@"área de transferência" | 44† | 8 (8) | 0 | >200† | >200 |
| copy paste | 1 | 166† | 8 (8) | 14 | >200† | >200 |
| clipboard | 1 | 187† | 10 (9) | 1 | >200† | >200 |
| teclado iphone | 2 | 180† | 9 (0) | 852 | >200† | >200 |
| atalho | - | 179† | 0 (0) | 649 | >200† | >200 |
| text expander | - | 126† | 8 (8) | 0 | >200† | >200 |
| clipboard manager | 5 | 177† | 10 (10) | 1 | 124† | 124 |
| atalhos de texto | - | 55† | 2 (2) | 29873 | 54† | 54 |
| teclado google | 2 | 181† | 8 (1) | 2452 | >200† | >200 |
| respostas rápidas | - | 39† | 4 (3) | 0 | 35† | 35 |
| área de transferência | - | 46† | 9 (9) | 0 | >200† | >200 |
| teclado desenhado | 1 | 21† | 9 (0) | 9 | >200† | >200 |
| text snippets | - | 165† | 8 (8) | 0 | 141† | 141 |
| notas | 1 | 185† | 0 (0) | 773 | >200† | >200 |
| custom keyboard | - | 187† | 10 (1) | 268 | >200† | >200 |
| teclado com design | 1 | 7† | 6 (0) | 14 | >200† | >200 |
| morada | - | 162† | 0 (0) | 8 | >200† | >200 |
| canned responses | - | 30† | 9 (7) | 0 | 20† | 20 |
| frases prontas | - | 121† | 0 (0) | 4 | >200† | >200 |
| clipboard keyboard | - | 168† | 10 (8) | 3 | 46† | 46 |
| teclado personalizado | 1 | 177† | 9 (1) | 852 | >200† | >200 |
| guardar | - | 192† | 0 (0) | 1480 | >200† | >200 |
| snippet | 2 | 153† | 10 (9) | 0 | >200† | >200 |
| modelo | 2 | 180† | 0 (0) | 470 | >200† | >200 |
| modelos de texto | - | 180† | 0 (0) | 2772 | >200† | >200 |
| teclado microsoft swiftkey | 1 | 24† | 7 (0) | 20 | >200† | >200 |

### PH (storefront id 143474)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| snippets! | 1 | 169† | 10 (10) | 0 | >200† | >200 |
| text snippets | - | 178† | 9 (9) | 0 | >200† | >200 |
| notes | 1 | 178† | 1 (1) | 1755 | >200† | >200 |
| phrases | - | 192† | 0 (0) | 7 | >200† | >200 |
| keyboard with clipboard | 1 | 14† | 10 (8) | 8 | >200† | >200 |
| canned responses | - | 31† | 9 (6) | 1 | 26† | 26 |
| notes keyboard | - | 181† | 10 (3) | 21 | >200† | >200 |
| clipboard keyboard | - | 191† | 10 (9) | 111 | 138† | 138 |
| save text | - | 190† | 0 (0) | 8470 | >200† | >200 |
| custom keyboard | 1 | 187† | 10 (0) | 2751 | >200† | >200 |
| clipboard paste keyboard | 1 | 190† | 10 (9) | 111 | 153† | 153 |
| clipboardvault smart keyboard | 1 | 1† | 1 (1) | 0 | >200† | >200 |
| snippet | 3 | 175† | 10 (10) | 1 | >200† | >200 |
| mabilis | 9 | 171† | 0 (0) | 35130 | >200† | >200 |
| text shortcut | - | 177† | 5 (4) | 52 | >200† | >200 |
| templates | 4 | 182† | 0 (0) | 22109 | >200† | >200 |
| ai text expander | 1 | 35† | 6 (6) | 0 | >200† | >200 |
| dev snippets | 1 | 29† | 9 (8) | 0 | >200† | >200 |
| template | 3 | 183† | 0 (0) | 22109 | >200† | >200 |
| paste | 5 | 185† | 10 (10) | 111 | >200† | >200 |
| snippets | - | 169† | 10 (10) | 0 | >200† | >200 |
| quick reply | - | 162† | 8 (4) | 1 | >200† | >200 |
| address | - | 176† | 0 (0) | 0 | >200† | >200 |
| mabilis na sagot | - | 0† | 0 (0) | 0 | >200† | >200 |
| text | - | 168† | 1 (0) | 2121 | >200† | >200 |
| text replacement | - | 96† | 2 (2) | 0 | >200† | >200 |
| kopya paste | - | 0† | 0 (0) | 0 | >200† | >200 |
| keyboard | 3 | 183† | 10 (0) | 2989 | >200† | >200 |
| copy paste | 2 | 187† | 8 (8) | 310 | >200† | >200 |
| snippets studio | 1 | 12† | 8 (8) | 0 | >200† | >200 |
| auto | - | 187† | 0 (0) | 183 | >200† | >200 |
| clipboard | 2 | 190† | 10 (9) | 18 | >200† | >200 |
| clipboard free | 1 | 193† | 10 (9) | 64 | >200† | >200 |
| autofill | 1 | 172† | 6 (6) | 79 | >200† | >200 |
| text expander | 1 | 129† | 10 (10) | 0 | >200† | >200 |
| clipboard manager | 1 | 190† | 10 (10) | 9 | >200† | >200 |

### MY (storefront id 143473)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| pastelnestix | 1 | 1 | 1 (1) | 0 | >250 | >200 |
| pastel girl | 1 | 83 | 5 (5) | 16 | >250 | >200 |
| paste | 3 | 250 | 10 (10) | 6 | >250 | >200 |
| pastest | 1 | 7 | 1 (1) | 34 | >250 | >200 |
| paste keyboard | 1 | 249 | 10 (10) | 1 | >250 | >200 |
| ai text expander | 2 | 36 | 5 (5) | 0 | >250 | >200 |
| keyboard clipboard | 1 | 250 | 10 (9) | 0 | 244 | >200 |
| snippet | 3 | 168† | 10 (10) | 0 | >200† | >200 |
| clipboardvault smart keyboard | 1 | 1† | 1 (1) | 0 | >200† | >200 |
| alamat | - | 111† | 0 (0) | 0 | 92† | 92 |
| balasan pantas | - | 6† | 5 (5) | 0 | >200† | >200 |
| papan kekunci | 1 | 181† | 10 (1) | 1681 | >200† | >200 |
| clipboard keyboard | - | 182† | 10 (9) | 29 | 73† | 73 |
| canned responses | - | 31† | 9 (7) | 3 | 25† | 25 |
| custom keyboard | - | 190† | 10 (1) | 2057 | >200† | >200 |
| isi automatik | - | 2† | 1 (1) | 0 | >200† | >200 |
| templat | - | 180† | 0 (0) | 423 | >200† | >200 |
| text snippets | - | 175† | 9 (9) | 0 | >200† | >200 |
| nota | 4 | 177† | 1 (1) | 716 | >200† | >200 |
| clipboard manager | 1 | 188† | 10 (10) | 8 | >200† | >200 |
| text expander | - | 130† | 10 (10) | 1 | >200† | >200 |
| salin tampal | - | 43† | 10 (10) | 0 | 33† | 33 |
| papan keratan | - | 27† | 8 (8) | 0 | >200† | >200 |
| clipboard | 2 | 189† | 10 (9) | 23 | >200† | >200 |
| teks pantas | - | 52† | 2 (2) | 1 | 48† | 48 |
| copy paste | 1 | 169† | 8 (8) | 174 | >200† | >200 |
| pantas | - | 187† | 0 (0) | 13 | >200† | >200 |
| template | 1 | 183† | 0 (0) | 7972 | >200† | >200 |

### KE (storefront id 143529)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| maandishi | - | 0 | 0 (0) | 0 | >250 | >200 |
| auto | - | 249 | 0 (0) | 4 | >250 | >200 |
| haraka | 1 | 69 | 0 (0) | 275 | >250 | >200 |
| anwani | - | 1 | 0 (0) | 0 | >250 | >200 |
| kiolezo | - | 0 | 0 (0) | 0 | >250 | >200 |
| kipande | - | 0 | 0 (0) | 0 | >250 | >200 |
| clipboard keyboard | - | 249 | 10 (9) | 4 | >250 | 45 |
| clipboard manager | 4 | 248 | 10 (10) | 0 | >250 | >200 |
| clipboard | 1 | 249 | 10 (9) | 1 | >250 | >200 |

### GR (storefront id 143448)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| σημείωση | - | 223 | 0 (0) | 0 | 140 | 141 |
| γρήγορο | - | 227 | 0 (0) | 6 | >250 | >200 |
| πρότυπο | - | 233 | 1 (1) | 0 | 195 | >200 |
| snippet | 2 | 201 | 10 (10) | 0 | >250 | >200 |
| επικόλληση | - | 60 | 10 (10) | 0 | 44 | 44 |
| πληκτρολόγιο | 2 | 233 | 10 (0) | 481 | >250 | >200 |
| clipboard keyboard | - | 197 | 10 (9) | 3 | 44 | 44 |
| clipboard manager | 6 | 210 | 10 (10) | 1 | >250 | >200 |
| clipboard | 1 | 214 | 8 (7) | 5 | >250 | >200 |

### HU (storefront id 143482)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| üzenet | 1 | 244 | 0 (0) | 3276 | >250 | >200 |
| jegyzet | 4 | 236 | 6 (6) | 226 | >250 | >200 |
| mentés | - | 228 | 1 (1) | 12 | >250 | >200 |
| gyors | - | 236 | 0 (0) | 3 | >250 | >200 |
| cím | - | 124 | 0 (0) | 0 | >250 | >200 |
| sablon | - | 237 | 2 (2) | 0 | 183 | 184 |
| clipboard keyboard | - | 214 | 10 (9) | 2 | 44 | 44 |
| clipboard manager | 6 | 217 | 10 (10) | 1 | 119 | 119 |
| clipboard | 1 | 226 | 9 (8) | 2 | >250 | >200 |

### RO (storefront id 143487)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| salvare | - | 225 | 0 (0) | 7 | >250 | >200 |
| notă | - | 245 | 3 (3) | 29 | >250 | >200 |
| rapid | - | 246 | 0 (0) | 4 | >250 | >200 |
| șablon | - | 234 | 1 (1) | 0 | >250 | >200 |
| adresă | - | 150 | 0 (0) | 0 | 75 | 76 |
| text | 9 | 247 | 6 (0) | 410 | >250 | >200 |
| clipboard keyboard | - | 205 | 10 (9) | 8 | 47 | 47 |
| clipboard manager | 7 | 214 | 10 (10) | 0 | 101 | 101 |
| clipboard | 1 | 227 | 9 (8) | 7 | >250 | >200 |

### FI (storefront id 143447)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| täyttö | - | 66 | 2 (2) | 0 | 39 | 39 |
| nopea | - | 214 | 0 (0) | 101 | >250 | >200 |
| pohja | - | 230 | 0 (0) | 1 | >250 | 145 |
| osoite | - | 121 | 0 (0) | 0 | 77 | 77 |
| snippet | 2 | 203 | 10 (10) | 0 | >250 | >200 |
| näppäimistö | 1 | 214 | 10 (0) | 87 | >250 | >200 |
| clipboard keyboard | - | 202 | 10 (9) | 1 | 48 | 48 |
| clipboard manager | 4 | 219 | 10 (10) | 0 | 124 | 124 |
| clipboard | 1 | 224 | 9 (8) | 1 | >250 | >200 |

### DK (storefront id 143458)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| adresse | - | 185 | 0 (0) | 0 | >250 | >200 |
| snippet | 2 | 202 | 9 (9) | 0 | >250 | >200 |
| tekst | 4 | 239 | 6 (2) | 251 | >250 | >200 |
| udklipsholder | - | 47 | 10 (10) | 0 | 33 | 33 |
| clipboard keyboard | - | 203 | 10 (9) | 1 | 107 | 107 |
| clipboard manager | 5 | 211 | 10 (10) | 1 | 171 | 171 |
| clipboard | 1 | 226 | 10 (10) | 0 | 192 | >200 |
| hurtig | 5 | 166† | 0 (0) | 90 | >200† | >200 |
| skabelon | 1 | 173† | 0 (0) | 148 | >200† | >200 |

### NO (storefront id 143457)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| rask | 4 | 246 | 0 (0) | 882 | >250 | >200 |
| mal | - | 250 | 0 (0) | 1 | >250 | >200 |
| adresse | - | 247 | 0 (0) | 16 | >250 | >200 |
| snippet | 3 | 248 | 10 (10) | 0 | >250 | >200 |
| tekst | 2 | 249 | 6 (2) | 562 | >250 | >200 |
| utklippstavle | - | 45 | 10 (10) | 0 | 25 | 30 |
| clipboard keyboard | - | 246 | 10 (9) | 7 | 236 | 57 |
| clipboard | 1 | 184† | 10 (10) | 2 | >200† | >200 |
| clipboard manager | 7 | 187† | 10 (10) | 0 | 159† | 159 |

### HR (storefront id 143494)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| bilješka | - | 205 | 1 (1) | 0 | 130 | 130 |
| brzo | - | 240 | 0 (0) | 1 | >250 | >200 |
| predložak | - | 211 | 1 (1) | 0 | 135 | 135 |
| adresa | - | 149 | 0 (0) | 0 | 55 | 55 |
| lijepljenje | - | 11 | 8 (8) | 0 | 7 | 7 |
| kopiranje | - | 35 | 5 (4) | 0 | 24 | 24 |
| clipboard keyboard | - | 222 | 10 (9) | 1 | 39 | 39 |
| clipboard manager | 6 | 223 | 10 (10) | 0 | 116 | 116 |
| clipboard | 1 | 232 | 10 (8) | 1 | >250 | >200 |

### SK (storefront id 143496)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| poznámka | - | 228 | 0 (0) | 0 | 213 | >200 |
| rýchlo | - | 236 | 2 (1) | 0 | >250 | >200 |
| text | 8 | 248 | 5 (1) | 96 | >250 | >200 |
| adresa | - | 139 | 0 (0) | 0 | 72 | 73 |
| šablóna | - | 244 | 1 (1) | 0 | 231 | >200 |
| clipboard keyboard | - | 212 | 10 (9) | 1 | 42 | 42 |
| clipboard manager | 7 | 214 | 10 (10) | 1 | 117 | 117 |
| clipboard | 1 | 215 | 10 (9) | 2 | >250 | >200 |

### SI (storefront id 143499)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| opomba | - | 0 | 0 (0) | 0 | >250 | >200 |
| besedilo | - | 1 | 0 (0) | 0 | >250 | >200 |
| hitro | - | 0 | 0 (0) | 0 | >250 | >200 |
| naslov | - | 1 | 0 (0) | 0 | >250 | >200 |
| predloga | - | 0 | 0 (0) | 0 | >250 | >200 |
| delček | - | 0 | 0 (0) | 0 | >250 | >200 |
| clipboard keyboard | - | 217 | 10 (9) | 0 | 32 | 32 |
| clipboard manager | 6 | 215 | 10 (10) | 0 | 123 | 123 |
| clipboard | 6 | 201 | 10 (8) | 0 | >250 | >200 |

### EE (storefront id 143518)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| katkend | - | 0 | 0 (0) | 0 | >250 | >200 |
| kiire | - | 196 | 0 (0) | 110 | >250 | >200 |
| automaatne | - | 1 | 0 (0) | 0 | >250 | >200 |
| aadress | - | 166 | 0 (0) | 0 | >250 | >200 |
| mall | - | 228 | 0 (0) | 4 | >250 | >200 |
| clipboard keyboard | - | 221 | 10 (9) | 0 | 43 | 43 |
| clipboard manager | 4 | 219 | 10 (10) | 0 | 117 | 117 |
| clipboard | 6 | 211 | 10 (9) | 0 | >250 | >200 |

### LV (storefront id 143519)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| piezīme | - | 2 | 0 (0) | 3 | >250 | >200 |
| auto | - | 232 | 0 (0) | 271 | >250 | >200 |
| ātri | - | 34 | 0 (0) | 3 | >250 | >200 |
| adrese | - | 165 | 0 (0) | 0 | >250 | >200 |
| veidne | - | 0 | 0 (0) | 0 | >250 | >200 |
| starpliktuve | - | 0 | 0 (0) | 0 | >250 | >200 |
| clipboard keyboard | - | 223 | 10 (9) | 1 | 33 | 33 |
| clipboard manager | 4 | 215 | 10 (10) | 0 | 190 | >200 |
| clipboard | 6 | 224 | 10 (8) | 0 | >250 | >200 |

### LT (storefront id 143520)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| fragmentas | - | 4 | 0 (0) | 0 | >250 | >200 |
| auto | - | 243 | 0 (0) | 370 | >250 | >200 |
| greitas | - | 6 | 0 (0) | 4 | >250 | >200 |
| adresas | - | 200 | 0 (0) | 3 | >250 | >200 |
| šablonas | - | 2 | 0 (0) | 0 | >250 | >200 |
| clipboard keyboard | - | 219 | 10 (9) | 1 | 40 | 40 |
| clipboard manager | 7 | 218 | 10 (10) | 0 | 117 | 117 |
| clipboard | 1 | 224 | 10 (10) | 1 | >250 | >200 |

### BG (storefront id 143526)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| бележка | - | 2 | 0 (0) | 121 | >250 | >200 |
| текст | - | 209 | 4 (1) | 82 | >250 | >200 |
| бързо | - | 6 | 0 (0) | 1 | >250 | >200 |
| автоматично | - | 0 | 0 (0) | 0 | >250 | >200 |
| адрес | - | 20 | 0 (0) | 0 | >250 | >200 |
| шаблон | - | 21 | 7 (7) | 30 | >250 | >200 |
| clipboard keyboard | - | 218 | 10 (9) | 2 | 39 | 39 |
| clipboard manager | 5 | 215 | 10 (10) | 0 | 109 | 109 |
| clipboard | 1 | 224 | 10 (9) | 2 | >250 | >200 |

### RS (storefront id 143500)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| ауто | - | 250 | 0 (0) | 27 | >250 | >200 |
| брзо | - | 2 | 0 (0) | 0 | >250 | >200 |
| адреса | - | 23 | 0 (0) | 0 | >250 | >200 |
| шаблон | - | 50 | 6 (6) | 46 | >250 | >200 |
| исечак | - | 0 | 0 (0) | 0 | >250 | >200 |
| clipboard keyboard | - | 249 | 10 (9) | 0 | 241 | 37 |
| clipboard manager | 7 | 249 | 10 (10) | 0 | >250 | 120 |
| clipboard | 1 | 249 | 10 (10) | 0 | >250 | >200 |

### PK (storefront id 143477)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| تیز | - | 244 | 0 (0) | 16 | >250 | >200 |
| پتہ | - | 248 | 1 (0) | 16 | >250 | >200 |
| ٹیمپلیٹ | - | 249 | 0 (0) | 34 | >250 | >200 |
| autofill | - | 245 | 6 (6) | 1288 | 190 | >200 |
| snippet | 3 | 250 | 9 (9) | 0 | >250 | >200 |
| clipboard keyboard | 1 | 248 | 10 (9) | 8 | >250 | 104 |
| clipboard manager | 1 | 248 | 10 (10) | 3 | 230 | >200 |
| clipboard | 3 | 248 | 10 (9) | 14 | >250 | >200 |

### BD (storefront id 143490)

| term | type-ahead pos | results | relevant top 10 (strict) | median ratings top 10 | Cutling rank (top 250) | Search API rank (top 200) |
|---|---|---|---|---|---|---|
| snippet | - | 0† | 0 (0) | 0 | >200† | >200 |
| টেক্সট | - | 0† | 0 (0) | 0 | >200† | >200 |
| নোট | - | 0† | 0 (0) | 0 | >200† | >200 |
| clipboard keyboard | - | 0† | 0 (0) | 0 | >200† | >200 |
| clipboard | - | 0† | 0 (0) | 0 | >200† | >200 |
| clipboard manager | - | 0† | 0 (0) | 0 | >200† | >200 |
| টেমপ্লেট | - | 0† | 0 (0) | 0 | >200† | >200 |
| autofill | - | 0† | 0 (0) | 0 | >200† | >200 |

## Keyword targets per storefront (proposal, 2026-10-01)

What each locale now targets, and the storefronts that index it (Apple's localization table). Name and subtitle words are searched; the keyword field adds the rest. Reasons cite the rows above.

| Locale | Indexed in | Name | Subtitle | Keyword field |
|---|---|---|---|---|
| ar-SA | Algeria, Bahrain, Egypt, Iraq, Jordan, Kuwait +11 | Cutling - لوحة مفاتيح الحافظة | نسخ ولصق وردود سريعة بلمسة | نصوص,جاهزة,قصاصة,ملاحظات,قوالب,الملء,التلقائي |
| bg | none | Cutling - Клипборд клавиатура | Копиране и поставяне на текст | шаблон,бележки,бързи,отговори |
| bn-BD | India | Cutling - ক্লিপবোর্ড কীবোর্ড | কপি পেস্ট হবে এক ট্যাপে | autofill,template,shortcuts,phrases,autotext,expander |
| bn-IN | none | Cutling - ক্লিপবোর্ড কীবোর্ড | এক ট্যাপেই কপি পেস্ট | autofill,template,shortcuts,phrases,autotext,expander |
| ca | Spain | Cutling - Teclat porta-retalls | Copiar i enganxar amb un toc | respostes,ràpides,textos,plantilles,notes,dreceres,adreça |
| cs | Czechia | Cutling - Schránka klávesnice | Kopírovat a vložit na klepnutí | rychlé,odpovědi,šablony,poznámky,zkratky,textové |
| da | Denmark | Cutling - Udklipsholder | Tastatur til kopiér og indsæt | hurtige,svar,tekst,skabeloner,noter,genveje,udfyldning,signatur,adresse,beskeder |
| de-DE | Austria, Germany, Luxembourg, Switzerland | Cutling - Zwischenablage | Tastatur für Textbausteine | kopieren,einfügen,schnellantworten,notizen,vorlagen,textersetzung,kurzbefehle,adresse,signatur |
| el | Cyprus, Greece | Cutling - Αντιγραφή επικόλληση | Πρόχειρο στο πληκτρολόγιο | γρήγορες,απαντήσεις,πρότυπα,σημειώσεις,διεύθυνση |
| en-AU | Australia, New Zealand | Cutling - Copy Paste Keyboard | Saved Replies & Clipboard Text | snippet,template,signature,iban,email,address,bank,booking,wifi,notepad,typing,quickpaste |
| en-CA | Canada | Cutling - Clipboard Keyboard | Paste Text Snippets & Replies | canned,response,copy,quick,history,manager,expander,notes,shortcuts,autotext,autofill,phrase |
| en-GB | Afghanistan, Albania, Algeria, Angola, Anguilla, Antigua and Barbuda +166 | Cutling - Clipboard Keyboard | Copy & Paste Text Snippets | canned,response,quick,reply,history,manager,expander,notes,shortcuts,autotext,autofill,replacement |
| en-IN | none | Cutling - Clipboard Keyboard | Copy & Paste Text Snippets | canned,response,quick,reply,history,manager,expander,notes,shortcuts,autotext,autofill,phrase |
| en-US | Japan, United States | Cutling - Clipboard Keyboard | Paste Text Snippets & Replies | canned,response,quick,history,manager,expander,notes,copy,shortcuts,autotext,autofill,replacement |
| es-ES | Spain | Cutling - Teclado portapapeles | Copiar y pegar tus textos | respuestas,rápidas,plantillas,notas,autorrellenar,atajos,frases |
| es-MX | Argentina, Belize, Bolivia, Chile, Colombia, Costa Rica +13 | Cutling - Teclado portapapeles | Copiar y pegar tus textos | respuestas,rápidas,plantillas,notas,autorrellenar,atajos,frases,firma |
| et | none | Cutling - Lõikelaua klaviatuur | Kopeeri ja kleebi kõikjal | kiirvastused,mallid,märkmed |
| fa | none | Cutling - کیبورد کلیپ‌بورد | کپی و چسباندن متن‌های آماده | متن,پاسخ,سریع,یادداشت |
| fi | Finland | Cutling - Leikepöytä | Kopioi ja liitä näppäimistöllä | pikavastaukset,tekstit,pohjat,muistiinpanot,täyttö,allekirjoitus,osoite,viestit |
| fil | none | Cutling - Clipboard Keyboard | Kopya at paste ng saved text | mabilis,sagot,teksto,template,tala |
| fr-CA | Canada | Cutling - Copier-coller | Clavier avec presse-papiers | réponses,rapides,raccourcis,texte,modèles,extraits,notes |
| fr-FR | Algeria, Belgium, Benin, Burkina Faso, Cambodia, Cameroon +26 | Cutling - Copier-coller | Clavier avec presse-papiers | réponses,rapides,raccourcis,texte,modèles,extraits,notes,remplissage |
| gu-IN | India | Cutling - ક્લિપબોર્ડ કીબોર્ડ | સેવ કરેલા ટેક્સ્ટ કૉપી પેસ્ટ | copy,paste,keyboard,clipboard,saver,typing |
| he | Israel | Cutling - מקלדת העתק הדבק | תשובות מהירות וטקסטים שמורים | לוח,גזירים,קיצורי,טקסט,קטעים,תבניות,הערות |
| hi | India | Cutling - क्लिपबोर्ड कीबोर्ड | सेव टेक्स्ट का कॉपी पेस्ट | clipboard,manager,copy,paste,history,keyboard,notes |
| hr | Bosnia and Herzegovina, Croatia, Montenegro, Serbia | Cutling - Kopiraj i zalijepi | Tipkovnica s međuspremnikom | lijepljenje,kopiranje,brzi,odgovori,predlošci,bilješke,isječci |
| hu | Hungary | Cutling - Vágólap billentyűzet | Gyors másolás és beillesztés | válaszok,sablonok,jegyzetek,szöveg,kitöltés,aláírás,cím,üzenetek |
| id | Indonesia | Cutling - Salin Tempel | Keyboard untuk balasan cepat | papan,klip,teks,catatan,template,isi,otomatis,alamat,rekening |
| it | Italy, Switzerland | Cutling - Tastiera appunti | Risposte rapide in ogni app | copia,incolla,testi,frasi,modelli,note,scorciatoie,indirizzo,messaggi,predefiniti,firma,compilazione |
| ja | Japan | Cutling - コピペ・定型文キーボード | クリップボードの文章を保存して入力 | クリップボード,履歴,スニペット,ペースト,辞書,返信,テンプレ |
| kn-IN | India | Cutling - ಕ್ಲಿಪ್‌ಬೋರ್ಡ್ | ಕೀಬೋರ್ಡ್‌ನಲ್ಲಿ ಕಾಪಿ ಪೇಸ್ಟ್ | text,replacement,shortcut,typing,faster |
| ko | Republic of Korea, United States | Cutling - 클립보드 복붙 키보드 | 자주 쓰는 문구와 답장을 탭 한 번에 | 정형문,상용구,스니펫,자동입력,메모,문구저장,답장 |
| lt | none | Cutling - Iškarpinė klaviatūra | Kopijuoti ir įklijuoti tekstus | greiti,atsakymai,šablonai,užrašai |
| lv | none | Cutling - Starpliktuve | Tastatūra, kas kopē un ielīmē | kopēt,ielīmēt,ātrās,atbildes,veidnes,piezīmes |
| ml-IN | India | Cutling - ക്ലിപ്ബോർഡ് കീബോർഡ് | കോപ്പി പേസ്റ്റ് ഒരു ടാപ്പിൽ | quick,messages,replies,saved,customer |
| mr-IN | India | Cutling - क्लिपबोर्ड कीबोर्ड | कॉपी पेस्ट एका टॅपमध्ये | text,snippets,quick,reply,canned,responses,saved |
| ms | Malaysia | Cutling - Salin Tampal | Papan klip bagi balasan pantas | teks,kekunci,keratan,nota,templat,isi,automatik,alamat,mesej,tandatangan |
| nl-NL | Belgium, Netherlands, Suriname | Cutling - Klembord toetsenbord | Kopiëren en plakken in één tik | snelle,antwoorden,tekst,sjablonen,notities,tekstvervanging |
| no | Norway | Cutling - Utklippstavle | Kopier og lim inn med tastatur | hurtigsvar,tekst,maler,notater,snarveier,utfylling,signatur,adresse,meldinger |
| or-IN | India | Cutling - କ୍ଲିପବୋର୍ଡ କୀବୋର୍ଡ | ସେଭ୍ ଉତ୍ତର ସହ କପି ପେଷ୍ଟ | custom,keyboard,snippet,saver,widget |
| pa-IN | India | Cutling - ਕਲਿੱਪਬੋਰਡ ਕੀਬੋਰਡ | ਸੇਵ ਟੈਕਸਟ, ਇੱਕ ਟੈਪ ਕਾਪੀ ਪੇਸਟ | paste,keyboard,clipboard,manager,typing |
| pl | Poland | Cutling - Schowek klawiatura | Kopiuj wklej na szybko | szybkie,odpowiedzi,skróty,tekstowe,szablony,notatki,autouzupełnianie |
| pt-BR | Brazil, United States | Cutling - Teclado copiar colar | Respostas rápidas em um toque | área,transferência,mensagens,prontas,frases,atalhos,textos,notas |
| pt-PT | Portugal | Cutling - Teclado copiar colar | Respostas rápidas num toque | área,transferência,atalhos,textos,frases,notas,morada |
| ro | Romania | Cutling - Tastatură clipboard | Copiere și lipire de fragmente | răspunsuri,rapide,șabloane,notițe,text,adresă |
| ru | Russia, Ukraine, United States | Cutling - Буфер обмена | Быстрые ответы на клавиатуре | копировать,вставить,шаблоны,заметки,автозаполнение |
| sk | Slovakia | Cutling - Schránka klávesnica | Kopírovať a vložiť kdekoľvek | rýchle,odpovede,šablóny,poznámky,skratky,vyplnenie,podpis,adresa |
| sl-SI | Slovenia | Cutling - Odložišče tipkovnica | Kopiraj in prilepi z dotikom | hitri,odgovori,predloge,beležke,besedilo,izpolnjevanje,podpis,naslov |
| sr | none | Cutling - Клипборд тастатура | Копирај и налепи одговоре | шаблон,брзи,одговори,белешке |
| sv | Sweden | Cutling - Urklipp tangentbord | Klistra in snabbsvar direkt | kopiera,anteckningar,autofyll,textgenvägar,mallar,historik |
| sw | none | Cutling - Kibodi ya Clipboard | Nakili na bandika maandishi | majibu,haraka,violezo |
| ta-IN | India | Cutling - கிளிப்போர்டு | எதிலும் காப்பி பேஸ்ட் கீபோர்டு | notes,keyboard,signature,address,iban,email |
| te-IN | India | Cutling - క్లిప్‌బోర్డ్ | కీబోర్డ్‌లో కాపీ పేస్ట్ | clipboard,history,saver,recent,copies |
| th | Thailand | Cutling - คีย์บอร์ดคลิปบอร์ด | คัดลอกวางข้อความสำเร็จรูปทันที | ตอบกลับด่วน,บันทึก,แม่แบบ,ข้อความ |
| tr | Cyprus, Türkiye | Cutling - Kopyala Yapıştır | Hızlı yanıtlar için klavye | yanıt,pano,metin,kısayolu,hazır,mesaj,şablon,notlar,otomatik,doldur |
| uk | Russia, Ukraine | Cutling - Буфер обміну | Копіюйте й вставляйте текст | клавіатура,копіювати,вставити,швидкі,відповіді |
| ur-PK | India, Pakistan | Cutling - کلپ بورڈ کی بورڈ | محفوظ جوابات، ہر جگہ کاپی پیسٹ | copy,paste,manager,history,quick,reply,snippets,autofill,notes |
| vi | United States, Vietnam | Cutling - Bàn phím sao chép | Bộ nhớ tạm cho tin nhắn mẫu | dán,trả,lời,nhanh,văn,bản,ghi,chú,địa,chỉ,chữ,ký,điền,tự,động |
| zh-Hans | China mainland, Singapore, United States | Cutling - 剪贴板输入法 | 常用语一点即输入，复制粘贴更省事 | 快捷短语,常用文字,自动填充,管理,模板,键盘 |
| zh-Hant | Hong Kong, Macau, Taiwan, United States | Cutling - 剪貼簿鍵盤 | 常用語一點即輸入，複製貼上更省事 | 常用文字,快捷短語,自動填寫,輸入法,範本,罐頭訊息 |
