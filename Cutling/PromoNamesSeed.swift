//
//  PromoNamesSeed.swift
//  Cutling
//
//  The seed of the Five names and Five taps films (`-PROMO_NAMES`, `-PROMO_LANG en|ja`): a small shop's six replies, and
//  the names the Name blank has been used with before. `-PROMO_NAMES_KIND taps` seeds the restaurant's replies of
//  Five taps instead; `-PROMO_NAMES_HISTORY a,b,c` is the Name blank's saved values, newest first, none when absent,
//  so the fill-in asks for the first name. Words: undirect docs/plans/app-store-growth/social/cutling-ja/copy-ja.json,
//  posts 3_five_names and 4_five_taps.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import Foundation

private struct PromoNamesCopy {
    typealias Reply = (name: String, value: String, icon: String, color: String)
    let blank: String
    let names: [Reply]
    let taps: [Reply]

    static func forLanguage(_ language: String) -> PromoNamesCopy { language == "ja" ? japanese : english }

    private static let english = PromoNamesCopy(
        blank: "Name",
        names: [
            ("Order update", "Hi {\u{2060}Name}, your order ships Friday.", "shippingbox.fill", "teal"),
            ("Home address", "14 Linden Road, Flat 3", "house.fill", "blue"),
            ("Bank details", "Account 0441 2290 18", "banknote.fill", "green"),
            ("Booking", "Your table is booked. See you then!", "calendar", "orange"),
            ("Wi-Fi", "studio-guest · fern2291", "wifi", "cyan"),
            ("Thank you", "Thank you so much for your order!", "sparkles", "pink"),
        ],
        taps: [
            ("Hello", "Good evening, {\u{2060}Name}!\n\n", "hand.wave.fill", "yellow"),
            ("Booking", "Your table for {\u{2060}Guests: 2 | 4 | 6} is booked for Saturday at 7:30. We’re upstairs from the flower shop on the corner; ring 4 at the green door and we’ll buzz you in.\n\n", "fork.knife", "orange"),
            ("Sign-off", "{\u{2060}cursor}See you then!\nSam", "sparkles", "pink"),
            ("Directions", "Upstairs from the flower shop on the corner; ring 4 at the green door.", "mappin.and.ellipse", "cyan"),
            ("Menu", "Tonight: the autumn menu, five courses, with a vegetarian option.", "doc.text.fill", "purple"),
            ("Allergies", "Tell us about any allergies and we’ll plan around them.", "exclamationmark.circle.fill", "green"),
        ]
    )

    private static let japanese = PromoNamesCopy(
        blank: "名前",
        names: [
            ("発送連絡", "{\u{2060}名前}様、ご注文の品は金曜日に発送いたします。", "shippingbox.fill", "teal"),
            ("自宅の住所", "東京都練馬区豊玉北4-21-6 203", "house.fill", "blue"),
            ("口座番号", "3058162", "banknote.fill", "green"),
            ("ご予約確定", "ご予約を承りました。当日を楽しみにお待ちしております。", "calendar", "orange"),
            ("教室の Wi-Fi", "tougei-guest / kama2580", "wifi", "cyan"),
            ("お礼", "お買い上げありがとうございました。", "sparkles", "pink"),
        ],
        taps: [
            ("あいさつ", "{\u{2060}名前}様、こんばんは。ご連絡ありがとうございます。\n\n", "hand.wave.fill", "yellow"),
            ("予約OK", "土曜日19:30より、{\u{2060}人数: 2名様 | 4名様 | 6名様}のお席をご用意いたしました。お店は角のお花屋さんの2階です。緑のドアのインターホンを押していただければ、下までお迎えにまいります。\n\n", "fork.knife", "orange"),
            ("しめの挨拶", "{\u{2060}cursor}それでは、当日お待ちしております。\n小料理つむぎ\u{3000}森田", "sparkles", "pink"),
            ("道案内", "駅の東口から歩いて3分、角のお花屋さんの2階です。", "mappin.and.ellipse", "cyan"),
            ("今夜の献立", "今夜は、旬の鰆の西京焼きと季節の小鉢をご用意しています。", "doc.text.fill", "purple"),
            ("アレルギー", "苦手な食材やアレルギーがあれば、お知らせください。", "exclamationmark.circle.fill", "green"),
        ]
    )
}

extension CutlingStore {
    func seedForNamesFilm() {
        let defaults = UserDefaults.standard
        let copy = PromoNamesCopy.forLanguage(defaults.string(forKey: "PROMO_LANG") ?? "en")
        for filename in cutlings.compactMap(\.imageFilename) { deleteImageFile(named: filename) }
        let replies = defaults.string(forKey: "PROMO_NAMES_KIND") == "taps" ? copy.taps : copy.names
        cutlings = replies.enumerated().map { index, reply in
            Cutling(name: reply.name, value: reply.value, icon: reply.icon, sortOrder: index, color: reply.color)
        }
        save()
        let group = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        let history = (defaults.string(forKey: "PROMO_NAMES_HISTORY") ?? "").split(separator: ",").map(String.init)
        if history.isEmpty { group?.removeObject(forKey: FillInMemory.defaultsKey) }
        else { group?.set([Placeholders.Field.key(copy.blank): history], forKey: FillInMemory.defaultsKey) }
        group?.removeObject(forKey: "keyboardFillSession")
    }
}
