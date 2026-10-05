import Foundation

public final class ExchangeRateService {
    public init() {}
    
    public func fetchRate(from: Currency, to: Currency, date: Date) async throws -> Decimal {
        return 1.0
    }
}
