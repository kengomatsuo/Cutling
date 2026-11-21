import Foundation
var fails = 0
func check<T: Equatable>(_ name: String, _ got: T, _ want: T) {
    if got == want { print("ok  ", name) } else { fails += 1; print("FAIL", name, "\n   got: \(got)\n  want: \(want)") }
}

// 2026-11-20 14:05 UTC, a Friday
let now = Date(timeIntervalSince1970: 1_795_183_500)
var ctx = Placeholders.Context(values: [:], now: now, locale: Locale(identifier: "en_US"), timeZone: TimeZone(identifier: "UTC")!)
/// Foundation puts a narrow no-break space before AM/PM; tests compare with a plain one.
func render(_ s: String, _ c: Placeholders.Context = ctx, markdown: Bool = false) -> String {
    Placeholders(s, markdown: markdown).render(c).text.replacingOccurrences(of: "\u{202F}", with: " ")
}

// Date stamps
check("date", render("Today is {date}."), "Today is Nov 20, 2026.")
check("date short", render("{date:short}"), "11/20/26")
check("date long", render("{date:long}"), "November 20, 2026")
check("date pattern", render("{date:yyyy-MM-dd}"), "2026-11-20")
check("time", render("{time}"), "2:05 PM")
check("datetime", render("{datetime}"), "Nov 20, 2026 at 2:05 PM")
check("day", render("{day}"), "Friday")
check("date +3d", render("{date +3d}"), "Nov 23, 2026")
check("date -1w", render("{date -1w}"), "Nov 13, 2026")
check("date +1M is a month", render("{date +1M:yyyy-MM-dd}"), "2026-12-20")
check("date +1mo is a month", render("{date +1mo:yyyy-MM-dd}"), "2026-12-20")
check("time +30m is minutes", render("{time +30m}"), "2:35 PM")
check("several offsets", render("{date +1y +2d:yyyy-MM-dd}"), "2027-11-22")
check("date +1y no spaces", render("{date+1y:yyyy}"), "2027")
check("time +2h", render("{time +2h}"), "4:05 PM")
check("case-insensitive name", render("{Date:yyyy}"), "2026")
var de = ctx; de.locale = Locale(identifier: "de_DE")
check("date follows locale", render("{date:long}", de), "20. November 2026")
check("day follows locale", render("{day}", de), "Freitag")
var th = ctx; th.locale = Locale(identifier: "th_TH")
check("pattern keeps Gregorian year", render("{date:yyyy}", th), "2026")

// Fill-in fields
let t = Placeholders("Hi {Name}, your {Plan: Basic | Pro} plan renews {date +30d:yyyy-MM-dd}. Thanks, {name}!")
check("fields unique in order", t.fields.map(\.label), ["Name", "Plan"])
check("options", t.fields[1].options, ["Basic", "Pro"])
var filled = ctx; filled.values = ["name": "Sarah", "plan": "Pro"]
check("filled", t.render(filled).text, "Hi Sarah, your Pro plan renews 2026-12-20. Thanks, Sarah!")
check("defaults when empty", t.render(ctx).text, "Hi , your Basic plan renews 2026-12-20. Thanks, !")
var raw = ctx; raw.values = nil
check("unfilled keeps source", t.render(raw).text, "Hi {Name}, your {Plan: Basic | Pro} plan renews 2026-12-20. Thanks, {name}!")
check("default value", Placeholders("{City: Jakarta}").fields.first?.options, ["Jakarta"])
check("unicode label", Placeholders("{名前}さん").fields.first?.label, "名前")
check("label with #", Placeholders("Order {Order #}").fields.first?.label, "Order #")

