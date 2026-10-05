import Foundation



public extension Decimal {
    func formattedAsCurrency(currency: Currency = .inr) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue.uppercased()
        return formatter.string(from: self as NSDecimalNumber) ?? ""
    }
    
    var formattedAsCompact: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        let doubleValue = NSDecimalNumber(decimal: self).doubleValue
        if doubleValue >= 100_000 {
            let lakhs = doubleValue / 100_000
            return "₹\(formatter.string(from: NSNumber(value: lakhs)) ?? "")L"
        } else if doubleValue >= 1_000 {
            let k = doubleValue / 1_000
            return "₹\(formatter.string(from: NSNumber(value: k)) ?? "")K"
        } else {
            return formattedAsCurrency()
        }
    }
    
    var abs: Decimal {
        self < 0 ? -self : self
    }
    
    var isPositive: Bool { self > 0 }
    var isNegative: Bool { self < 0 }
    var isZero: Bool { self == 0 }
}
