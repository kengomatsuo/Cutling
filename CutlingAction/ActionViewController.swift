import UIKit
import SwiftUI
import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let extensionContext else { return }

        let shareView = ShareView(
            extensionContext: extensionContext,
            dismiss: { [weak self] in
                self?.extensionContext?.completeRequest(returningItems: nil)
            }
        )

        let hostingController = UIHostingController(rootView: shareView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        hostingController.didMove(toParent: self)
    }
}
