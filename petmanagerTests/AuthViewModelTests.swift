//
//  AuthViewModelTests.swift
//  petmanagerTests
//

import Testing
import Foundation
@testable import petmanager

struct AuthViewModelTests {

    // MARK: - Mock

    class MockAuthService: AuthServiceProtocol {
        var signInError: Error?
        var signUpResult: AuthSignUpResult = AuthSignUpResult(identities: ["email"])
        var signUpError: Error?
        var signOutError: Error?
        var resetPasswordError: Error?
        var signInWithAppleError: Error?
        var deleteAccountError: Error?
        var resendVerificationError: Error?

        var signInCalledWith: (email: String, password: String)?
        var signUpCalledWith: (email: String, password: String)?
        var signOutCalled = false
        var resetPasswordCalledWith: String?
        var signInWithAppleCalledWith: (idToken: String, nonce: String)?
        var deleteAccountCalled = false
        var resendVerificationCalledWith: String?

        func signIn(email: String, password: String) async throws {
            signInCalledWith = (email, password)
            if let error = signInError { throw error }
        }

        func signUp(email: String, password: String) async throws -> AuthSignUpResult {
            signUpCalledWith = (email, password)
            if let error = signUpError { throw error }
            return signUpResult
        }

        func signOut() async throws {
            signOutCalled = true
            if let error = signOutError { throw error }
        }

        func resetPasswordForEmail(_ email: String) async throws {
            resetPasswordCalledWith = email
            if let error = resetPasswordError { throw error }
        }

        func signInWithApple(idToken: String, nonce: String) async throws {
            signInWithAppleCalledWith = (idToken, nonce)
            if let error = signInWithAppleError { throw error }
        }

        func deleteAccount() async throws {
            deleteAccountCalled = true
            if let error = deleteAccountError { throw error }
        }

        func resendVerificationEmail(email: String) async throws {
            resendVerificationCalledWith = email
            if let error = resendVerificationError { throw error }
        }
    }

    // MARK: - Helpers

    enum TestError: LocalizedError {
        case mock(String)

        var errorDescription: String? {
            switch self {
            case .mock(let message): return message
            }
        }
    }

    private func makeSUT(mock: MockAuthService = MockAuthService()) -> (AuthViewModel, MockAuthService) {
        let vm = AuthViewModel(authService: mock, startListening: false)
        return (vm, mock)
    }

    // MARK: - Initial State

    @Test func initialStateDefaults() {
        let (vm, _) = makeSUT()
        #expect(vm.isLoggedIn == false)
        #expect(vm.isLoading == false)
        #expect(vm.isGuest == false)
        #expect(vm.errorMessage == nil)
        #expect(vm.successMessage == nil)
    }

    // MARK: - Sign In

    @Test func signInSuccessSetsLoggedIn() async {
        let (vm, mock) = makeSUT()

        await vm.signIn(email: "test@example.com", password: "password123")

        #expect(vm.isLoggedIn == true)
        #expect(vm.errorMessage == nil)
        #expect(mock.signInCalledWith?.email == "test@example.com")
        #expect(mock.signInCalledWith?.password == "password123")
    }

    @Test func signInFailureSetsError() async {
        let mock = MockAuthService()
        mock.signInError = TestError.mock("Invalid login credentials")
        let (vm, _) = makeSUT(mock: mock)

        await vm.signIn(email: "test@example.com", password: "wrong")

        #expect(vm.isLoggedIn == false)
        #expect(vm.errorMessage == "Invalid email or password. Please try again.")
    }

    @Test func signInClearsPreviousMessages() async {
        let (vm, _) = makeSUT()
        vm.errorMessage = "old error"
        vm.successMessage = "old success"

        await vm.signIn(email: "test@example.com", password: "password123")

        #expect(vm.errorMessage == nil)
        #expect(vm.successMessage == nil)
    }

    // MARK: - Sign Up

    @Test func signUpSuccessWithIdentities() async {
        let mock = MockAuthService()
        mock.signUpResult = AuthSignUpResult(identities: ["email"])
        let (vm, _) = makeSUT(mock: mock)

        let result = await vm.signUp(email: "new@example.com", password: "password123")

        #expect(result == true)
        #expect(vm.successMessage == "Account created! Check your email to confirm, then sign in.")
        #expect(vm.errorMessage == nil)
        #expect(mock.signUpCalledWith?.email == "new@example.com")
    }

    @Test func signUpDuplicateEmailEmptyIdentities() async {
        let mock = MockAuthService()
        mock.signUpResult = AuthSignUpResult(identities: [])
        let (vm, _) = makeSUT(mock: mock)

        let result = await vm.signUp(email: "existing@example.com", password: "password123")

        #expect(result == false)
        #expect(vm.errorMessage == "An account with this email already exists. Please sign in instead.")
    }

