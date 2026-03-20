//
//  StreakMilestoneShareView.swift
//  MyApp
//
//  Shareable milestone graphic generated via ImageRenderer.
//  Shows a gradient card with flame icon, streak count, and app name.
//  Includes ShareLink for sharing the rendered image.
//

import SwiftUI
import TipKit

struct StreakMilestoneShareView: View {
    let milestone: Int
    let appName: String

    @ScaledMetric(relativeTo: .largeTitle) private var flameSize: CGFloat = 60

    var body: some View {
        VStack(spacing: 20) {
            // Shareable graphic
            shareableGraphic
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)

            // TipKit: Encourage sharing milestones
            TipView(MilestoneShareTip())

            // Share button
            ShareLink(
                item: shareableImage(),
                preview: SharePreview(
                    String(localized: "milestone_share_title \(milestone)"),
                    image: shareableImage()
                )
            ) {
                Label(String(localized: "milestone_share_button"), systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .primaryStyle()
            .accessibilityIdentifier(AccessibilityID.Streak.shareButton)
            .accessibilityLabel(String(localized: "accessibility_milestone_share \(milestone)"))
        }
        .padding()
        .accessibilityIdentifier(AccessibilityID.Streak.milestoneShareView)
    }

    // MARK: - Shareable Graphic

    private var shareableGraphic: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(
                    colors: [.orange, .red, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            VStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: flameSize))
                    .foregroundColor(.white)
                    .accessibilityHidden(true)

                Text("\(milestone)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .accessibilityLabel(String(localized: "accessibility_milestone_count \(milestone)"))

                Text(String(localized: "milestone_days_streak"))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))

                Text(appName)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }

    // MARK: - Image Rendering

    @MainActor
    private func shareableImage() -> Image {
        let renderer = ImageRenderer(content: shareableGraphic.frame(width: 300, height: 300))
        renderer.scale = 3.0
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "flame.fill")
    }
}

// MARK: - Preview

#Preview {
    StreakMilestoneShareView(
        milestone: 100,
        appName: "MyApp"
    )
}
