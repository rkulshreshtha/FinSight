import Foundation
import CoreGraphics

public protocol ImageServiceProtocol {
    func compressImage(_ data: Data, maxSizeKB: Int, maxDimension: CGFloat) -> Data
    func uploadToGDrive(_ data: Data, fileName: String) async throws -> String
    func downloadImage(from url: String) async throws -> Data
    func deleteFromGDrive(fileId: String) async throws
}
