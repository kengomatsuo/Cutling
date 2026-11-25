//
//  SnapshotSeedData.swift
//  Cutling
//
//  Provides visually appealing sample data for App Store screenshots.
//  Only loaded when the app is launched with -SNAPSHOT_MODE.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import Foundation

#if DEBUG
#if os(iOS)
import UIKit
#endif

/// What a promo take's cutlings say in one language. All of it is invented.
private struct PromoSeedCopy {
    typealias Entry = (name: String, value: String)
    let bank, address, notes, deploy, email, signature, wifi, bio, phone, booking, link: Entry
    let history: [String]

    static func forLanguage(_ language: String) -> PromoSeedCopy {
        switch language {
        case "id": indonesian
        case "ja": japanese
        default: english
        }
    }

    private static let english = PromoSeedCopy(
        bank: ("Bank Account", "IBAN: DE89 3704 0044 0532 0130 00"),
        address: ("Home Address", "123 Main Street, Apt 4B\nNew York, NY 10001"),
        notes: ("Meeting Notes", "**Agenda** for Friday, see [the brief](https://example.com/brief)"),
        deploy: ("Deploy", "git push origin main"),
        email: ("Work Email", "alex@example.com"),
        signature: ("Signature", "Best regards,\nAlex Chen\nalex@example.com"),
        wifi: ("Wi-Fi Password", "c0ff33-Sh0p-2024!"),
        bio: ("Social Bio", "Designer & developer. Building things that make life simpler."),
        phone: ("Phone Number", "+1 (555) 234-5678"),
        booking: ("Booking Ref", "FLT-2026-XKCD42"),
        link: ("Meeting Link", "https://meet.example.com/alex-weekly"),
        history: ["1Z 999 AA1 01 2345 6784", "+1 (555) 014-2233", "alex@example.com", "https://example.com/brief", "DE89 3704 0044 0532 0130 00"]
    )

    private static let indonesian = PromoSeedCopy(
        bank: ("Rekening BCA", "BCA 1234567890 a.n. Rangga Wirawan"),
        address: ("Alamat Rumah", "Jl. Flamboyan Asri II No. 17, RT 05/RW 08\nRawamangun, Jakarta Timur 13220"),
        notes: ("Catatan Rapat", "**Agenda** rapat Jumat, cek [briefnya di sini](https://example.com/brief)"),
        deploy: ("Deploy", "git push origin main"),
        email: ("Email Kerja", "rangga@example.com"),
        signature: ("Tanda Tangan", "Salam,\nRangga Wirawan\nrangga@example.com"),
        wifi: ("Password Wi-Fi", "k0pi-Senja-2024!"),
        bio: ("Bio", "Desainer yang doyan ngopi dan bikin hal-hal jadi lebih simpel."),
        phone: ("Nomor HP", "0812-0000-0000"),
        booking: ("Kode Booking", "FLT-2026-XKCD42"),
        link: ("Link Meeting", "https://meet.example.com/rangga-mingguan"),
        history: ["JNE 0000 1234 5678", "0812-0000-0000", "rangga@example.com", "https://example.com/brief", "BCA 1234567890"]
    )

    private static let japanese = PromoSeedCopy(
        bank: ("振込先", "三菱UFJ銀行 渋谷支店\n普通 1234567 タナカ タロウ"),
        address: ("住所", "〒154-0015 東京都世田谷区桜新町9-12-3\nメゾンひなた 305号室"),
        notes: ("議事メモ", "**金曜の議題**は[こちらの資料](https://example.com/brief)をご確認ください"),
        deploy: ("デプロイ", "git push origin main"),
        email: ("仕事のメール", "taro@example.com"),
        signature: ("署名", "よろしくお願いいたします。\n田中 太郎\ntaro@example.com"),
        wifi: ("Wi-Fiパスワード", "k0ban-Cafe-2024!"),
        bio: ("自己紹介", "デザイナー。暮らしをシンプルにするものを作っています。"),
        phone: ("電話番号", "090-0000-0000"),
        booking: ("予約番号", "FLT-2026-XKCD42"),
        link: ("会議リンク", "https://meet.example.com/tanaka-weekly"),
        history: ["ヤマト 0000-1234-5678", "090-0000-0000", "taro@example.com", "https://example.com/brief", "〒154-0015 東京都世田谷区桜新町9-12-3"]
    )
}

