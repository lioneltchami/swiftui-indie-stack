//
//  CachedAsyncImage.swift
//  MyApp
//
//  Cached image view using URLCache with 50MB memory / 200MB disk capacity.
//  Drop-in replacement for AsyncImage with persistent caching.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var image: UIImage?
    @State private var isLoading = false

    private static let cache: URLCache = {
        URLCache(
            memoryCapacity: 50 * 1024 * 1024,  // 50 MB memory
            diskCapacity: 200 * 1024 * 1024     // 200 MB disk
        )
    }()

    var body: some View {
        Group {
            if let image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .task(id: url) {
                        await loadImage()
                    }
            }
        }
    }

    private func loadImage() async {
        guard let url, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        let request = URLRequest(url: url)

        // Check cache first
        if let cachedResponse = Self.cache.cachedResponse(for: request),
           let uiImage = UIImage(data: cachedResponse.data) {
            self.image = uiImage
            return
        }

        // Fetch from network
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let uiImage = UIImage(data: data) {
                // Cache the response
                let cachedResponse = CachedURLResponse(response: response, data: data)
                Self.cache.storeCachedResponse(cachedResponse, for: request)
                self.image = uiImage
            }
        } catch {
            // Silently fail - placeholder remains visible
        }
    }
}
