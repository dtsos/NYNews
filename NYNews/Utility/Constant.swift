//
//  Constant.swift
//  NYNews
//
//  Created by David Trivian S on 5/18/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import Foundation
class Constant {
    static let RootServerSearch = "https://api.nytimes.com/svc/search/v2/"
    static let RootServerImage = "https://www.nytimes.com/"
    static let RootServerTopStories = "https://api.nytimes.com/svc/topstories/v2/"
    static let URLArticleSearch = "\(RootServerSearch)articlesearch.json?"
    static let URLTrending = "\(RootServerTopStories)home.json?"
    static let paramAPIKey = "api-key="
    static let paramAPIValue = "9b693ffaa5fe451090146e5c90fbed78"
    static let paramAPIKeyValue = "\(paramAPIKey)\(paramAPIValue)"
}
