//
//  ArticleService.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/8/23.
//

import Foundation
import Combine

class ArticleDownloader {
    // Singleton instance
    static let shared = ArticleDownloader()
    
    // URLSession for downloading data
    let _session = URLSession.shared

    init() {}
  
    func downloadArticlesData(with url: URL) -> AnyPublisher<Data, Error> {
        let request = URLRequest(url: url)
        
        return _session.dataTaskPublisher(for: request)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            return data
        }
        .eraseToAnyPublisher()
    }
}
