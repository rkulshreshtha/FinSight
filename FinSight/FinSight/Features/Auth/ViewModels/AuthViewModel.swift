import Foundation

@Observable
public class AuthViewModel {
    public var email = ""
    public var password = ""
    public var displayName = ""
    public var isLoading = false
    public var errorMessage: String?
    public var isAuthenticated = false
    public var showEmailAuth = false
    public var currentUser: User? // Replace User with your actual user model

    // Injected: authService (AuthServiceProtocol)
    // private let authService: AuthServiceProtocol

    public init() {
        // self.authService = authService
    }

    public func signInWithEmail() async {
        isLoading = true
        errorMessage = nil
        do {
            // let user = try await authService.signIn(email: email, password: password)
            // currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func signUpWithEmail() async {
        isLoading = true
        errorMessage = nil
        do {
            // let user = try await authService.signUp(email: email, password: password, displayName: displayName)
            // currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        do {
            // let user = try await authService.signInWithApple()
            // currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        do {
            // let user = try await authService.signInWithGoogle()
            // currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func signOut() async {
        isLoading = true
        errorMessage = nil
        do {
            // try await authService.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func resetPassword() async {
        isLoading = true
        errorMessage = nil
        do {
            // try await authService.resetPassword(email: email)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// Dummy model to make it compile
public struct User {
    let id: String
    let displayName: String?
    let email: String?
}