/// The "Every app" preview's keys (docs/aso/previews-2.0/directions.md, G) in one language, in the keyboard's order.
/// The order update's blank and weekday are inserted with Cutling's marker, as the editor's Variables insert them.
private struct EveryAppSeedCopy {
    typealias Entry = (name: String, value: String)
    let home, order, account, studio, thanks: Entry
    let sizeChart: String
    /// The order reply's blank, as the editor's Ask Each Time names it in the language.
    let blank: String
    /// The Name blank's recent values, newest first: the fill-in screen's choices.
    let names: [String]

    static func forLanguage(_ language: String) -> EveryAppSeedCopy {
        switch language {
        case "id": indonesian
        case "ja": japanese
        default: english
        }
    }

    private static let english = EveryAppSeedCopy(
        home: ("Home address", "14 Linden Road, Flat 3"),
        order: ("Order update", "Hi {\u{2060}Name}, your order ships {\u{2060}day +1d}."),
        account: ("Account number", "0441 2290 18"),
        studio: ("Studio address", "22 Mill Lane, Studio 4"),
        thanks: ("Thank you", "Thank you so much for your order!"),
        sizeChart: "Size chart",
        blank: "Name",
        names: ["Maya", "Jonas", "Aiko", "Sam", "Lea"]
    )

    // Written blind from directions.md's meanings: docs/aso/previews-2.0/g-words.json.
    private static let indonesian = EveryAppSeedCopy(
        home: ("Alamat rumah", "Jl. Kenanga Blok C2 No. 5, Depok"),
        order: ("Jadwal kirim", "Kak {\u{2060}Nama}, paketnya kami kirim {\u{2060}day +1d} ya."),
        account: ("No. rekening", "5270183946"),
        studio: ("Studio keramik", "Jl. Cempaka No. 21, Lt. 2, Depok"),
        thanks: ("Terima kasih", "Terima kasih sudah belanja, Kak!"),
        sizeChart: "Tabel ukuran",
        blank: "Nama",
        names: ["Rina", "Dimas", "Sari", "Yoga", "Fitri"]
    )

    /// The order reply ends with a line break: the keyboard puts a space between two cutlings typed in a row, which after
    /// 「。」 reads as a typo, and none after a line break, so the thanks starts its own line as Japanese shop messages do.
    private static let japanese = EveryAppSeedCopy(
        home: ("自宅の住所", "東京都練馬区豊玉北4-21-6 203"),
        order: ("発送連絡", "{\u{2060}名前}様、ご注文の品は{\u{2060}day +1d}に発送いたします。\n"),
        account: ("口座番号", "3058162"),
        studio: ("教室の住所", "東京都三鷹市下連雀3-25-9 2階"),
        thanks: ("お礼", "お買い上げありがとうございました。"),
        sizeChart: "サイズ表",
        blank: "名前",
        names: ["中村", "小林", "松本", "岡田", "原田"]
    )
}

/// The 2.0 release film's keys (cutling-promo storyboard/release-2.0.md) in one language, in the keyboard's order.
/// PromoReleaseUITests types the welcome note's words on camera, so they are kept in step with `welcome` there.
private struct ReleaseSeedCopy {
    typealias Entry = (name: String, value: String)
    typealias Reply = (name: String, value: String, icon: String, color: String)
    let order, delivery, welcome, home, account, thanks: Entry
    /// The order reply's blank, as the editor's Ask Each Time names it in the language.
    let blank: String
    /// The Name blank's recent values, newest first: the fill-in screen's choices.
    let names: [String]
    /// The plain replies that fill the grid up to `-PROMO_ROOM`.
    let room: [Reply]

    static func forLanguage(_ language: String) -> ReleaseSeedCopy {
        language == "ja" ? japanese : english
    }

