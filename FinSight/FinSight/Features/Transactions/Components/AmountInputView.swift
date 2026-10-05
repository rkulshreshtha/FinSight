import SwiftUI

public struct AmountInputView: View {
    @Binding var amountText: String
    @Binding var currency: Currency
    var exchangeRate: Decimal?
    var onCurrencyTapped: () -> Void
    var onEditExchangeRateTapped: (() -> Void)?
    
    public init(amountText: Binding<String>, currency: Binding<Currency>, exchangeRate: Decimal? = nil, onCurrencyTapped: @escaping () -> Void, onEditExchangeRateTapped: (() -> Void)? = nil) {
        self._amountText = amountText
        self._currency = currency
        self.exchangeRate = exchangeRate
        self.onCurrencyTapped = onCurrencyTapped
        self.onEditExchangeRateTapped = onEditExchangeRateTapped
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(currency.symbol)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primary)
                
                TextField("0.00", text: $amountText)
                    .font(.system(size: 40, weight: .bold))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
                    .accessibilityLabel("Transaction Amount")
                
                Button(action: onCurrencyTapped) {
                    HStack {
                        Text(currency.rawValue.uppercased())
                        Image(systemName: "chevron.down")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
                }
                .accessibilityLabel("Select Currency")
            }
            
            if currency != .inr, let rate = exchangeRate {
                HStack {
                    Text("1 \(currency.rawValue.uppercased()) = ₹\(NSDecimalNumber(decimal: rate).stringValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let onEditExchangeRateTapped = onEditExchangeRateTapped {
                        Button(action: onEditExchangeRateTapped) {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.App.accentPrimary)
                        }
                        .accessibilityLabel("Edit Exchange Rate")
                    }
                    
                    Spacer()
                    
                    if let amount = Decimal(string: amountText) {
                        Text("Equivalent: ₹\(NSDecimalNumber(decimal: amount * rate).stringValue)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.App.cardBackground)
        .cornerRadius(12)
    }
}
