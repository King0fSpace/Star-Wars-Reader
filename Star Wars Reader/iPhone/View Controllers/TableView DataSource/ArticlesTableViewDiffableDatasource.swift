//
//  ArticleDiffableDataSource.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/8/23.
//

import UIKit
import Combine

class ArticlesTableViewDiffableDatasource: UITableViewDiffableDataSource<Int, Article> {
    
    // Array to hold articles
    var articles = [Article]()
    
    // Article cache which returns articles from cache
    private let _articleCache = ArticleCache.shared
    
    // Image cache which returns images from cache
    let _imageCache = ImageCache.shared
    
    // Set to hold Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // Initialize the data source
    init(tableView: UITableView) {
        super.init(tableView: tableView) { (tableView, indexPath, article) -> UITableViewCell? in
            
            // Dequeue a cell and cast it to ArticleTableViewCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as! ArticleTableViewCell
            
            // Configure the cell with the article data 
            cell.configure(with: article, indexPath: indexPath)
            
            return cell
        }
    }
    
    // Function to load articles from cache or API
    func loadArticles(completion: @escaping (Error?) -> Void) {
        let url = URL(string: "https://raw.githubusercontent.com/phunware-services/dev-interview-homework/master/feed.json")!
        
        _articleCache.articles(withURL: url)
        .sink(receiveCompletion: { result in
            // Handle the completion result
            switch result {
            case .finished:
                print("Finished fetching articles")
                completion(nil)
            case .failure(let error):
                print("Error fetching articles: \(error.localizedDescription)")
                completion(error)
            }
        }, receiveValue: { [weak self] articles in
            // When receiving articles, update the data source and call the completion closure
            guard let self = self else {
                return
            }
            self.articles = articles
            self.updateData(with: articles)
            completion(nil)
        })
        .store(in: &cancellables)
    }

    
    // Function to update the data source with new articles
    func updateData(with articles: [Article]) {
        // Create a new snapshot and append the articles to it
        var snapshot = NSDiffableDataSourceSnapshot<Int, Article>()
        snapshot.appendSections([0])
        snapshot.appendItems(articles, toSection: 0)
        
        // Apply the snapshot to the data source, animating the differences
        apply(snapshot, animatingDifferences: true)
    }
}
