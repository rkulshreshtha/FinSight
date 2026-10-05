import SwiftUI

public struct PaymentMethodFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var viewModel: PaymentMethodsViewModel
    let editingMethod: PaymentMethod?
    var onSave: (PaymentMethod) -> Void
    
    @State private var type: PaymentMethodType = .creditCard
    @State private var bankName: String = ""
    @State private var last4: String = ""
    @State private var cardNetwork: CardNetwork = .visa
    @State private var walletName: String = ""
    @State private var upiId: String = ""
    @State private var nickname: String = ""
    @State private var isDefault: Bool = false
    
    let walletSuggestions = ["Amazon Pay", "PhonePe", "Google Pay", "Paytm", "Freecharge", "MobiKwik", "PayZapp"]
    
    public init(viewModel: PaymentMethodsViewModel, editingMethod: PaymentMethod?, onSave: @escaping (PaymentMethod) -> Void) {
        self.viewModel = viewModel
        self.editingMethod = editingMethod
        self.onSave = onSave
        
        if let method = editingMethod {
            _type = State(initialValue: method.type)
            _bankName = State(initialValue: method.bankName ?? "")
            _last4 = State(initialValue: method.last4 ?? "")
            _cardNetwork = State(initialValue: method.cardNetwork ?? .visa)
            _walletName = State(initialValue: method.walletName ?? "")
            _upiId = State(initialValue: method.upiId ?? "")
            _nickname = State(initialValue: method.nickname)
            _isDefault = State(initialValue: method.isDefault)
        }
    }
    
    public var body: some View {
        Form {
            Section {
                Picker("Type", selection: $type) {
                    ForEach(PaymentMethodType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
            }
            
            Section(header: Text("Details")) {
                switch type {
                case .creditCard, .debitCard:
                    TextField("Bank Name", text: $bankName)
                    TextField("Last 4 Digits", text: $last4)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .onChange(of: last4) { _, newValue in
                            if newValue.count > 4 {
                                last4 = String(newValue.prefix(4))
                            }
                        }
                    Picker("Network", selection: $cardNetwork) {
                        ForEach(CardNetwork.allCases) { network in
                            Text(network.rawValue.capitalized).tag(network)
                        }
                    }
                case .bankTransfer:
                    TextField("Bank Name", text: $bankName)
                    TextField("Account Nickname", text: $nickname)
                case .wallet:
                    TextField("Wallet Name", text: $walletName)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(walletSuggestions, id: \.self) { suggestion in
                                Button(suggestion) {
                                    walletName = suggestion
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }
                    }
                case .upi:
                    TextField("UPI ID or App Name", text: $upiId)
                        #if os(iOS)
                        .keyboardType(.emailAddress)
                        #endif
                        #if os(iOS) || os(macOS)
                        .autocorrectionDisabled()
                        #endif
                case .cash:
                    Text("Cash")
                        .foregroundColor(.secondary)
                }
            }
            
            if type != .bankTransfer {
                Section(header: Text("Nickname (Optional)")) {
                    TextField("e.g. Personal Card", text: $nickname)
                }
            }
            
            Section {
                Toggle("Set as Default", isOn: $isDefault)
            }
        }
        .navigationTitle(editingMethod == nil ? "Add Method" : "Edit Method")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(!isValid)
            }
        }
        .onChange(of: type) { _, _ in
            generateNickname()
        }
    }
    
    private var isValid: Bool {
        switch type {
        case .creditCard, .debitCard:
            return !bankName.isEmpty && last4.count == 4
        case .bankTransfer:
            return !bankName.isEmpty
        case .wallet:
            return !walletName.isEmpty
        case .upi:
            return !upiId.isEmpty
        case .cash:
            return true
        }
    }
    
    private func generateNickname() {
        if nickname.isEmpty {
            switch type {
            case .creditCard, .debitCard:
                if !bankName.isEmpty && last4.count == 4 {
                    nickname = "\(bankName) \(cardNetwork.rawValue.capitalized) ····\(last4)"
                }
            case .wallet:
                if !walletName.isEmpty {
                    nickname = walletName
                }
            case .upi:
                if !upiId.isEmpty {
                    nickname = upiId
                }
            case .cash:
                nickname = "Cash"
            case .bankTransfer:
                break
            }
        }
    }
    
    private func save() {
        generateNickname()
        
        var method = editingMethod ?? PaymentMethod(type: type, nickname: nickname)
        method.type = type
        method.bankName = (type == .creditCard || type == .debitCard || type == .bankTransfer) ? bankName : nil
        method.last4 = (type == .creditCard || type == .debitCard) ? last4 : nil
        method.cardNetwork = (type == .creditCard || type == .debitCard) ? cardNetwork : nil
        method.walletName = type == .wallet ? walletName : nil
        method.upiId = type == .upi ? upiId : nil
        method.nickname = nickname.isEmpty ? type.displayName : nickname
        method.isDefault = isDefault
        
        onSave(method)
        dismiss()
    }
}
