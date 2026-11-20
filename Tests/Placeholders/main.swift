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

print(fails == 0 ? "ALL PASS" : "\(fails) FAILED"); exit(fails == 0 ? 0 : 1)
