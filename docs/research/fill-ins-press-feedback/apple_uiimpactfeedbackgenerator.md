<!--
{
  "availability" : [
    "iOS: 10.0.0 -",
    "iPadOS: 10.0.0 -",
    "macCatalyst: 13.1.0 -"
  ],
  "documentType" : "symbol",
  "framework" : "UIKit",
  "identifier" : "/documentation/UIKit/UIImpactFeedbackGenerator",
  "metadataVersion" : "0.1.0",
  "role" : "Class",
  "symbol" : {
    "kind" : "Class",
    "modules" : [
      "UIKit"
    ],
    "preciseIdentifier" : "c:objc(cs)UIImpactFeedbackGenerator"
  },
  "title" : "UIImpactFeedbackGenerator"
}
-->

# UIImpactFeedbackGenerator

A concrete feedback generator subclass that creates haptics to simulate physical impacts.

```
@MainActor class UIImpactFeedbackGenerator
```

## Overview

Use impact feedback to indicate when an impact occurs. For example, you might trigger impact feedback when a user interface object collides with another object.

The following code example shows how to use a pan gesture to drag a square, playing haptic feedback to indicate when the square collides with the edge of its superview.

```swift
var feedback = UIImpactFeedbackGenerator()

override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create an impact feedback object and associate it with the view.
    feedback = UIImpactFeedbackGenerator(view: view)
    
    // Draw a basic square and add it to the view hierarchy.
    let center = CGPoint(x: view.center.x - 50, y: view.center.y - 50)
    let square = UIView(frame: CGRect(origin: center,
                                     size: CGSize(width: 100, height: 100)))
    square.backgroundColor = .tintColor
    view.addSubview(square)
    
    // Add a pan gesture to allow dragging the square.
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragSquare(_:)))
    square.isUserInteractionEnabled = true
    square.addGestureRecognizer(panGesture)
}

@objc
private func dragSquare(_ sender: UIPanGestureRecognizer) {
    guard let square = sender.view else { return }
    
    if sender.state == .began {
        // Prepare the feedback object.
        feedback.prepare()
    }

    // Move the square in response to a pan gesture.
    let distance = sender.translation(in: view)
    square.center = CGPoint(x: square.center.x + distance.x, y: square.center.y + distance.y)
    sender.setTranslation(CGPoint.zero, in: view)

    // Play impact feedback if the square bumps into the edge of its superview.
    if square.hitEdge(of: view) {
        feedback.impactOccurred(intensity: 1, at: sender.location(in: view))
    }
}
```

For more information, read <doc://com.apple.documentation/documentation/ApplePencil/playing-haptic-feedback-in-your-app>.

## Topics

### Initializing the feedback generator

[`convenience init(style: UIImpactFeedbackGenerator.FeedbackStyle, view: UIView)`](/documentation/UIKit/UIImpactFeedbackGenerator/init(style:view:))

Creates an impact feedback generator with the specified style and view.

[`enum FeedbackStyle`](/documentation/UIKit/UIImpactFeedbackGenerator/FeedbackStyle)

The mass of the objects in the collision simulated by an impact feedback generator object.

[`init(style: UIImpactFeedbackGenerator.FeedbackStyle)`](/documentation/UIKit/UIImpactFeedbackGenerator/init(style:))

Creates an impact feedback generator with the specified style.

### Reporting impacts

[`func impactOccurred()`](/documentation/UIKit/UIImpactFeedbackGenerator/impactOccurred())

Triggers impact feedback.

[`func impactOccurred(intensity: CGFloat)`](/documentation/UIKit/UIImpactFeedbackGenerator/impactOccurred(intensity:))

Triggers impact feedback with a specific intensity.

[`func impactOccurred(at: CGPoint)`](/documentation/UIKit/UIImpactFeedbackGenerator/impactOccurred(at:))

Triggers impact feedback at the specified location.

[`func impactOccurred(intensity: CGFloat, at: CGPoint)`](/documentation/UIKit/UIImpactFeedbackGenerator/impactOccurred(intensity:at:))

Triggers impact feedback with a specific intensity at the specified location.

## Relationships

### Conforms To

[`CVarArg`](/documentation/Swift/CVarArg)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`Equatable`](/documentation/Swift/Equatable)

[`Hashable`](/documentation/Swift/Hashable)

[`Sendable`](/documentation/Swift/Sendable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`UIInteraction`](/documentation/UIKit/UIInteraction)

### Inherits From

[`UIFeedbackGenerator`](/documentation/UIKit/UIFeedbackGenerator)

---

Copyright &copy; 2026 Apple Inc. All rights reserved. | [Terms of Use](https://www.apple.com/legal/internet-services/terms/site.html) | [Privacy Policy](https://www.apple.com/privacy/privacy-policy)