    @Test func signUpFailureSetsError() async {
        let mock = MockAuthService()
        mock.signUpError = TestError.mock("User already registered")
        let (vm, _) = makeSUT(mock: mock)

        let result = await vm.signUp(email: "test@example.com", password: "password123")

        #expect(result == false)
        #expect(vm.errorMessage == "An account with this email already exists. Please sign in instead.")
    }

    // MARK: - Sign Out

    @Test func signOutSuccessClearsLoggedIn() async {
        let (vm, mock) = makeSUT()
        vm.isLoggedIn = true

        await vm.signOut()

        #expect(vm.isLoggedIn == false)
        #expect(mock.signOutCalled == true)
    }

    @Test func signOutFailureSetsError() async {
        let mock = MockAuthService()
        mock.signOutError = TestError.mock("network error")
        let (vm, _) = makeSUT(mock: mock)

        await vm.signOut()

        #expect(vm.errorMessage == "Network error. Please check your connection and try again.")
    }

    // MARK: - Reset Password

    @Test func resetPasswordSuccessSetsMessage() async {
        let (vm, mock) = makeSUT()

        await vm.resetPassword(email: "test@example.com")

        #expect(vm.successMessage == "Password reset email sent! Check your inbox.")
        #expect(vm.errorMessage == nil)
        #expect(mock.resetPasswordCalledWith == "test@example.com")
    }

    @Test func resetPasswordFailureSetsError() async {
        let mock = MockAuthService()
        mock.resetPasswordError = TestError.mock("Unable to validate email address")
        let (vm, _) = makeSUT(mock: mock)

        await vm.resetPassword(email: "bad")

        #expect(vm.errorMessage == "Please enter a valid email address.")
        #expect(vm.successMessage == nil)
    }

    // MARK: - friendlyError Mapping

    @Test func friendlyErrorMapsInvalidLogin() {
        let (vm, _) = makeSUT()
        let result = vm.friendlyError(TestError.mock("Invalid login credentials"))
        #expect(result == "Invalid email or password. Please try again.")
    }

    @Test func friendlyErrorMapsEmailNotConfirmed() {
        let (vm, _) = makeSUT()
        let result = vm.friendlyError(TestError.mock("Email not confirmed"))
        #expect(result == "Please check your email and confirm your account before signing in.")
    }

    @Test func friendlyErrorMapsUserAlreadyRegistered() {
        let (vm, _) = makeSUT()
        let result = vm.friendlyError(TestError.mock("User already registered"))
        #expect(result == "An account with this email already exists. Please sign in instead.")
    }

    @Test func friendlyErrorPassesUnknownThrough() {
        let (vm, _) = makeSUT()
        let result = vm.friendlyError(TestError.mock("Something unexpected"))
        #expect(result == "Something unexpected")
    }

    // MARK: - Sign In With Apple

    @Test func signInWithAppleTokenSuccess() async {
        let (vm, mock) = makeSUT()

        await vm.signInWithAppleToken(idToken: "test-token", nonce: "test-nonce")

        #expect(vm.isLoggedIn == true)
        #expect(vm.errorMessage == nil)
        #expect(mock.signInWithAppleCalledWith?.idToken == "test-token")
        #expect(mock.signInWithAppleCalledWith?.nonce == "test-nonce")
    }

    @Test func signInWithAppleTokenFailure() async {
        let mock = MockAuthService()
        mock.signInWithAppleError = TestError.mock("Apple sign in failed")
        let (vm, _) = makeSUT(mock: mock)

        await vm.signInWithAppleToken(idToken: "bad-token", nonce: "nonce")

        #expect(vm.isLoggedIn == false)
        #expect(vm.errorMessage == "Apple sign in failed")
    }

    // MARK: - Delete Account

    @Test func deleteAccountSuccess() async {
        let (vm, mock) = makeSUT()
        vm.isLoggedIn = true

        await vm.deleteAccount()

        #expect(vm.isLoggedIn == false)
        #expect(mock.deleteAccountCalled == true)
        #expect(mock.signOutCalled == true)
        #expect(vm.errorMessage == nil)
    }

    @Test func deleteAccountFailure() async {
        let mock = MockAuthService()
        mock.deleteAccountError = TestError.mock("Delete failed")
        let (vm, _) = makeSUT(mock: mock)
        vm.isLoggedIn = true

        await vm.deleteAccount()

        #expect(vm.errorMessage == "Delete failed")
    }

    // MARK: - Resend Verification

    @Test func resendVerificationSuccess() async {
        let (vm, mock) = makeSUT()

        await vm.resendVerification(email: "test@example.com")

        #expect(vm.successMessage == "Verification email sent! Check your inbox.")
        #expect(vm.errorMessage == nil)
        #expect(mock.resendVerificationCalledWith == "test@example.com")
    }

    @Test func resendVerificationFailure() async {
        let mock = MockAuthService()
        mock.resendVerificationError = TestError.mock("Rate limit exceeded")
        let (vm, _) = makeSUT(mock: mock)

        await vm.resendVerification(email: "test@example.com")

        #expect(vm.errorMessage == "Rate limit exceeded")
        #expect(vm.successMessage == nil)
    }
}
