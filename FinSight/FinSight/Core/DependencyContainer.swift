import SwiftUI

@Observable
public final class DependencyContainer: @unchecked Sendable {
    public let authService: FirebaseAuthService
    public let dataService: FirestoreService
    public let aiService: GeminiAIService
    public let driveService: GoogleDriveService
    public let notificationService: LocalNotificationService
    public let imageCaptureManager: ImageCaptureManager
    public let dataRetentionService: DataRetentionService
    public let exportService: ExportService
    public let transactionRepository: TransactionRepository
    public let paymentMethodRepository: PaymentMethodRepository
    public let budgetRepository: BudgetRepository
    
    public init() {
        self.authService = FirebaseAuthService()
        let firestoreService = FirestoreService()
        self.dataService = firestoreService
        self.aiService = GeminiAIService()
        self.driveService = GoogleDriveService()
        self.notificationService = LocalNotificationService()
        self.imageCaptureManager = ImageCaptureManager()
        self.dataRetentionService = DataRetentionService(dataService: firestoreService)
        self.exportService = ExportService()
        
        self.transactionRepository = TransactionRepository(dataService: firestoreService)
        self.paymentMethodRepository = PaymentMethodRepository(dataService: firestoreService)
        self.budgetRepository = BudgetRepository(dataService: firestoreService)
    }
}

private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer()
}

extension EnvironmentValues {
    public var container: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
