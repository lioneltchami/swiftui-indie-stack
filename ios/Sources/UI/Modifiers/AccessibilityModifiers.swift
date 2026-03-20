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

    func body(content: Content) -> some View {
        content
            .transaction { transaction in
                if reduceMotion {
                    transaction.animation = nil
                }
            }
    }
}

extension View {
    /// Suppress all animations on this view when the reduce motion accessibility
    /// preference is enabled. No-op when reduce motion is off.
    func reduceMotionSafe() -> some View {
        modifier(ReduceMotionModifier())
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
