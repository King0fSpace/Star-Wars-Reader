//  ArticleDataSource+Extension.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/20/23.
//

import Foundation
import UIKit

extension ArticlesTableViewDiffableDatasource: UITableViewDataSourcePrefetching {
    
    // This function is called when a table view is about to display cells for rows that are not yet visible.
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // For each indexPath that needs to be prefetched
        indexPaths.forEach { indexPath in
            // Check if indexPath is valid (within range of articles array)
            guard indexPath.row < articles.count else { return }
            
            // Get the article and image URL for the indexPath
            let article = articles[indexPath.row]
            guard let image = article.image, let imageURL = URL(string: image) else { return }
            
            // Load the image into the cell. The timestamp is used to determine whether image can be obtained from cache or needs to be re-downloaded
            _ = _imageCache.image(for: imageURL, timestamp: articles[indexPath.row].timestamp)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error prefetching image: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { image in
                DispatchQueue.main.async {
                    // Image was prefetched and is now in cache
                    if let cell = tableView.cellForRow(at: indexPath) as? ArticleTableViewCell {
                        print("Prefetched image: \(imageURL.lastPathComponent)")
                        cell.articleImageView.image = image
                    }
                }
            }
        }
    }
    
    // This function is called when a table view cancels a pending prefetch request.
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // For each indexPath that needs to be cancelled
        for indexPath in indexPaths {
            // Get the URL for the article image
            guard let imageURLString = articles[indexPath.row].image,
                  let imageURL = URL(string: imageURLString) else { continue }
            
            // Cancel image request and log cancellation for prefetching
            _imageCache.cancelRequest(withURL: imageURL)
            print("Cancelled prefetch for: \(imageURL.lastPathComponent)")
        }
    }
}
