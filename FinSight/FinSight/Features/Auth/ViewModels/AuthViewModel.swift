import Foundation
import Observation

@Observable
@MainActor
public class AuthViewModel {
    public var email = ""
    public var password = ""
    public var displayName = ""
    public var isLoading = false
    public var errorMessage: String?
    public var showEmailAuth = false
    
    private let authService: AuthServiceProtocol
    
    public var currentUser: UserProfile? {
        authService.currentUser
    }
    
    public var isAuthenticated: Bool {
        authService.isAuthenticated
    }
    
    public init(authService: AuthServiceProtocol = FirebaseAuthService()) {
        self.authService = authService
    }
    
    public func signInWithEmail() async {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.signInWithEmail(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func signUpWithEmail() async {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.signUpWithEmail(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password,
                displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func signOut() {
        isLoading = true
        errorMessage = nil
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func resetPassword() async {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your email address to reset password."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await authService.resetPassword(email: email.trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
