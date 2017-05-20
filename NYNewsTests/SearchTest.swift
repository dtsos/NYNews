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
        //        let storyboard =  UIStoryboard(name: storyboardName, bundle: nil)
        //        listNewsVC = storyboard.instantiateViewController(withIdentifier: ListNewsViewController.ID) as? ListNewsViewController
        
        searchFeedModel =  SearchNewsFeedModel.init(fetching: self.fetcher!)
        let aSearchModel =  SearchModel.init()
        for  search in aSearchModel.listSearch!{
            self.managedObjectContext?.delete(search)
            (try! self.managedObjectContext?.save())
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.searchFeedModel?.cancelOperation()
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
    
    func testNeedUpdate() {
        searchFeedModel?.search = searchFeedModel?.createNewSearch(keyword: "testingX")
        var checkUpdateItems = searchFeedModel?.isNeedUpdateServer(dictionary: nil, page: 0)
        XCTAssertFalse(checkUpdateItems! ,"It mush be false")
        checkUpdateItems = searchFeedModel?.isNeedUpdateServer(dictionary: [String : AnyObject](), page: 0)
        searchFeedModel?.page = 0
        var aDictionary = [String:AnyObject]()
        
        aDictionary ["web_url"] = "https://www.nytimes.com/aponline/2017/05/08/us/ap-us-mtv-movie-and-tv-awards.html" as AnyObject
        aDictionary["snippet"] = "Snipppet" as AnyObject
        aDictionary["headline"] = ["main":"this title"] as AnyObject
        
        
        aDictionary["pub_date"] = "2017-05-08T04:24:44+0007" as AnyObject
        
        aDictionary["_id"] = "590ff3167c459f24986de3dx" as AnyObject
        
        checkUpdateItems = searchFeedModel?.isNeedUpdateServer(dictionary: aDictionary, page: 1)
        searchFeedModel?.page = 1
        //        var arrayNews =newsFeedsModel?.listNews(page: 0)
        //        for news in arrayNews {
        //            self.managedObjectContext?.delete(news)
        //        }
        createdDummyArrayFeed(page: 2,max: 10,search: (self.searchFeedModel?.search)!)
        checkUpdateItems = searchFeedModel?.isNeedUpdateServer(dictionary: aDictionary, page: 2)
        createdDummyArrayFeed(page: 3,max: 5,search: (self.searchFeedModel?.search)!)
        aDictionary["_id"] = nil
        checkUpdateItems = searchFeedModel?.isNeedUpdateServer(dictionary: aDictionary, page: 3)
        
        
        createdDummyArrayFeed(page: 4,max: 5,search:(self.searchFeedModel?.search)!)
        aDictionary["_id"] = "idSame" as AnyObject
        checkUpdateItems = searchFeedModel?.isNeedUpdateServer(dictionary: aDictionary, page: 4)
        checkUpdateItems = searchFeedModel?.isNeedUpdateServer(dictionary: aDictionary, page: 4)
        
        
        
        //        XCTAssertFalse((checkUpdateItems?.update)! ,"It mush be false")
        
    }
    func createdDummyArrayFeed(page:Int16,max:Int,search:Search){
        var arrayFeedPage:[NewsFeed] =  [NewsFeed]()
        for i  in 0...(max - 1) {
            var aDictionary = [String:AnyObject]()
            
            aDictionary ["web_url"] = "https://www.nytimes.com/aponline/2017/05/08/us/ap-us-mtv-movie-and-tv-awards.html" as AnyObject
            aDictionary["snippet"] = "Snipppet" as AnyObject
            aDictionary["headline"] = ["main":"this title"] as AnyObject
            
            
            aDictionary["pub_date"] = "2017-05-08T04:24:44+000\(i)" as AnyObject
            
            aDictionary["_id"] = "590ff3167c459f24986de3d\(i)" as AnyObject
            if page == 4 {
                aDictionary["_id"] = "idSame" as AnyObject
            }
            let aNewsModel = NewsModel.init(fetcher: self.fetcher!, dictionary: aDictionary)
            aNewsModel.news?.page = page
            aNewsModel.news?.isHeadline =  false
            aNewsModel.news?.whichSearch = search
            aNewsModel.save()
            arrayFeedPage.append(aNewsModel.news!)
            
            
        }
    }

    
    func testUpdate() {
        weak var weakSelf = self
        searchFeedModel?.search = nil
        let stringKey = "New ItemsX"
        searchFeedModel?.letSearch(keyword: stringKey, completion: { (search) in
            XCTAssertTrue(weakSelf?.searchFeedModel?.numberOfSections() == 1 , "section always 1")
            XCTAssertNotNil(weakSelf?.searchFeedModel?.search,"It mustNot Nil")
            let needUpdate = weakSelf?.searchFeedModel?.isNeedUpdateServer(dictionary: nil, page: 0)
            XCTAssertTrue(needUpdate == false, "It is Must be true")
            var aDictionary = [String:AnyObject]()
            
            aDictionary ["web_url"] = "https://www.nytimes.com/aponline/2017/05/08/us/ap-us-mtv-movie-and-tv-awards.html" as AnyObject
            aDictionary["snippet"] = "Snipppet" as AnyObject
            aDictionary["headline"] = ["main":"this title"] as AnyObject
            
            
            aDictionary["pub_date"] = "2017-05-08T04:24:44+0000" as AnyObject
            
            aDictionary["_id"] = "590ff3167c459f24986de3d5" as AnyObject
            let aNewsModel = NewsModel.init(fetcher: (weakSelf?.fetcher!)!, dictionary: aDictionary, search: search)
            aNewsModel.save()
            XCTAssertTrue((weakSelf?.searchFeedModel?.search?.listNews?.count)! >= 1, "Min 1")
            
            let aSearch = weakSelf?.searchFeedModel?.search?.listNews?.allObjects.first as! NewsFeed
            debugPrint(aSearch.title!)
            XCTAssertTrue(weakSelf?.searchFeedModel?.search?.keyword ==  stringKey, "must Equal")
            weakSelf?.searchFeedModel?.letSearch(keyword: "New X", completion: { (search) in
                XCTAssertTrue(weakSelf?.searchFeedModel?.numberOfSections() == 1 , "section always 1")
                XCTAssertNotNil(weakSelf?.searchFeedModel?.search,"It mustNot Nil")
                let aNewsModel = NewsModel.init(fetcher: (weakSelf?.fetcher!)!, dictionary: aDictionary, search: search)
                
                aNewsModel.save()
                weakSelf?.searchFeedModel?.isNeedUpdateServer(dictionary: aDictionary, page: 0)
                //                XCTAssertTrue(needUpdate == true, "It is Must be true")
                weakSelf?.searchFeedModel?.letSearch(keyword: stringKey, completion: { (search) in
                    XCTAssertNotNil(weakSelf?.searchFeedModel?.search,"It mustNot Nil")
                    weakSelf?.searchFeedModel?.isNeedUpdateServer(dictionary: aDictionary, page: 0)
                    weakSelf?.searchFeedModel?.letSearch(keyword: stringKey, completion: { (search) in
                        XCTAssertNotNil(weakSelf?.searchFeedModel?.search,"It mustNot Nil")
                    })
                })
            })
            
        })
        
    }
    func testNewsFeed(){
        weak var weakSelf = self
            
        self.searchFeedModel?.cancelOperation()
        self.searchFeedModel?.letSearch(keyword: "Dolphin", completion: { (search) in
            
            XCTAssertTrue(weakSelf?.searchFeedModel?.isNews == false, "It is News")
            let indexPath = IndexPath(row:0, section:1)
            let AnyItem = weakSelf?.searchFeedModel?.itemForRow(at: indexPath)
            XCTAssertTrue(AnyItem is Search,"Item type must Search")
            XCTAssertTrue((AnyItem as! Search).keyword ==  "Dolphin" && weakSelf?.searchFeedModel?.itemsSearch.first?.keyword == "Dolphin", "FirstItem Equal Last Search")
            XCTAssertTrue((weakSelf?.searchFeedModel?.numberOfRows(inSection: 0))! >= 1, "Minumum 1")
            XCTAssertTrue(weakSelf?.searchFeedModel?.search?.keyword == "Dolphin", "Dolphin the newest")
            weakSelf?.measure {
            weakSelf?.searchFeedModel?.checkServer(page: 0, search: (weakSelf?.searchFeedModel?.search)!, beginUpdateView: {
                
            }, failed: {

            }, completion: { (page) in
                XCTAssertTrue(weakSelf?.searchFeedModel?.isNews == true, "It is News")
                
               
                    let AnyItem = weakSelf?.searchFeedModel?.itemForRow(at: indexPath)
                    XCTAssertTrue(AnyItem is NewsFeed,"Item type must News")
                    
                

              
                
                
                
            })
            
            }
          
        })
       
        
    }
    
    func  test11Search(){
        searchFunc()
    }
    
    func searchFunc(){
        var firstSearch:String?
        var lastSearch:String?
        weak var weakSelf = self
        for i in 0...11{
            let stringKey:String = "New \(i)"
            if i == 2{
                firstSearch = stringKey
            }
            if i == 11 {
                lastSearch =  stringKey
            }
            self.searchFeedModel?.letSearch(keyword: stringKey, completion: { (search) in
                XCTAssertNotNil(weakSelf?.searchFeedModel?.search,"It mustNot Nil")
                if(i == 11){
                    XCTAssertTrue(weakSelf?.searchFeedModel?.itemsSearch.first?.keyword == lastSearch)
                    
                    XCTAssertTrue(weakSelf?.searchFeedModel?.itemsSearch.last?.keyword == firstSearch)
                }
            })
            
        }
    }
    
    func testSearchSyncServer(){
        let aSearch1 =  searchFeedModel?.createNewSearch(keyword: "Singapore")
        let aSearch2 =  searchFeedModel?.createNewSearch(keyword: "Indonesia")
        searchFeedModel?.checkServer(page: 0, search: aSearch1!, beginUpdateView: {
            
        }, failed: {
            
        }, completion: { (page) in
            
        })
        searchFeedModel?.checkServer(page: 1, search: aSearch1!, beginUpdateView: {
            
        }, failed: {
            
        }, completion: { (page) in
            
        })
        
        searchFeedModel?.checkServer(page: 0, search: aSearch2!, beginUpdateView: {
            
        }, failed: {
            
        }, completion: { (page) in
            
        })
        
    }
    func complete(page:Int16){
        debugPrint("Complete")
    }
    
    func testSearchServer(){
        weak var weakSelf = self
        searchFeedModel?.letSearch(keyword: "SingaporeX", completion: { (search) in
            weakSelf?.searchFeedModel?.checkServer(page: 0, search: search, beginUpdateView: {
                
            }, failed: {
                
            }, completion:(weakSelf?.complete)!)
        })
        
    }
    
    
    func testListNewsFound(){
        weak var weakSelf = self
        searchFeedModel?.search = nil
        searchFeedModel?.letSearch(keyword: "New ItemsX", completion: { (search) in
            XCTAssertNotNil(weakSelf?.searchFeedModel?.search,"It mustNot Nil")
           
            
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
    
    func checkServer(){
        
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
            
            self.checkServer()
            
        }
    }
}
