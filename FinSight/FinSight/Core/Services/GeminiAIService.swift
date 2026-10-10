import Foundation
import GoogleGenerativeAI
import Observation

/// Full Gemini AI service implementation for FinSight.
/// Provides receipt OCR, translation, categorization, SMS parsing,
/// recurring detection, exchange rates, and expected transaction matching.
@Observable
public final class GeminiAIService: AIServiceProtocol {

    // MARK: - Properties

    private let textModel: GenerativeModel
    private let visionModel: GenerativeModel

    // MARK: - Initialization

    public init() {
        let apiKey = AppConfig.geminiAPIKey

        let modelName = AppConfig.geminiModel
        self.textModel = GenerativeModel(
            name: modelName,
            apiKey: apiKey
        )

        self.visionModel = GenerativeModel(
            name: modelName,
            apiKey: apiKey
        )
    }

    // MARK: - Receipt OCR & Item Extraction

    public func extractReceiptData(from image: Data) async throws -> ReceiptExtractionResult {
        let prompt = """
        Analyze this receipt image and extract the following information in JSON format:
        {
            "merchant": "store/merchant name",
            "amount": total amount as a number,
            "date": "YYYY-MM-DD" format if visible,
            "currency": "INR" or detected currency code,
            "items": [
                {
                    "name": "item name in English (translate if needed)",
                    "nameOriginal": "item name in original language if different",
                    "quantity": number (default 1),
                    "unit": "kg/pcs/L/etc or null",
                    "unitPrice": price per unit as number,
                    "lineTotal": total for this line as number
                }
            ],
            "rawText": "all text visible on the receipt",
            "detectedLanguage": "language code (en, hi, ta, kn, te, etc.)"
        }

        Rules:
        - Extract ALL individual items/products listed on the receipt
        - Translate item names to English if they are in another language, but preserve original in nameOriginal
        - If quantity or unit price is not clear, estimate from the line total
        - Amount should be the grand total
        - If date is not visible, return null for date
        - Return valid JSON only, no markdown formatting
        """

        let imagePart = ModelContent.Part.data(mimetype: "image/jpeg", image)
        let response = try await visionModel.generateContent(prompt, imagePart)

        guard let text = response.text else {
            throw AIServiceError.emptyResponse
        }

        return try parseReceiptJSON(text)
    }

    // MARK: - Translation

