import SwiftUI

public extension Color {
    struct App {
        public static let accentPrimary = Color.blue
        public static let income = Color.green
        public static let expense = Color.red
        public static let net = Color.blue
        public static let warning = Color.orange
        public static let danger = Color.red
        public static let flagged = Color.yellow
        public static let aiSuggestion = Color.indigo
        
        #if os(macOS)
        public static let cardBackground = Color(NSColor.controlBackgroundColor)
        public static let sectionBackground = Color(NSColor.windowBackgroundColor)
        #else
        public static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
        public static let sectionBackground = Color(UIColor.systemGroupedBackground)
        #endif
        
        public static let budgetSafe = Color.green
        public static let budgetWarning = Color.orange
        public static let budgetDanger = Color.red
        public static let budgetExceeded = Color.purple
    }
}
