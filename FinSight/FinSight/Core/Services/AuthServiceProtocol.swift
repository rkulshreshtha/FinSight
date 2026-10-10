import Foundation

public protocol AuthServiceProtocol {
    var currentUser: UserProfile? { get }
    var isAuthenticated: Bool { get }
    func signInWithEmail(email: String, password: String) async throws -> UserProfile
    func signUpWithEmail(email: String, password: String, displayName: String) async throws -> UserProfile
    func signInWithGoogle() async throws -> UserProfile
    func signOut() throws
    func resetPassword(email: String) async throws
    func deleteAccount() async throws
}
