//
//  Fetching.swift
//  NewsFeed
//
//  Created by David Trivian S on 5/4/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import Foundation
import UIKit
protocol FetchingProtocol {
    func fetch(withQueryString queryString: String,failure: @escaping (Error?) -> Void, completion: @escaping (NSDictionary) -> Void)
     
}
class Fetching: FetchingProtocol {
    //fetching
    
    func fetch(withQueryString queryString: String,failure: @escaping (Error?) -> Void, completion: @escaping (NSDictionary) -> Void) {
        debugPrint(queryString)
        let encoded = queryString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: encoded)!
        
        
        let task = URLDataTask.init(session: URLSession.shared, url: url)
        task.dataTask { (data, response, error) in
            debugPrint(url)
            guard response?.isHTTPResponseValid() == true else {
                failure(error)
                return
            }
            guard data != nil else{
                failure(error)
                return
            }
            do {
                let object = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                
                
                debugPrint("docatch")
                completion(object!)
                
            } catch {
                failure(error)
                debugPrint(error)
            }
        }.resume()
        
//        URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
//            debugPrint(request)
//            
//            
//           
//            
//        }).resume()
    }
    
    
}
