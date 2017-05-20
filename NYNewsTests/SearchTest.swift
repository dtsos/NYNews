//
//  SearchTest.swift
//  NYNews
//
//  Created by David Trivian S on 5/7/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import XCTest
import CoreData
@testable import NYNews

class SearchTest: XCTestCase {
    
    
    var appDelegate : AppDelegate?
    var managedObjectContext: NSManagedObjectContext?
    var listNewsVC : ListNewsViewController?
    //    var newsFeedsModel :NewsFeedModel?
    var searchFeedModel: SearchNewsFeedModel?
    let storyboardName = "Main"
    static let viewName = "ListNewsVC"
    
    var fetcher:Fetching?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate?.persistentContainer.viewContext
        fetcher = Fetching()
        let storyboard =  UIStoryboard(name: storyboardName, bundle: nil)
        listNewsVC = storyboard.instantiateViewController(withIdentifier: ListNewsViewController.ID) as? ListNewsViewController
        
        searchFeedModel =  SearchNewsFeedModel.init(fetching: self.fetcher!)
        let aSearchModel =  SearchModel.init()
        for  search in aSearchModel.listSearch!{
            self.managedObjectContext?.delete(search)
            (try! self.managedObjectContext?.save())
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        releaseAll()
        super.tearDown()
    }
    func releaseAll(){
        let aSearchModel =  SearchModel.init()
        for  search in aSearchModel.listSearch!{
            self.managedObjectContext?.delete(search)
            (try! self.managedObjectContext?.save())
        }
        appDelegate = nil
        managedObjectContext = nil
        fetcher = nil
        searchFeedModel = nil
        listNewsVC =  nil
    }
    
  
    func testUpdate() {
        searchFeedModel?.search = nil
        let stringKey = "New ItemsX"
        searchFeedModel?.letSearch(keyword: stringKey, completion: { (search) in
            XCTAssertNotNil(self.searchFeedModel?.search,"It mustNot Nil")
            let needUpdate = self.searchFeedModel?.isNeedUpdateServer(dictionary: nil, page: 0)
            XCTAssertTrue(needUpdate == true, "It is Must be true")
            var aDictionary = [String:AnyObject]()
            
            aDictionary ["web_url"] = "https://www.nytimes.com/aponline/2017/05/08/us/ap-us-mtv-movie-and-tv-awards.html" as AnyObject
            aDictionary["snippet"] = "Snipppet" as AnyObject
            aDictionary["headline"] = ["main":"this title"] as AnyObject
            
            
            aDictionary["pub_date"] = "2017-05-08T04:24:44+0000" as AnyObject
            
            aDictionary["_id"] = "590ff3167c459f24986de3d5" as AnyObject
            let aNewsModel = NewsModel.init(fetcher: self.fetcher!, dictionary: aDictionary, search: search)
            aNewsModel.save()
            XCTAssertTrue((self.searchFeedModel?.search?.listNews?.count)! >= 1, "Min 1")
            
            let aSearch = self.searchFeedModel?.search?.listNews?.allObjects.first as! NewsFeed
            debugPrint(aSearch.title!)
            XCTAssertTrue(self.searchFeedModel?.search?.keyword ==  stringKey, "must Equal")
            self.searchFeedModel?.letSearch(keyword: "New X", completion: { (search) in
                XCTAssertNotNil(self.searchFeedModel?.search,"It mustNot Nil")
                self.searchFeedModel?.letSearch(keyword: stringKey, completion: { (search) in
                    XCTAssertNotNil(self.searchFeedModel?.search,"It mustNot Nil")
                    self.searchFeedModel?.letSearch(keyword: stringKey, completion: { (search) in
                        XCTAssertNotNil(self.searchFeedModel?.search,"It mustNot Nil")
                    })
                })
            })
            
        })
        
    }
    
    func  test11Search(){
        searchFunc()
    }
    
    func searchFunc(){
        var firstSearch:String?
        var lastSearch:String?
        
        for i in 0...11{
            let stringKey:String = "New \(i)"
            if i == 2{
                firstSearch = stringKey
            }
            if i == 11 {
                lastSearch =  stringKey
            }
            self.searchFeedModel?.letSearch(keyword: stringKey, completion: { (search) in
                XCTAssertNotNil(self.searchFeedModel?.search,"It mustNot Nil")
                if(i == 11){
                    XCTAssertTrue(self.searchFeedModel?.itemsSearch.first?.keyword == lastSearch)
                    
                    XCTAssertTrue(self.searchFeedModel?.itemsSearch.last?.keyword == firstSearch)
                }
            })

        }
    }
    
