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
    var searchFeedModel: SearchFeedModel?
    let storyboardName = "Main"
    static let viewName = "ListNewsVC"
    
    var fetcher:Fetching?
    
    var fetchedResultsController: NSFetchedResultsController<NewsFeed>? = nil
    
    var _fetchedResultsController: NSFetchedResultsController<NewsFeed>? = nil
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate?.persistentContainer.viewContext
        fetcher = Fetching()
        let fetchRequest: NSFetchRequest<NewsFeed> = NewsFeed.fetchRequest()
        
        
        fetchRequest.fetchBatchSize = 20
        fetchRequest.predicate = NSPredicate(format: "page <= 0 AND isHeadline = true")
        
        
        
        let sortDescriptor = NSSortDescriptor(key: "dateModified", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName:nil)
        
        self._fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        self.fetchedResultsController = self._fetchedResultsController!
        
        
        let storyboard =  UIStoryboard(name: storyboardName, bundle: nil)
        listNewsVC = storyboard.instantiateViewController(withIdentifier: ListNewsViewController.ID) as? ListNewsViewController
        //        newsFeedsModel =  NewsFeedModel.init(fetcher: self.fetcher!, fetchNewsController: fetchedResultsController)
        searchFeedModel =  SearchFeedModel.init(fetching: self.fetcher!, managedContext: self.managedObjectContext!)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        releaseAll()
        super.tearDown()
    }
    func releaseAll(){
        appDelegate = nil
        managedObjectContext = nil
        fetcher = nil
        searchFeedModel = nil
        listNewsVC =  nil
        fetchedResultsController =  nil
        _fetchedResultsController =  nil
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
        self.searchFeedModel?.search =  nil
        XCTAssertTrue(self.searchFeedModel?.list().count == 0,"its muset zero")
        self.searchFeedModel!.letSearch(keyword: "Key wan", completion: { (search) in
            
        
            self.searchFeedModel?.checkServer(page: 0, search: search, beginUpdateView: {
                
            }, failed: {
                
            }, completion: { (page) in
                 XCTAssertTrue(self.searchFeedModel?.list().count != 0,"its not empty")
                XCTAssertNotNil(self.searchFeedModel?.list(),"Not Nil")
                XCTAssertEqual(self.searchFeedModel?.list().count, self.searchFeedModel?.numberOfRows(inSection: 0)," Its must be Equal")
            })
        })
        
        
        
       self.searchFeedModel!.letSearch(keyword: "Key wan2", completion: { (search) in
            self.searchFeedModel?.checkServer(page: 0, search: search, beginUpdateView: {
                
            }, failed: {
                
            }, completion: { (page) in
                XCTAssertNotNil(self.searchFeedModel?.list(),"Not Nil")
            })
        })
        //         managedObjectContext?.delete(search!)
        //
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            
            self.testCheckServer()
            
        }
    }
}
