//
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
    
    var fetcher:Fetching?
    
    var fetchedResultsController: NSFetchedResultsController<NewsFeed> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<NewsFeed> = NewsFeed.fetchRequest()
        
        
        fetchRequest.fetchBatchSize = 20
        fetchRequest.predicate = NSPredicate(format: "page <= 0 AND isHeadline = true")
        
        
        
        
        
        let sortDescriptor = NSSortDescriptor(key: "dateModified", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName:nil)
        
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<NewsFeed>? = nil
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate?.persistentContainer.viewContext
        fetcher = Fetching()
        let storyboard =  UIStoryboard(name: storyboardName, bundle: nil)
        listNewsVC = storyboard.instantiateViewController(withIdentifier: ListNewsViewController.ID) as? ListNewsViewController
        newsFeedsModel =  NewsFeedModel.init(fetcher: self.fetcher!,managedObjectContext: managedObjectContext!)
//        listNewsVC?.fetchedResultsController = fetchedResultsController
        listNewsVC?.managedObjectContext = managedObjectContext
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
        fetcher = nil
        listNewsVC =  nil
    }
    
    func testCreateNews() {
        let aDictionary:[String:AnyObject] = ["web_url": "https://www.nytimes.com/aponline/2017/05/08/us/ap-us-mtv-movie-and-tv-awards.html" as AnyObject,
                                              "snippet": "Snipppet" as AnyObject,
                                              
                                              
                                              
                                              "pub_date": "2017-05-08T04:24:44+0000" as AnyObject,
                                              
                                              "_id": "590ff3167c459f24986de3d5" as AnyObject]
        let aNewsModel = NewsModel.init(fetcher: self.fetcher!, dictionary: aDictionary, context: self.managedObjectContext!)
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
        aNewsModel.createNewsFeed()
        self.managedObjectContext?.delete(aNewsModel.news!)
        aNewsModel.save()
        
    }
   
    func testPull() {
        listNewsVC?.didPullToRefresh()
        
    }
    func testGetListViewModel(){
        
        listNewsVC?.newsModel = newsFeedsModel
        newsFeedsModel?.readyVC()
        let indexPath:IndexPath =  IndexPath(row: 0, section: 0)
        XCTAssertTrue(listNewsVC?.newsModel?.itemForRow(at: indexPath) != nil)
    }

    
    func testCheckListAfterComplete() {
        let aPage = 10
        self.newsFeedsModel?.checkServer(page: Int16(aPage), beginUpdateView: {
            debugPrint("update")
        }, failed: {
            debugPrint("failed")
            
        }, completion: { (page) in

            XCTAssertEqual(aPage,Int(page),"it must be equal")
        
        })
        
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            self.testCheckListAfterComplete()
        }
    }
    
}
