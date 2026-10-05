import XCTest

final class FinSightTests: XCTestCase {
    func testTransactionCreation() throws {
        let transaction = Transaction(
            type: .expense,
            amount: 1500,
            title: "BigBasket Groceries",
            date: Date(),
            source: .manual
        )
        
        XCTAssertEqual(transaction.type, .expense)
        XCTAssertEqual(transaction.amount, 1500)
        XCTAssertFalse(transaction.isCredit)
        XCTAssertEqual(transaction.signedAmount, -1500)
        XCTAssertEqual(transaction.currency, .inr)
    }
}
