//
//  AuthServiceProtocol.swift
//  MyApp
//
//  Protocol abstraction for AuthManager.
//  Enables dependency injection and testability without exposing
//  Firebase-specific types (User, AuthCredential, etc.).
//

import Foundation

@MainActor
protocol AuthServiceProtocol: AnyObject {

    // MARK: - Observable State

    /// Current authentication state (signedOut, authenticated, signedIn)
    var authState: AuthState { get }

    /// Whether the initial auth check is still in progress
    var isCheckingAuth: Bool { get }

    // MARK: - User Identity

    /// Current user ID (Firebase UID in Firebase mode, device ID in local mode)
    var userId: String { get }

    /// Whether the current user is anonymous (no provider sign-in)
    var isAnonymous: Bool { get }

    /// Whether sign-in UI should be shown (requires Firebase + enableAuth)
    var canSignIn: Bool { get }

    // MARK: - Authentication Actions

    /// Perform initial authentication (anonymous sign-in or local mode setup)
    func handleInitialAuthentication() async

    /// Sign in anonymously (Firebase mode only)
    func signInAnonymously() async throws

    /// Sign out the current user
    func signOut()
}
