import SwiftUI

#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct FinSightApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #else
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif
    
    @State private var themeManager = ThemeManager()
    @State private var container = DependencyContainer()
    @State private var authViewModel = AuthViewModel()
    
    // As per requirement to instantiate services directly as well
    @State private var authService = FirebaseAuthService()
    @State private var firestoreService = FirestoreService()
    @State private var geminiService = GeminiAIService()
    @State private var driveService = GoogleDriveService()
    @State private var notificationService = LocalNotificationService()
    @State private var imageCaptureManager = ImageCaptureManager()
    @State private var exportService = ExportService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(container)
                .environment(\.container, container)
                .environment(themeManager)
                .environment(authViewModel)
                .environment(authService)
                .environment(firestoreService)
                .environment(geminiService)
                .environment(driveService)
                .environment(notificationService)
                .environment(imageCaptureManager)
                .environment(exportService)
                .environment(container.dataRetentionService)
                .environment(container.transactionRepository)
                .environment(container.paymentMethodRepository)
                .environment(container.budgetRepository)
                .preferredColorScheme(themeManager.colorScheme)
                .onOpenURL { url in
                    #if os(iOS)
                    _ = GIDSignIn.sharedInstance.handle(url)
                    #endif
                }
                .onAppear {
                    Task {
                        do {
                            _ = try await container.notificationService.requestPermission()
                        } catch {
                            print("Notification permission error: \(error)")
                        }
                        await container.dataRetentionService.checkRetentionStatus()
                    }
                }
        }
    }
}

#if os(iOS)
import UIKit
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
#else
import AppKit
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
    }
}
#endif
