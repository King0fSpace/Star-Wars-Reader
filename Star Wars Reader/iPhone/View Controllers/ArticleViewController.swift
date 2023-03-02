//
//  ArticleViewController.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/20/23.
//

import Foundation
import UIKit
import Combine

class ArticleViewController: UIViewController {
    
    // MARK: - Properties

    let _dateFormatter = DateFormatterUtils.shared
    let _imageCache = ImageCache.shared
    var cancellables = Set<AnyCancellable>()
    var article: Article

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!

    var titleOnNavBar = false
    var navBarLabel = UILabel()
    var transitionCompleted = false

    // MARK: - Initialization

    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.article = Article(id: 0, description: "", title: "", timestamp: "", image: "", date: "", locationline1: "", locationline2: "")
        super.init(coder: aDecoder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        if let backArrowImage = UIImage(named: "chevron.backward") {
            appearance.setBackIndicatorImage(backArrowImage.withRenderingMode(.alwaysOriginal), transitionMaskImage: backArrowImage.withRenderingMode(.alwaysOriginal))
        }
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = false
        
        dateLabel.text = _dateFormatter.formatDate(from: article.date)
        articleTitleLabel.text = article.title
        locationLabel.text = "\(article.locationline1), \(article.locationline2)"
        eventDescriptionLabel.text = article.description
        
        guard let image = article.image, let url = URL(string: image) else { return }
        
        _imageCache.image(for: url, timestamp: article.timestamp)
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error loading image in ArticleViewController: \(error.localizedDescription)")
                case .finished:
                    break
                }
            },
            receiveValue: { image in
                if let image = image {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        )
        .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = ""
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.transitionCompleted = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navBarLabel.removeFromSuperview()
    }

}

