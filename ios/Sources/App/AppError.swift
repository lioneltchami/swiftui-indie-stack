//
//  AppError.swift
//  MyApp
//
//  Unified error enum for the app. All user-facing errors should be expressed
//  as AppError cases so the ErrorHandler can present them consistently.
//
//  Conforms to LocalizedError for user-friendly messages and
//  @unchecked Sendable because some cases wrap Error (which is not Sendable).
//
//  Usage:
//  ```swift
//  throw AppError.authFailed(reason: "Invalid credentials")
//  errorHandler.handle(AppError.networkUnavailable)
//  ```
//

import Foundation

enum AppError: Error, LocalizedError, @unchecked Sendable {

    // MARK: - Network

    /// Device has no internet connection
    case networkUnavailable

    /// A network request failed with an underlying error
    case networkError(underlying: Error)

    /// Response data could not be decoded
    case decodingError(context: String)

    /// A URL string was malformed
    case invalidURL(String)

    // MARK: - Authentication

    /// Authentication attempt failed
    case authFailed(reason: String)

    /// User's sign-in credentials have been revoked by the provider
    case authRevoked

    // MARK: - Subscription

    /// Could not verify the user's subscription status
    case subscriptionCheckFailed

    // MARK: - Firestore

    /// A Firestore write or transaction failed
    case firestoreWriteFailed(context: String)

    /// A Firestore read failed
    case firestoreReadFailed(context: String)

    // MARK: - Library

    /// Library content could not be loaded
    case libraryContentLoadFailed(context: String)

    // MARK: - Generic

    /// An unexpected error from a lower-level API
    case unknown(Error)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection. Please check your network."

        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"

        case .decodingError(let context):
            return "Failed to process data: \(context)"

        case .invalidURL(let url):
            return "Invalid URL: \(url)"

        case .authFailed(let reason):
            return "Authentication failed: \(reason)"

        case .authRevoked:
            return "Your sign-in credentials have been revoked. Please sign in again."

        case .subscriptionCheckFailed:
            return "Could not verify subscription status."

        case .firestoreWriteFailed(let context):
            return "Failed to save data: \(context)"

        case .firestoreReadFailed(let context):
            return "Failed to load data: \(context)"

        case .libraryContentLoadFailed(let context):
            return "Failed to load library content: \(context)"

        case .unknown(let error):
            return error.localizedDescription
        }
    }

    var failureReason: String? {
        switch self {
        case .networkUnavailable:
            return "The device appears to be offline."

        case .networkError(let error):
            return "The server returned an error: \(error.localizedDescription)"

        case .decodingError(let context):
            return "The response format was unexpected: \(context)"

        case .invalidURL(let url):
            return "The URL \"\(url)\" could not be parsed."

        case .authFailed(let reason):
            return reason

        case .authRevoked:
            return "The identity provider invalidated the current session."

        case .subscriptionCheckFailed:
            return "The subscription service did not respond."

        case .firestoreWriteFailed(let context):
            return "Firestore rejected the write operation: \(context)"

        case .firestoreReadFailed(let context):
            return "Firestore could not return the requested document: \(context)"

        case .libraryContentLoadFailed(let context):
            return context

        case .unknown:
            return nil
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable, .networkError:
            return "Check your Wi-Fi or cellular connection and try again."

        case .authFailed, .authRevoked:
            return "Try signing in again."

        case .subscriptionCheckFailed:
            return "Please try again later or contact support."

        case .firestoreWriteFailed, .firestoreReadFailed:
            return "Check your connection and try again."

        case .libraryContentLoadFailed:
            return "Pull to refresh or check your connection."

        case .decodingError, .invalidURL, .unknown:
            return nil
        }
    }
}
