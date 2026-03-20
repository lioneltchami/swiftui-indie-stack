//
//  HoverEffectModifier.swift
//  MyApp
//
//  Reusable hover effect modifier for iPad/Mac pointer interactions.
//

import SwiftUI

struct HoverableModifier: ViewModifier {
    let effect: HoverEffect

    func body(content: Content) -> some View {
        content
            .hoverEffect(effect)
            .contentShape(Rectangle())
    }
}

extension View {
    /// Add pointer hover effect for iPad/Mac
    func hoverable(_ effect: HoverEffect = .lift) -> some View {
        modifier(HoverableModifier(effect: effect))
    }
}
