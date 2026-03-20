//
//  LibraryDetailView.swift
//  MyApp
//
//  Detail view for reading library articles with markdown rendering.
//

import SwiftUI
import MarkdownUI

struct LibraryDetailView: View {
    let entry: LibraryEntry
    let viewModel: LibraryViewModel

    @State private var content: String = ""
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var imageLoadError = false
    @ScaledMetric(relativeTo: .title) private var headerHeight: CGFloat = 250
    @ScaledMetric(relativeTo: .title) private var placeholderIconSize: CGFloat = 70

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header section
                ZStack(alignment: .bottomLeading) {
                    headerImage
                        .frame(height: headerHeight)
                        .clipped()
                        .accessibilityHidden(true)

                    // Gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .accessibilityHidden(true)

                    // Title overlay
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 0, y: 1)
                            .accessibilityAddTraits(.isHeader)

                        HStack {
                            CategoryPill(category: entry.category)

                            Spacer()

                            HStack(spacing: 8) {
                                if entry.featured == true {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                        .accessibilityLabel(String(localized: "accessibility_featured_badge"))
                                }

                                if viewModel.isEntryNew(entry.publishDate) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                        .accessibilityLabel(String(localized: "accessibility_new_badge"))
                                }
                            }
                        }

                        Text(String(localized: "library_detail_published_prefix \(formatDate(entry.publishDate))"))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black, radius: 1, x: 0, y: 1)
                    }
                    .padding(20)
                }

                // Content section
                VStack(alignment: .leading, spacing: 20) {
                    if isLoading {
                        VStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else if let error = errorMessage {
                        VStack {
                            Spacer()
                            Text(String(localized: "library_detail_error_prefix \(error)"))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()

                            Button(String(localized: "library_detail_try_again")) {
                                loadContent()
                            }
                            .primaryStyle()
                            .frame(width: 150)
                            .accessibilityLabel(String(localized: "accessibility_try_again"))

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        Markdown(content)
                            .markdownTheme(.gitHub)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                content = try await viewModel.fetchEntryContent(for: entry)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
            Analytics.track(
                event: "library.view.entry",
                parameters: [
                    "id": entry.id,
                    "title": entry.title,
                    "category": entry.category
                ]
            )
        }
    }

    @ViewBuilder
    private var headerImage: some View {
        if let imageURL = entry.imageURL, !imageLoadError, let url = URL(string: imageURL) {
            CachedAsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                placeholderImage
            }
        } else {
            placeholderImage
        }
    }

    private var placeholderImage: some View {
        ZStack {
            Rectangle()
                .fill(entry.category.categoryColor.opacity(0.2))

            Image(systemName: entry.category.categoryIcon)
                .font(.system(size: placeholderIconSize))
                .foregroundColor(entry.category.categoryColor)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func loadContent() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                content = try await viewModel.fetchEntryContent(for: entry)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        LibraryDetailView(
            entry: LibraryEntry(
                id: "test",
                title: "Getting Started",
                summary: "Learn how to use the app",
                contentURL: "https://example.com/content.md",
                publishDate: Date(),
                expiryDate: nil,
                category: "getting_started",
                imageURL: nil,
                featured: true,
                version: "1.0"
            ),
            viewModel: LibraryViewModel()
        )
    }
}
