//
//  ArticleTableViewCell.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/8/23.
//

import UIKit
import Combine

class ArticleTableViewCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    
    // Properties
    private let imageCache = ImageCache.shared
    private var cancellables = Set<AnyCancellable>()
    private let dateFormatter = DateFormatterUtils.shared
    
    // Configures the cell with article data
    func configure(with article: Article, indexPath: IndexPath) {
        // Set labels' text to article data
        dateLabel.text = dateFormatter.formatDate(from: article.date)
        titleLabel.text = article.title
        locationLabel.text = "\(article.locationline1). \(article.locationline2)"
        previewLabel.text = article.description

        // Fetch image from cache or URL
        guard let urlString = article.image, let url = URL(string: urlString) else { return }
        imageCache.image(for: url, timestamp: article.timestamp)
        .sink { completion in
            switch completion {
            case .failure(let error):
                print("Error fetching image: \(error.localizedDescription)")
            case .finished:
                break
            }
        } receiveValue: { image in
            if let image = image {
                DispatchQueue.main.async {
                    self.articleImageView.image = image
                }
            }
        }
        .store(in: &cancellables)
    }
    
    // Resets the cell's properties for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        // Cancel all publishers attached to this cell so the wrong images aren't loaded when the cell is reused
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        // Reset any properties that may have been changed by the previous use of the cell
        dateLabel.text = ""
        titleLabel.text = ""
        locationLabel.text = ""
        previewLabel.text = ""
        articleImageView.image = UIImage(named: "placeholder_nomoon")
    }
}