// Things that are not tokens
check("code braces", Placeholders("func a() { return 1 }").hasTokens, false)
check("spaced label is text", Placeholders("{ Name }").hasTokens, false)
check("spaced stamp still works", render("{ date:yyyy }"), "2026")
check("json", Placeholders(#"{"a": 1}"#).hasTokens, false)
check("empty braces", Placeholders("{}").hasTokens, false)
check("multi-line braces", Placeholders("{Name\n}").hasTokens, false)
check("label too long", Placeholders("{" + String(repeating: "a", count: 41) + "}").hasTokens, false)
check("template literal", Placeholders("${x}").fields.map(\.label), ["x"]) // documented: Code cutlings skip expansion
check("escaped brace plain", render(#"\{date} and {date:yyyy}"#), "{date} and 2026")
check("escaped brace markdown kept", render(#"\{date\}"#, markdown: true), #"\{date\}"#)
check("bad offset is text", Placeholders("{date +3x}").hasTokens, false)
check("unknown word is a field", Placeholders("{Company}").fields.first?.label, "Company")

// Markdown (Formatted cutlings): labels read through escapes, values escaped
let md = Placeholders(#"**Hi {first\_name}**"#, markdown: true)
check("markdown label unescaped", md.fields.first?.label, "first_name")
var mdv = ctx; mdv.values = ["first_name": "A*B"]
check("markdown value escaped", md.render(mdv, escape: { $0.replacingOccurrences(of: "*", with: #"\*"#) }).text, #"**Hi A\*B**"#)

// Cursor
let c = Placeholders("Dear {cursor},\nThanks")
let r = c.render(ctx)
check("cursor removed", r.text, "Dear ,\nThanks")
check("cursor offset", r.charactersAfterCursor, 8)
check("no cursor", Placeholders("x").render(ctx).charactersAfterCursor, nil)

// Clipboard
var clip = ctx; clip.clipboard = "PO-1234"
check("clipboard", render("Ref {clipboard}", clip), "Ref PO-1234")
check("clipboard unknown kept", render("Ref {clipboard}"), "Ref {clipboard}")

// Chunks for the keyboard
check("chunks", Placeholders("Hi {Name}, on {date:yyyy}{cursor}. Bye {Name}").chunks(ctx), [
    .text("Hi "), .field(Placeholders.Field(label: "Name", options: [])), .text(", on 2026"), .cursor, .text(". Bye "), .field(Placeholders.Field(label: "Name", options: [])),
])

// Raycast forms
let rc = Placeholders(#"{argument name="Tone" default="friendly" options="formal, friendly"} {date format="yyyy-MM-dd" offset="+2d"}"#)
check("raycast argument", rc.fields.first?.options, ["friendly", "formal"])
check("raycast date", rc.render(ctx).text, "friendly 2026-11-22")
check("raycast offsets", render(#"{date offset="+2y +5M" format="yyyy-MM"}"#), "2029-04")
check("raycast locale", render(#"{day locale="fr-FR"}"#), "vendredi")

// Marked mode: only braces Cutling inserted (with the invisible marker) are fill-ins.
let typedBraces = Placeholders("\\textbf{bold} and Hello {name}", marked: true)
check("marked: typed braces stay text", typedBraces.render(ctx).text, "\\textbf{bold} and Hello {name}")
check("marked: typed braces have no fields", typedBraces.hasTokens, false)
let markedReply = Placeholders("Hi {\u{2060}Name}, {\u{2060}date:yyyy-MM-dd}", marked: true)
var markedValues = ctx; markedValues.values = ["name": "Sarah"]
check("marked: inserted fill-in", markedReply.render(markedValues).text, "Hi Sarah, 2026-11-20")
check("marked: fields", markedReply.fields.map(\.label).joined(separator: ","), "Name")
check("marked helper", Placeholders.marked("date"), "{\u{2060}date}")

// Editing a pill: a marked token read into a model and written back (FillInEdit.swift).
func edit(_ body: String) -> FillInEdit? { FillInEdit(token: Placeholders.marked(body)) }
check("edit: blank", edit("Name"), .blank(label: "Name", choices: []))
check("edit: blank with default", edit("City: Jakarta"), .blank(label: "City", choices: ["Jakarta"]))
check("edit: choice", edit("Plan: Basic | Pro | Team"), .blank(label: "Plan", choices: ["Basic", "Pro", "Team"]))
check("edit: raycast argument reads as a blank", edit(#"argument name="Tone" default="warm" options="warm, formal""#), .blank(label: "Tone", choices: ["warm", "formal"]))
check("edit: date", edit("date"), .stamp(Placeholders.Stamp(kind: .date)))
check("edit: date offset and style", edit("date +1d:long"), .stamp(Placeholders.Stamp(kind: .date, offset: [.init(amount: 1, unit: .day)], style: .long)))
check("edit: pattern", edit("date:yyyy-MM-dd"), .stamp(Placeholders.Stamp(kind: .date, style: .pattern("yyyy-MM-dd"))))
check("edit: cursor has nothing to edit", edit("cursor"), nil)
check("edit: clipboard has nothing to edit", edit("clipboard"), nil)
check("edit: a locale is not edited", edit(#"day locale="fr-FR""#), nil)
check("edit: text is not a pill", FillInEdit(token: "hello"), nil)
check("write: blank", FillInEdit.blank(label: "Name", choices: []).token, Placeholders.marked("Name"))
check("write: choice", FillInEdit.blank(label: "Plan", choices: ["Basic", "Pro"]).token, Placeholders.marked("Plan: Basic | Pro"))
check("write: label loses syntax characters", FillInEdit.blank(label: " {A:b|c}\n", choices: [" x ", ""]).token, Placeholders.marked("Abc: x"))
check("write: empty label is refused", FillInEdit.blank(label: "{}", choices: []).isValid, false)
check("write: a keyword label is refused", FillInEdit.blank(label: "Date", choices: []).isValid, false)
check("write: a normal label is valid", FillInEdit.blank(label: "Name", choices: []).isValid, true)
check("write: date", FillInEdit.stamp(.init(kind: .date)).token, Placeholders.marked("date"))
check("write: offsets and style", FillInEdit.stamp(.init(kind: .datetime, offset: [.init(amount: -3, unit: .day), .init(amount: 1, unit: .month)], style: .short)).token, Placeholders.marked("datetime -3d +1M:short"))
check("write: time in minutes", FillInEdit.stamp(.init(kind: .time, offset: [.init(amount: 30, unit: .minute)])).token, Placeholders.marked("time +30m"))
check("write: pattern", FillInEdit.stamp(.init(kind: .date, style: .pattern("HH:mm"))).token, Placeholders.marked("date:HH:mm"))
for body in ["Name", "Plan: A | B", "date", "day", "time +2h", "date +1y +2d:long", "date -1w:yyyy-MM-dd", "datetime:full", "City: Jakarta"] {
    check("round trip \(body)", edit(body)?.token, Placeholders.marked(body))
}

print(fails == 0 ? "ALL PASS" : "\(fails) FAILED"); exit(fails == 0 ? 0 : 1)
