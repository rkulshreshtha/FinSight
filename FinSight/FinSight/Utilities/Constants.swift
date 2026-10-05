import Foundation

public enum UserDefaultsKeys: String {
    case appTheme
    case hasSeenOnboarding
}

public struct Constants {
    public struct Formatters {
        public static let shortDate: DateFormatter = {
            let df = DateFormatter()
            df.dateStyle = .short
            return df
        }()
        
        public static let mediumDate: DateFormatter = {
            let df = DateFormatter()
            df.dateStyle = .medium
            return df
        }()
        
        public static let timeOnly: DateFormatter = {
            let df = DateFormatter()
            df.timeStyle = .short
            return df
        }()
        
        public static let monthYear: DateFormatter = {
            let df = DateFormatter()
            df.dateFormat = "MMMM yyyy"
            return df
        }()
        
        public static let currencyFormat: NumberFormatter = {
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.currencyCode = "INR"
            return nf
        }()
        
        public static let decimalFormat: NumberFormatter = {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.maximumFractionDigits = 2
            return nf
        }()
        
        public static let percentFormat: NumberFormatter = {
            let nf = NumberFormatter()
            nf.numberStyle = .percent
            nf.maximumFractionDigits = 1
            return nf
        }()
    }
    
    public struct Animation {
        public static let standard: Double = 0.3
        public static let slow: Double = 0.5
        public static let fast: Double = 0.15
    }
    
    public struct FirestorePaths {
        public static let users = "users"
        public static let transactions = "transactions"
        public static let categories = "categories"
        public static let budgets = "budgets"
    }
}
