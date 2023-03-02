//
//  ArticleTableViewController.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/8/23.
//

import UIKit

class ArticlesViewController: UIViewController, NetworkMonitorDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    private let reuseIdentifier = "ArticleTableViewCell"
    var _dataSource: ArticlesTableViewDiffableDatasource?
    
    let _networkMonitor = NetworkMonitor.shared
    
    @IBOutlet weak var noInternetLabel: UILabel!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        _networkMonitor.addDelegate(self)
        _networkMonitor.startMonitoring()

        self.title = "Star Wars Reader"
        
        // Set up navigation bar appearance.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 210.0
        
        _dataSource = ArticlesTableViewDiffableDatasource(tableView: self.tableView)
        tableView.dataSource = _dataSource
        tableView.prefetchDataSource = _dataSource
        tableView.delegate = self
        
        navigationController?.delegate = self
        
        self.loadArticles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Datasource
    
    func loadArticles() {
        // Load articles and prefetch visible rows
        _dataSource?.loadArticles { error in
            if let _ = error {
                DispatchQueue.main.async {
                    self.tableView.isHidden = true
                    self.noInternetLabel.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    let visibleRows = self.tableView.indexPathsForVisibleRows ?? []
                    self._dataSource?.tableView(self.tableView, prefetchRowsAt: visibleRows)
                    
                    self.tableView.isHidden = false
                    self.noInternetLabel.isHidden = true
                }
            }
        }
    }
    
    // MARK: - Network Monitor Delegate Methods

    deinit {
        _networkMonitor.removeDelegate(self)
    }
    
    func networkMonitorDidChangeConnectionStatus(_ isConnected: Bool) {
        if isConnected {
            self.loadArticles()
        }
    }
}




