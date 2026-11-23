# gu-IN (Gujarati, India): Cutling 2.0 store frames, direction C (card ASG167)

Written blind from `C-words-brief.md` and the `gu-IN` entry of `locale-facts.json`; the words file is
`fastlane/compose/creative/v2/words/gu-IN.json`. Register: તમે (polite "you"), the form Google Pay's Gujarati Play
listing, the gu-IN store description and the app's own Gujarati strings use, kept in every line; the shop owner's
replies speak as "we" (મોકલી દઈશું). Punctuation is the Western full stop, comma and colon modern Gujarati uses: no
danda, no dashes, no quotation marks. Loanwords keep the app's spellings (ઑર્ડર, ઍપ, ટૅપ, કૉપિ, ફૉર્મ). Lengths are
counted in Unicode code points; the reply with હેતલ is exactly 40. Seven sublines carry non-breaking spaces (written
` ` in the JSON) so a particle or verb never ends up alone on a line. Rendered at store size with the repo's C build
on 2026-11-23: nothing clipped on iPhone, iPad or Mac. Square brackets mark the green chips.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| `cseed.names[0]` | હેતલ | Hetal | Common Gujarati woman's name; the frame 1 customer. |
| `cseed.names[1]` | ધવલ | Dhaval | Common Gujarati man's name; the frame 2 customer. |
| `cseed.names[2]` | કૃપા | Krupa | Common Gujarati woman's name; all three are 3 or 4 code points, so the name keys stay short. |
| `cseed.mac_name` | ચિરાગ | Chirag | Common Gujarati man's name; two women and two men across the four. |
| `cseed.reply` | {name}, ઑર્ડર {date} સુધીમાં મોકલી દઈશું. | {name}, order {date} by [we] will send off. | The weekday stays bare before the separate postposition સુધીમાં ("by"), because મંગળવારે ("on Tuesday") would inflect it; મોકલી દઈશું ("we'll get it sent off") is how a shop answers on WhatsApp; તમારો ("your") left out to stay inside 40. |
| `cseed.reply_name` | ઑર્ડર અપડેટ | Order update | What Indian sellers call this message; the loanword is what they say. |
| `cseed.mac_reply` | {name}, {plan} પ્લાન {date} સુધીમાં ચાલુ થઈ જશે. | {name}, {plan} plan {date} by will get started. | Same bare weekday + સુધીમાં; a plan starts rather than ships, so ચાલુ થઈ જશે ("will be up and running"); 50 code points with ચિરાગ and પ્રીમિયમ. |
| `cseed.name_label` | નામ | Name | The app's own word for Name. |
| `cseed.plan_label` | પ્લાન | Plan | The app's own word (its Variables screen shows પ્લાન ▾); buyers say plan, not યોજના. |
| `cseed.plan_choices[0]` | બેઝિક | Basic | The loanword pair Indian pricing pages use, and the pair the gu-IN 2.0 release notes already name. |
| `cseed.plan_choices[1]` | પ્રીમિયમ | Premium | 8 code points, at the limit. |
| `cseed.delivered` | ઑર્ડર પહોંચી ગયો: {date} | Order has arrived: {date} | The date follows a colon, as Gujarati notes and forms write it (તારીખ: …), so it needs no case ending; "your" left out so the line sits above the date chip in two lines on iPhone. |
| `cseed.delivered_name` | ડિલિવરી નોંધ | Delivery note | How a seller labels it. |
| `C.iphone.1.k` | આ જવાબ એક જ વાર લખ્યો છે | This reply has been written only once | Perfect tense with the writer unstated; masculine લખ્યો agrees with જવાબ; 24 code points, at the limit. |
| `C.iphone.1.s` | સાચવેલો જવાબ ટૅપ કરો, કટલિંગ ગ્રાહકનું નામ પૂછશે. | Saved reply tap, Cutling customer's name will ask. | "Do X, Y follows" without a connector, as it is said; ગ્રાહકનું ("the customer's") says whose name; fits one line. |
| `C.iphone.2.k` | એ જ જવાબ, હવે બીજા ગ્રાહકને | That same reply, now to another customer | Verbless, to pair with frame 1's kicker; બીજા ("another") over આગલા, which can mean next or previous. |
| `C.iphone.2.s` | તમે પહેલાં વાપરેલાં નામ કી પર તૈયાર છે, બસ એક ટૅપ કરો. | The names you used before are ready on keys, just one tap do. | તૈયાર ("ready") is the Gujarati picture for waiting keys; neuter plural વાપરેલાં agrees with નામ; colloquial બસ ("just"). |
| `C.iphone.3.k` | કટલિંગ તારીખ આપોઆપ લખે છે | Cutling date automatically writes | આપોઆપ is the usual Gujarati UI word for "by itself". |
| `C.iphone.3.s` | તારીખ આજની હોય, આવતીકાલની કે અઠવાડિયા પછીની, પેસ્ટ કરતી વખતે સાચી જ આવે છે. | Whether the date be today's, tomorrow's or a week later's, at the time of pasting it comes out right. | The "X હોય, Y કે Z" (be it X, Y or Z) frame; આવતીકાલ because કાલ alone means both yesterday and tomorrow; the app's names for the three dates. |
| `C.iphone.4.k` | અને કદી ન બદલાતી તમારી વિગતો: | And your never-changing details: | Leads into the headline with a colon; one possessive on the group, as Gujarati does with a list, instead of three gendered "your"s inside the chips. |
| `C.iphone.4.h` | [ખાતા નંબર], [સરનામું] અને [સહી] | [account number], [address] and [signature] | The words bank forms and the app's own seed use (ખાતા નંબર; ઘરનું સરનામું, ઈમેઇલ સહી); અને before the last item. |
| `C.iphone.4.s` | કટલિંગ કીબોર્ડ પર દરેક વિગત એક ટૅપથી લખાય છે, કોઈ પણ ઍપમાં. | On the Cutling keyboard each detail with one tap gets typed, in any app. | એક ટૅપથી as the app's release notes and Google Pay's Gujarati listing say it; the app comes last as an afterthought, so the line breaks at the comma; nbsp in કોઈ પણ. |
| `C.iphone.5.k` | બધું સમાઈ જાય એટલી જગ્યા | So much room that everything fits | The idiom "એટલી જગ્યા" (room enough that…). |
| `C.iphone.5.h` | [5,000] કટલિંગ | [5,000] cutlings | n5000 and the product word exactly as the facts give them; the plural is the same word. |
| `C.iphone.5.s` | પહેલાં 100 જ હતાં, હવે દરેકમાં આખો ઈમેઇલ આવી જાય. | Before only 100 there were, now in each a whole email fits. | Neuter plural હતાં agrees with કટલિંગ; before/now set side by side without a connector; ઈમેઇલ spelled as the app's seed spells it. |
| `C.iphone.6.k` | iPhone, iPad અને Mac | iPhone, iPad and Mac | Device names stay in Latin script, as Apple and the app write them. |
| `C.iphone.6.h` | [એક જ વાર] ચૂકવો | [Just once] pay | Chip on એક જ વાર ("one single time"); polite imperative; 14 code points. |
| `C.iphone.6.s` | એક ખરીદી ત્રણેય પર ચાલે છે, ન ખાતું જોઈએ, ન સબ્સ્ક્રિપ્શન. | One purchase works on all three, neither an account is needed, nor a subscription. | The "ન X, ન Y" neither-nor; invariant જોઈએ needs no gender for the loanword; ખાતું is the app's word for an account; nbsp keeps each ન with its noun. |
| `C.mac.1.k` | એક વાર લખો, બધાને મોકલો | Once write, to everyone send | Two parallel polite imperatives. |
| `C.mac.1.s` | {cmd} દબાવીને જવાબ પસંદ કરો, પેસ્ટ થતાં પહેલાં નાનું ફૉર્મ ખાલી ભાગ ભરવા કહે છે. | Having pressed ⌘⇧V, choose the reply; before it pastes, a small form asks [you] to fill the blanks. | ખાલી ભાગ is the app's word for a blank; નાનું ફૉર્મ ("small form") because ટૂંકું ફૉર્મ echoes the Indian English "short form", an abbreviation; nbsp keeps નાનું ફૉર્મ together. |
| `C.mac.2.k` | જ્યાં પણ લખતા હો | Wherever [you] may be writing | Subjunctive હો of તમે; leads into the keys. |
| `C.mac.2.h` | {cmd} | ⌘⇧V | Fixed by the brief. |
| `C.mac.2.s` | કોઈ પણ ઍપ ઉપર તમારાં કટલિંગ અને તાજેતરમાં કૉપિ કરેલું ખૂલે છે. | On top of any app your cutlings and what [you] copied recently open. | ઉપર ("on top of") for over; તાજેતરમાં echoes the app's "recent clipboard"; nbsp keeps કૉપિ કરેલું whole. |
| `C.mac.3.k` | ક્લિપબોર્ડ ઇતિહાસ આ છોડી દે છે: | The clipboard history this leaves out: | Gujarati puts the object before the verb, so આ ("this") and a colon point at the dots below; છોડી દે છે is the store description's verb for it. |
| `C.mac.3.s` | પાસવર્ડ મેનેજરે છુપાવેલું કંઈ પણ ઇતિહાસમાં ક્યારેય આવતું નથી. | Anything hidden by a password manager never comes into the history. | Agent marker on મેનેજરે plus છુપાવેલું ("hidden by it"), the store description's wording; nbsp keeps આવતું નથી together. |
| `C.mac.4.k` | તમારા Mac પર કંઈ બદલો, | On your Mac change something, | An imperative as the condition, leading into the headline. |
| `C.mac.4.h` | [iPhone] પર પણ બદલાઈ જાય | On [iPhone] too it gets changed | પર is written as a separate word, so the chip holds iPhone alone; no full stop, like the other non-reply headlines. |
| `C.mac.4.s` | તમારા પોતાના iCloud થી સિંક થાય છે, કોઈ ખાતું બનાવવાનું નથી. | Through your own iCloud it syncs, no account to make. | The app's own onboarding wording (તમારા પોતાના iCloud થી સિંક); nbsp keeps the second clause on one line. |
| `C.mac.5.k` | iPhone, iPad અને Mac | iPhone, iPad and Mac | Same as iPhone 6. |
| `C.mac.5.h` | [એક જ વાર] ચૂકવો | [Just once] pay | Same as iPhone 6. |
| `C.mac.5.s` | એક ખરીદી ત્રણેય પર ચાલે છે, ન ખાતું જોઈએ, ન સબ્સ્ક્રિપ્શન. | One purchase works on all three, neither an account is needed, nor a subscription. | Same as iPhone 6. |

Headlines the build makes from the seed, as they render:

| Frame | Headline | Back-translation |
|---|---|---|
| iPhone/iPad 1 | [હેતલ], ઑર્ડર [મંગળવાર] સુધીમાં મોકલી દઈશું. | Hetal, [we]'ll send off the order by Tuesday. |
| iPhone/iPad 2 | [ધવલ], ઑર્ડર [મંગળવાર] સુધીમાં મોકલી દઈશું. | Dhaval, [we]'ll send off the order by Tuesday. |
| iPhone/iPad 3 | ઑર્ડર પહોંચી ગયો: [23 નવેમ્બર, 2026] | Order has arrived: 23 November 2026 |
| Mac 1 | [ચિરાગ], [પ્રીમિયમ] પ્લાન [મંગળવાર] સુધીમાં ચાલુ થઈ જશે. | Chirag, the Premium plan will be up and running by Tuesday. |
