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
    
    public init(repository: PaymentMethodRepository = PaymentMethodRepository(dataService: FirestoreService())) {
        self.repository = repository
    }
    
    @MainActor
    public func loadPaymentMethods() async {
        isLoading = true
        errorMessage = nil
        do {
            try await repository.fetchPaymentMethods()
            self.paymentMethods = repository.paymentMethods
            groupMethods()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    @MainActor
    public func savePaymentMethod(_ method: PaymentMethod) async {
        do {
            try await repository.savePaymentMethod(method)
            self.paymentMethods = repository.paymentMethods
            groupMethods()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    public func deletePaymentMethod(_ method: PaymentMethod) async {
        do {
            try await repository.deletePaymentMethod(id: method.id)
            self.paymentMethods = repository.paymentMethods
            groupMethods()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    public func setDefault(_ method: PaymentMethod) async {
        for var m in paymentMethods {
            m.isDefault = (m.id == method.id)
            try? await repository.savePaymentMethod(m)
        }
        self.paymentMethods = repository.paymentMethods
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
