import AppKit
var fails = 0
func check(_ name: String, _ got: String?, _ want: String?) {
    if got == want { print("ok  ", name) } else { fails += 1; print("FAIL", name, "\n   got: \(got.debugDescription)\n  want: \(want.debugDescription)") }
}
// Escape round trip: plain text survives as Markdown
for s in ["snake_case_name", "a*b*c", "price: $5 & up <tag>", "[x](y)", "~~no~~", "back\\slash `tick`", "  indented\n\tline", "# not heading\n- not list"] {
    check("escape round trip \(s.prefix(15))", RichText.plainText(RichText.escape(s)), s)
}
// Inline styles parse
let md = "**bold** *italic* ~~gone~~ `code` [link](https://example.com)"
check("plain of rich", RichText.plainText(md), "bold italic gone code link")
// Attributed -> markdown -> attributed keeps styles
let ns = RichText.nsAttributed(md)
let back = RichText.markdown(from: ns)
check("ns round trip plain", back.map(RichText.plainText), "bold italic gone code link")
print("   md back:", back ?? "nil")
// RTF round trip
let rtf = RichText.rtfData(md)!
let fromRTF = RichText.markdown(fromRTF: rtf)
check("rtf round trip plain", fromRTF.map(RichText.plainText), "bold italic gone code link")
print("   md from rtf:", fromRTF ?? "nil")
// Plain RTF yields nil
let plainNS = NSAttributedString(string: "just text", attributes: [.font: NSFont.systemFont(ofSize: 12)])
check("no formatting -> nil", RichText.markdown(from: plainNS), nil)
// Google Docs HTML (wrapper b font-weight:normal, spans with font-weight:700)
let gdoc = """
<meta charset='utf-8'><b style="font-weight:normal;" id="docs-internal-guid-61c25daf-7fff-1234"><p dir="ltr" style="line-height:1.38;margin-top:0pt;margin-bottom:0pt;"><span style="font-size:11pt;font-family:Arial,sans-serif;color:#000000;font-weight:400;font-style:normal;white-space:pre-wrap;">Hello </span><span style="font-size:11pt;font-family:Arial,sans-serif;color:#000000;font-weight:700;font-style:normal;white-space:pre-wrap;">bold</span><span style="font-size:11pt;font-family:Arial,sans-serif;color:#000000;font-weight:400;font-style:italic;white-space:pre-wrap;"> and italic</span></p></b>
"""
let gmd = MainActor.assumeIsolated { RichText.markdown(fromHTML: gdoc.data(using: .utf8)!) }
print("   gdocs md:", gmd ?? "nil")
check("gdocs plain", gmd.map { RichText.plainText($0).trimmingCharacters(in: .whitespacesAndNewlines) }, "Hello bold and italic")
check("gdocs wrapper not bold", gmd.map { String($0.hasPrefix("**Hello")) }, "false")
// html export
print("   html:", RichText.html(md))
// Underline and highlight: Apple's Markdown attribute syntax
let uh = "a ^[under](underline: true) and ^[**both**](underline: true, highlight: true) z"
check("underline/highlight plain", RichText.plainText(uh), "a under and both z")
let uhNS = RichText.nsAttributed(uh, editorColors: true)
check("underline/highlight round trip", RichText.markdown(from: uhNS), uh)
let uhRTF = RichText.markdown(fromRTF: RichText.rtfData(uh)!)
check("underline/highlight rtf round trip", uhRTF, uh)
check("old reader drops the attributes", String((try! AttributedString(markdown: uh, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))).characters), "a under and both z")
check("html underline/highlight", RichText.html("^[u](underline: true) ^[h](highlight: true)").contains("<u>u</u>") && RichText.html("^[h](highlight: true)").contains("<mark") ? "yes" : "no", "yes")
// Links keep their own underline out of the Markdown
let linkNS = NSAttributedString(string: "site", attributes: [.link: URL(string: "https://a.b")!, .underlineStyle: 1])
check("underlined link is a link", RichText.markdown(from: linkNS), "[site](https://a.b)")
// A white or grey box behind pasted text is not a highlight; a colour is
check("white background ignored", RichText.markdown(from: NSAttributedString(string: "x", attributes: [.backgroundColor: NSColor.white])), nil)
check("grey background ignored", RichText.markdown(from: NSAttributedString(string: "x", attributes: [.backgroundColor: NSColor(white: 0.9, alpha: 1)])), nil)
check("yellow background is highlight", RichText.markdown(from: NSAttributedString(string: "x", attributes: [.backgroundColor: NSColor.yellow])), "^[x](highlight: true)")

