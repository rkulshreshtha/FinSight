import SwiftUI

@Observable
public class RecurringViewModel {
    public var aiSuggestions: [RecurringPattern] = []
    public var activeRules: [RecurringRule] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public init() {}
    
    public func loadRecurringRules() async {
        isLoading = true
        // Mock data for UI
        if aiSuggestions.isEmpty && activeRules.isEmpty {
            let mockSuggestion = RecurringPattern(
                title: "Netflix Subscription",
                amount: 499.0,
                frequency: "Monthly",
                confidence: 0.95,
                matchingTransactionIds: []
            )
            aiSuggestions.append(mockSuggestion)
            
            let mockActive = RecurringRule(
                templateTitle: "Internet Bill",
                templateType: .expense,
                templateAmount: 999.0,
                frequency: .monthly,
                startDate: Date(),
                nextOccurrence: Date().addingTimeInterval(86400 * 10),
                isActive: true
            )
            activeRules.append(mockActive)
        }
        isLoading = false
    }
    
    public func acceptSuggestion(id: String) {
        if let idx = aiSuggestions.firstIndex(where: { $0.id == id }) {
            let rule = aiSuggestions.remove(at: idx)
            
            let activeRule = RecurringRule(
                templateTitle: rule.title,
                templateType: .expense,
                templateAmount: rule.amount,
                frequency: .monthly, // Mock frequency mapping
                startDate: Date(),
                nextOccurrence: Date().addingTimeInterval(86400 * 30),
                isActive: true,
                isAIDetected: false
            )
            activeRules.append(activeRule)
        }
    }
    
    public func dismissSuggestion(id: String) {
        aiSuggestions.removeAll(where: { $0.id == id })
    }
    
    public func pauseRule(id: String) {
        if let idx = activeRules.firstIndex(where: { $0.id == id }) {
            activeRules[idx].isActive = false
        }
    }
    
    public func deleteRule(id: String) {
        activeRules.removeAll(where: { $0.id == id })
    }
    
    public func editRule(id: String) {
        // Implementation for editing rule
    }
}
