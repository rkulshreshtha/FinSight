import Foundation
import Observation
import GoogleSignIn
import GoogleAPIClientForRESTCore
import GoogleAPIClientForREST_Drive

public struct PendingUpload: Codable, Identifiable {
    public let id: UUID
    public let imageData: Data
    public let fileName: String
    public let transactionId: String
    public var retryCount: Int
    public let createdAt: Date
    
    public init(id: UUID = UUID(), imageData: Data, fileName: String, transactionId: String, retryCount: Int = 0, createdAt: Date = Date()) {
        self.id = id
        self.imageData = imageData
        self.fileName = fileName
        self.transactionId = transactionId
        self.retryCount = retryCount
        self.createdAt = createdAt
    }
}

@Observable
public final class GoogleDriveService: ImageServiceProtocol {
    public var isAuthenticated: Bool = false
    public var userEmail: String?
    public var finsightFolderId: String? {
        get { UserDefaults.standard.string(forKey: "FinsightGDriveFolderId") }
        set { UserDefaults.standard.set(newValue, forKey: "FinsightGDriveFolderId") }
    }
    public var uploadQueue: [PendingUpload] = []
    public var isProcessingQueue: Bool = false
    
    private let compressionService = ImageCompressionService()
    private let driveService = GTLRDriveService()
    
    public init() {
        restorePreviousSignIn()
        loadUploadQueue()
    }
    
