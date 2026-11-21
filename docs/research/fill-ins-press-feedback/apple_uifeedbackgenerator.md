<!--
{
  "availability" : [
    "iOS: 10.0.0 -",
    "iPadOS: 10.0.0 -",
    "macCatalyst: 13.1.0 -"
  ],
  "documentType" : "symbol",
  "framework" : "UIKit",
  "identifier" : "/documentation/UIKit/UIFeedbackGenerator",
  "metadataVersion" : "0.1.0",
  "role" : "Class",
  "symbol" : {
    "kind" : "Class",
    "modules" : [
      "UIKit"
    ],
    "preciseIdentifier" : "c:objc(cs)UIFeedbackGenerator"
  },
  "title" : "UIFeedbackGenerator"
}
-->

# UIFeedbackGenerator

The abstract superclass for all feedback generators.

```
@MainActor class UIFeedbackGenerator
```

## Overview

Don’t subclass or create instances of this class yourself. Instead, instantiate one of the concrete feedback generator subclasses:

- [`UIImpactFeedbackGenerator`](/documentation/UIKit/UIImpactFeedbackGenerator). Use impact feedback to indicate when an impact occurs. For example, you might trigger impact feedback when a user interface object collides with something or snaps into place.
- [`UISelectionFeedbackGenerator`](/documentation/UIKit/UISelectionFeedbackGenerator). Use selection feedback to indicate a change in selection.
- [`UINotificationFeedbackGenerator`](/documentation/UIKit/UINotificationFeedbackGenerator). Use notification feedback to indicate successes, failures, and warnings.
- [`UICanvasFeedbackGenerator`](/documentation/UIKit/UICanvasFeedbackGenerator). Use canvas feedback to indicate when a drawing event occurs, such as an object snapping to a guide or ruler.

For more information, read <doc://com.apple.documentation/documentation/ApplePencil/playing-haptic-feedback-in-your-app>.

## Topics

### Initializing a feedback generator

[`convenience init(view: UIView)`](/documentation/UIKit/UIFeedbackGenerator/init(view:))

Creates a feedback generator and attaches it to the specified view.

[`init()`](/documentation/UIKit/UIFeedbackGenerator/init())

Creates a feedback generator.

### Preparing to generate feedback

[`func prepare()`](/documentation/UIKit/UIFeedbackGenerator/prepare())

Prepares the generator to trigger feedback.

## Relationships

### Inherits From

[`NSObject-swift.class`](/documentation/ObjectiveC/NSObject-swift.class)

### Inherited By

[`UIImpactFeedbackGenerator`](/documentation/UIKit/UIImpactFeedbackGenerator)

[`UINotificationFeedbackGenerator`](/documentation/UIKit/UINotificationFeedbackGenerator)

[`UICanvasFeedbackGenerator`](/documentation/UIKit/UICanvasFeedbackGenerator)

[`UISelectionFeedbackGenerator`](/documentation/UIKit/UISelectionFeedbackGenerator)

### Conforms To

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`UIInteraction`](/documentation/UIKit/UIInteraction)

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`Sendable`](/documentation/Swift/Sendable)

[`CVarArg`](/documentation/Swift/CVarArg)

[`Hashable`](/documentation/Swift/Hashable)

[`Equatable`](/documentation/Swift/Equatable)

[`Copyable`](/documentation/Swift/Copyable)

[`Escapable`](/documentation/Swift/Escapable)

---

Copyright &copy; 2026 Apple Inc. All rights reserved. | [Terms of Use](https://www.apple.com/legal/internet-services/terms/site.html) | [Privacy Policy](https://www.apple.com/privacy/privacy-policy)