    private static let english = ReleaseSeedCopy(
        order: ("Order update", "Hi {\u{2060}Name}, your order ships {\u{2060}day +1d}."),
        delivery: ("Delivery note", "Delivered on {\u{2060}date:long}."),
        welcome: ("Welcome note", "**Welcome to the studio!**\nEverything for your first visit:\n• Door code ^[4815](highlight: true)\n• Wi-Fi: studio-guest\n• Parking behind the bakery"),
        home: ("Home address", "14 Linden Road, Flat 3"),
        account: ("Account number", "0441 2290 18"),
        thanks: ("Thank you", "Thank you so much for your order!"),
        blank: "Name",
        names: ["Maya", "Jonas", "Aiko", "Sam", "Lea"],
        room: [
            ("Opening hours", "We're open Tuesday to Saturday, 10 to 6.", "clock.fill", "indigo"),
            ("Returns", "You can return anything within 30 days, no questions asked.", "arrow.uturn.backward", "red"),
            ("Shipping times", "Orders placed before 2 pm ship the same day.", "shippingbox.fill", "teal"),
            ("Gift wrap", "Yes, we gift wrap for free. Just tell us at checkout.", "gift.fill", "pink"),
            ("Size guide", "Our sizes run true. If you're between two, take the larger.", "ruler.fill", "brown"),
            ("Out of stock", "That one sold out, and it's back in about two weeks.", "tray.fill", "orange"),
            ("Directions", "Upstairs from the flower shop on the corner; ring 4 at the green door.", "map.fill", "green"),
            ("Booking", "Your table is booked. See you then!", "calendar", "orange"),
            ("Invoice", "Your invoice is attached. Payment is due within 14 days.", "doc.text.fill", "blue"),
            ("Follow-up", "Just checking in: did everything arrive as expected?", "bubble.left.fill", "purple"),
            ("Wi-Fi", "Network: studio-guest", "wifi", "cyan"),
            ("Sign-off", "Thanks again, and have a lovely week!", "hand.wave.fill", "yellow"),
        ]
    )

    // The designer's strings: undirect docs/plans/app-store-growth/social/cutling-ja/copy-ja.json, post 2_release_2_0, seed.
    private static let japanese = ReleaseSeedCopy(
        order: ("発送連絡", "{\u{2060}名前}様、ご注文の品は{\u{2060}day +1d}に発送いたします。\n"),
        delivery: ("発送完了", "ご注文の品を{\u{2060}date:M月d日}に発送いたしました。"),
        welcome: ("初回のご案内", "**陶芸教室へようこそ！**\nお越しの際は、以下をご確認ください。\n• 入口の暗証番号は ^[4815](highlight: true)\n• Wi-Fi は tougei-guest\n• 駐車場は隣のパン屋さんの裏"),
        home: ("自宅の住所", "東京都練馬区豊玉北4-21-6 203"),
        account: ("口座番号", "3058162"),
        thanks: ("お礼", "お買い上げありがとうございました。"),
        blank: "名前",
        names: ["中村", "小林", "松本", "岡田", "原田"],
        room: [
            ("営業時間", "営業は火曜〜土曜、10時〜18時です。", "clock.fill", "indigo"),
            ("返品について", "商品到着後30日以内であれば、返品を承ります。", "arrow.uturn.backward", "red"),
            ("発送の目安", "ご注文から2営業日以内に発送いたします。", "shippingbox.fill", "teal"),
            ("ギフトラッピング", "ギフトラッピングは無料で承ります。ご注文時にお申し付けください。", "gift.fill", "pink"),
            ("サイズについて", "普段のサイズでお選びください。迷われた場合はワンサイズ上がおすすめです。", "ruler.fill", "brown"),
            ("品切れ", "あいにく品切れ中です。2週間ほどで再入荷の予定です。", "tray.fill", "orange"),
            ("教室への道順", "角の花屋さんの上、2階です。緑の扉が目印です。", "map.fill", "green"),
            ("ご予約確定", "ご予約を承りました。当日を楽しみにお待ちしております。", "calendar", "orange"),
            ("請求書の送付", "請求書を添付いたしましたので、ご確認ください。お支払いは発行日より14日以内にお願いいたします。", "doc.text.fill", "blue"),
            ("到着の確認", "商品は無事にお手元に届きましたでしょうか。", "bubble.left.fill", "purple"),
            ("教室の Wi-Fi", "tougei-guest / kama2580", "wifi", "cyan"),
            ("結びのあいさつ", "末永くお使いいただけますように。またのご利用をお待ちしております。", "hand.wave.fill", "yellow"),
        ]
    )
}

