//
//  FillInKinds.swift
//  Cutling
//
//  The fill-in picker's rows (the ranked kinds in docs/research/fill-ins-kinds/README.md and
//  docs/research/fill-ins-apple-apis.md section 10): what each is called, its symbol, a sample read now in
//  the person's locale, and what choosing it does. A kind the engine does not know yet has no action
//  and the picker marks it "Soon".
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import Foundation

struct FillInKind: Identifiable {
    enum Group: CaseIterable {
        case blanks, dates, contacts, places, calendar, clipboardText, device, mathOther

        var title: String {
            switch self {
            case .blanks: String(localized: "Filled In When Used")
            case .dates: String(localized: "Dates and Times")
            case .contacts: String(localized: "Me and Contacts")
            case .places: String(localized: "Places")
            case .calendar: String(localized: "Calendar")
            case .clipboardText: String(localized: "Clipboard and Text")
            case .device: String(localized: "Device")
            case .mathOther: String(localized: "Math and Other")
            }
        }
    }

    enum Action {
        /// Opens the editor on a new blank, then types it.
        case blank, choice
        /// Types this marked token at the cursor.
        case token(String)
    }

    let id: String
    let group: Group
    let icon: String
    let name: String
    let sample: String
    /// nil: not built yet.
    let action: Action?

    var isSoon: Bool { action == nil }

    /// Every row, with samples read at `now` in `locale`.
    static func all(now: Date = Date(), locale: Locale = .autoupdatingCurrent, timeZone: TimeZone = .autoupdatingCurrent) -> [FillInKind] {
        func stamp(_ body: String) -> String {
            let context = Placeholders.Context(values: nil, now: now, locale: locale, timeZone: timeZone, clipboard: nil)
            return Placeholders(Placeholders.marked(body), marked: true).render(context).text
        }
        func ready(_ id: String, _ group: Group, _ icon: String, _ name: String, _ sample: String, _ action: Action) -> FillInKind {
            FillInKind(id: id, group: group, icon: icon, name: name, sample: sample, action: action)
        }
        func soon(_ id: String, _ group: Group, _ icon: String, _ name: String, _ sample: String) -> FillInKind {
            FillInKind(id: id, group: group, icon: icon, name: name, sample: sample, action: nil)
        }
        var calendar = locale.calendar
        calendar.timeZone = timeZone
        let clock = DateFormatter()
        clock.locale = locale
        clock.timeZone = timeZone
        clock.timeStyle = .short
        clock.dateStyle = .none
        let spelled = NumberFormatter()
        spelled.locale = locale
        spelled.numberStyle = .spellOut
        let hour = calendar.component(.hour, from: now)
        let region = locale.region?.identifier
        let degrees = Measurement(value: 21, unit: UnitTemperature.celsius).formatted(.measurement(width: .narrow, usage: .weather).locale(locale))

        return [
            ready("blank", .blanks, "character.textbox", String(localized: "Ask Each Time"), String(localized: "Name"), .blank),
            ready("choice", .blanks, "filemenu.and.selection", String(localized: "Choice"), String(localized: "Plan ▾"), .choice),

            ready("date", .dates, "calendar", String(localized: "Today’s Date"), stamp("date"), .token(Placeholders.marked("date"))),
            ready("time", .dates, "clock", String(localized: "Time"), stamp("time"), .token(Placeholders.marked("time"))),
            ready("datetime", .dates, "calendar.badge.clock", String(localized: "Date and Time"), stamp("datetime"), .token(Placeholders.marked("datetime"))),
            ready("day", .dates, "calendar.day.timeline.leading", String(localized: "Weekday"), stamp("day"), .token(Placeholders.marked("day"))),
            ready("tomorrow", .dates, "calendar.badge.plus", String(localized: "Tomorrow"), stamp("date +1d"), .token(Placeholders.marked("date +1d"))),
            ready("yesterday", .dates, "calendar.badge.minus", String(localized: "Yesterday"), stamp("date -1d"), .token(Placeholders.marked("date -1d"))),
            ready("nextWeek", .dates, "calendar", String(localized: "In a Week"), stamp("date +1w"), .token(Placeholders.marked("date +1w"))),
            soon("timeZone", .dates, "globe", String(localized: "Time Zone"), timeZone.localizedName(for: .standard, locale: locale) ?? timeZone.identifier),
            soon("weekNumber", .dates, "number", String(localized: "Week Number"), String(calendar.component(.weekOfYear, from: now))),
            soon("greeting", .dates, "sun.horizon", String(localized: "Greeting by Hour"), hour < 12 ? String(localized: "Good morning") : hour < 18 ? String(localized: "Good afternoon") : String(localized: "Good evening")),

            soon("myName", .contacts, "person.crop.circle", String(localized: "My Name"), String(localized: "Your name")),
            soon("myEmail", .contacts, "envelope", String(localized: "My Email"), String(localized: "Your email")),
            soon("myPhone", .contacts, "phone", String(localized: "My Phone"), String(localized: "Your number")),
            soon("myAddress", .contacts, "house", String(localized: "My Address"), String(localized: "Your address")),
            soon("person", .contacts, "person.2", String(localized: "Saved Person"), String(localized: "A contact you chose")),

            soon("city", .places, "mappin.and.ellipse", String(localized: "City"), String(localized: "Where you are")),
            soon("weather", .places, "cloud.sun", String(localized: "Weather Now"), degrees),
            soon("sunset", .places, "sunset", String(localized: "Sunset"), clock.string(from: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now)),

            soon("nextEvent", .calendar, "calendar.badge.exclamationmark", String(localized: "Next Event"), clock.string(from: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now) ?? now)),
            soon("freeSlots", .calendar, "clock.badge.checkmark", String(localized: "Free Time Slots"), clock.string(from: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now) ?? now)),
            soon("agenda", .calendar, "list.bullet.rectangle", String(localized: "Today’s Agenda"), String(localized: "Your events")),
            soon("reminders", .calendar, "checklist", String(localized: "Reminders Due"), String(localized: "Your reminders")),

            ready("clipboard", .clipboardText, "doc.on.clipboard", String(localized: "Clipboard Text"), String(localized: "What you copied"), .token(Placeholders.marked("clipboard"))),
            ready("cursor", .clipboardText, "text.cursor", String(localized: "Cursor Position"), String(localized: "Where typing ends"), .token(Placeholders.marked("cursor"))),
            soon("selection", .clipboardText, "text.badge.checkmark", String(localized: "Selected Text"), String(localized: "Text you selected")),
            soon("clipboardLink", .clipboardText, "link", String(localized: "Link on Clipboard"), "https://"),
            soon("clipboardEmail", .clipboardText, "at", String(localized: "Email on Clipboard"), "name@example.com"),

            soon("language", .device, "character.bubble", String(localized: "Language"), locale.localizedString(forLanguageCode: locale.language.languageCode?.identifier ?? "") ?? ""),
            soon("country", .device, "flag", String(localized: "Country"), region.flatMap { locale.localizedString(forRegionCode: $0) } ?? ""),
            soon("currency", .device, "coloncurrencysign.circle", String(localized: "Currency"), locale.currency?.identifier ?? ""),

            soon("words", .mathOther, "textformat.123", String(localized: "Number in Words"), spelled.string(from: 42) ?? "42"),
            soon("counter", .mathOther, "plus.forwardslash.minus", String(localized: "Counter"), "INV-0042"),
            soon("shortcut", .mathOther, "square.stack.3d.up", String(localized: "Value from a Shortcut"), String(localized: "A shortcut’s result")),
        ]
    }
}
