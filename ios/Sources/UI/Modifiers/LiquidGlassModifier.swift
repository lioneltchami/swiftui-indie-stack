//
//  LiquidGlassModifier.swift
//  MyApp
//
//  Applies iOS 26 Liquid Glass styling when available, with graceful fallback.
//  Uses compile-time and runtime availability checks to ensure backward compatibility.
//

import SwiftUI

/// Applies iOS 26 Liquid Glass styling when available, with graceful fallback
struct LiquidGlassModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
        }
    }
}

extension View {
    /// Apply Liquid Glass effect on iOS 26+, no-op on earlier versions
    func liquidGlass(cornerRadius: CGFloat = 16) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Glass Button Style

/// A button style that uses Liquid Glass material on iOS 26+
@available(iOS 26.0, *)
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .glassEffect(.regular, in: .capsule)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
