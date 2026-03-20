//
//  LibraryView.swift
//  MyApp
//
//  Main library view with category filtering and search.
//

import SwiftUI

struct LibraryView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        if sizeClass == .regular {
            LibrarySplitView()
        } else {
            LibraryCompactView()
        }
    }
}

// MARK: - Compact (iPhone) Layout

struct LibraryCompactView: View {
    @State private var viewModel = LibraryViewModel()
    @State private var searchText = ""
    @State private var showingSearchBar = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showingSearchBar {
                    SearchBar(text: $searchText, onCommit: {
                        viewModel.searchText = searchText
                    })
                    .padding(.horizontal)
                    .accessibilityIdentifier(AccessibilityID.Library.searchField)
                }

                if viewModel.isLoading && viewModel.entries.isEmpty {
                    LoadingView()
                } else if viewModel.errorMessage != nil && viewModel.entries.isEmpty {
                    ErrorView(
                        errorMessage: viewModel.errorMessage ?? "Unknown error",
                        onRetry: { viewModel.fetchEntries(forceRefresh: true) }
                    )
                } else {
                    contentView
                }
            }
            .navigationTitle(String(localized: "library_navigation_title"))
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: LibraryEntry.self) { entry in
                LibraryDetailView(entry: entry, viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        withAnimation {
                            showingSearchBar.toggle()
                            if !showingSearchBar {
                                searchText = ""
                                viewModel.searchText = ""
                            }
                        }
                    }) {
                        Image(systemName: showingSearchBar ? "xmark.circle.fill" : "magnifyingglass")
                    }
                    .keyboardShortcut("f", modifiers: .command)
                    .accessibilityIdentifier(AccessibilityID.Library.searchButton)
                    .accessibilityLabel(showingSearchBar ? String(localized: "accessibility_close_search") : String(localized: "accessibility_open_search"))
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: { viewModel.fetchEntries(forceRefresh: true) }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .keyboardShortcut("r", modifiers: .command)
                    .accessibilityIdentifier(AccessibilityID.Library.refreshButton)
                    .accessibilityLabel(String(localized: "accessibility_refresh_library"))
                }
            }
        }
        .task {
            viewModel.fetchEntries()
            Analytics.trackScreenView("LibraryView")
        }
        .onChange(of: searchText) { _, newValue in
            viewModel.searchText = newValue
        }
        .task(id: viewModel.searchText) {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            viewModel.filterEntries()
        }
    }

    private var contentView: some View {
        ScrollView {
            // Category filters
            categoryFilters
                .padding(.horizontal)

            if viewModel.filteredEntries.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 0) {
                    // Featured entries
                    if viewModel.hasFeaturedEntries {
                        featuredEntriesSection
                    }

                    // Regular entries
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredEntries.filter { $0.featured != true }) { entry in
                            NavigationLink(value: entry) {
                                LibraryEntryRow(entry: entry, viewModel: viewModel)
                                    .frame(height: 260)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, viewModel.hasFeaturedEntries ? 0 : 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryFilterButton(
                    title: String(localized: "library_category_all"),
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    withAnimation {
                        viewModel.resetCategory()
                    }
                }

                ForEach(viewModel.availableCategories, id: \.self) { category in
                    CategoryFilterButton(
                        title: viewModel.displayNameForCategory(category),
                        isSelected: viewModel.selectedCategory == category,
                        color: category.categoryColor
                    ) {
                        withAnimation {
                            if viewModel.selectedCategory == category {
                                viewModel.selectedCategory = nil
                            } else {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var featuredEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "library_featured_section"))
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 16)
                .accessibilityAddTraits(.isHeader)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(viewModel.filteredEntries.filter { $0.featured == true }) { entry in
                        NavigationLink(value: entry) {
                            LibraryEntryRow(entry: entry, viewModel: viewModel)
                                .frame(width: 260, height: 320)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }

    @ViewBuilder
    private var emptyStateView: some View {
        if viewModel.selectedCategory != nil {
            EmptyStateView(
                icon: "folder.badge.questionmark",
                title: String(localized: "library_no_category_title"),
                message: String(localized: "library_no_category_message")
            )
        } else if !viewModel.searchText.isEmpty {
            EmptyStateView(
                icon: "magnifyingglass",
                title: String(localized: "library_no_results_title"),
                message: String(localized: "library_no_results_message \(viewModel.searchText)")
            )
        } else {
            EmptyStateView(
                icon: "book.closed",
                title: String(localized: "library_empty_title"),
                message: String(localized: "library_empty_message")
            )
        }
    }
}

// MARK: - Supporting Views

struct SearchBar: View {
    @Binding var text: String
    var onCommit: () -> Void = {}

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(String(localized: "library_search_placeholder"), text: $text, onCommit: onCommit)
                .disableAutocorrection(true)
                .accessibilityLabel(String(localized: "accessibility_search_field"))

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onCommit()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(minHeight: 44)
                .background(isSelected ? color.opacity(0.2) : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? color : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? color : Color.clear, lineWidth: 1)
                )
                .contentShape(Capsule())
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text(String(localized: "library_loading"))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct ErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text(String(localized: "library_error_title"))
                .font(.title2)
                .fontWeight(.bold)

            Text(errorMessage)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button(String(localized: "library_try_again"), action: onRetry)
                .primaryStyle()
                .frame(width: 200)
                .accessibilityLabel(String(localized: "accessibility_try_again"))

            Spacer()
        }
        .padding()
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 40)

            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }
}

#Preview("iPhone") {
    LibraryView()
}

#Preview("iPad") {
    LibraryView()
        .previewDevice("iPad Pro (12.9-inch)")
}
