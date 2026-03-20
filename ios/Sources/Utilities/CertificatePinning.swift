//
//  CertificatePinning.swift
//  MyApp
//
//  URLSessionDelegate for certificate validation on GitHub content API.
//  Pins to domain rather than specific certificate (certificates rotate).
//

import Foundation

final class GitHubContentSessionDelegate: NSObject, URLSessionDelegate, Sendable {
    /// Pinned domains for certificate validation
    private let pinnedDomains: Set<String> = [
        "raw.githubusercontent.com",
        "githubusercontent.com"
    ]

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              pinnedDomains.contains(where: { challenge.protectionSpace.host.hasSuffix($0) }) else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Validate the server certificate chain against the system trust store
        // plus verify the domain matches our expected host
        let policy = SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)
        SecTrustSetPolicies(serverTrust, policy)

        var error: CFError?
        if SecTrustEvaluateWithError(serverTrust, &error) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
