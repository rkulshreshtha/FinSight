import os

base_path = "/Users/gurudev122/Documents/AI Practise/FinSight/FinSight/Core"
os.makedirs(os.path.join(base_path, "Services"), exist_ok=True)
os.makedirs(os.path.join(base_path, "Repositories"), exist_ok=True)

def write_file(path, content):
    full_path = os.path.join(base_path, path)
    with open(full_path, "w") as f:
        f.write(content)

auth_proto = """import Foundation

public struct UserProfile: Codable, Identifiable {
    public let id: String
    public var email: String
    public var displayName: String?
    
    public init(id: String, email: String, displayName: String?) {
        self.id = id
        self.email = email
        self.displayName = displayName
    }
}

public protocol AuthServiceProtocol {
    var currentUser: UserProfile? { get }
    var isAuthenticated: Bool { get }
    func signInWithEmail(email: String, password: String) async throws -> UserProfile
    func signUpWithEmail(email: String, password: String, displayName: String) async throws -> UserProfile
    func signInWithApple() async throws -> UserProfile
    func signInWithGoogle() async throws -> UserProfile
    func signOut() throws
    func resetPassword(email: String) async throws
    func deleteAccount() async throws
}
"""

ai_proto = """import Foundation

public struct LineItem: Codable {
    public var name: String
    public var quantity: Double
    public var price: Decimal
}

public struct ReceiptExtractionResult: Codable {
    public var merchant: String
    public var amount: Decimal
    public var date: Date
    public var items: [LineItem]
    public var rawText: String
    public var detectedLanguage: String
}

public struct SMSParseResult: Codable {
    public var amount: Decimal
    public var merchant: String
    public var date: Date
    public var cardLast4: String
    public var transactionType: String
    public var rawText: String
}

public struct RecurringPattern: Codable {
    public var title: String
    public var amount: Decimal
    public var frequency: String
    public var confidence: Double
    public var matchingTransactionIds: [String]
}

public struct ExpectedTransactionMatch: Codable {
    public var expectedId: String
    public var confidence: Double
    public var matchReason: String
}

public struct CategoryCorrection: Codable {
    public var original: String
    public var corrected: String
}

public struct Currency: Codable {
    public var code: String
}

public struct Transaction: Codable, Identifiable {
    public var id: String
    public var title: String
    public var amount: Decimal
    public var date: Date
    public var category: String
}

public struct ExpectedTransaction: Codable, Identifiable {
    public var id: String
}

public protocol AIServiceProtocol {
    func extractReceiptData(from image: Data) async throws -> ReceiptExtractionResult
    func translateText(_ text: String, from: String?, to: String) async throws -> String
    func suggestCategories(for title: String, description: String?, ocrText: String?, corrections: [CategoryCorrection]) async throws -> [String]
    func parseFinancialSMS(_ smsText: String) async throws -> SMSParseResult
    func detectRecurringPatterns(transactions: [Transaction]) async throws -> [RecurringPattern]
    func fetchExchangeRate(from: Currency, to: Currency, date: Date) async throws -> Decimal
    func matchExpectedTransaction(credit: Transaction, expectations: [ExpectedTransaction]) async throws -> ExpectedTransactionMatch?
}
"""

data_proto = """import Foundation

public struct PaymentMethod: Codable, Identifiable { public var id: String }
public struct Budget: Codable, Identifiable { public var id: String; public var amount: Decimal }
public struct RecurringRule: Codable, Identifiable { public var id: String }
public struct Reminder: Codable, Identifiable { public var id: String }

public struct TransactionFilter: Codable {
    public var dateRange: ClosedRange<Date>?
    public var types: [String]?
    public var categories: [String]?
    public var paymentMethodIds: [String]?
    public var cardLast4: String?
    public var bankName: String?
    public var isFlagged: Bool?
    public var isShared: Bool?
    public var amountRange: ClosedRange<Decimal>?
    public var searchText: String?
    public var itemSearchText: String?
    
    public init() {}
}

public protocol DataServiceProtocol {
    func getTransactions(filter: TransactionFilter) async throws -> [Transaction]
    func searchTransactions(query: String) async throws -> [Transaction]
    func getTotals(filter: TransactionFilter) async throws -> (credits: Decimal, debits: Decimal, net: Decimal, count: Int)
    func saveTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(id: String) async throws
    
    func getPaymentMethods() async throws -> [PaymentMethod]
    func savePaymentMethod(_ method: PaymentMethod) async throws
    
    func getBudgets() async throws -> [Budget]
    func saveBudget(_ budget: Budget) async throws
}
"""

