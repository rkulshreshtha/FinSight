import SwiftUI

public struct ImageAttachmentView: View {
    @Binding var attachments: [ImageAttachment]
    var onCameraTapped: () -> Void
    var onGalleryTapped: () -> Void
    var onFilesTapped: () -> Void
    
    public init(attachments: Binding<[ImageAttachment]>, onCameraTapped: @escaping () -> Void, onGalleryTapped: @escaping () -> Void, onFilesTapped: @escaping () -> Void) {
        self._attachments = attachments
        self.onCameraTapped = onCameraTapped
        self.onGalleryTapped = onGalleryTapped
        self.onFilesTapped = onFilesTapped
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Button(action: onCameraTapped) {
                    VStack {
                        Image(systemName: "camera")
                            .font(.title2)
                        Text("Camera")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button(action: onGalleryTapped) {
                    VStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                        Text("Gallery")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button(action: onFilesTapped) {
                    VStack {
                        Image(systemName: "folder")
                            .font(.title2)
                        Text("Files")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            if !attachments.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(Array(attachments.enumerated()), id: \.element.id) { index, attachment in
                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 100)
                                .overlay(
                                    VStack {
                                        Image(systemName: "photo")
                                            .foregroundColor(.secondary)
                                        if attachment.isUploading {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        }
                                    }
                                )
                            
                            Button(action: {
                                attachments.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                            }
                            .padding(4)
                        }
                    }
                }
            }
        }
    }
}
