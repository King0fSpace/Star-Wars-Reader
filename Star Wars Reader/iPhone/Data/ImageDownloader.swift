//
//  ImageFetcher.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/16/23.
//

import Foundation
import Combine
import UIKit

class ImageDownloader {
    
    let _session = URLSession.shared

    private let concurrentDownloadLimit = 10
    var retryCount = 0
    var retryLimit = 5
    var retryInterval: TimeInterval = 3600.0  // 1 hour
    
    private var queue = [URL]()
    var downloads = [URL: AnyPublisher<Data?, Error>]()
    private var retryCounts = [URL: Int]()
    private var retryIntervals = [URL: TimeInterval]()
    

    func downloadImageData(withURL url: URL) -> AnyPublisher<Data?, Error> {
        if let existingDownload = downloads[url] {
            return existingDownload
        }

        let download = _session.dataTaskPublisher(for: url)
        .tryMap { data, response -> Data? in
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                throw NSError(domain: "ImageDownloadError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Image not found"])   
            }
            return data
        }
        .mapError { error -> Error in
            return error
        }
        .handleEvents(receiveCompletion: { [weak self] completion in
            switch completion {
            case .failure:
                guard let self = self else { return }
                var retryCount = self.retryCounts[url] ?? 0
                if retryCount < self.retryLimit {
                    retryCount += 1
                    self.retryCounts[url] = retryCount
                    let retryInterval = self.retryIntervals[url] ?? self.retryInterval
                    DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
                        _ = self.downloadImageData(withURL: url).sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                    }
                    self.retryIntervals[url] = retryInterval * 2
                }
            case .finished:
                self?.downloads.removeValue(forKey: url)
                self?.retryCounts.removeValue(forKey: url)
                self?.retryIntervals.removeValue(forKey: url)
                self?.startNextDownload()
            }
         })
        .eraseToAnyPublisher()

        downloads[url] = download

        if downloads.count <= concurrentDownloadLimit {
            startNextDownload()
        } else {
            if !queue.contains(url) {
                queue.append(url)
                let results = queue.map { queuedDownload in queuedDownload.lastPathComponent }
                print("ImageDownloader queue contains \(queue.count) pending requests: \(results)")
            }
        }

        return download
    }
    
    private func startNextDownload() {
        guard let nextURL = queue.first, downloads.count <= concurrentDownloadLimit else {
            return
        }
        queue.removeFirst()
        print("ImageDownloader starting download of: \(nextURL.lastPathComponent)")
        _ = downloads[nextURL]?.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
    
    func cancelDownload(withURL url: URL) {
        if let subscription = downloads[url]?.sink(receiveCompletion: { _ in }, receiveValue: { _ in }) {
            subscription.cancel()
            downloads.removeValue(forKey: url)
        }
    }
}

