//
//  ArticlesTBVDelegate.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/20/23.
//

import Foundation
import UIKit

extension ArticlesViewController: UITableViewDelegate {
    
    // Handle row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let dataSource = _dataSource, let article = dataSource.itemIdentifier(for: indexPath) {
            let articleVC = self.storyboard?.instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
            articleVC.article = article
            
            self.navigationController?.pushViewController(articleVC, animated: true)
        }
    }
}
