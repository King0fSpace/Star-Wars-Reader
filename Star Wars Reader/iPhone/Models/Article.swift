//
//  Article.swift
//  Star Wars Reader
//
//  Created by Long Le on 2/8/23.
//

import Foundation

struct Article: Codable, Hashable {
    let id: Int
    let description: String
    let title: String
    let timestamp: String
    let image: String?
    let date: String?
    let locationline1: String
    let locationline2: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.id == rhs.id
    }
}
