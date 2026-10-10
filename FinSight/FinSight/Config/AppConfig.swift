import Foundation
import CoreGraphics

public enum AppConfig {
    public static let bundleId = "com.rkulshreshtha.finsight"
    public static let appName = "FinSight"
    public static let maxImageSizeKB = 500
    public static let maxImageDimension: CGFloat = 1920
    public static let dataRetentionDays = 365
    public static let exportWarningDays = 335
    public static let inactivityReminderHoursDefault = 48
    public static let maxCategoryCorrections = 100
    public static let recurringDetectionMonths = 6
    public static let budgetWarningThreshold = 0.80
    public static let budgetDangerThreshold = 0.95
    public static let googleDriveFolderName = "FinSight Receipts"
    public static let geminiModel = "gemini-2.5-flash"

    public static var geminiAPIKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let key = dict["GEMINI_API_KEY"] as? String,
              !key.isEmpty else {
            fatalError("GEMINI_API_KEY missing in Secrets.plist")
        }
        return key
    }
}
