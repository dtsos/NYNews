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

class Fetching :FetchingProtocol{
    //fetching
   
    private let engine: NetworkEngine
    
    init(engine: NetworkEngine = URLSession.shared) {
        self.engine = engine
    }

    func fetch(withQueryString queryString: String,failure: @escaping (Error?) -> Void, completion: @escaping (NSDictionary) ->Void) {
        debugPrint(queryString)
        let encoded = queryString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: encoded)!
        
        
       
        
        engine.performRequest(for: url) { (data, response, xerror) in
            
            debugPrint(url)
            guard response?.isHTTPResponseValid() == true else {
                failure(xerror)
                return
            }
            guard data != nil else{
                failure(xerror)
                return
            }
            do {
                let object = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                
                
                debugPrint("docatch")
                completion(object!)
                
            } catch  {
                failure(error)
                debugPrint(error)
            }
        }

    }
    
    
}


protocol NetworkEngine {
    typealias Handler = (Data?, URLResponse?, Error?) -> Void
    
    func performRequest(for url: URL, completionHandler: @escaping Handler)
}

extension URLSession: NetworkEngine {
    typealias Handler = NetworkEngine.Handler
    
    func performRequest(for url: URL, completionHandler: @escaping Handler) {
        let task = dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
}
