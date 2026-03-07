//
//  AuthViewModel.swift
//  petmanager
//
//  Created by Sam Matthews on 26/02/2026.
//

import SwiftUI
import Supabase

@Observable
class AuthViewModel {
    var isLoggedIn = false
    var isLoading = true
    var isGuest = false
    var errorMessage: String?
    var successMessage: String?

    private let authService: AuthServiceProtocol
    private var authStateTask: Task<Void, Never>?

    init(authService: AuthServiceProtocol = SupabaseAuthService(), startListening: Bool = true) {
        self.authService = authService
        if startListening {
            listenForAuthChanges()
        } else {
            isLoading = false
        }
    }

    deinit {
        authStateTask?.cancel()
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        successMessage = nil
        do {
            try await authService.signIn(email: email, password: password)
            isLoggedIn = true
        } catch {
            errorMessage = friendlyError(error)
        }
    }

    /// Returns `true` if the account was created and needs email confirmation.
    func signUp(email: String, password: String) async -> Bool {
        errorMessage = nil
        successMessage = nil
        do {
            let result = try await authService.signUp(email: email, password: password)
            // Supabase returns an empty identity list when the email is
            // already registered (to avoid leaking which emails exist).
            if result.identities?.isEmpty == true {
                errorMessage = "An account with this email already exists. Please sign in instead."
                return false
            }
            successMessage = "Account created! Check your email to confirm, then sign in."
            return true
        } catch {
            errorMessage = friendlyError(error)
            return false
        }
    }

    func signOut() async {
        do {
            try await authService.signOut()
            isLoggedIn = false
        } catch {
            errorMessage = friendlyError(error)
        }
    }

    func resetPassword(email: String) async {
        errorMessage = nil
        successMessage = nil
        do {
            try await authService.resetPasswordForEmail(email)
            successMessage = "Password reset email sent! Check your inbox."
        } catch {
            errorMessage = friendlyError(error)
        }
    }

    private func listenForAuthChanges() {
        authStateTask = Task {
            for await state in SupabaseManager.shared.client.auth.authStateChanges {
                guard !Task.isCancelled else { return }
                if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                    isLoggedIn = state.session != nil
                    isLoading = false
                }
            }
        }
    }

    func friendlyError(_ error: Error) -> String {
        let message = error.localizedDescription
        if message.contains("Invalid login credentials") {
            return "Invalid email or password. Please try again."
        }
        if message.contains("Email not confirmed") {
            return "Please check your email and confirm your account before signing in."
        }
        if message.contains("User already registered") {
            return "An account with this email already exists. Please sign in instead."
        }
        if message.contains("Password should be at least") {
            return "Password must be at least 6 characters."
        }
        if message.contains("Unable to validate email address") || message.contains("invalid format") {
            return "Please enter a valid email address."
        }
        if message.contains("network") || message.contains("offline") || message.contains("connection") {
            return "Network error. Please check your connection and try again."
        }
        return message
    }
}
