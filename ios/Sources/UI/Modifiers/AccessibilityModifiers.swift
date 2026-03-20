//
//  AccessibilityModifiers.swift
//  MyApp
//
//  Reusable accessibility modifiers for reduce-motion support
//  and minimum touch target enforcement.
//

import SwiftUI

// MARK: - Reduce Motion Support

struct ReduceMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation
    let reducedAnimation: Animation?

    func body(content: Content) -> some View {
        content.animation(
            reduceMotion ? (reducedAnimation ?? .none) : animation,
            value: UUID() // triggers on any change
        )
    }
}

extension View {
    /// Apply animation that respects the reduce motion accessibility preference.
    /// When reduce motion is enabled, falls back to `reducedTo` animation (defaults to `.none`).
    func motionSafeAnimation(
        _ animation: Animation,
        reducedTo reduced: Animation? = nil
    ) -> some View {
        modifier(ReduceMotionModifier(
            animation: animation,
            reducedAnimation: reduced
        ))
    }
}

// MARK: - Minimum Touch Target

struct MinimumTouchTargetModifier: ViewModifier {
    let minSize: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(minWidth: minSize, minHeight: minSize)
            .contentShape(Rectangle())
    }
}

extension View {
    /// Ensure minimum 44pt touch target as required by Apple HIG.
    /// Sets both `frame(minWidth:minHeight:)` and `contentShape(Rectangle())`
    /// so the entire tappable area registers touches.
    func minimumTouchTarget(_ size: CGFloat = 44) -> some View {
        modifier(MinimumTouchTargetModifier(minSize: size))
    }
}
