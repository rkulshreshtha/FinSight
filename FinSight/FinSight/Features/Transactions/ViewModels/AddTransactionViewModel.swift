import Foundation
import Observation

public enum FormMode {
    case add
    case edit(Transaction)
}

public struct EditablePaymentSplit: Identifiable {
    public let id = UUID()
    public var methodId: String
    public var amountText: String
    
    public init(methodId: String, amountText: String) {
        self.methodId = methodId
        self.amountText = amountText
    }
}

public struct EditableLineItem: Identifiable {
    public let id = UUID()
    public var name: String
    public var quantityText: String
    public var unitPriceText: String
    public var unit: String
    public var lineTotalText: String
    public var source: ItemSource
    public var isAISuggested: Bool
    
    public init(name: String, quantityText: String, unitPriceText: String, unit: String, lineTotalText: String, source: ItemSource, isAISuggested: Bool) {
        self.name = name
        self.quantityText = quantityText
        self.unitPriceText = unitPriceText
        self.unit = unit
        self.lineTotalText = lineTotalText
        self.source = source
        self.isAISuggested = isAISuggested
    }
}

public struct ImageAttachment: Identifiable {
    public let id = UUID()
    public var imageData: Data?
    public var localPath: String?
    public var driveLink: String?
    public var isUploading: Bool
    public var thumbnail: Data?
    
    public init(imageData: Data? = nil, localPath: String? = nil, driveLink: String? = nil, isUploading: Bool = false, thumbnail: Data? = nil) {
        self.imageData = imageData
        self.localPath = localPath
        self.driveLink = driveLink
        self.isUploading = isUploading
        self.thumbnail = thumbnail
    }
}

@Observable
public final class AddTransactionViewModel {
    public var mode: FormMode
    public var transactionType: TransactionType = .expense
    public var amountText: String = "" {
        didSet {
            // Update items/splits total logic if necessary
        }
    }
    public var amount: Decimal {
        Decimal(string: amountText) ?? 0
    }
    public var currency: Currency = .inr
    public var exchangeRate: Decimal?
    public var equivalentINR: Decimal {
        if let rate = exchangeRate { return amount * rate }
        return amount
    }
    public var title: String = ""
    public var description: String = ""
    public var date: Date = Date()
    public var selectedCategories: [String] = []
    public var availableCategories: [String] = []
    public var aiSuggestedCategories: [String] = []
    public var showAISuggestion: Bool = false
    public var selectedPaymentMethodId: String? = nil
    public var isSplitPayment: Bool = false
    public var paymentSplits: [EditablePaymentSplit] = []
    public var availablePaymentMethods: [PaymentMethod] = []
    public var note: String = ""
    public var location: GeoLocation?
    public var showLocationPicker: Bool = false
    public var items: [EditableLineItem] = []
    public var attachedImages: [ImageAttachment] = []
    public var isRecurring: Bool = false
    public var recurringFrequency: RecurringFrequency = .monthly
    public var isFlagged: Bool = false
    public var flagNote: String = ""
    public var isShared: Bool = false
    public var sharedWith: String = ""
    public var isExpected: Bool = false
    public var expectedDate: Date = Date()
    public var isLoading: Bool = false
    public var isSaving: Bool = false
    public var errorMessage: String? = nil
    public var showCamera: Bool = false
    public var showGallery: Bool = false
    public var showCurrencyPicker: Bool = false

    private let aiService: AIServiceProtocol
    private let dataService: DataServiceProtocol
    private let transactionRepo: TransactionRepository
    private let paymentMethodRepo: PaymentMethodRepository
    
    public init(
        mode: FormMode = .add,
        aiService: AIServiceProtocol = GeminiAIService(),
        dataService: DataServiceProtocol = FirestoreService(),
        transactionRepo: TransactionRepository = TransactionRepository(dataService: FirestoreService()),
        paymentMethodRepo: PaymentMethodRepository = PaymentMethodRepository(dataService: FirestoreService())
    ) {
        self.mode = mode
        self.aiService = aiService
        self.dataService = dataService
        self.transactionRepo = transactionRepo
        self.paymentMethodRepo = paymentMethodRepo
        
        if case .edit(let transaction) = mode {
            self.transactionType = transaction.type
            self.amountText = "\(transaction.amount)"
            self.currency = transaction.currency
            self.exchangeRate = transaction.exchangeRate
            self.title = transaction.title
            self.description = transaction.description ?? ""
            self.date = transaction.date
            self.selectedCategories = transaction.categories
            if !transaction.paymentSplits.isEmpty {
                self.isSplitPayment = true
                self.paymentSplits = transaction.paymentSplits.map { EditablePaymentSplit(methodId: $0.methodId, amountText: "\($0.amount)") }
            }
            self.note = transaction.note ?? ""
            self.location = transaction.location
            self.items = transaction.items.map {
                EditableLineItem(name: $0.name, quantityText: "\($0.quantity)", unitPriceText: $0.unitPrice != nil ? "\($0.unitPrice!)" : "", unit: $0.unit ?? "", lineTotalText: "\($0.lineTotal)", source: $0.source, isAISuggested: false)
            }
            self.isRecurring = transaction.isRecurring
            self.recurringFrequency = transaction.recurringFrequency ?? .monthly
            self.isFlagged = transaction.isFlagged
            self.flagNote = transaction.flagNote ?? ""
            self.isShared = transaction.isShared
            self.sharedWith = transaction.sharedWith ?? ""
            self.isExpected = transaction.isExpected
        }
    }
    
