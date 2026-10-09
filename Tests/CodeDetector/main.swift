// Each line: rule verdict, final verdict, language, snippet.
import Foundation
import FoundationModels
print("model available:", SystemLanguageModel.default.isAvailable, SystemLanguageModel.default.availability)
let samples = ["func greet() {\n    print(\"hi\")\n}", "SELECT name FROM users WHERE id = 3", "git checkout -b feature/login", "Meet me at 5, near the café.", "221B Baker Street\nLondon", "<div class=\"card\">Hi</div>", "{\"id\": 1, \"ok\": true}", "npm i react", "Hello", "Call Mum tomorrow", "Kenneth Fang", "brew install wget"]
for s in samples {
    let rule = CodeDetector.ruleVerdict(s)
    let v = await CodeDetector.detect(s)
    print(String(describing: rule).padding(toLength: 8, withPad: " ", startingAt: 0), v.isCode, v.language ?? "-", "|", s.replacingOccurrences(of: "\n", with: "⏎"))
}