    public func translateText(_ text: String, from sourceLanguage: String?, to targetLanguage: String) async throws -> String {
        let sourceLang = sourceLanguage.map { " from \($0)" } ?? ""
        let prompt = """
        Translate the following text\(sourceLang) to \(targetLanguage). 
        Preserve the meaning and structure. Return ONLY the translated text, nothing else.

        Text:
        \(text)
        """

        let response = try await textModel.generateContent(prompt)
        guard let translated = response.text, !translated.isEmpty else {
            throw AIServiceError.emptyResponse
        }
        return translated.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Auto-Categorization

    public func suggestCategories(
        for title: String,
        description: String?,
        ocrText: String?,
        corrections: [CategoryCorrection]
    ) async throws -> [String] {
        var prompt = """
        Suggest 1-3 category labels for this financial transaction.
        
        Transaction: "\(title)"
        """

        if let desc = description, !desc.isEmpty {
            prompt += "\nDescription: \"\(desc)\""
        }
        if let ocr = ocrText, !ocr.isEmpty {
            prompt += "\nReceipt text: \"\(ocr.prefix(500))\""
        }

        // Include recent corrections as few-shot examples for learning
        if !corrections.isEmpty {
            prompt += "\n\nLearn from these past corrections (what I suggested vs what the user chose):"
            for correction in corrections.suffix(20) {
                prompt += "\n- \"\(correction.transactionTitle)\": suggested [\(correction.originalSuggestion.joined(separator: ", "))] → corrected to [\(correction.correctedTo.joined(separator: ", "))]"
            }
        }

        prompt += """
        
        
        Return ONLY a JSON array of category strings, e.g.: ["Groceries", "Food"]
        Use common category names like: Food, Groceries, Transport, Shopping, Bills, Health, Entertainment, Education, Travel, Dining, Subscriptions, Salary, Freelance, Investments, Insurance, Utilities, Rent, Personal Care, Gifts, Others.
        """

        let response = try await textModel.generateContent(prompt)
        guard let text = response.text else {
            throw AIServiceError.emptyResponse
        }

        return try parseCategoryJSON(text)
    }

    // MARK: - SMS Parsing

    public func parseFinancialSMS(_ smsText: String) async throws -> SMSParseResult {
        let prompt = """
        Parse this Indian bank SMS/financial message and extract transaction details in JSON format:
        {
            "amount": transaction amount as a number,
            "merchant": "merchant/payee name if mentioned",
            "date": "YYYY-MM-DD" if mentioned,
            "cardLast4": "last 4 digits of card if mentioned",
            "transactionType": "credit" or "debit",
            "accountInfo": "account or card info mentioned",
            "rawText": "the original SMS text"
        }

        SMS:
        \(smsText)

        Rules:
        - Common Indian bank SMS patterns: HDFC, SBI, ICICI, Axis, Kotak, etc.
        - Look for keywords: debited, credited, spent, received, withdrawn, transferred
        - Extract card/account numbers (last 4 digits like XX1234 or ****1234)
        - Amount formats: Rs., Rs, INR, ₹
        - Return valid JSON only
        """

        let response = try await textModel.generateContent(prompt)
        guard let text = response.text else {
            throw AIServiceError.emptyResponse
        }

        return try parseSMSJSON(text, originalText: smsText)
    }

    // MARK: - Recurring Pattern Detection

    public func detectRecurringPatterns(transactions: [Transaction]) async throws -> [RecurringPattern] {
        // Prepare a summary of transactions for analysis
        let summaries = transactions.prefix(200).map { tx in
            "\(tx.date.formatted(date: .numeric, time: .omitted)) | \(tx.title) | \(tx.type.rawValue) | ₹\(tx.amount)"
        }

        let prompt = """
        Analyze these financial transactions and identify recurring patterns.
        Look for transactions that repeat with similar amounts and regular intervals (weekly, monthly, etc.).

        Transactions (Date | Title | Type | Amount):
        \(summaries.joined(separator: "\n"))

        Return a JSON array of detected patterns:
        [
            {
                "title": "merchant/transaction name",
                "averageAmount": average amount as number,
                "frequency": "weekly" or "monthly" or "quarterly" or "yearly",
                "confidence": confidence score from 0.0 to 1.0,
                "occurrenceCount": number of matching transactions found
            }
        ]

        Rules:
        - Only include patterns with at least 3 occurrences
        - Allow ±10% variance in amounts
        - Confidence should be based on regularity of intervals and amount consistency
        - Return empty array [] if no patterns found
        - Return valid JSON only
        """

        let response = try await textModel.generateContent(prompt)
        guard let text = response.text else {
            return []
        }

        return try parseRecurringJSON(text)
    }

    // MARK: - Exchange Rate

    public func fetchExchangeRate(from sourceCurrency: Currency, to targetCurrency: Currency, date: Date) async throws -> Decimal {
        let dateStr = date.formatted(date: .numeric, time: .omitted)
        let prompt = """
        What was the exchange rate from \(sourceCurrency.rawValue.uppercased()) to \(targetCurrency.rawValue.uppercased()) on \(dateStr)?
        Return ONLY the numeric exchange rate as a single number, nothing else.
        For example: 83.45
        """

        let response = try await textModel.generateContent(prompt)
        guard let text = response.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let rate = Decimal(string: text) else {
            throw AIServiceError.parsingFailed("Could not parse exchange rate")
        }
        return rate
    }

    // MARK: - Expected Transaction Matching

    public func matchExpectedTransaction(
        credit: Transaction,
        expectations: [ExpectedTransaction]
    ) async throws -> ExpectedTransactionMatch? {
        guard !expectations.isEmpty else { return nil }

        let expectationSummaries = expectations.map { et in
            "ID: \(et.id) | Source: \(et.source) | Amount: ₹\(et.expectedAmount) | Expected by: \(et.expectedBy.formatted(date: .numeric, time: .omitted))"
        }

        let prompt = """
        A credit transaction was just recorded:
        - Amount: ₹\(credit.amount)
        - Title: \(credit.title)
        - Date: \(credit.date.formatted(date: .numeric, time: .omitted))
        - Description: \(credit.description ?? "none")

        Does this match any of these expected transactions?
        \(expectationSummaries.joined(separator: "\n"))

        If yes, return JSON:
        {
            "expectedId": "the matching expected transaction ID",
            "confidence": confidence from 0.0 to 1.0,
            "matchReason": "brief explanation"
        }

        If no match, return: null

        Rules:
        - Amount should be within ±5% tolerance
        - Consider source name similarity
        - Return valid JSON only
        """

        let response = try await textModel.generateContent(prompt)
        guard let text = response.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        if text.lowercased() == "null" || text.isEmpty {
            return nil
        }

        return try parseMatchJSON(text)
    }

    // MARK: - Private JSON Parsers

    private func parseReceiptJSON(_ text: String) throws -> ReceiptExtractionResult {
        let cleaned = cleanJSON(text)
        let data = Data(cleaned.utf8)

        struct ReceiptResponse: Decodable {
            let merchant: String?
            let amount: Double?
            let date: String?
            let items: [ItemResponse]?
            let rawText: String?
            let detectedLanguage: String?

            struct ItemResponse: Decodable {
                let name: String
                let nameOriginal: String?
                let quantity: Double?
                let unit: String?
                let unitPrice: Double?
                let lineTotal: Double?
            }
        }

        let decoded = try JSONDecoder().decode(ReceiptResponse.self, from: data)

        let lineItems: [LineItem] = (decoded.items ?? []).map { item in
            LineItem(
                name: item.name,
                nameTranslated: item.nameOriginal != item.name ? item.name : nil,
                quantity: Decimal(item.quantity ?? 1),
                unit: item.unit,
                unitPrice: item.unitPrice.map { Decimal($0) },
                lineTotal: Decimal(item.lineTotal ?? 0),
                source: .ocr
            )
        }

        var parsedDate: Date?
        if let dateStr = decoded.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            parsedDate = formatter.date(from: dateStr)
        }

        return ReceiptExtractionResult(
            merchant: decoded.merchant ?? "Unknown",
            amount: Decimal(decoded.amount ?? 0),
            date: parsedDate ?? Date(),
            items: lineItems,
            rawText: decoded.rawText ?? "",
            detectedLanguage: decoded.detectedLanguage ?? "en"
        )
    }

