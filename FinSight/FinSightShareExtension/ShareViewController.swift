import UIKit
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = ShareExtensionViewModel()
        let contentView = ShareExtensionView(viewModel: viewModel, extensionContext: self.extensionContext)
        let hostingController = UIHostingController(rootView: contentView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        
        extractSharedContent(viewModel: viewModel)
    }
    
    private func extractSharedContent(viewModel: ShareExtensionViewModel) {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProviders = extensionItem.attachments else {
            return
        }
        
        for provider in itemProviders {
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, error in
                    if let url = item as? URL, let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            viewModel.sharedContent = .image(data)
                            Task { await viewModel.processSharedContent() }
                        }
                    } else if let image = item as? UIImage, let data = image.jpegData(compressionQuality: 0.8) {
                        DispatchQueue.main.async {
                            viewModel.sharedContent = .image(data)
                            Task { await viewModel.processSharedContent() }
                        }
                    }
                }
                break // Only process first item for simplicity
            } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, error in
                    if let text = item as? String {
                        DispatchQueue.main.async {
                            viewModel.sharedContent = .text(text)
                            Task { await viewModel.processSharedContent() }
                        }
                    }
                }
                break
            } else if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, error in
                    if let url = item as? URL {
                        DispatchQueue.main.async {
                            viewModel.sharedContent = .url(url)
                            Task { await viewModel.processSharedContent() }
                        }
                    }
                }
                break
            }
        }
    }
}
