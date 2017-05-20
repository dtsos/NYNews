//  NYNewsTests.swift
//  NYNewsTests
//
//  Created by David Trivian S on 5/5/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import XCTest
import CoreData
@testable import NYNews

class NYNewsTests: XCTestCase {
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
    
    
    func testDateDiff() {
        let dateNil:NSDate? =  nil
        let stringDate:String? = dateNil?.dateDiff()
        
        XCTAssertNil(dateNil,"Must nil")
        XCTAssertTrue(dateNil == nil && stringDate == nil, "is Nil")
        
        let dateNow:NSDate =  NSDate()
        dateDiffTest(dateNow)
        
        let halfminute = Calendar.current.date(byAdding: .second, value: -30, to: dateNow as Date)
        dateDiffTest(halfminute! as NSDate)
        
        
        let aminute = Calendar.current.date(byAdding: .minute, value: -1, to: dateNow as Date)
        dateDiffTest(aminute! as NSDate)
        
        let aHour = Calendar.current.date(byAdding: .hour, value: -1, to: dateNow as Date)
        dateDiffTest(aHour! as NSDate)
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: dateNow as Date)
        dateDiffTest(yesterday! as NSDate)
        
        
        let longTime = Calendar.current.date(byAdding: .year, value: -10, to: dateNow as Date)
        dateDiffTest(longTime! as NSDate)
        
    }
    
    func dateDiffTest(_ date:NSDate){
        let stringDate =  date.dateDiff()
        XCTAssertNotNil(!(stringDate?.isEmpty)!, "Is Not Empty")
    }
    
    
    
    //    func testFailed(){
    //        let QueryString =  "http://xxx.xxx.xxx/"
    //        fetch(query: QueryString)
    //        cancelOperation(stringUrl: QueryString)
    //    }
    //
    func cancelOperation(stringUrl:String?)
    {
        if stringUrl != nil && (stringUrl?.characters.count)! > 0{
            URLSession.shared.getTasksWithCompletionHandler { (dataStacks, uploadStacks, downloadStacks) in
                for dataStack in dataStacks {
                    
                    if dataStack.originalRequest?.url?.absoluteString == stringUrl {
                        dataStack.cancel()
                        return
                    }
                    
                }
            }
        }
    }
    
    
    
    func testCheckServer(){
        debugPrint(fetcher)
        newsFeedsModel?.checkServer(page: 0, beginUpdateView: {
            debugPrint("update")
        }, failed: {
            debugPrint("failed")
        }, completion: { (page) in
            debugPrint(page)
            
        })
    }
    
    func testCreateNews() {
        var aDictionary = [String:AnyObject]()
        
        aDictionary ["web_url"] = "https://www.nytimes.com/aponline/2017/05/08/us/ap-us-mtv-movie-and-tv-awards.html" as AnyObject
        aDictionary["snippet"] = "Snipppet" as AnyObject
        aDictionary["headline"] = ["main":"this title"] as AnyObject
        
        
        aDictionary["pub_date"] = "2017-05-08T04:24:44+0000" as AnyObject
        
        aDictionary["_id"] = "590ff3167c459f24986de3d5" as AnyObject
        let aNewsModel = NewsModel.init(fetcher: self.fetcher, dictionary: aDictionary)
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
    func testErrorDictionary(){
        var aDictionary = [String:AnyObject]()
        
        aDictionary["web_url"] = nil
        aDictionary["snippet"] = nil
        aDictionary["headline"] = ["main":""] as AnyObject
        aDictionary["multimedia"] = [["url":"urlLink"]] as AnyObject
        
        
        aDictionary["pub_date"] = nil
        
        aDictionary["_id"] = nil
        let aNewsModel = NewsModel.init(fetcher: self.fetcher, dictionary: aDictionary as [String : AnyObject])
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
        var aDictionary = [String:AnyObject]()
        
        aDictionary ["web_url"] = nil
        aDictionary["snippet"] = nil
        aDictionary["headline"] = [:] as AnyObject
        aDictionary["multimedia"] = [[String:AnyObject]]() as AnyObject
        
        
        aDictionary["pub_date"] = nil
        
        aDictionary["_id"] = nil
        
        let aNewsModel = NewsModel.init(fetcher: self.fetcher, dictionary: aDictionary as [String : AnyObject])
        aNewsModel.save()
        XCTAssertEqual(aNewsModel.news?.snippet, "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.url,  "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.id,  "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.imageUrl,  "","Its must be Equal")
        XCTAssertEqual(aNewsModel.news?.title,  "","Its must be Equal")
        self.managedObjectContext?.delete(aNewsModel.news!)
        aNewsModel.save()
        
    }
    func testPull() {
        listNewsVC?.didPullToRefresh()
        
    }
    func testGetListViewModel(){
        
        listNewsVC?.newsModel = newsFeedsModel
        newsFeedsModel?.readyVC()
//        let indexPath:IndexPath =  IndexPath(row: 0, section: 0)
//        XCTAssertTrue(listNewsVC?.newsModel?.itemForRow(at: indexPath) != nil)
    }
    //
    //
    func testCheckListAfterComplete() {
        let aPage = 0
        self.newsFeedsModel?.checkServer(page: Int16(aPage), beginUpdateView: {
            debugPrint("update")
        }, failed: {
            debugPrint("failed")
            
        }, completion: { (page) in
            
            XCTAssertEqual(aPage,Int(page),"it must be equal")
            
        })
        
        
    }
    func createdDummyArrayFeed(page:Int16,max:Int){
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
            let aNewsModel = NewsModel.init(fetcher: self.fetcher, dictionary: aDictionary)
            aNewsModel.news?.page = page
            aNewsModel.news?.isHeadline =  true
            aNewsModel.save()
            arrayFeedPage.append(aNewsModel.news!)
            
            
        }
    }
    func testNeedUpdate() {
        var checkUpdateItems = newsFeedsModel?.isNeedUpdateServer(dictionary: nil, page: 0)
        XCTAssertFalse((checkUpdateItems?.update)! ,"It mush be false")
        checkUpdateItems = newsFeedsModel?.isNeedUpdateServer(dictionary: [String : AnyObject](), page: 0)
        newsFeedsModel?.page = 0
        var aDictionary = [String:AnyObject]()
        
        aDictionary ["web_url"] = "https://www.nytimes.com/aponline/2017/05/08/us/ap-us-mtv-movie-and-tv-awards.html" as AnyObject
        aDictionary["snippet"] = "Snipppet" as AnyObject
        aDictionary["headline"] = ["main":"this title"] as AnyObject
        
        
        aDictionary["pub_date"] = "2017-05-08T04:24:44+0007" as AnyObject
        
        aDictionary["_id"] = "590ff3167c459f24986de3dx" as AnyObject
        
        checkUpdateItems = newsFeedsModel?.isNeedUpdateServer(dictionary: aDictionary, page: 1)
        newsFeedsModel?.page = 1
        //        var arrayNews =newsFeedsModel?.listNews(page: 0)
        //        for news in arrayNews {
        //            self.managedObjectContext?.delete(news)
        //        }
        createdDummyArrayFeed(page: 2,max: 10)
        checkUpdateItems = newsFeedsModel?.isNeedUpdateServer(dictionary: aDictionary, page: 2)
        createdDummyArrayFeed(page: 3,max: 5)
        aDictionary["_id"] = nil
        checkUpdateItems = newsFeedsModel?.isNeedUpdateServer(dictionary: aDictionary, page: 3)
        
        
        createdDummyArrayFeed(page: 4,max: 5)
        aDictionary["_id"] = "idSame" as AnyObject
        checkUpdateItems = newsFeedsModel?.isNeedUpdateServer(dictionary: aDictionary, page: 4)
        checkUpdateItems = newsFeedsModel?.isNeedUpdateServer(dictionary: aDictionary, page: 4)
        
        
        
        //        XCTAssertFalse((checkUpdateItems?.update)! ,"It mush be false")
        
    }
    
    func callServer(page:Int16){
        newsFeedsModel?.checkServer(page: page, beginUpdateView: {
            
        }, failed: {
            
        }, completion: { (page) in
            if page < 5 {
                self.callServer(page: page + 1)
                
            }
        })
        
    }
    
    func testServer(){
        self.callServer(page: -1)
        self.callServer(page: 0)
        
        newsFeedsModel?.checkServer(page: 0, beginUpdateView: {
            
        }, failed: {
            
        }, completion: { (page) in
           
        })
        newsFeedsModel?.checkServer(page: 1, beginUpdateView: {
            
        }, failed: {
            
        }, completion: { (page) in
            
        })
        self.callServer(page: 1)
        
        
        
        
        
        
        
        
    }
    
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //            self.testCheckListAfterComplete()
    //        }
    //    }
    //
}
