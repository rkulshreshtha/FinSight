import SwiftUI

public extension Color {
    static func budgetColor(for progress: Double) -> Color {
        if progress >= AppConfig.budgetDangerThreshold {
            return App.budgetDanger
        } else if progress >= AppConfig.budgetWarningThreshold {
            return App.budgetWarning
        }
        return App.budgetSafe
    }
    
    static func amountColor(isCredit: Bool) -> Color {
        return isCredit ? App.income : App.expense
    }
}
