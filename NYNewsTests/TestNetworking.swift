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
    var searchFeedModel: SearchNewsFeedModel?
    let storyboardName = "Main"
    static let viewName = "ListNewsVC"
    var arrayNewsFeedPage0 = [NewsFeed]()
    var fetcher:Fetching = Fetching()
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        newsFeedsModel =  NewsFeedModel.init(fetcher: self.fetcher)
        ////        listNewsVC?.fetchedResultsController = fetchedResultsController
        //
        searchFeedModel =  SearchNewsFeedModel.init(fetching: self.fetcher)
        self.searchFeedModel?.cancelOperation()
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
    //    func testFecthing(){
    //        var QueryString = ""
    //
    //        //        var QueryString =  "\(Constant.URLArticleSearch)\(Constant.paramAPIKeyValue)&page=0&sort=newest"
    //        //        fetch(query: QueryString)
    //
    //        //        QueryString = "http://rss.cnn.com/rss/cnn_topstories.rss"
    //        //        fetch(query: QueryString)
    //
    //
    //        QueryString =  "http://xxx.xxx.xxx/"
    //        fetch(query: QueryString)
    //    }
    
//    func testNewsFeed(){
//        
//        weak var weakSelf =  self
//        self.searchFeedModel?.cancelOperation()
//        self.searchFeedModel?.letSearch(keyword: "Dolphin", completion: { (search) in
//            
//            XCTAssertTrue(weakSelf?.searchFeedModel?.isNews == false, "It is News")
//            let indexPath = IndexPath(row:0, section:1)
//            let AnyItem = weakSelf?.searchFeedModel?.itemForRow(at: indexPath)
//            XCTAssertTrue(AnyItem is Search,"Item type must Search")
//            XCTAssertTrue((AnyItem as! Search).keyword ==  "Dolphin" && weakSelf?.searchFeedModel?.itemsSearch.first?.keyword == "Dolphin", "FirstItem Equal Last Search")
//            XCTAssertTrue((weakSelf?.searchFeedModel?.numberOfRows(inSection: 0))! >= 1, "Minumum 1")
//            XCTAssertTrue(weakSelf?.searchFeedModel?.search?.keyword == "Dolphin", "Dolphin the newest")
//            weakSelf?.measure {
//                weakSelf?.searchFeedModel?.cancelOperation()
//                weakSelf?.searchFeedModel?.checkServer(page: 0, search: (weakSelf?.searchFeedModel?.search)!, beginUpdateView: {
//                    
//                }, failed: {
//                    
//                }, completion: { (page) in
//                    XCTAssertTrue(weakSelf?.searchFeedModel?.isNews == true, "It is News")
//                    weakSelf?.searchFeedModel?.itemForRow(at: indexPath)
//                    XCTAssertTrue((weakSelf?.searchFeedModel?.numberOfRows(inSection: 0))! >= 1, "Minumum 1")
//                    let indexPath = IndexPath(row:0, section:1)
//                  
//                        let AnyItem = weakSelf?.searchFeedModel?.itemForRow(at: indexPath)
//                        XCTAssertTrue(AnyItem is NewsFeed,"Item type must News")
//                        
//                    
//
//                    
//                    
//                })
//                
//            }
//            
//        })
//        
//        
//    }
    func testArrayNews(){
        let aNewsFeed =  NewsFeed(context:self.managedObjectContext!)
        aNewsFeed.title = "Title"
        
        
        self.searchFeedModel?.isNews = true
        XCTAssertTrue(self.searchFeedModel?.numberOfSections() == 1, "Section alawys 1")
        self.searchFeedModel?.search?.addToListNews(aNewsFeed)
        self.searchFeedModel?.itemsNewsFeed.append(aNewsFeed)
        (try! self.managedObjectContext?.save())
        let indexPath = IndexPath(row:0, section:1)
        XCTAssertTrue((self.searchFeedModel?.numberOfRows(inSection: 0))! >= 0, "Minumum 1")
        
        
            let AnyItem = self.searchFeedModel?.itemForRow(at: indexPath)
            XCTAssertTrue(AnyItem is NewsFeed,"Item type must News")
        XCTAssertEqual(self.searchFeedModel?.list().count, self.searchFeedModel?.itemsNewsFeed.count,"Must Equal Array of News Feed")
            
        
    }
    func testNeedUpdate2(){
        self.searchFeedModel?.search = searchFeedModel?.createNewSearch(keyword: "dua duanya kanu")
        let update = self.searchFeedModel?.isNeedUpdateServer(dictionary: [String : AnyObject](), page: 0)
        XCTAssertTrue(update == true, "Need Update")
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