// Lists: markers stored at line start, plain form unchanged
let list = "Shopping:\n• milk\n• **eggs**\n- one\n1. first\n2. second\nend"
check("list plain", RichText.plainText(list), "Shopping:\n• milk\n• eggs\n- one\n1. first\n2. second\nend")
check("list kinds", RichText.listKinds(list).map { $0?.rawValue ?? "-" }.joined(separator: ","), "-,bulleted,bulleted,dashed,numbered,numbered,-")
let listEditor = RichText.nsAttributed(list, editorColors: true)
check("list editor keeps markers", listEditor.string, RichText.plainText(list))
check("list editor round trip", RichText.markdown(from: listEditor), list)
let listExport = RichText.nsAttributed(list)
check("list export drops markers", listExport.string, "Shopping:\nmilk\neggs\none\nfirst\nsecond\nend")
check("list export round trip", RichText.markdown(from: listExport), list)
let listRTF = RichText.rtfData(list)!
let rtfText = String(data: listRTF, encoding: .utf8)!
check("rtf has Apple's list table", rtfText.contains(#"\{disc\}"#) && rtfText.contains(#"\{hyphen\}"#) && rtfText.contains(#"\{decimal\}"#) ? "yes" : "no", "yes")
check("list rtf round trip", RichText.markdown(fromRTF: listRTF), list)
check("only a list is still formatted", RichText.markdown(from: RichText.nsAttributed("• a\n• b")), "• a\n• b")
// Numbers are written by position, whatever the source says
check("renumbered", RichText.markdown(from: RichText.nsAttributed("1. a\n7. b\n\n3. c")), "1. a\n2. b\n\n1. c")
// A line typed to look like a list is text: escaped, shown as typed, never a list
for s in ["- not list", "• not list", "12. not list", "a\n- b\n• c\n3. d"] {
    let e = RichText.escape(s)
    check("escape keeps \(s.prefix(12)) as text", RichText.plainText(e), s)
    check("escaped \(s.prefix(12)) is no list", RichText.listKinds(e).contains { $0 != nil } ? "list" : "text", "text")
}
let typed = NSMutableAttributedString(string: "- typed\n", attributes: [.font: NSFont.systemFont(ofSize: 12)])
typed.append(NSAttributedString(string: "bold", attributes: [.font: NSFont.boldSystemFont(ofSize: 12)]))
check("typed dash stays text", RichText.markdown(from: typed), "\\- typed\n**bold**")
// A list pasted from another app (HTML through WebKit, RTF as Notes and TextEdit write it)
let htmlList = "<p>Intro <u>u</u></p><ul><li>One</li><li>Two</li></ul><ol><li>First</li><li>Second</li></ol><p>after</p>"
let hmd = MainActor.assumeIsolated { RichText.markdown(fromHTML: htmlList.data(using: .utf8)!) }
check("html list", hmd, "Intro ^[u](underline: true)\n• One\n• Two\n1. First\n2. Second\nafter")
let textEditRTF = #"{\rtf1\ansi{\fonttbl\f0\fnil Helvetica;}{\*\listtable{\list\listtemplateid1\listhybrid{\listlevel\levelnfc23\levelnfcn23\leveljc0\leveljcn0\levelfollow0\levelstartat1\levelspace360\levelindent0{\*\levelmarker \{hyphen\}}{\leveltext\leveltemplateid1\'01\uc0\u8259 ;}{\levelnumbers;}\fi-360\li720\lin720 }{\listname ;}\listid1}}{\*\listoverridetable{\listoverride\listid1\listoverridecount0\ls1}}\pard\ls1\ilvl0\f0\fs24 {\listtext\tab \uc0\u8259 \tab }Dash one\par {\listtext\tab \uc0\u8259 \tab }Dash two\par }"#
check("textedit dashed rtf", RichText.markdown(fromRTF: textEditRTF.data(using: .utf8)!), "- Dash one\n- Dash two")
// HTML export of lists
let listHTML = RichText.html(list)
check("html lists", listHTML.contains("<ul><li>milk</li><li><b>eggs</b></li></ul>") && listHTML.contains("Apple-dash-list") && listHTML.contains("<ol><li>first</li><li>second</li></ol>") ? "yes" : listHTML, "yes")
check("html without lists unchanged", RichText.html("a\n**b**"), "<meta charset=\"utf-8\"><span style=\"white-space:pre-wrap\">a<br><b>b</b></span>")
// Existing cutlings read as before
check("existing rich unchanged", RichText.markdown(from: RichText.nsAttributed(md, editorColors: true)), md)

// A preview cut to its first 400 characters never shows a marker: the cut is made after parsing
let longRich = String(repeating: "word ", count: 76) + "^[an underlined phrase](underline: true) and **bold words** then ^[a highlight](highlight: true)\n• Milk\n• Eggs"
let previewText = Cutling.previewPieces(longRich, format: .rich).map { piece -> String in
    if case .text(let run) = piece { return String(run.characters) }
    return ""
}.joined()
check("cut preview shows no markers", previewText.contains("^[") || previewText.contains("](") || previewText.contains("**") ? previewText.suffix(40).description : "clean", "clean")
check("cut preview length", String(previewText.count), "400")
check("cut preview keeps underline", Cutling.previewPieces(longRich, format: .rich).contains { piece in
    if case .text(let run) = piece { return run.runs.contains { $0.swiftUI.underlineStyle != nil } }
    return false
} ? "yes" : "no", "yes")
check("short plain preview whole", Cutling.previewPieces("a *b* c", format: .plain).map { piece -> String in
    if case .text(let run) = piece { return String(run.characters) }
    return ""
}.joined(), "a *b* c")

// code heuristics
check("code: swift", String(TextFormat.looksLikeCode("func a() {\n    return 1\n}")), "true")
check("code: sentence", String(TextFormat.looksLikeCode("Hi there, see you at 5.")), "false")
check("code: address", String(TextFormat.looksLikeCode("221B Baker Street\nLondon")), "false")
print(fails == 0 ? "ALL PASS" : "\(fails) FAILED"); exit(fails == 0 ? 0 : 1)
