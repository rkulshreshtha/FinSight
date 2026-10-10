import Foundation
import Observation

@Observable
public final class PaymentMethodRepository {
    private let dataService: DataServiceProtocol
    public var paymentMethods: [PaymentMethod] = []
    
    public init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    public func fetchPaymentMethods() async throws {
        self.paymentMethods = try await dataService.getPaymentMethods()
    }
    
    public func savePaymentMethod(_ method: PaymentMethod) async throws {
        try await dataService.savePaymentMethod(method)
        if let idx = paymentMethods.firstIndex(where: { $0.id == method.id }) {
            paymentMethods[idx] = method
        } else {
            paymentMethods.append(method)
        }
    }
    
    public func deletePaymentMethod(id: String) async throws {
        try await dataService.deletePaymentMethod(id: id)
        paymentMethods.removeAll(where: { $0.id == id })
    }
}
