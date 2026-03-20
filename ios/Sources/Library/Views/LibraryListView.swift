//
//  LibraryListView.swift
//  MyApp
//
//  Extracted list content for use in NavigationSplitView content column.
//

import SwiftUI

struct LibraryListView: View {
    let viewModel: LibraryViewModel
    @Binding var selectedEntry: LibraryEntry?

    var body: some View {
        List(viewModel.filteredEntries, selection: $selectedEntry) { entry in
            LibraryEntryRow(entry: entry, viewModel: viewModel)
                .tag(entry)
        }
        .listStyle(.plain)
        .searchable(text: .init(
            get: { viewModel.searchText },
            set: { viewModel.searchText = $0 }
        ))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.fetchEntries(forceRefresh: true)
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: .command)
                .accessibilityLabel(String(localized: "accessibility_refresh_library"))
            }
        }
    }
}
