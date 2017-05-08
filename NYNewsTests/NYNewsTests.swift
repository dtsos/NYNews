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
        newsFeedsModel =  NewsFeedModel.init(fetcher: self.fetcher!, fetchNewsController: fetchedResultsController)
        
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
        listNewsVC =  nil
    }
    func testGetListViewModel(){
        listNewsVC?.newsModel = newsFeedsModel
        
        XCTAssertTrue(listNewsVC?.newsModel?.getNewsModel(index: 0) != nil)
    }
    //    func
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testCheckListAfterComplete() {
        self.newsFeedsModel?.checkServer(page: 0, beginUpdateView: {
            
        }, failed: {
            
        }, completion: { (page) in
            let newsModel = self.newsFeedsModel?.getNewsModel(index: 0)
            let newsFetch = self.fetchedResultsController.fetchedObjects?.first
            XCTAssertTrue(newsFetch == newsModel?.news)
            
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
