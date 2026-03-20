//
//  ErrorAlertModifier.swift
//  MyApp
//
//  View modifier that adds error alert presentation and toast overlay
//  to any view. Uses the environment-injected ErrorHandler to display
//  blocking alerts for errors and non-blocking toasts for confirmations.
//
//  Usage:
//  ```swift
//  ContentView()
//      .withErrorHandling()
//  ```
//

import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    @Environment(ErrorHandler.self) private var errorHandler

    func body(content: Content) -> some View {
        @Bindable var handler = errorHandler

        content
            .alert(
                String(localized: "error_alert_title"),
                isPresented: $handler.isAlertPresented,
                presenting: errorHandler.currentError
            ) { _ in
                Button("OK", role: .cancel) {
                    errorHandler.currentError = nil
                }
            } message: { error in
                Text(error.errorDescription ?? String(localized: "error_alert_default_message"))
            }
            .overlay(alignment: .top) {
                if errorHandler.isToastPresented, let message = errorHandler.toastMessage {
                    ToastView(message: message)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            Task {
                                try? await Task.sleep(for: .seconds(2))
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    errorHandler.isToastPresented = false
                                    errorHandler.toastMessage = nil
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: errorHandler.isToastPresented)
    }
}

// MARK: - Toast View

private struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray))
            )
    }
}

// MARK: - View Extension

extension View {
    /// Attach error alert and toast handling to this view.
    func withErrorHandling() -> some View {
        modifier(ErrorAlertModifier())
    }
}
