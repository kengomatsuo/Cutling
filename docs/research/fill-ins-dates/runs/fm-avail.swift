import Foundation
import FoundationModels
let m = SystemLanguageModel.default
print("availability:", m.availability)
print("supportsLocale(current):", m.supportsLocale(), "current:", Locale.current.identifier)
print("languages:", m.supportedLanguages.map { $0.maximalIdentifier }.sorted().joined(separator: ", "))
