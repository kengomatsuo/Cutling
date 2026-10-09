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
// code heuristics
check("code: swift", String(TextFormat.looksLikeCode("func a() {\n    return 1\n}")), "true")
check("code: sentence", String(TextFormat.looksLikeCode("Hi there, see you at 5.")), "false")
check("code: address", String(TextFormat.looksLikeCode("221B Baker Street\nLondon")), "false")
print(fails == 0 ? "ALL PASS" : "\(fails) FAILED"); exit(fails == 0 ? 0 : 1)
