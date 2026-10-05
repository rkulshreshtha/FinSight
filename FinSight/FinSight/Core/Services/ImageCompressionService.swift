import Foundation
import CoreGraphics

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class ImageCompressionService: ImageServiceProtocol {
    public init() {}
    
    public func compressImage(_ data: Data, maxSizeKB: Int, maxDimension: CGFloat) -> Data {
        return data
    }
    
    public func uploadToGDrive(_ data: Data, fileName: String) async throws -> String {
        return ""
    }
    
    public func downloadImage(from url: String) async throws -> Data {
        return Data()
    }
    
    public func deleteFromGDrive(fileId: String) async throws {}
}
