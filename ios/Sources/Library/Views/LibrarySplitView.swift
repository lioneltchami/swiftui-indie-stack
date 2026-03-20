//
//  LibrarySplitView.swift
//  MyApp
//
//  iPad-specific NavigationSplitView wrapper for Library with three-column layout.
//

import SwiftUI

struct LibrarySplitView: View {
    @State private var viewModel = LibraryViewModel()
    @State private var selectedEntry: LibraryEntry?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar: category list
            List(selection: $viewModel.selectedCategory) {
                Section("Categories") {
                    Label("All", systemImage: "square.grid.2x2")
                        .tag(nil as String?)

                    ForEach(viewModel.availableCategories, id: \.self) { category in
                        Label(
                            viewModel.displayNameForCategory(category),
                            systemImage: category.categoryIcon
                        )
                        .tag(category as String?)
                    }
                }
            }
            .navigationTitle("Library")
            .listStyle(.sidebar)
        } content: {
            // Content: article list
            LibraryListView(
                viewModel: viewModel,
                selectedEntry: $selectedEntry
            )
            .navigationTitle(viewModel.selectedCategory.map {
                viewModel.displayNameForCategory($0)
            } ?? "All Articles")
        } detail: {
            // Detail: article content
            if let entry = selectedEntry {
                LibraryDetailView(entry: entry, viewModel: viewModel)
            } else {
                ContentUnavailableView(
                    String(localized: "library_select_article"),
                    systemImage: "doc.text",
                    description: Text("library_select_article_prompt")
                )
            }
        }
        .task {
            viewModel.fetchEntries()
            Analytics.trackScreenView("LibrarySplitView")
        }
    }
}

#Preview("iPad") {
    LibrarySplitView()
        .previewDevice("iPad Pro (12.9-inch)")
}