image_proto = """import Foundation
import CoreGraphics

public protocol ImageServiceProtocol {
    func compressImage(_ data: Data, maxSizeKB: Int, maxDimension: CGFloat) -> Data
    func uploadToGDrive(_ data: Data, fileName: String) async throws -> String
    func downloadImage(from url: String) async throws -> Data
    func deleteFromGDrive(fileId: String) async throws
}
"""

notif_proto = """import Foundation

public protocol NotificationServiceProtocol {
    func requestPermission() async throws -> Bool
    func scheduleDailySummary(at time: String, spent: Decimal, count: Int)
    func scheduleBudgetAlert(budget: Budget, currentSpent: Decimal)
    func scheduleFlagReminder(count: Int)
    func schedulePaymentReminder(reminder: Reminder)
    func scheduleExportWarning(daysUntilPurge: Int)
    func cancelAll()
    func cancelNotification(id: String)
}
"""

auth_impl = """import Foundation
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn
import Observation

public enum AuthError: LocalizedError {
    case notConfigured
    case invalidCredentials
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .notConfigured: return "Authentication is not configured properly."
        case .invalidCredentials: return "Invalid credentials provided."
        case .unknown: return "An unknown error occurred."
        }
    }
}

@Observable
public final class FirebaseAuthService: AuthServiceProtocol {
    public var currentUser: UserProfile?
    public var isAuthenticated: Bool { currentUser != nil }
    
    public init() {}
    
    public func signInWithEmail(email: String, password: String) async throws -> UserProfile {
        let profile = UserProfile(id: UUID().uuidString, email: email, displayName: nil)
        self.currentUser = profile
        return profile
    }
    
    public func signUpWithEmail(email: String, password: String, displayName: String) async throws -> UserProfile {
        let profile = UserProfile(id: UUID().uuidString, email: email, displayName: displayName)
        self.currentUser = profile
        return profile
    }
    
    public func signInWithApple() async throws -> UserProfile {
        throw AuthError.notConfigured
    }
    
    public func signInWithGoogle() async throws -> UserProfile {
        throw AuthError.notConfigured
    }
    
    public func signOut() throws {
        self.currentUser = nil
    }
    
    public func resetPassword(email: String) async throws {}
    
    public func deleteAccount() async throws {
        self.currentUser = nil
    }
}
"""

firestore_impl = """import Foundation
import FirebaseFirestore
import Observation

public enum DataError: LocalizedError {
    case documentNotFound
    case decodingError
    case unknown
}

@Observable
public final class FirestoreService: DataServiceProtocol {
    public init() {}
    
    public func getTransactions(filter: TransactionFilter) async throws -> [Transaction] {
        return []
    }
    
    public func searchTransactions(query: String) async throws -> [Transaction] {
        return []
    }
    
    public func getTotals(filter: TransactionFilter) async throws -> (credits: Decimal, debits: Decimal, net: Decimal, count: Int) {
        return (0, 0, 0, 0)
    }
    
    public func saveTransaction(_ transaction: Transaction) async throws {}
    public func deleteTransaction(id: String) async throws {}
    
    public func getPaymentMethods() async throws -> [PaymentMethod] { return [] }
    public func savePaymentMethod(_ method: PaymentMethod) async throws {}
    
    public func getBudgets() async throws -> [Budget] { return [] }
    public func saveBudget(_ budget: Budget) async throws {}
}
"""

