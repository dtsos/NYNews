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
    var operation:URLSessionDataTask?
    //fetching
    func fetch(withQueryString queryString: String,failure: @escaping (Error?) -> Void, completion: @escaping (NSDictionary) -> Void) {
        
        let encoded = queryString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: encoded)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        operation = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            
            guard error != nil else {
                failure(error)
                return
            }
            guard data != nil else{
                failure(error)
                return
            }
            do {
                let object = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                
                completion(object!)
                
            } catch {
                failure(error)
                debugPrint(error)
            }
            
        })
        operation?.resume()
    }
    
    
}