    func testListNewsFound(){
        searchFeedModel?.search = nil
        searchFeedModel?.letSearch(keyword: "New ItemsX", completion: { (search) in
            XCTAssertNotNil(self.searchFeedModel?.search,"It mustNot Nil")
            let needUpdate = self.searchFeedModel?.isNeedUpdateServer(dictionary: nil, page: 0)
            XCTAssertTrue(needUpdate == true, "It is Must be true")
        })
        

    }
    func testCreateNews() {
         let search = searchFeedModel?.createNewSearch(keyword: "Singapore")
        var aDictionary = [String:AnyObject]()
        
        aDictionary ["web_url"] = "https://www.nytimes.com/aponline/2017/05/08/us/ap-us-mtv-movie-and-tv-awards.html" as AnyObject
        aDictionary["snippet"] = "Snipppet" as AnyObject
        aDictionary["headline"] = ["main":"this title"] as AnyObject
        
        
        aDictionary["pub_date"] = "2017-05-08T04:24:44+0000" as AnyObject
        
        aDictionary["_id"] = "590ff3167c459f24986de3d5" as AnyObject
        let aNewsModel = NewsModel.init(fetcher: self.fetcher!, dictionary: aDictionary, search: search!)
        aNewsModel.snippet = "newSnippet"
        aNewsModel.url = "newURl"
        aNewsModel.id = "newId"
        aNewsModel.imageUrl = "newImageUrl"
        aNewsModel.date = "newDate"
        aNewsModel.title = "newDate"
        XCTAssertEqual(aNewsModel.snippet, aNewsModel.news?.snippet,"Its must be Equal")
        XCTAssertEqual(aNewsModel.url, aNewsModel.news?.url,"Its must be Equal")
        XCTAssertEqual(aNewsModel.id, aNewsModel.news?.id,"Its must be Equal")
        XCTAssertEqual(aNewsModel.imageUrl, aNewsModel.news?.imageUrl,"Its must be Equal")
        XCTAssertEqual(aNewsModel.title, aNewsModel.news?.title,"Its must be Equal")
        aNewsModel.date = nil
        aNewsModel.snippet = nil
        aNewsModel.url = nil
        aNewsModel.id = nil
        aNewsModel.imageUrl = nil
        
        aNewsModel.title = nil
        aNewsModel.datePostDate()
        debugPrint(aNewsModel)
        
        aNewsModel.save()
        
        XCTAssertEqual(aNewsModel.news?.snippet, "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.url,  "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.id,  "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.imageUrl,  "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.title,  "","Its must be Equal")
        self.managedObjectContext?.delete(aNewsModel.news!)
        aNewsModel.save()
        
    }
    
    func testRemoveGetListSearch() {
       
    }
    func testErrorDictionary(){
         let search = searchFeedModel?.createNewSearch(keyword: "Singapore")
        var aDictionary = [String:AnyObject]()
        
        aDictionary["web_url"] = nil
        aDictionary["snippet"] = nil
        aDictionary["headline"] = ["main":""] as AnyObject
        aDictionary["multimedia"] = [["url":"urlLink"]] as AnyObject
        
        
        aDictionary["pub_date"] = nil
        
        aDictionary["_id"] = nil
        let aNewsModel = NewsModel.init(fetcher: self.fetcher!, dictionary: aDictionary, search: search!)
        aNewsModel.save()
        XCTAssertEqual(aNewsModel.news?.snippet, "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.url,  "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.id,  "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.imageUrl,  "urlLink","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.title,  "","Its must be Equal")
        self.managedObjectContext?.delete(aNewsModel.news!)
        aNewsModel.save()
    }
    
    func testErrorDictionary2(){
         let search = searchFeedModel?.createNewSearch(keyword: "Singapore")
        var aDictionary = [String:AnyObject]()
        
        aDictionary ["web_url"] = nil
        aDictionary["snippet"] = nil
        aDictionary["headline"] = [:] as AnyObject
        aDictionary["multimedia"] = [[String:AnyObject]]() as AnyObject
        
        
        aDictionary["pub_date"] = nil
        
        aDictionary["_id"] = nil
        
        let aNewsModel = NewsModel.init(fetcher: self.fetcher!, dictionary: aDictionary, search: search!)
        aNewsModel.save()
        XCTAssertEqual(aNewsModel.news?.snippet, "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.url,  "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.id,  "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.imageUrl,  "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.title,  "","Its must be Equal")
        self.managedObjectContext?.delete(aNewsModel.news!)
        aNewsModel.save()
        
    }
    
    func testSearch(){
        let search = searchFeedModel?.createNewSearch(keyword: "Key")
        XCTAssertNotNil(search, "Search not nil")
        managedObjectContext?.delete(search!)
        do {
            try self.managedObjectContext?.save()
        } catch  {
            XCTFail("Cannot save to CoreData")
        }
    }
    
    func testCheckServer(){
//        self.searchFeedModel?.search =  nil
//        XCTAssertTrue(self.searchFeedModel?.list().count == 0,"its muset zero")
//        self.searchFeedModel!.letSearch(keyword: "Key wan", completion: { (search) in
//            
//            
//            self.searchFeedModel?.checkServer(page: 0, search: search, beginUpdateView: {
//                
//            }, failed: {
//                
//            }, completion: { (page) in
//                XCTAssertTrue(self.searchFeedModel?.list().count != 0,"its not empty")
//                XCTAssertNotNil(self.searchFeedModel?.list(),"Not Nil")
//                XCTAssertEqual(self.searchFeedModel?.list().count, self.searchFeedModel?.numberOfRows(inSection: 0)," Its must be Equal")
//            })
//        })
        
        
        
        self.searchFeedModel!.letSearch(keyword: "Key wan2", completion: { (search) in
            self.searchFeedModel?.checkServer(page: 0, search: search, beginUpdateView: {
                
            }, failed: {
                
            }, completion: { (page) in
                XCTAssertTrue(self.searchFeedModel?.list().count != 0,"its not empty")
            })
        })
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            
            self.testCheckServer()
            
        }
    }
}
