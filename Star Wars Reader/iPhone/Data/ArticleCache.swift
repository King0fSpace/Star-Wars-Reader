//
//  ArticleCache.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/16/23.
//

import Foundation
import Combine

class ArticleCache {
    
    // Singleton instance
    static let shared = ArticleCache()
    
    // URL cache used for caching responses
    private let _cache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "articleCache")

    // URLSession used for downloading articles
    private let _articleDownloader = ArticleDownloader.shared

    // Initialize the singleton instance
    init() {}

    // Returns a publisher for the articles at the specified URL.
    func articles(withURL url: URL) -> AnyPublisher<[Article], Error> {
        let request = URLRequest(url: url)

        // If internet is available download articles and cache the response
        return _articleDownloader.downloadArticlesData(with: url)
        .tryMap { data in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
            let cachedResponse = CachedURLResponse(response: response, data: data)
            self._cache.storeCachedResponse(cachedResponse, for: request)
            return data
        }
        .decode(type: [Article].self, decoder: JSONDecoder())
        .catch { error -> AnyPublisher<[Article], Error> in
            // Download failed; try to load articles from memory
            if let cachedResponse = URLCache.shared.cachedResponse(for: request),
               let articles = try? JSONDecoder().decode([Article].self, from: cachedResponse.data) {
                // Use the cached articles
                return Just(articles)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return Fail(error: error).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
