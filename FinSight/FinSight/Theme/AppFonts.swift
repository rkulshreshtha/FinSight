import SwiftUI

public extension Font {
    struct App {
        public static let largeTitle = Font.largeTitle.weight(.bold)
        public static let title = Font.title.weight(.semibold)
        public static let headline = Font.headline.weight(.medium)
        public static let body = Font.body
        public static let caption = Font.caption
        
        public static let amountLarge = Font.system(size: 36, weight: .bold, design: .rounded)
        public static let amountMedium = Font.system(size: 24, weight: .semibold, design: .rounded)
        public static let amountSmall = Font.system(size: 16, weight: .medium, design: .rounded)
    }
}