extension CutlingStore {
    /// The "Every app" preview's seed (`-PROMO_EVERY`), in `-PROMO_LANG id|en|ja`: six keys, the size chart an image,
    /// and the Name blank's recent values. No input-type triggers, so the keyboard shows the same keys in every app.
    func seedForEveryApp() {
        let language = UserDefaults.standard.string(forKey: "PROMO_LANG") ?? "en"
        let copy = EveryAppSeedCopy.forLanguage(language)
        for filename in cutlings.compactMap(\.imageFilename) { deleteImageFile(named: filename) }
        var seeded = [
            Cutling(name: copy.home.name, value: copy.home.value, icon: "house.fill", sortOrder: 0, color: "blue"),
            Cutling(name: copy.order.name, value: copy.order.value, icon: "shippingbox.fill", sortOrder: 1, color: "teal"),
            Cutling(name: copy.account.name, value: copy.account.value, icon: "banknote.fill", sortOrder: 2, color: "green"),
            Cutling(name: copy.studio.name, value: copy.studio.value, icon: "mappin.and.ellipse", sortOrder: 3, color: "orange"),
        ]
        #if os(iOS)
        let id = UUID()
        if let filename = Self.sizeChartImage().flatMap({ saveImageData($0, for: id) }) {
            seeded.append(Cutling(id: id, name: copy.sizeChart, value: "", icon: "photo", kind: .image, imageFilename: filename,
                                  sortOrder: 4, color: "purple"))
        }
        #endif
        seeded.append(Cutling(name: copy.thanks.name, value: copy.thanks.value, icon: "sparkles", sortOrder: seeded.count, color: "pink"))
        cutlings = seeded
        save()
        let group = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        group?.set([Placeholders.Field.key(copy.blank): copy.names], forKey: FillInMemory.defaultsKey)
        group?.removeObject(forKey: "keyboardFillSession")
    }

    /// The 2.0 release film's seed (`-PROMO_RELEASE`), in `-PROMO_LANG en|ja`: six keys, one with a date that fills itself in
    /// and one written like a note, and the Name blank's recent values. `-PROMO_ROOM n` adds plain replies up to n text
    /// cutlings, for the take that shows the grid's own count.
    func seedForReleaseFilm() {
        let language = UserDefaults.standard.string(forKey: "PROMO_LANG") ?? "en"
        let copy = ReleaseSeedCopy.forLanguage(language)
        for filename in cutlings.compactMap(\.imageFilename) { deleteImageFile(named: filename) }
        var seeded = [
            Cutling(name: copy.order.name, value: copy.order.value, icon: "shippingbox.fill", sortOrder: 0, color: "teal"),
            Cutling(name: copy.delivery.name, value: copy.delivery.value, icon: "calendar", sortOrder: 1, color: "orange"),
            Cutling(name: copy.welcome.name, value: copy.welcome.value, icon: "textformat", sortOrder: 2, color: "purple", format: .rich),
            Cutling(name: copy.home.name, value: copy.home.value, icon: "house.fill", sortOrder: 3, color: "blue"),
            Cutling(name: copy.account.name, value: copy.account.value, icon: "banknote.fill", sortOrder: 4, color: "green"),
            Cutling(name: copy.thanks.name, value: copy.thanks.value, icon: "sparkles", sortOrder: 5, color: "pink"),
        ]
        let room = UserDefaults.standard.integer(forKey: "PROMO_ROOM")
        if room > seeded.count {
            for index in seeded.count..<room {
                let reply = copy.room[index % copy.room.count]
                seeded.append(Cutling(name: reply.name, value: reply.value, icon: reply.icon, sortOrder: index, color: reply.color))
            }
        }
        cutlings = seeded
        save()
        let group = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        // `-PROMO_NO_RECENT`: no name used before, so the fill-in asks for the first one.
        if ProcessInfo.processInfo.arguments.contains("-PROMO_NO_RECENT") { group?.removeObject(forKey: FillInMemory.defaultsKey) }
        else { group?.set([Placeholders.Field.key(copy.blank): copy.names], forKey: FillInMemory.defaultsKey) }
        group?.removeObject(forKey: "keyboardFillSession")
        // `-PROMO_TODAY yyyy-MM-dd`: the day the film's post goes out, which the date stamps type (FillInClock).
        if let today = UserDefaults.standard.string(forKey: "PROMO_TODAY") { group?.set(today, forKey: "promoToday") } else { group?.removeObject(forKey: "promoToday") }
    }

