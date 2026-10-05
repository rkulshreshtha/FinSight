import Foundation

public enum TransactionType: String, Codable, Hashable, CaseIterable, Identifiable {
    case income
    case expense
    case transfer
    case investment
    case loanGiven
    case loanReceived
    case cashback
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .income: return "Income"
        case .expense: return "Expense"
        case .transfer: return "Transfer"
        case .investment: return "Investment"
        case .loanGiven: return "Loan Given"
        case .loanReceived: return "Loan Received"
        case .cashback: return "Cashback"
        }
    }
    
    public var isCredit: Bool {
        switch self {
        case .income, .loanReceived, .cashback, .investment: return true
        case .expense, .loanGiven, .transfer: return false
        }
    }
}

public enum PaymentMethodType: String, Codable, Hashable, CaseIterable, Identifiable {
    case creditCard
    case debitCard
    case bankTransfer
    case wallet
    case upi
    case cash
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .creditCard: return "Credit Card"
        case .debitCard: return "Debit Card"
        case .bankTransfer: return "Bank Transfer"
        case .wallet: return "Wallet"
        case .upi: return "UPI"
        case .cash: return "Cash"
        }
    }
    
    public var iconName: String {
        switch self {
        case .creditCard: return "creditcard"
        case .debitCard: return "creditcard"
        case .bankTransfer: return "building.columns"
        case .wallet: return "wallet.pass"
        case .upi: return "qrcode.viewfinder"
        case .cash: return "banknote"
        }
    }
}

public enum CardNetwork: String, Codable, Hashable, CaseIterable, Identifiable {
    case visa
    case mastercard
    case amex
    case rupay
    case other
    
    public var id: String { rawValue }
}

public enum Currency: String, Codable, Hashable, CaseIterable, Identifiable {
    case inr
    case usd
    case eur
    case gbp
    
    public var id: String { rawValue }
    
    public var symbol: String {
        switch self {
        case .inr: return "₹"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        }
    }
    
    public var displayName: String {
        switch self {
        case .inr: return "Indian Rupee"
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        }
    }
}

public enum RecurringFrequency: String, Codable, Hashable, CaseIterable, Identifiable {
    case daily, weekly, biWeekly, monthly, quarterly, semiAnnually, yearly
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .biWeekly: return "Bi-Weekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .semiAnnually: return "Semi-Annually"
        case .yearly: return "Yearly"
        }
    }
    
    public var calendarComponent: Calendar.Component {
        switch self {
        case .daily: return .day
        case .weekly, .biWeekly: return .weekOfYear
        case .monthly: return .month
        case .quarterly, .semiAnnually: return .quarter
        case .yearly: return .year
        }
    }
}

public enum TransactionSource: String, Codable, Hashable, CaseIterable, Identifiable {
    case manual
    case ocr
    case sms
    case shareExtension
    
    public var id: String { rawValue }
}

public enum SyncStatus: String, Codable, Hashable, CaseIterable, Identifiable {
    case synced
    case pending
    case conflict
    
    public var id: String { rawValue }
}

public enum BudgetPeriod: String, Codable, Hashable, CaseIterable, Identifiable {
    case weekly
    case monthly
    
    public var id: String { rawValue }
}

public enum ReminderStatus: String, Codable, Hashable, CaseIterable, Identifiable {
    case upcoming
    case dueToday
    case overdue
    case completed
    case snoozed
    
    public var id: String { rawValue }
}

public enum ExpectedTransactionStatus: String, Codable, Hashable, CaseIterable, Identifiable {
    case pending
    case completed
    case cancelled
    
    public var id: String { rawValue }
}

public enum ItemSource: String, Codable, Hashable, CaseIterable, Identifiable {
    case ocr
    case manual
    
    public var id: String { rawValue }
}
