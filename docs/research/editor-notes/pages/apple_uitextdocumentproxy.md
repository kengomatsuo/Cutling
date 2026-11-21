<!--
{
  "availability" : [
    "iOS: -",
    "iPadOS: -",
    "macCatalyst: -",
    "tvOS: -",
    "visionOS: -"
  ],
  "documentType" : "symbol",
  "framework" : "UIKit",
  "identifier" : "/documentation/UIKit/UITextDocumentProxy",
  "metadataVersion" : "0.1.0",
  "role" : "Protocol",
  "symbol" : {
    "kind" : "Protocol",
    "modules" : [
      "UIKit"
    ],
    "preciseIdentifier" : "c:objc(pl)UITextDocumentProxy"
  },
  "title" : "UITextDocumentProxy"
}
-->

# UITextDocumentProxy

An object that provides textual context to a custom keyboard.

```
@MainActor protocol UITextDocumentProxy : UIKeyInput
```

## Overview

Through conformance to the [`UIKeyInput`](/documentation/UIKit/UIKeyInput) protocol, a text document proxy enables a custom keyboard (which is based on the [`UIInputViewController`](/documentation/UIKit/UIInputViewController) class) to insert and delete text, to adjust the position of the insertion point, and to determine whether a text input object is empty. The text document proxy uses the keyboard’s [`textDocumentProxy`](/documentation/UIKit/UIInputViewController/textDocumentProxy) property to do this.

For more about using a text document proxy, see [`UIInputViewController`](/documentation/UIKit/UIInputViewController) and [Creating a custom keyboard](/documentation/UIKit/creating-a-custom-keyboard).

## Topics

### Getting the text-input mode

[`var documentInputMode: UITextInputMode?`](/documentation/UIKit/UITextDocumentProxy/documentInputMode)

The text-input mode for the keyboard.

### Obtaining textual context around the insertion point

[`var documentContextAfterInput: String?`](/documentation/UIKit/UITextDocumentProxy/documentContextAfterInput)

Textual context after the insertion point in the current text input object.

[`var documentContextBeforeInput: String?`](/documentation/UIKit/UITextDocumentProxy/documentContextBeforeInput)

Textual context before the insertion point in the current text input object.

### Adjusting the insertion point position

[`func adjustTextPosition(byCharacterOffset: Int)`](/documentation/UIKit/UITextDocumentProxy/adjustTextPosition(byCharacterOffset:))

Moves the insertion point forward or backward in the current text input object.

### Getting the selected text

[`var selectedText: String?`](/documentation/UIKit/UITextDocumentProxy/selectedText)

The currently selected text in the document.

### Managing marked text

[`func setMarkedText(String, selectedRange: NSRange)`](/documentation/UIKit/UITextDocumentProxy/setMarkedText(_:selectedRange:))

Inserts the provided text and marks it to indicate that it’s part of an active input session.

[`func unmarkText()`](/documentation/UIKit/UITextDocumentProxy/unmarkText())

Unmarks the currently marked text.

### Distinguishing changes in the document

[`var documentIdentifier: UUID`](/documentation/UIKit/UITextDocumentProxy/documentIdentifier)

The unique identifier for the document.

## Relationships

### Inherits From

[`UITextInputTraits`](/documentation/UIKit/UITextInputTraits)

[`UIKeyInput`](/documentation/UIKit/UIKeyInput)

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

---

Copyright &copy; 2026 Apple Inc. All rights reserved. | [Terms of Use](https://www.apple.com/legal/internet-services/terms/site.html) | [Privacy Policy](https://www.apple.com/privacy/privacy-policy)