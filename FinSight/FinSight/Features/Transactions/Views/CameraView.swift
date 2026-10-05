import SwiftUI

#if os(iOS)
import UIKit

public struct CameraView: UIViewControllerRepresentable {
    public var onCapture: (Data?) -> Void
    public var onCancel: () -> Void
    
    public init(onCapture: @escaping (Data?) -> Void, onCancel: @escaping () -> Void) {
        self.onCapture = onCapture
        self.onCancel = onCancel
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 1.0) {
                parent.onCapture(data)
            } else {
                parent.onCapture(nil)
            }
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }
    }
}
#else
public struct CameraView: View {
    public var onCapture: (Data?) -> Void
    public var onCancel: () -> Void
    
    public init(onCapture: @escaping (Data?) -> Void, onCancel: @escaping () -> Void) {
        self.onCapture = onCapture
        self.onCancel = onCancel
    }
    
    public var body: some View {
        VStack {
            Text("Camera not supported on macOS")
            Button("Cancel") {
                onCancel()
            }
        }
    }
}
#endif
