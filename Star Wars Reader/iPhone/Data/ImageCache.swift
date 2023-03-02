//
//  ImageCache.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/14/23.
//

import Foundation
import UIKit
import Combine

class ImageCache {
    
    // Singleton instance of ImageCache
    static let shared = ImageCache()

    // Instance variables
    private let _imageDownloader = ImageDownloader()
    private let cache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "imageCache")
    private let fileManager = FileManager.default
    private var ongoingRequests: [URL: AnyPublisher<UIImage?, Error>] = [:]

    // Private initializer
    private init() {}

    // Function to retrieve an image from cache or download it if it's not available in cache or on disk
    func image(for url: URL, timestamp: String? = nil) -> AnyPublisher<UIImage?, Error> {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60.0)
        
        // Try to load image from cache
        if let cachedResponse = cache.cachedResponse(for: request), let image = UIImage(data: cachedResponse.data) {
            if let cachedTimestamp = cachedResponse.userInfo?["timestamp"] as? String, timestamp == cachedTimestamp {
                return Just(image)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }
        
        // If a publisher already exists for this url return it
        if let ongoingRequest = ongoingRequests[url] {
            return ongoingRequest
        }
        
        // If image isn't in cache, download and cache it
        let publisher = _imageDownloader.downloadImageData(withURL: url)
        .tryMap { data -> UIImage? in
            guard let data = data else { return nil }
            guard let image = UIImage(data: data) else { return nil }
            guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
            
            // Cache the downloaded image in memory
            let response = URLResponse(url: url, mimeType: "image/jpeg", expectedContentLength: imageData.count, textEncodingName: nil)
            var userInfo = [AnyHashable: Any]()
            userInfo["timestamp"] = timestamp
            let cachedResponse = CachedURLResponse(response: response, data: imageData, userInfo: userInfo, storagePolicy: .allowed)
            self.cache.storeCachedResponse(cachedResponse, for: request)
            
            return image
        }
        .mapError { error -> Error in
            return error
        }
        .handleEvents(receiveCompletion: { [weak self] completion in
            switch completion {
            case .failure:
                self?.ongoingRequests.removeValue(forKey: url)
            case .finished:
                self?.ongoingRequests.removeValue(forKey: url)
            }
        })
        .eraseToAnyPublisher()
        
        ongoingRequests[url] = publisher

        return publisher
    }

    func cancelRequest(withURL url: URL) {
        // Cancel the ongoing request and remove it from the dictionary
        if let subscription = ongoingRequests[url]?.sink(receiveCompletion: { _ in }, receiveValue: { _ in }) {
            subscription.cancel()
            ongoingRequests.removeValue(forKey: url)
        }
    }
}