    public func loadPaymentMethods() async {
        do {
            self.availablePaymentMethods = try await dataService.getPaymentMethods()
            if selectedPaymentMethodId == nil && !availablePaymentMethods.isEmpty && !isSplitPayment {
                selectedPaymentMethodId = availablePaymentMethods.first(where: { $0.isDefault })?.id ?? availablePaymentMethods.first?.id
            }
        } catch {
            self.errorMessage = "Failed to load payment methods"
        }
    }
    
    public func loadCategories() async {
        self.availableCategories = ["Food", "Transport", "Rent", "Groceries", "Utilities"]
    }
    
    public func requestAICategorization() async {
        self.isLoading = true
        do {
            // Mock AI category suggestions
            self.aiSuggestedCategories = ["Dining", "Entertainment"]
            self.showAISuggestion = !self.aiSuggestedCategories.isEmpty
        } catch {
            self.errorMessage = "Failed to get AI suggestions"
        }
        self.isLoading = false
    }
    
    public func acceptAISuggestion() {
        for cat in aiSuggestedCategories {
            addCategory(cat)
        }
        showAISuggestion = false
    }
    
    public func addCategory(_ name: String) {
        if !selectedCategories.contains(name) {
            selectedCategories.append(name)
        }
    }
    
    public func removeCategory(_ name: String) {
        selectedCategories.removeAll { $0 == name }
    }
    
    public func addItem() {
        items.append(EditableLineItem(name: "", quantityText: "1", unitPriceText: "", unit: "", lineTotalText: "", source: .manual, isAISuggested: false))
    }
    
    public func removeItem(at index: Int) {
        if index >= 0 && index < items.count {
            items.remove(at: index)
        }
    }
    
    public func addPaymentSplit() {
        if let firstMethod = availablePaymentMethods.first {
            paymentSplits.append(EditablePaymentSplit(methodId: firstMethod.id, amountText: ""))
        }
    }
    
    public func removePaymentSplit(at index: Int) {
        if index >= 0 && index < paymentSplits.count {
            paymentSplits.remove(at: index)
        }
    }
    
    public func validateForm() -> Bool {
        return !title.isEmpty && amount > 0
    }
    
    public func save() async throws {
        self.isSaving = true
        defer { self.isSaving = false }
        
        let finalSplits: [PaymentSplit]
        if isSplitPayment {
            finalSplits = paymentSplits.compactMap { split in
                guard let amt = Decimal(string: split.amountText) else { return nil }
                return PaymentSplit(methodId: split.methodId, amount: amt)
            }
        } else if let methodId = selectedPaymentMethodId {
            finalSplits = [PaymentSplit(methodId: methodId, amount: amount)]
        } else {
            finalSplits = []
        }
        
        let finalItems = items.compactMap { item -> LineItem? in
            guard let qty = Decimal(string: item.quantityText),
                  let total = Decimal(string: item.lineTotalText) else { return nil }
            return LineItem(name: item.name, quantity: qty, unit: item.unit.isEmpty ? nil : item.unit, unitPrice: Decimal(string: item.unitPriceText), lineTotal: total, source: item.source)
        }
        
        let transaction = Transaction(
            id: {
                if case .edit(let t) = mode { return t.id }
                return UUID().uuidString
            }(),
            type: transactionType,
            amount: amount,
            currency: currency,
            exchangeRate: exchangeRate,
            title: title,
            description: description.isEmpty ? nil : description,
            date: date,
            categories: selectedCategories,
            paymentSplits: finalSplits,
            note: note.isEmpty ? nil : note,
            location: location,
            items: finalItems,
            isRecurring: isRecurring,
            recurringFrequency: isRecurring ? recurringFrequency : nil,
            isFlagged: isFlagged,
            flagNote: flagNote.isEmpty ? nil : flagNote,
            isShared: isShared,
            sharedWith: isShared ? sharedWith : nil,
            isExpected: isExpected,
            source: .manual
        )
        
        try await dataService.saveTransaction(transaction)
    }
    
    public func delete() async throws {
        if case .edit(let transaction) = mode {
            try await dataService.deleteTransaction(id: transaction.id)
        }
    }
    
    public func fetchExchangeRate() async {
        // Example mock
        if currency != .inr {
            exchangeRate = 83.5
        } else {
            exchangeRate = nil
        }
    }
    
    public var splitTotal: Decimal {
        paymentSplits.reduce(0) { $0 + (Decimal(string: $1.amountText) ?? 0) }
    }
    
    public var itemsSubtotal: Decimal {
        items.reduce(0) { $0 + (Decimal(string: $1.lineTotalText) ?? 0) }
    }
    
    public var isValid: Bool {
        validateForm()
    }
    
    public var canSave: Bool {
        isValid && splitMismatchMessage == nil && itemsMismatchMessage == nil
    }
    
    public var splitMismatchMessage: String? {
        if isSplitPayment && splitTotal != amount {
            return "Split total (\(splitTotal)) doesn't match amount (\(amount))"
        }
        return nil
    }
    
    public var itemsMismatchMessage: String? {
        if !items.isEmpty && itemsSubtotal != amount {
            return "Items subtotal (\(itemsSubtotal)) doesn't match amount (\(amount))"
        }
        return nil
    }
}
