import SwiftUI

public struct ImageViewerView: View {
    public let imageLinks: [String]
    public let localImageData: [Data]
    
    @State private var currentIndex = 0
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    @Environment(\.dismiss) private var dismiss
    
    public init(imageLinks: [String], localImageData: [Data] = []) {
        self.imageLinks = imageLinks
        self.localImageData = localImageData
    }
    
    public var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                TabView(selection: $currentIndex) {
                    let total = localImageData.count + imageLinks.count
                    ForEach(0..<total, id: \.self) { index in
                        imageContent(for: index)
                            .tag(index)
                            .scaleEffect(scale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { val in
                                        scale = lastScale * val
                                    }
                                    .onEnded { val in
                                        lastScale = scale
                                        if scale < 1.0 {
                                            withAnimation {
                                                scale = 1.0
                                                lastScale = 1.0
                                            }
                                        }
                                    }
                            )
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    if scale > 1.0 {
                                        scale = 1.0
                                        lastScale = 1.0
                                    } else {
                                        scale = 2.0
                                        lastScale = 2.0
                                    }
                                }
                            }
                    }
                }
                .tabViewStyle(.page)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func imageContent(for index: Int) -> some View {
        if index < localImageData.count {
            #if canImport(UIKit)
            if let uiImage = UIImage(data: localImageData[index]) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Invalid Image Data").foregroundColor(.white)
            }
            #elseif canImport(AppKit)
            if let nsImage = NSImage(data: localImageData[index]) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Invalid Image Data").foregroundColor(.white)
            }
            #else
            Text("Unsupported").foregroundColor(.white)
            #endif
        } else {
            let linkIndex = index - localImageData.count
            AsyncImage(url: URL(string: imageLinks[linkIndex])) { phase in
                switch phase {
                case .empty:
                    ProgressView().tint(.white)
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text("Failed to load").foregroundColor(.white)
                    }
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}
