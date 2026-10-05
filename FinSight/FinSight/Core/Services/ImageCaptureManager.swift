import Foundation
import SwiftUI
import Observation

public enum ImageSource: String, Codable {
    case camera
    case gallery
    case files
}

public struct CapturedImage: Identifiable, Codable {
    public let id: UUID
    public let originalData: Data
    public let compressedData: Data
    public let thumbnail: Data
    public let source: ImageSource
    public let createdAt: Date
    
    public init(id: UUID = UUID(), originalData: Data, compressedData: Data, thumbnail: Data, source: ImageSource, createdAt: Date = Date()) {
        self.id = id
        self.originalData = originalData
        self.compressedData = compressedData
        self.thumbnail = thumbnail
        self.source = source
        self.createdAt = createdAt
    }
}

@Observable
public final class ImageCaptureManager {
    public var showCamera = false
    public var showPhotoPicker = false
    public var showFilePicker = false
    public var capturedImages: [CapturedImage] = []
    public var isCompressing = false
    public var compressionProgress = 0.0
    
    private let compressionService = ImageCompressionService()
    
    public init() {}
    
    public var totalSizeKB: Int {
        return capturedImages.reduce(0) { $0 + ($1.compressedData.count / 1024) }
    }
    
    public func processImage(_ data: Data, source: ImageSource) async -> CapturedImage {
        isCompressing = true
        defer { isCompressing = false }
        
        // Simulate progress for UI
        compressionProgress = 0.5
        
        let maxDimension = AppConfig.maxImageDimension
        let maxSizeKB = AppConfig.maxImageSizeKB
        
        let compressed = compressionService.compressImage(data, maxSizeKB: maxSizeKB, maxDimension: maxDimension)
        
        let thumbnail = generateThumbnail(from: compressed, size: CGSize(width: 100, height: 100))
        
        compressionProgress = 1.0
        
        let image = CapturedImage(originalData: data, compressedData: compressed, thumbnail: thumbnail, source: source)
        
        await MainActor.run {
            self.capturedImages.append(image)
        }
        
        return image
    }
    
    public func removeImage(at index: Int) {
        guard index >= 0 && index < capturedImages.count else { return }
        capturedImages.remove(at: index)
    }
    
    public func clearAll() {
        capturedImages.removeAll()
    }
    
    public func generateThumbnail(from data: Data, size: CGSize) -> Data {
        #if canImport(UIKit)
        guard let image = UIImage(data: data) else { return data }
        let renderer = UIGraphicsImageRenderer(size: size)
        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return scaledImage.jpegData(compressionQuality: 0.7) ?? data
        #elseif canImport(AppKit)
        // Basic implementation for macOS
        return data
        #else
        return data
        #endif
    }
}
