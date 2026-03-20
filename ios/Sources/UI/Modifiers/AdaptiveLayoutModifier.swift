//
//  AdaptiveLayoutModifier.swift
//  MyApp
//
//  Size class-aware layout components for adaptive iPad/iPhone layouts.
//

import SwiftUI

struct AdaptiveStack<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    @ViewBuilder let content: () -> Content

    init(
        horizontalAlignment: HorizontalAlignment = .center,
        verticalAlignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        if sizeClass == .regular {
            HStack(alignment: verticalAlignment, spacing: spacing) {
                content()
            }
        } else {
            VStack(alignment: horizontalAlignment, spacing: spacing) {
                content()
            }
        }
    }
}

extension View {
    /// Apply different padding based on size class
    func adaptivePadding(_ edges: Edge.Set = .all) -> some View {
        modifier(AdaptivePaddingModifier(edges: edges))
    }
}

struct AdaptivePaddingModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var sizeClass
    let edges: Edge.Set

    func body(content: Content) -> some View {
        content
            .padding(edges, sizeClass == .regular ? 24 : 16)
    }
}
