//
//  LoginView.swift
//  MyApp
//
//  Sign-in screen with Apple and Google authentication options.
//  Only compiled when Firebase/GoogleSignIn are available.
//

#if canImport(GoogleSignIn)
import AuthenticationServices
import GoogleSignInSwift
import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @Environment(AuthManager.self) var authManager

    @StateObject private var googleButtonVM: GoogleSignInButtonViewModel

    let tosURL = AppConfiguration.termsOfServiceURL
    let privacyPolicyURL = AppConfiguration.privacyPolicyURL

    init() {
        let viewModel = GoogleSignInButtonViewModel()
        viewModel.style = .wide
        viewModel.scheme = .light
        _googleButtonVM = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            // Header Section
            VStack(spacing: 16) {
                Text(String(localized: "login_sign_in_to"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                    .padding(.top)

                // TODO: Replace with your app name
                Text(String(localized: "login_app_name"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                    .accessibilityAddTraits(.isHeader)
            }

            Spacer()

            // Sign-in Buttons Section
            VStack(spacing: 16) {
                // Apple Sign-In Button
                SignInWithAppleButton(
                    onRequest: { request in
                        AppleSignInManager.shared.requestAppleAuthorization(request)
                    },
                    onCompletion: { result in
                        handleAppleID(result)
                    }
                )
                .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                .frame(width: 312, height: 48, alignment: .center)

                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    Text(String(localized: "login_or_divider"))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                }

                // Google Sign-In Button
                GoogleSignInButton(viewModel: googleButtonVM) {
                    Task {
                        await signInWithGoogle()
                    }
                }
                .frame(width: 312, height: 48, alignment: .center)

                // Terms and Privacy Links
                VStack(spacing: 0) {
                    Text(String(localized: "login_terms_prefix"))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    HStack {
                        Text(String(localized: "login_terms_link"))
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                            .underline()
                            .onTapGesture {
                                if let url = URL(string: tosURL) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .accessibilityAddTraits(.isLink)
                            .accessibilityLabel(String(localized: "login_terms_link"))
                        Text(String(localized: "login_and"))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(String(localized: "login_privacy_link"))
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                            .underline()
                            .onTapGesture {
                                if let url = URL(string: privacyPolicyURL) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .accessibilityAddTraits(.isLink)
                            .accessibilityLabel(String(localized: "login_privacy_link"))
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .task {
            Analytics.trackScreenView("LoginView")
        }
    }

    // MARK: - Google Sign-In

    func signInWithGoogle() async {
        do {
            guard let user = try await GoogleSignInManager.shared.signInWithGoogle() else { return }

            let result = try await authManager.googleAuth(user)
            if result != nil {
                dismiss()
            }
        } catch {
            debugPrint("GoogleSignInError: \(error)")
        }
    }

    // MARK: - Apple Sign-In

    func handleAppleID(_ result: Result<ASAuthorization, Error>) {
        if case let .success(auth) = result {
            guard let appleIDCredentials = auth.credential as? ASAuthorizationAppleIDCredential else {
                debugPrint("AppleAuthorization failed: AppleID credential not available")
                return
            }

            Task {
                do {
                    let result = try await authManager.appleAuth(
                        appleIDCredentials,
                        nonce: AppleSignInManager.nonce
                    )
                    if result != nil {
                        dismiss()
                    }
                } catch {
                    debugPrint("AppleAuthorization failed: \(error)")
                }
            }
        } else if case let .failure(error) = result {
            debugPrint("AppleAuthorization failed: \(error)")
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager.shared)
}
#endif