    #if os(iOS)
    /// A clothing size chart as a shop would send it: sizes and centimetres only, so it reads in every language.
    private static func sizeChartImage() -> Data? {
        let rows = [["", "S", "M", "L", "XL"], ["cm", "88", "96", "104", "112"], ["", "66", "68", "70", "72"]]
        let size = CGSize(width: 900, height: 600)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor(red: 0.96, green: 0.93, blue: 0.88, alpha: 1).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            let ink = UIColor(red: 0.16, green: 0.14, blue: 0.12, alpha: 1)
            // A T-shirt outline above the table.
            let shirt = UIBezierPath()
            for (x, y) in [(370, 40), (330, 60), (290, 110), (330, 140), (355, 120), (355, 230), (545, 230), (545, 120), (570, 140),
                           (610, 110), (570, 60), (530, 40), (500, 60), (400, 60)] {
                shirt.isEmpty ? shirt.move(to: CGPoint(x: x, y: y)) : shirt.addLine(to: CGPoint(x: x, y: y))
            }
            shirt.close()
            UIColor(red: 0.16, green: 0.55, blue: 0.47, alpha: 1).setFill()
            shirt.fill()
            for (row, cells) in rows.enumerated() {
                for (column, text) in cells.enumerated() {
                    let bold = row == 0 || column == 0
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 56, weight: bold ? .bold : .regular), .foregroundColor: ink,
                    ]
                    let box = CGRect(x: 60 + column * 160, y: 280 + row * 100, width: 160, height: 100)
                    let measured = (text as NSString).size(withAttributes: attributes)
                    (text as NSString).draw(at: CGPoint(x: box.midX - measured.width / 2, y: box.midY - measured.height / 2), withAttributes: attributes)
                }
            }
            ink.withAlphaComponent(0.25).setFill()
            context.fill(CGRect(x: 60, y: 378, width: 800, height: 3))
        }
        return image.pngData()
    }
    #endif

    /// One cutling per format, for FormattingUITests.
    func seedForFormatTests() {
        cutlings = [
            Cutling(name: "Rich", value: "**Bold** and [link](https://example.com)", icon: "textformat", sortOrder: 0, format: .rich),
            Cutling(name: "Code", value: "print(\"a_b\")", icon: "chevron.left.forwardslash.chevron.right", sortOrder: 1, format: .code),
            Cutling(name: "Plain", value: "Hello", icon: "document", sortOrder: 2),
            // Saved before formats existed: no stored format, detected as code.
            Cutling(name: "Legacy", value: "def greet():\n    return \"hi\"", icon: "document", sortOrder: 3),
            // Styles where a key's two lines and a card's preview cut them off.
            Cutling(name: "Hours", value: "^[Please note:](highlight: true) our ^[office hours](underline: true) change next week, and **every** booking made before Friday keeps its ^[original time](underline: true, highlight: true).", icon: "clock", sortOrder: 4, format: .rich),
            Cutling(name: "Shopping", value: "• Milk\n• ^[Eggs](highlight: true)\n• **Bread**\n• Butter", icon: "cart", sortOrder: 5, format: .rich),
            Cutling(name: "Steps", value: "1. Open ^[Settings](underline: true)\n2. Tap Keyboards\n3. Turn on Cutling", icon: "list.number", sortOrder: 6, format: .rich),
            // Underlined across the 400th character, where previews stop laying out text.
            Cutling(name: "Long", value: String(repeating: "word ", count: 76) + "^[an underlined phrase](underline: true) and **bold words** then ^[a highlight](highlight: true)", icon: "text.alignleft", sortOrder: 7, format: .rich),
        ]
        save()
    }

    /// Fill-in tests: a cutling with a typed blank, a choice, a date stamp and the cursor spot,
    /// and one with only a stamp. Saved values and any half-typed keyboard session are cleared.
    func seedForFillInTests() {
        cutlings = [
            // Fill-ins as the editor's menu inserts them: each brace carries Placeholders.marker.
            Cutling(name: "Reply", value: "Hi {\u{2060}Name}, your {\u{2060}Plan: Basic | Pro} order ships {\u{2060}date:yyyy-MM-dd}.{\u{2060}cursor} Thanks!", icon: "envelope", sortOrder: 0),
            Cutling(name: "Stamp", value: "Today: {\u{2060}date:yyyy-MM-dd}", icon: "calendar", sortOrder: 1),
            // Long enough that the keyboard's bar and the card previews must trim around a blank.
            Cutling(name: "Order", value: "Thanks for ordering the espresso machine with the milk frother and the travel case, {\u{2060}Customer}. It ships on {\u{2060}date:long} from our warehouse with tracking, {\u{2060}Plan: Basic | Pro} support included.", icon: "shippingbox", sortOrder: 2),
        ]
        save()
        let group = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        group?.removeObject(forKey: FillInMemory.defaultsKey)
        group?.removeObject(forKey: "keyboardFillSession")
        // `-FILLIN_OFF` leaves the switch off, to check that shipped builds type braces as written.
        group?.set(ProcessInfo.processInfo.arguments.contains("-FILLIN_OFF"), forKey: FillIns.offKey)
    }

    /// A promo take's seed, in the language its viewer reads: `-PROMO_LANG id|en|ja`.
    /// `-PROMO_WITHOUT_BANK` leaves the bank card out and keeps the grid short, for the take that saves it.
    /// `-PROMO_CLIP` puts the bank text on the clipboard, written by this app so
    /// "Paste from Clipboard" raises no paste prompt on camera.
    /// Every name, number and address is made up.
    func seedForPromo() {
        let defaults = UserDefaults.standard
        let language = defaults.string(forKey: "PROMO_LANG") ?? Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
        let copy = PromoSeedCopy.forLanguage(language)
        let arguments = ProcessInfo.processInfo.arguments
        var seeded = [
            Cutling(name: copy.bank.name, value: copy.bank.value, icon: "banknote.fill", kind: .text, sortOrder: 0, color: "green"),
            Cutling(name: copy.address.name, value: copy.address.value, icon: "house.fill", kind: .text, sortOrder: 1, color: "blue", inputTypeTriggers: ["content:streetAddressLine1", "content:postalCode"]),
            Cutling(name: copy.notes.name, value: copy.notes.value, icon: "textformat", sortOrder: 2, color: "yellow", format: .rich),
            Cutling(name: copy.deploy.name, value: copy.deploy.value, icon: "chevron.left.forwardslash.chevron.right", sortOrder: 3, color: "brown", format: .code),
            Cutling(name: copy.email.name, value: copy.email.value, icon: "at", sortOrder: 4, color: "cyan", inputTypeTriggers: ["content:emailAddress", "keyboard:emailAddress"]),
            Cutling(name: copy.signature.name, value: copy.signature.value, icon: "envelope.fill", kind: .text, sortOrder: 5, color: "purple", inputTypeTriggers: ["content:emailAddress"]),
            Cutling(name: copy.wifi.name, value: copy.wifi.value, icon: "wifi", kind: .text, sortOrder: 6, color: "orange"),
            Cutling(name: copy.bio.name, value: copy.bio.value, icon: "person.crop.circle.fill", kind: .text, sortOrder: 7, color: "pink"),
            Cutling(name: copy.phone.name, value: copy.phone.value, icon: "phone.fill", kind: .text, sortOrder: 8, color: "teal", inputTypeTriggers: ["content:telephoneNumber"]),
            Cutling(name: copy.booking.name, value: copy.booking.value, icon: "airplane", kind: .text, sortOrder: 9, color: "indigo"),
            Cutling(name: copy.link.name, value: copy.link.value, icon: "video.fill", kind: .text, sortOrder: 10, color: "red", inputTypeTriggers: ["content:URL"])
        ]
        if arguments.contains("-PROMO_WITHOUT_BANK") { seeded = Array(seeded.dropFirst().prefix(6)) }
        cutlings = seeded
        save()
        #if os(iOS)
        if arguments.contains("-PROMO_CLIP") { UIPasteboard.general.string = copy.bank.value }
        #endif
    }

    #if os(macOS)
    /// The Mac History tab of a promo take, in that take's language.
    func seedHistoryForPromo() {
        historyCutlings.removeAll()
        let language = UserDefaults.standard.string(forKey: "PROMO_LANG") ?? "en"
        for text in PromoSeedCopy.forLanguage(language).history { appendHistoryText(text) }
    }
    #endif

    /// Seeds the store with sample cutlings for screenshot automation.
    func seedForSnapshots() {
        // Clear any existing data first
        cutlings.removeAll()

        let samples: [Cutling] = [
            Cutling(
                name: String(localized: "Home Address", comment: "Snapshot seed data"),
                value: String(localized: "123 Main Street, Apt 4B\nNew York, NY 10001", comment: "Snapshot seed data"),
                icon: "house.fill",
                kind: .text,
                sortOrder: 0,
                color: "blue",
                inputTypeTriggers: ["content:streetAddressLine1", "content:postalCode"]
            ),
            Cutling(
                name: String(localized: "Email Signature", comment: "Snapshot seed data"),
                value: String(localized: "Best regards,\nAlex Chen\nalex@example.com", comment: "Snapshot seed data"),
                icon: "envelope.fill",
                kind: .text,
                sortOrder: 1,
                color: "purple",
                inputTypeTriggers: ["content:emailAddress"]
            ),
            Cutling(
                name: String(localized: "Bank Account", comment: "Snapshot seed data"),
                value: String(localized: "IBAN: DE89 3704 0044 0532 0130 00", comment: "Snapshot seed data"),
                icon: "banknote.fill",
                kind: .text,
                sortOrder: 2,
                color: "green"
            ),
            Cutling(
                name: String(localized: "Wi-Fi Password", comment: "Snapshot seed data"),
                value: "c0ff33-Sh0p-2024!",
                icon: "wifi",
                kind: .text,
                sortOrder: 3,
                color: "orange"
            ),
            Cutling(
                name: String(localized: "Social Bio", comment: "Snapshot seed data"),
                value: String(localized: "Designer & developer. Building things that make life simpler.", comment: "Snapshot seed data"),
                icon: "person.crop.circle.fill",
                kind: .text,
                sortOrder: 4,
                color: "pink"
            ),
            Cutling(
                name: String(localized: "Phone Number", comment: "Snapshot seed data"),
                value: "+1 (555) 234-5678",
                icon: "phone.fill",
                kind: .text,
                sortOrder: 5,
                color: "teal",
                inputTypeTriggers: ["content:telephoneNumber"]
            ),
            Cutling(
                name: String(localized: "Booking Ref", comment: "Snapshot seed data"),
                value: "FLT-2026-XKCD42",
                icon: "airplane",
                kind: .text,
                sortOrder: 6,
                color: "indigo"
            ),
            Cutling(
                name: String(localized: "Meeting Link", comment: "Snapshot seed data"),
                value: "https://meet.example.com/alex-weekly",
                icon: "video.fill",
                kind: .text,
                sortOrder: 7,
                color: "red",
                inputTypeTriggers: ["content:URL"]
            ),
        ]

        cutlings = samples
        save()
    }

    /// KeyboardMemoryUITests' worst case, past the caps on purpose:
    /// `-MEMTEST_IMAGES m` image cutlings, each a full-size 4032×3024 PNG as the editor saves a photo,
    /// then `-MEMTEST_TEXT n` text cutlings at the full `maxTextLength` in mixed scripts,
    /// a third each Plain, Formatted and Code. A store already holding those counts is kept.
    func seedForMemoryTest() {
        let defaults = UserDefaults.standard
        let textCount = defaults.integer(forKey: "MEMTEST_TEXT")
        let imageCount = defaults.integer(forKey: "MEMTEST_IMAGES")
        if textCutlingsCount == textCount, imageCutlingsCount == imageCount { return }
        for filename in cutlings.compactMap(\.imageFilename) {
            deleteImageFile(named: filename)
        }
        var seeded: [Cutling] = []
        #if os(iOS)
        // One photo is rendered and written; the rest are APFS clones of its file, which write no data,
        // so seeding takes seconds on a loaded Mac while every cutling still has its own full-size file.
        if imageCount > 0, let photo = Self.memoryTestPhoto() {
            var first: URL?
            for index in 0..<imageCount {
                let id = UUID()
                var filename: String?
                if let first {
                    let name = id.uuidString + ".png"
                    if (try? FileManager.default.copyItem(at: first, to: imagesDirectory.appendingPathComponent(name))) != nil {
                        filename = name
                    }
                } else {
                    filename = saveImageData(photo, for: id)
                    first = filename.map { imagesDirectory.appendingPathComponent($0) }
                }
                seeded.append(Cutling(
                    id: id, name: "Photo \(index + 1)", value: "", icon: "photo", kind: .image,
                    imageFilename: filename, sortOrder: seeded.count
                ))
            }
        }
        #endif
        let mixed = "Invoice 2026-118 for **Alex Chen**, see [terms](https://example.com/terms). "
            + "お振込みは月末までにお願いいたします。 Überweisung bis Monatsende 🙂 "
            + "func pay(_ amount: Int) -> Bool { amount > 0 } "
        let value = String(String(repeating: mixed, count: CutlingStore.maxTextLength / mixed.count + 1)
            .prefix(CutlingStore.maxTextLength))
        let formats: [TextFormat] = [.plain, .rich, .code]
        for index in 0..<textCount {
            seeded.append(Cutling(
                name: "Snippet \(index + 1)", value: value, icon: "doc.text",
                sortOrder: seeded.count, color: "blue", format: formats[index % formats.count]
            ))
        }
        cutlings = seeded
        save()
    }

    #if os(iOS)
    /// A 12-megapixel photo-like PNG: a gradient under a few thousand translucent circles.
    private static func memoryTestPhoto() -> Data? {
        let size = CGSize(width: 4032, height: 3024)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            let cg = context.cgContext
            let colors = [UIColor.systemTeal.cgColor, UIColor.systemOrange.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: nil) {
                cg.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            }
            var generator = SystemRandomNumberGenerator()
            for _ in 0..<3000 {
                let radius = CGFloat.random(in: 8...120, using: &generator)
                let center = CGPoint(x: .random(in: 0...size.width, using: &generator),
                                     y: .random(in: 0...size.height, using: &generator))
                UIColor(hue: .random(in: 0...1, using: &generator), saturation: 0.6, brightness: 0.9, alpha: 0.35).setFill()
                cg.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
            }
        }
        return image.pngData()
    }
    #endif

    #if os(macOS)
    /// Language-neutral clipboard history for the Mac History frame.
    func seedHistoryForSnapshots() {
        historyCutlings.removeAll()
        for text in [
            "1Z 999 AA1 01 2345 6784",
            "+1 (555) 014-2233",
            "alex@example.com",
            "https://cutling.matsuokengo.com",
            "DE89 3704 0044 0532 0130 00",
        ] {
            appendHistoryText(text)
        }
    }
    #endif
}

#endif