    private func parseCategoryJSON(_ text: String) throws -> [String] {
        let cleaned = cleanJSON(text)
        let data = Data(cleaned.utf8)
        let categories = try JSONDecoder().decode([String].self, from: data)
        return Array(categories.prefix(3))
    }

    private func parseSMSJSON(_ text: String, originalText: String) throws -> SMSParseResult {
        let cleaned = cleanJSON(text)
        let data = Data(cleaned.utf8)

        struct SMSResponse: Decodable {
            let amount: Double?
            let merchant: String?
            let date: String?
            let cardLast4: String?
            let transactionType: String?
        }

        let decoded = try JSONDecoder().decode(SMSResponse.self, from: data)

        return SMSParseResult(
            amount: Decimal(decoded.amount ?? 0),
            merchant: decoded.merchant ?? "Unknown",
            date: {
                if let dateStr = decoded.date {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.date(from: dateStr) ?? Date()
                }
                return Date()
            }(),
            cardLast4: decoded.cardLast4 ?? "",
            transactionType: decoded.transactionType ?? "debit",
            rawText: originalText
        )
    }

    private func parseRecurringJSON(_ text: String) throws -> [RecurringPattern] {
        let cleaned = cleanJSON(text)
        let data = Data(cleaned.utf8)

        struct PatternResponse: Decodable {
            let title: String
            let averageAmount: Double
            let frequency: String
            let confidence: Double
            let occurrenceCount: Int?
        }

        let decoded = try JSONDecoder().decode([PatternResponse].self, from: data)

        return decoded.map { pattern in
            RecurringPattern(
                title: pattern.title,
                amount: Decimal(pattern.averageAmount),
                frequency: pattern.frequency,
                confidence: pattern.confidence,
                matchingTransactionIds: []
            )
        }
    }

    private func parseMatchJSON(_ text: String) throws -> ExpectedTransactionMatch {
        let cleaned = cleanJSON(text)
        let data = Data(cleaned.utf8)

        struct MatchResponse: Decodable {
            let expectedId: String
            let confidence: Double
            let matchReason: String
        }

        let decoded = try JSONDecoder().decode(MatchResponse.self, from: data)

        return ExpectedTransactionMatch(
            expectedId: decoded.expectedId,
            confidence: decoded.confidence,
            matchReason: decoded.matchReason
        )
    }

    /// Strips markdown code fences and extra whitespace from Gemini JSON responses
    private func cleanJSON(_ text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Remove markdown code block markers
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Errors

public enum AIServiceError: LocalizedError {
    case emptyResponse
    case parsingFailed(String)
    case apiError(String)
    case rateLimited

    public var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "AI returned an empty response. Please try again."
        case .parsingFailed(let detail):
            return "Failed to parse AI response: \(detail)"
        case .apiError(let message):
            return "AI service error: \(message)"
        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."
        }
    }
}
