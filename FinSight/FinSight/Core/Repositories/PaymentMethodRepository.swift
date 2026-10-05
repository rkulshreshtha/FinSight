import Foundation
import Observation

@Observable
public final class PaymentMethodRepository {
    private let dataService: DataServiceProtocol
    public var paymentMethods: [PaymentMethod] = []
    
    public init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
}
