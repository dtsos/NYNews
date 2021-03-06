//
//  Constant.swift
//  NewsFeed
//
//  Created by David Trivian S on 5/4/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import Foundation
import UIKit

extension URLResponse {
    func isHTTPResponseValid() -> Bool {
        let httpResponse = self as? HTTPURLResponse
        return ((httpResponse?.statusCode)! >= 200 && (httpResponse?.statusCode)! <= 299)

    }
    
}
extension URLSession {
    func cancelOperation(stringUrl:String?)
    {
        if stringUrl != nil && (stringUrl?.characters.count)! > 0{
            self.getTasksWithCompletionHandler { (dataStacks, uploadStacks, downloadStacks) in
                for dataStack in dataStacks {
                    
                    if dataStack.originalRequest?.url?.absoluteString == stringUrl {
                        dataStack.cancel()
                        break
                    }
                    
                }
            }
        }
    }
    
}


extension Date {
    func dateDiff() -> String? {
        
        
        
        let currentDate =  NSDate()
        
        
        
        
        var ti: Double = self.timeIntervalSince(currentDate as Date)
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
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy"
        //            dateFormatter.locale = Locale.init(identifier: "en_SG")
        let stringDate = dateFormatter.string(from: self as Date)
        return stringDate
        
        
        
    }
    
    
}