gemini_impl = """import Foundation
import GoogleGenerativeAI
import Observation

@Observable
public final class GeminiAIService: AIServiceProtocol {
    public init() {}
    
    public func extractReceiptData(from image: Data) async throws -> ReceiptExtractionResult {
        return ReceiptExtractionResult(merchant: "Unknown", amount: 0, date: Date(), items: [], rawText: "", detectedLanguage: "en")
    }
    
    public func translateText(_ text: String, from: String?, to: String) async throws -> String {
        return text
    }
    
    public func suggestCategories(for title: String, description: String?, ocrText: String?, corrections: [CategoryCorrection]) async throws -> [String] {
        return ["Groceries", "Dining"]
    }
    
    public func parseFinancialSMS(_ smsText: String) async throws -> SMSParseResult {
        return SMSParseResult(amount: 0, merchant: "Unknown", date: Date(), cardLast4: "0000", transactionType: "debit", rawText: smsText)
    }
    
    public func detectRecurringPatterns(transactions: [Transaction]) async throws -> [RecurringPattern] {
        return []
    }
    
    public func fetchExchangeRate(from: Currency, to: Currency, date: Date) async throws -> Decimal {
        return 1.0
    }
    
    public func matchExpectedTransaction(credit: Transaction, expectations: [ExpectedTransaction]) async throws -> ExpectedTransactionMatch? {
        return nil
    }
}
"""

image_impl = """import Foundation
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
"""

exchange_impl = """import Foundation

public final class ExchangeRateService {
    public init() {}
    
    public func fetchRate(from: Currency, to: Currency, date: Date) async throws -> Decimal {
        return 1.0
    }
}
"""

repo_trans = """import Foundation
import Observation

@Observable
public final class TransactionRepository {
    private let dataService: DataServiceProtocol
    public var recentTransactions: [Transaction] = []
    
    public init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    public func fetchRecent() async throws {
        self.recentTransactions = try await dataService.getTransactions(filter: TransactionFilter())
    }
}
"""

repo_pay = """import Foundation
import Observation

@Observable
public final class PaymentMethodRepository {
    private let dataService: DataServiceProtocol
    public var paymentMethods: [PaymentMethod] = []
    
    public init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
}
"""

repo_budget = """import Foundation
import Observation

public enum BudgetStatus {
    case safe, warning, danger, exceeded
}

@Observable
public final class BudgetRepository {
    private let dataService: DataServiceProtocol
    public var budgets: [Budget] = []
    
    public init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    public func computeSpent(for budget: Budget, transactions: [Transaction]) -> Decimal {
        return 0
    }
    
    public func progress(for budget: Budget, spent: Decimal) -> Double {
        return 0.0
    }
    
    public func budgetStatus(progress: Double) -> BudgetStatus {
        if progress >= 1.0 { return .exceeded }
        if progress >= 0.9 { return .danger }
        if progress >= 0.75 { return .warning }
        return .safe
    }
}
"""

write_file("Services/AuthServiceProtocol.swift", auth_proto)
write_file("Services/AIServiceProtocol.swift", ai_proto)
write_file("Services/DataServiceProtocol.swift", data_proto)
write_file("Services/ImageServiceProtocol.swift", image_proto)
write_file("Services/NotificationServiceProtocol.swift", notif_proto)

write_file("Services/FirebaseAuthService.swift", auth_impl)
write_file("Services/FirestoreService.swift", firestore_impl)
write_file("Services/GeminiAIService.swift", gemini_impl)
write_file("Services/ImageCompressionService.swift", image_impl)
write_file("Services/ExchangeRateService.swift", exchange_impl)

write_file("Repositories/TransactionRepository.swift", repo_trans)
write_file("Repositories/PaymentMethodRepository.swift", repo_pay)
write_file("Repositories/BudgetRepository.swift", repo_budget)

print("Files generated successfully.")
