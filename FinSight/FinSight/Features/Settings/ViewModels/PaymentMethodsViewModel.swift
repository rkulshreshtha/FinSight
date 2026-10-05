import Foundation
import Observation
import SwiftUI

@Observable
public class PaymentMethodsViewModel {
    public var paymentMethods: [PaymentMethod] = []
    public var groupedMethods: [(PaymentMethodType, [PaymentMethod])] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    public var showAddForm: Bool = false
    public var editingMethod: PaymentMethod? = nil
    
    private let repository: PaymentMethodRepository
    
    public init(repository: PaymentMethodRepository) {
        self.repository = repository
    }
    
    @MainActor
    public func loadPaymentMethods() async {
        isLoading = true
        errorMessage = nil
        do {
            self.paymentMethods = repository.paymentMethods
            groupMethods()
        }
        isLoading = false
    }
    
    @MainActor
    public func deletePaymentMethod(_ method: PaymentMethod) async {
        paymentMethods.removeAll { $0.id == method.id }
        repository.paymentMethods = paymentMethods
        groupMethods()
    }
    
    @MainActor
    public func setDefault(_ method: PaymentMethod) async {
        for i in 0..<paymentMethods.count {
            paymentMethods[i].isDefault = (paymentMethods[i].id == method.id)
        }
        repository.paymentMethods = paymentMethods
        groupMethods()
    }
    
    public func groupMethods() {
        let dictionary = Dictionary(grouping: paymentMethods, by: { $0.type })
        
        let order: [PaymentMethodType] = [.creditCard, .debitCard, .bankTransfer, .wallet, .upi, .cash]
        
        var grouped: [(PaymentMethodType, [PaymentMethod])] = []
        for type in order {
            if let methods = dictionary[type], !methods.isEmpty {
                grouped.append((type, methods))
            }
        }
        self.groupedMethods = grouped
    }
}
