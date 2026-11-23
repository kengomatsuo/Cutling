# Korean (ko): words for the 2.0 store frames, direction C

Written blind from `C-words-brief.md` and the `ko` entry of `locale-facts.json`. One speech level throughout: polite
해요체, as the Korean listing's promotional text and description already speak to buyers; kickers are short phrases
without a verb ending. The app is 컷링, its name on the Korean home screen. Rendered on iPhone, iPad and Mac with
`python3 build.py ko C`.

| Key | Korean | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | 민지 | Minji | Female; a common girls' name through the 1990s in the Supreme Court birth records (Segye Ilbo, 2016), so an adult customer today. |
| cseed.names[1] | 지훈 | Jihun | Male; the top boys' name of the 1980s and 1990s, and first of all time, in the same records. |
| cseed.names[2] | 서연 | Seoyeon | Female; in the 2000s list, the top girls' name of the 2010s. |
| cseed.mac_name | 현우 | Hyunwoo | Male; in the 2000s list and third of all time. |
| cseed.reply | {name} 님, 주문하신 상품 {date}에 출발해요! | {name}-nim, the product you ordered sets off on {date}! | 님 and honorific 주문하신, as a small Korean shop writes to a buyer; 님 spaced after a name as 표준국어대사전 gives it ("길동 님"); the bare weekday takes 에 ("화요일에"), so the app's word stays as it is; 출발해요 is the shop idiom for shipping; this ! is the only one in the set. |
| cseed.reply_name | 주문 안내 | order notice | 안내 is the shop word for a notice to customers; "order" fits both replies, and the Mac form shows this name above the Mac reply. |
| cseed.mac_reply | {name} 님, {plan} 요금제는 {date}부터 시작돼요. | {name}-nim, the {plan} plan starts from {date}. | 요금제 is the app's own word for Plan; 부터 ("from") attaches after the bare weekday. |
| cseed.name_label | 이름 | name | The app's string for Name. |
| cseed.plan_label | 요금제 | (price) plan | The app's string for Plan, the label a Korean user gets from the Plan choice preset. |
| cseed.plan_choices[0] | 베이직 | Basic | Loanword used for a base tier; the Korean 2.0 release notes already name these two plans. |
| cseed.plan_choices[1] | 프리미엄 | Premium | As above. |
| cseed.delivered | {date}에 배송 완료됐어요. | It was delivered (delivery completed) on {date}. | 배송 완료 is the delivery-tracking word for "delivered"; 해요체 because it is pasted to a customer. |
| cseed.delivered_name | 배송 완료 안내 | delivery-completed notice | Named the way shops name a notice template (…안내). |
| C.iphone.1.k | 딱 한 번 써 둔 답장 | a reply written (and kept) just once | A label for the reply below it; 써 둔 means written and kept for later. |
| C.iphone.1.s | 저장한 답장을 탭하면 컷링이 이름만 물어봐요. | When you tap the saved reply, Cutling asks only for the name. | 이름만 ("only the name") because the date fills itself. |
| C.iphone.2.k | 다음 고객에게도 그대로 | to the next customer too, just as it is | Reads on from frame 1's kicker as one thought; 고객 is a shop's word for its buyers. |
| C.iphone.2.s | 전에 쓴 이름이 키로 기다리고 있어서 누르기만 하면 돼요. | The names you used before are waiting as keys, so all you do is press. | 누르기만 하면 돼요 carries "one tap" without repeating 탭 한 번 from frame 4. |
| C.iphone.3.k | 날짜는 컷링이 알아서 채워요 | as for dates, Cutling fills them in on its own | 알아서 is everyday Korean for doing something without being told. |
| C.iphone.3.s | 오늘이든 내일이든 일주일 뒤든, 붙여넣는 날에 맞는 날짜가 찍혀요. | Whether today, tomorrow or a week later, the date that fits the day you paste is stamped in. | ~이든 ~이든 ~든 lists the three; 찍히다 is how Korean says a date is printed on something. |
| C.iphone.4.k | 바뀔 일 없는 내 정보도 | my info that has no reason to change, too | Leads into the list; 내 ("my") carries the possessive once rather than on every chip. |
| C.iphone.4.h | [계좌번호], [집 주소], [이메일 서명] | [account number], [home address], [email signature] | Shortest everyday names; 집 주소 and 이메일 서명 are the names of the cutlings in the Korean capture under this headline. |
| C.iphone.4.s | 어느 앱에서든 컷링 키보드로 탭 한 번이면 입력돼요. | In any app, one tap with the Cutling keyboard and it is typed. | 입력돼요 (it gets typed), so the keyboard does the work. |
| C.iphone.5.k | 다 넣어 둬도 넉넉해요 | even if you put it all in, there is plenty of room | 넉넉하다 means ample. |
| C.iphone.5.h | [5,000]개의 컷링 | [5,000] cutlings | The app's own count pattern ("8개의 컷링" on the grid); chip on the number. |
| C.iphone.5.s | 전에는 100개였고, 컷링 하나에 이메일 한 통이 통째로 들어가요. | Before, it was 100, and a whole email fits in one cutling. | 통째로 means whole, in one piece. |
| C.iphone.6.k | iPhone, iPad, Mac 모두 | iPhone, iPad, Mac, all of them | Device names in Latin letters, as the Korean listing writes Mac. |
| C.iphone.6.h | 결제는 [한 번]만 | payment, only [once] | Chip on 한 번 ("once"). |
| C.iphone.6.s | 그 한 번으로 세 기기에서 다 쓰고, 가입도 구독도 필요 없어요. | With that one time you use it on all three devices, and you need neither a sign-up nor a subscription. | 그 한 번 points back to the chip instead of saying "one purchase" again; 가입 (sign-up) is the Korean word for creating an account. |
| C.mac.1.k | 한 번 써 두면 누구에게나 | once you have written it, for anyone | Verbless headline phrasing. |
| C.mac.1.s | {cmd}로 답장을 고르면 붙여넣기 전에 간단한 창이 빈칸을 물어봐요. | When you pick the reply with ⌘⇧V, a simple window asks for the blanks before pasting. | 로 because the keys end on V, read 브이, a vowel. |
| C.mac.2.k | 어디서 입력하든 | wherever you type | |
| C.mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief. |
| C.mac.2.s | 컷링과 최근에 복사한 내용이 바로 그 자리에 열려요. | Your cutlings and what you copied recently open right there, in that spot. | 바로 그 자리에 ("right in that spot") says "over the app you are in" without repeating the kicker's 어디서. |
| C.mac.3.k | 클립보드 기록에 남지 않는 것 | the thing that does not stay in the clipboard history | Korean puts the object before the verb, so the kicker names "what is not kept" and the dots below are that thing; 클립보드 기록 is the app's name for the history. |
| C.mac.3.s | 암호 관리자가 숨김으로 표시한 내용은 기록에 아예 들어가지 않아요. | What a password manager marks as hidden does not get into the history at all. | 암호 관리자 and 숨김 are the app's own words for this setting. |
| C.mac.4.k | Mac에서 고친 내용이 | what you edited on the Mac | Subject in the kicker, its predicate in the headline. |
| C.mac.4.h | [iPhone]에도 그대로 | on the [iPhone] too, just the same | Chip on iPhone; 에도 reads the same after any ending. |
| C.mac.4.s | 가입할 필요 없이 내 iCloud로 동기화돼요. | It syncs through my iCloud, with no need to sign up. | 내 iCloud ("my iCloud"), the way Korean apps say 내 정보. |
| C.mac.5.k | iPhone, iPad, Mac 모두 | iPhone, iPad, Mac, all of them | Same as iPhone 6. |
| C.mac.5.h | 결제는 [한 번]만 | payment, only [once] | Same as iPhone 6. |
| C.mac.5.s | 그 한 번으로 세 기기에서 다 쓰고, 가입도 구독도 필요 없어요. | With that one time you use it on all three devices, and you need neither a sign-up nor a subscription. | Same as iPhone 6. |

## Headlines the build makes from the seed

| Frame | Headline as rendered | Back-translation |
|---|---|---|
| iPhone 1 | [민지] 님, 주문하신 상품 [화요일]에 출발해요! | Minji-nim, the product you ordered sets off on Tuesday! |
| iPhone 2 | [지훈] 님, 주문하신 상품 [화요일]에 출발해요! | Jihun-nim, the product you ordered sets off on Tuesday! |
| iPhone 3 | [2026년 11월 23일]에 배송 완료됐어요. | It was delivered on November 23, 2026. |
| Mac 1 | [현우] 님, [프리미엄] 요금제는 [화요일]부터 시작돼요. | Hyunwoo-nim, the Premium plan starts from Tuesday. |

## Rendering

Korean breaks lines between words, and Chrome breaks it between any two syllables unless told otherwise. The build
kept words whole only in the headline, so sublines and the frame 3 card and bubble split words ("날|짜가", "없|어요",
"완료됐|어요"). `locale_css` in `fastlane/compose/creative/v2/build.py` now sets `word-break: keep-all` on the whole
Korean page. With it, every line on all 17 frames breaks at a space.
