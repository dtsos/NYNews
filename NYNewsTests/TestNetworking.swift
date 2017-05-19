//
//  TestNetworking.swift
//  NYNews
//
//  Created by David Trivian S on 5/18/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//


import XCTest
import CoreData
@testable import NYNews

class TestNetworking: XCTestCase {
    var appDelegate : AppDelegate?
    var managedObjectContext: NSManagedObjectContext?
    var listNewsVC : ListNewsViewController?
    var newsFeedsModel :NewsFeedModel?
    let storyboardName = "Main"
    static let viewName = "ListNewsVC"
    var arrayNewsFeedPage0 = [NewsFeed]()
    var fetcher:Fetching = Fetching()
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let storyboard =  UIStoryboard(name: storyboardName, bundle: nil)
        listNewsVC = storyboard.instantiateViewController(withIdentifier: ListNewsViewController.ID) as? ListNewsViewController
        newsFeedsModel =  NewsFeedModel.init(fetcher: self.fetcher)
        ////        listNewsVC?.fetchedResultsController = fetchedResultsController
        //
        listNewsVC?.newsModel = newsFeedsModel
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        releaseAll()
        super.tearDown()
    }
    func releaseAll(){
        appDelegate = nil
        newsFeedsModel = nil
        managedObjectContext = nil
        
        listNewsVC =  nil
    }
    func testFecthing(){
        var QueryString = ""
        
        //        var QueryString =  "\(Constant.URLArticleSearch)\(Constant.paramAPIKeyValue)&page=0&sort=newest"
        //        fetch(query: QueryString)
        
        //        QueryString = "http://rss.cnn.com/rss/cnn_topstories.rss"
        //        fetch(query: QueryString)
        
        
        QueryString =  "http://xxx.xxx.xxx/"
        fetch(query: QueryString)
    }
    
    func fetch(query:String){
        debugPrint(fetcher)
        self.fetcher.fetch(withQueryString: query, failure: { (error) in
            debugPrint("error \(String(describing: error))")
            XCTAssertNotNil(error, "error Not nil")
        }, completion: { (dictionary) in
            debugPrint("this fetch \(dictionary)")
            XCTAssertNotNil(dictionary, "dictionary Not nil")
        })
    }
    
    
}
