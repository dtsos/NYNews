//
//  Constant.swift
//  NewsFeed
//
//  Created by David Trivian S on 5/4/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import Foundation
import UIKit
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
extension URLResponse {
    func isHTTPResponseValid() -> Bool {
        guard let response = self as? HTTPURLResponse else {
            return false
        }
        
        return (response.statusCode >= 200 && response.statusCode <= 299)
    }
}


extension NSDate {
    func dateDiff() -> String? {
        
        
        
        
        let todayDate: NSDate = NSDate()
        var ti: Double = self.timeIntervalSince(todayDate as Date)
        ti = ti * -1
        if ti < 1 {
            return "now"
        }
        else if ti < 60 {
            return "less than a minute ago"
        }
        else if ti < 3600 {
            let diff: Int = Int(round(ti / 60))
            return "\(diff) minutes ago"
        }
        else if ti < 86400 {
            let diff: Int = Int(round(ti / 60 / 60))
            return "\(diff) hours ago"
        }
        else if ti < 2629743 {
            let diff: Int = Int(round(ti / 60 / 60 / 24))
            return "\(diff) days ago"
        }
        else {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy"
//            dateFormatter.locale = Locale.init(identifier: "en_SG")
            let stringDate = dateFormatter.string(from: self as Date)
            return stringDate
        }
   
    
    }
    
    
}

extension UIScrollView {
    
   
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
   
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}