    private func restorePreviousSignIn() {
        #if os(iOS)
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let user = user, error == nil {
                self.isAuthenticated = true
                self.userEmail = user.profile?.email
                self.driveService.authorizer = user.fetcherAuthorizer
            }
        }
        #endif
    }
    
    public func authenticate() async throws {
        #if os(iOS)
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = await windowScene.windows.first?.rootViewController else {
            throw NSError(domain: "GoogleDriveService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootVC,
            hint: nil,
            additionalScopes: [kGTLRAuthScopeDriveFile]
        )
        
        let user = result.user
        self.isAuthenticated = true
        self.userEmail = user.profile?.email
        self.driveService.authorizer = user.fetcherAuthorizer
        #else
        // macOS implementation or alternative
        throw NSError(domain: "GoogleDriveService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authentication not supported on macOS yet"])
        #endif
    }
    
    public func disconnect() {
        #if os(iOS)
        GIDSignIn.sharedInstance.signOut()
        #endif
        isAuthenticated = false
        userEmail = nil
        driveService.authorizer = nil
    }
    
    public func ensureFinsightFolder() async throws -> String {
        if let id = finsightFolderId {
            // Optionally verify it exists
            return id
        }
        
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "name = '\(AppConfig.googleDriveFolderName)' and mimeType = 'application/vnd.google-apps.folder' and trashed = false"
        query.spaces = "drive"
        query.fields = "files(id, name)"
        
        let fileList = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GTLRDrive_FileList, Error>) in
            driveService.executeQuery(query) { ticket, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let list = result as? GTLRDrive_FileList {
                    continuation.resume(returning: list)
                } else {
                    continuation.resume(throwing: NSError(domain: "GoogleDriveService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown result type"]))
                }
            }
        }
        
        if let files = fileList.files, let first = files.first, let id = first.identifier {
            self.finsightFolderId = id
            return id
        }
        
        let folder = GTLRDrive_File()
        folder.name = AppConfig.googleDriveFolderName
        folder.mimeType = "application/vnd.google-apps.folder"
        
        let createQuery = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        createQuery.fields = "id"
        
        let createdFolder = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GTLRDrive_File, Error>) in
            driveService.executeQuery(createQuery) { ticket, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let file = result as? GTLRDrive_File {
                    continuation.resume(returning: file)
                } else {
                    continuation.resume(throwing: NSError(domain: "GoogleDriveService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown result type"]))
                }
            }
        }
        
        guard let id = createdFolder.identifier else {
            throw NSError(domain: "GoogleDriveService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create folder"])
        }
        
        self.finsightFolderId = id
        return id
    }
    
    public func compressImage(_ data: Data, maxSizeKB: Int, maxDimension: CGFloat) -> Data {
        return compressionService.compressImage(data, maxSizeKB: maxSizeKB, maxDimension: maxDimension)
    }
    
    public func uploadToGDrive(_ data: Data, fileName: String) async throws -> String {
        guard isAuthenticated else {
            throw NSError(domain: "GoogleDriveService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let folderId = try await ensureFinsightFolder()
        
        let file = GTLRDrive_File()
        file.name = fileName
        file.parents = [folderId]
        
        let uploadParams = GTLRUploadParameters(data: data, mimeType: "image/jpeg")
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParams)
        query.fields = "id, webViewLink"
        
        let uploadedFile = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GTLRDrive_File, Error>) in
            driveService.executeQuery(query) { ticket, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let file = result as? GTLRDrive_File {
                    continuation.resume(returning: file)
                } else {
                    continuation.resume(throwing: NSError(domain: "GoogleDriveService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown result type"]))
                }
            }
        }
        
        guard let fileId = uploadedFile.identifier, let webViewLink = uploadedFile.webViewLink else {
            throw NSError(domain: "GoogleDriveService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload failed or missing fields"])
        }
        
        let perm = GTLRDrive_Permission()
        perm.type = "anyone"
        perm.role = "reader"
        let permQuery = GTLRDriveQuery_PermissionsCreate.query(withObject: perm, fileId: fileId)
        
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            driveService.executeQuery(permQuery) { ticket, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
        
        return webViewLink
    }
    
    public func downloadImage(from url: String) async throws -> Data {
        guard let fileId = extractFileId(from: url) else {
            throw NSError(domain: "GoogleDriveService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)
        return try await withCheckedThrowingContinuation { continuation in
            driveService.executeQuery(query) { ticket, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = (result as? GTLRDataObject)?.data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: NSError(domain: "GoogleDriveService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"]))
                }
            }
        }
    }
    
    public func deleteFromGDrive(fileId: String) async throws {
        let query = GTLRDriveQuery_FilesDelete.query(withFileId: fileId)
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            driveService.executeQuery(query) { ticket, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    public func queueUpload(imageData: Data, fileName: String, transactionId: String) {
        let pending = PendingUpload(imageData: imageData, fileName: fileName, transactionId: transactionId)
        uploadQueue.append(pending)
        saveUploadQueue()
    }
    
    public func processUploadQueue() async {
        guard !isProcessingQueue, isAuthenticated else { return }
        isProcessingQueue = true
        defer { isProcessingQueue = false }
        
        var successfulIds = Set<UUID>()
        
        for var upload in uploadQueue {
            do {
                _ = try await uploadToGDrive(upload.imageData, fileName: upload.fileName)
                // In a real app we'd save this link back to the transaction
                successfulIds.insert(upload.id)
            } catch {
                upload.retryCount += 1
                if upload.retryCount > 3 {
                    successfulIds.insert(upload.id) // drop after 3 retries
                }
            }
        }
        
        uploadQueue.removeAll { successfulIds.contains($0.id) }
        saveUploadQueue()
    }
    
    public func extractFileId(from driveUrl: String) -> String? {
        // e.g. https://drive.google.com/file/d/1ABC1234567/view
        let pattern = "/d/([a-zA-Z0-9_-]+)"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: driveUrl, options: [], range: NSRange(location: 0, length: driveUrl.utf16.count)),
           let range = Range(match.range(at: 1), in: driveUrl) {
            return String(driveUrl[range])
        }
        return nil
    }
    
    private func saveUploadQueue() {
        if let data = try? JSONEncoder().encode(uploadQueue) {
            UserDefaults.standard.set(data, forKey: "FinsightUploadQueue")
        }
    }
    
    private func loadUploadQueue() {
        if let data = UserDefaults.standard.data(forKey: "FinsightUploadQueue"),
           let queue = try? JSONDecoder().decode([PendingUpload].self, from: data) {
            self.uploadQueue = queue
        }
    }
}
