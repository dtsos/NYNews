//
//  MockingSearchNetwork.swift
//  NYNews
//
//  Created by David Trivian S on 5/20/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import XCTest
import CoreData
@testable import NYNews
class MockingSearchNetwork: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext!
        let fetchRequest : NSFetchRequest<NewsFeed> = NewsFeed.fetchRequest()
        
        
        fetchRequest.predicate = NSPredicate(format: "isHeadline = true")
        
        
        var result :[NewsFeed]?
        
        result = (try! managedObjectContext.fetch(fetchRequest))
        for news in result! {
            managedObjectContext.delete(news)
            (try! managedObjectContext.save())
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testServerNoWrongDataResponseValid(){
        
        
        class NetworkEngineMock: NetworkEngine {
            typealias Handler = NetworkEngine.Handler
            
            var requestedURL: URL?
            
            func performRequest(for url: URL, completionHandler: @escaping Handler) {
                requestedURL = url
                var dictionary:[String:AnyObject] = [String:AnyObject]()
                
                var dictItem:[String:AnyObject]  = ["web_url":"https://www.nytimes.com/reuters/2017/05/20/world/americas/20reuters-mexico-violence-russian.html" as AnyObject,"snippet":"A mob of angry Mexicans attacked a Russian man in the Caribbean resort of Cancun with sticks and rocks over his repeated insults against locals, and the 42-year-old man was accused of fatally stabbing a youth in the melee, authorities said on Satu..." as AnyObject,"multimedia":"" as AnyObject,"pub_date":"2017-05-21T00:51:34+0000" as AnyObject,"_id":"5920e49b95d0e024b5871fe3" as AnyObject]
                let dictionaryHeadline = ["main":"Mexican Mob Attacks Russian Man in Cancun Over Insults"]
                dictItem["headline"] = dictionaryHeadline as AnyObject
                var arrayMultimedia:[[String:AnyObject]] = [[String:AnyObject]] ()
                let multimediaSample1:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-thumbStandard.jpg" as AnyObject]
                let multimediaSample2:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-articleLarge.jpg" as AnyObject]
                
                
                let multimediaSample3:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-thumbWide.jpg" as AnyObject]
                arrayMultimedia.append(multimediaSample1)
                arrayMultimedia.append(multimediaSample2)
                arrayMultimedia.append(multimediaSample3)
                dictItem["multimedia"] = arrayMultimedia as AnyObject
                var arrayDocs:[[String:AnyObject]] = [[String:AnyObject]]()
                
                
                arrayDocs.append(dictItem)
                
                
                var dictionaryResponse = [String:AnyObject]()
                dictionaryResponse["docs"] = arrayDocs as AnyObject
                dictionaryResponse["copyright"] = "Copyright (c) 2013 The New York Times Company. All Rights Reserved." as AnyObject
                dictionary["response"] = dictionaryResponse as AnyObject
                let data = (try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted))
                let Urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: nil)
                completionHandler(data,Urlresponse,nil)
            }
        }
        
        let engine = NetworkEngineMock()
        let fetching =  Fetching(engine:engine)
        
        let searchFeedModel =  SearchNewsFeedModel.init(fetching: fetching)
        
        searchFeedModel.letSearch(keyword: "Coba 1") { (search) in
            searchFeedModel.checkServer(page: 0, search: search, beginUpdateView: { 
                
            }, failed: { 
                
            }, completion: { (page) in
                XCTAssertTrue(searchFeedModel.list().count > 0 ,"have news")
                let aNews:NewsFeed = searchFeedModel.itemForRow(at: IndexPath(row:0,section:0)) as! NewsFeed
                XCTAssertTrue(aNews.id == "5920e49b95d0e024b5871fe3" ,"same ID")

            })
        }
        
    }
    
    func testServerNoWrongDataResponseInValid(){
        class NetworkEngineMock: NetworkEngine {
            typealias Handler = NetworkEngine.Handler
            
            var requestedURL: URL?
            
            func performRequest(for url: URL, completionHandler: @escaping Handler) {
                requestedURL = url
                var dictionary:[String:AnyObject] = [String:AnyObject]()
                
                var dictItem:[String:AnyObject]  = ["web_url":"https://www.nytimes.com/reuters/2017/05/20/world/americas/20reuters-mexico-violence-russian.html" as AnyObject,"snippet":"A mob of angry Mexicans attacked a Russian man in the Caribbean resort of Cancun with sticks and rocks over his repeated insults against locals, and the 42-year-old man was accused of fatally stabbing a youth in the melee, authorities said on Satu..." as AnyObject,"multimedia":"" as AnyObject,"pub_date":"2017-05-21T00:51:34+0000" as AnyObject,"_id":"5920e49b95d0e024b5871fe3" as AnyObject]
                let dictionaryHeadline = ["main":"Mexican Mob Attacks Russian Man in Cancun Over Insults"]
                dictItem["headline"] = dictionaryHeadline as AnyObject
                var arrayMultimedia:[[String:AnyObject]] = [[String:AnyObject]] ()
                let multimediaSample1:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-thumbStandard.jpg" as AnyObject]
                let multimediaSample2:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-articleLarge.jpg" as AnyObject]
                
                
                let multimediaSample3:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-thumbWide.jpg" as AnyObject]
                arrayMultimedia.append(multimediaSample1)
                arrayMultimedia.append(multimediaSample2)
                arrayMultimedia.append(multimediaSample3)
                dictItem["multimedia"] = arrayMultimedia as AnyObject
                var arrayDocs:[[String:AnyObject]] = [[String:AnyObject]]()
                
                
                arrayDocs.append(dictItem)
                
                
                var dictionaryResponse = [String:AnyObject]()
                dictionaryResponse["docs"] = arrayDocs as AnyObject
                dictionaryResponse["copyright"] = "Copyright (c) 2013 The New York Times Company. All Rights Reserved." as AnyObject
                dictionary["response"] = dictionaryResponse as AnyObject
                let data = (try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted))
                
                completionHandler(data,nil,nil)
            }
        }
        
        let engine = NetworkEngineMock()
        let fetching =  Fetching(engine:engine)
        let searchFeedModel =  SearchNewsFeedModel.init(fetching: fetching)
        
        searchFeedModel.letSearch(keyword: "Singa") { (search) in
            searchFeedModel.checkServer(page: 0, search: search, beginUpdateView: {
                
            }, failed: {
                
            }, completion: { (page) in
                XCTAssertTrue(searchFeedModel.list().count > 0 ,"have news")
                let aNews:NewsFeed = searchFeedModel.itemForRow(at: IndexPath(row:0,section:0)) as! NewsFeed
                XCTAssertTrue(aNews.id == "5920e49b95d0e024b5871fe3" ,"same ID")
            })
        }

    }
    
    func testServerNoData(){
        class NetworkEngineMock: NetworkEngine {
            typealias Handler = NetworkEngine.Handler
            
            var requestedURL: URL?
            
            func performRequest(for url: URL, completionHandler: @escaping Handler) {
                requestedURL = url
                let Urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: nil)
                completionHandler(nil,Urlresponse,nil)
            }
        }
        
        let engine = NetworkEngineMock()
        let fetching =  Fetching(engine:engine)
        let searchFeedModel =  SearchNewsFeedModel.init(fetching: fetching)
        
        searchFeedModel.letSearch(keyword: "Singa") { (search) in
            searchFeedModel.checkServer(page: 0, search: search, beginUpdateView: {
                
            }, failed: {
                XCTAssertTrue(searchFeedModel.list().count == 0 ,"no have news")
               
            }, completion: { (page) in
                XCTAssertTrue(searchFeedModel.list().count > 0 ,"have news")
                let aNews:NewsFeed = searchFeedModel.itemForRow(at: IndexPath(row:0,section:0)) as! NewsFeed
                XCTAssertTrue(aNews.id == "5920e49b95d0e024b5871fe3" ,"same ID")
            })
        }

        
    }
    
    func testServerNoValidData(){
        class NetworkEngineMock: NetworkEngine {
            typealias Handler = NetworkEngine.Handler
            
            var requestedURL: URL?
            
            func performRequest(for url: URL, completionHandler: @escaping Handler) {
                requestedURL = url
                let Urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: nil)
                let data = "Hello world".data(using: .utf8)
                completionHandler(data,Urlresponse,nil)
            }
        }
        
        let engine = NetworkEngineMock()
        let fetching =  Fetching(engine:engine)
        let searchFeedModel =  SearchNewsFeedModel.init(fetching: fetching)
        
        searchFeedModel.letSearch(keyword: "Singapore") { (search) in
            searchFeedModel.checkServer(page: 0, search: search, beginUpdateView: {
                
            }, failed: {
                XCTAssertTrue(searchFeedModel.list().count == 0 ,"no have news")
                
                
            }, completion: { (page) in
                XCTAssertTrue(searchFeedModel.list().count > 0 ,"have news")
                let aNews:NewsFeed = searchFeedModel.itemForRow(at: IndexPath(row:0,section:0)) as! NewsFeed
                XCTAssertTrue(aNews.id == "5920e49b95d0e024b5871fe3" ,"same ID")
            })
        }
        
    }
    
    
    func testServerNoResponseKeyDataResponseValid(){
        class NetworkEngineMock: NetworkEngine {
            typealias Handler = NetworkEngine.Handler
            
            var requestedURL: URL?
            
            func performRequest(for url: URL, completionHandler: @escaping Handler) {
                requestedURL = url
                var dictionary:[String:AnyObject] = [String:AnyObject]()
                
                var dictItem:[String:AnyObject]  = ["web_url":"https://www.nytimes.com/reuters/2017/05/20/world/americas/20reuters-mexico-violence-russian.html" as AnyObject,"snippet":"A mob of angry Mexicans attacked a Russian man in the Caribbean resort of Cancun with sticks and rocks over his repeated insults against locals, and the 42-year-old man was accused of fatally stabbing a youth in the melee, authorities said on Satu..." as AnyObject,"multimedia":"" as AnyObject,"pub_date":"2017-05-21T00:51:34+0000" as AnyObject,"_id":"5920e49b95d0e024b5871fe3" as AnyObject]
                let dictionaryHeadline = ["main":"Mexican Mob Attacks Russian Man in Cancun Over Insults"]
                dictItem["headline"] = dictionaryHeadline as AnyObject
                var arrayMultimedia:[[String:AnyObject]] = [[String:AnyObject]] ()
                let multimediaSample1:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-thumbStandard.jpg" as AnyObject]
                let multimediaSample2:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-articleLarge.jpg" as AnyObject]
                
                
                let multimediaSample3:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-thumbWide.jpg" as AnyObject]
                arrayMultimedia.append(multimediaSample1)
                arrayMultimedia.append(multimediaSample2)
                arrayMultimedia.append(multimediaSample3)
                dictItem["multimedia"] = arrayMultimedia as AnyObject
                var arrayDocs:[[String:AnyObject]] = [[String:AnyObject]]()
                
                
                arrayDocs.append(dictItem)
                
                
                var dictionaryResponse = [String:AnyObject]()
                dictionaryResponse["docs"] = arrayDocs as AnyObject
                dictionaryResponse["copyright"] = "Copyright (c) 2013 The New York Times Company. All Rights Reserved." as AnyObject
                dictionary["simple"] = dictionaryResponse as AnyObject
                let data = (try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted))
                
                let Urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: nil)
                completionHandler(data,Urlresponse,nil)
            }
        }
        
        let engine = NetworkEngineMock()
        let fetching =  Fetching(engine:engine)
        let searchFeedModel =  SearchNewsFeedModel.init(fetching: fetching)
        
        searchFeedModel.letSearch(keyword: "Singap") { (search) in
            searchFeedModel.checkServer(page: 0, search: search, beginUpdateView: {
                
            }, failed: {
                XCTAssertTrue(searchFeedModel.list().count == 0 ,"no have news")
                
            }, completion: { (page) in
                XCTAssertTrue(searchFeedModel.list().count > 0 ,"have news")
                let aNews:NewsFeed = searchFeedModel.itemForRow(at: IndexPath(row:0,section:0)) as! NewsFeed
                XCTAssertTrue(aNews.id == "5920e49b95d0e024b5871fe3" ,"same ID")
            })
        }

        
    }
    func testServerNoDocsKeyDataResponseValid(){
        class NetworkEngineMock: NetworkEngine {
            typealias Handler = NetworkEngine.Handler
            
            var requestedURL: URL?
            
            func performRequest(for url: URL, completionHandler: @escaping Handler) {
                requestedURL = url
                var dictionary:[String:AnyObject] = [String:AnyObject]()
                
                var dictItem:[String:AnyObject]  = ["web_url":"https://www.nytimes.com/reuters/2017/05/20/world/americas/20reuters-mexico-violence-russian.html" as AnyObject,"snippet":"A mob of angry Mexicans attacked a Russian man in the Caribbean resort of Cancun with sticks and rocks over his repeated insults against locals, and the 42-year-old man was accused of fatally stabbing a youth in the melee, authorities said on Satu..." as AnyObject,"multimedia":"" as AnyObject,"pub_date":"2017-05-21T00:51:34+0000" as AnyObject,"_id":"5920e49b95d0e024b5871fe3" as AnyObject]
                let dictionaryHeadline = ["main":"Mexican Mob Attacks Russian Man in Cancun Over Insults"]
                dictItem["headline"] = dictionaryHeadline as AnyObject
                var arrayMultimedia:[[String:AnyObject]] = [[String:AnyObject]] ()
                let multimediaSample1:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-thumbStandard.jpg" as AnyObject]
                let multimediaSample2:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-articleLarge.jpg" as AnyObject]
                
                
                let multimediaSample3:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-thumbWide.jpg" as AnyObject]
                arrayMultimedia.append(multimediaSample1)
                arrayMultimedia.append(multimediaSample2)
                arrayMultimedia.append(multimediaSample3)
                dictItem["multimedia"] = arrayMultimedia as AnyObject
                var arrayDocs:[[String:AnyObject]] = [[String:AnyObject]]()
                
                
                arrayDocs.append(dictItem)
                
                
                var dictionaryResponse = [String:AnyObject]()
                dictionaryResponse["docsx"] = arrayDocs as AnyObject
                dictionaryResponse["copyright"] = "Copyright (c) 2013 The New York Times Company. All Rights Reserved." as AnyObject
                dictionary["response"] = dictionaryResponse as AnyObject
                let data = (try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted))
                
                let Urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: nil)
                completionHandler(data,Urlresponse,nil)
            }
        }
        
        let engine = NetworkEngineMock()
        let fetching =  Fetching(engine:engine)
        let searchFeedModel =  SearchNewsFeedModel.init(fetching: fetching)
        
        searchFeedModel.letSearch(keyword: "What") { (search) in
            searchFeedModel.checkServer(page: 0, search: search, beginUpdateView: {
                
            }, failed: {
                XCTAssertTrue(searchFeedModel.list().count == 0 ,"no have news")
                
            }, completion: { (page) in
                XCTAssertTrue(searchFeedModel.list().count > 0 ,"have news")
                let aNews:NewsFeed = searchFeedModel.itemForRow(at: IndexPath(row:0,section:0)) as! NewsFeed
                XCTAssertTrue(aNews.id == "5920e49b95d0e024b5871fe3" ,"same ID")
            })
        }

        
    }
    
    func testServerNoWrongDataResponseValidDouble(){
        class NetworkEngineMockBefore: NetworkEngine {
            typealias Handler = NetworkEngine.Handler
            
            var requestedURL: URL?
            
            func performRequest(for url: URL, completionHandler: @escaping Handler) {
                requestedURL = url
                var dictionary:[String:AnyObject] = [String:AnyObject]()
                
                var dictItem:[String:AnyObject]  = ["web_url":"https://www.nytimes.com/reuters/2017/05/20/world/americas/20reuters-mexico-violence-russian.html" as AnyObject,"snippet":"A mob of angry Mexicans attacked a Russian man in the Caribbean resort of Cancun with sticks and rocks over his repeated insults against locals, and the 42-year-old man was accused of fatally stabbing a youth in the melee, authorities said on Satu..." as AnyObject,"multimedia":"" as AnyObject,"pub_date":"2017-05-21T00:51:34+0000" as AnyObject,"_id":"5920e49b95d0e024b5871fe0" as AnyObject]
                let dictionaryHeadline = ["main":"Mexican Mob Attacks Russian Man in Cancun Over Insults"]
                dictItem["headline"] = dictionaryHeadline as AnyObject
                var arrayMultimedia:[[String:AnyObject]] = [[String:AnyObject]] ()
                let multimediaSample1:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-thumbStandard.jpg" as AnyObject]
                let multimediaSample2:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-articleLarge.jpg" as AnyObject]
                
                
                let multimediaSample3:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-thumbWide.jpg" as AnyObject]
                arrayMultimedia.append(multimediaSample1)
                arrayMultimedia.append(multimediaSample2)
                arrayMultimedia.append(multimediaSample3)
                dictItem["multimedia"] = arrayMultimedia as AnyObject
                var arrayDocs:[[String:AnyObject]] = [[String:AnyObject]]()
                
                
                arrayDocs.append(dictItem)
                
                
                var dictionaryResponse = [String:AnyObject]()
                dictionaryResponse["docs"] = arrayDocs as AnyObject
                dictionaryResponse["copyright"] = "Copyright (c) 2013 The New York Times Company. All Rights Reserved." as AnyObject
                dictionary["response"] = dictionaryResponse as AnyObject
                let data = (try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted))
                let Urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: nil)
                completionHandler(data,Urlresponse,nil)
            }
        }
        
        class NetworkEngineMockAfter: NetworkEngine {
            typealias Handler = NetworkEngine.Handler
            
            var requestedURL: URL?
            
            func performRequest(for url: URL, completionHandler: @escaping Handler) {
                requestedURL = url
                var dictionary:[String:AnyObject] = [String:AnyObject]()
                
                var dictItem:[String:AnyObject]  = ["web_url":"https://www.nytimes.com/reuters/2017/05/20/world/americas/20reuters-mexico-violence-russian.html" as AnyObject,"snippet":"A mob of angry Mexicans attacked a Russian man in the Caribbean resort of Cancun with sticks and rocks over his repeated insults against locals, and the 42-year-old man was accused of fatally stabbing a youth in the melee, authorities said on Satu..." as AnyObject,"multimedia":"" as AnyObject,"pub_date":"2017-05-21T00:51:34+0000" as AnyObject,"_id":"5920e49b95d0e024b5871f9" as AnyObject]
                let dictionaryHeadline = ["main":"Mexican Mob Attacks Russian Man in Cancun Over Insults"]
                dictItem["headline"] = dictionaryHeadline as AnyObject
                var arrayMultimedia:[[String:AnyObject]] = [[String:AnyObject]] ()
                let multimediaSample1:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-thumbStandard.jpg" as AnyObject]
                let multimediaSample2:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-articleLarge.jpg" as AnyObject]
                
                
                let multimediaSample3:[String:AnyObject] = ["url":"images/2017/05/19/world/00sansimon1/00sansimon1-thumbWide.jpg" as AnyObject]
                arrayMultimedia.append(multimediaSample1)
                arrayMultimedia.append(multimediaSample2)
                arrayMultimedia.append(multimediaSample3)
                dictItem["multimedia"] = arrayMultimedia as AnyObject
                
                
                var arrayDocs:[[String:AnyObject]] = [[String:AnyObject]]()
                 let dictItem2:[String:AnyObject]  = ["web_url":"https://www.nytimes.com/reuters/2017/05/20/world/americas/20reuters-mexico-violence-russian.html" as AnyObject,"snippet":"A mob of angry Mexicans attacked a Russian man in the Caribbean resort of Cancun with sticks and rocks over his repeated insults against locals, and the 42-year-old man was accused of fatally stabbing a youth in the melee, authorities said on Satu..." as AnyObject,"multimedia":"" as AnyObject,"pub_date":"2017-05-21T00:51:34+0000" as AnyObject,"_id":"5920e49b95d0e024b5871f9" as AnyObject]
                
                arrayDocs.append(dictItem)
                arrayDocs.append(dictItem2)
                
                
                var dictionaryResponse = [String:AnyObject]()
                dictionaryResponse["docs"] = arrayDocs as AnyObject
                dictionaryResponse["copyright"] = "Copyright (c) 2013 The New York Times Company. All Rights Reserved." as AnyObject
                dictionary["response"] = dictionaryResponse as AnyObject
                let data = (try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted))
                let Urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: nil)
                completionHandler(data,Urlresponse,nil)
            }
        }
        
        let engine = NetworkEngineMockBefore()
        let fetching =  Fetching(engine:engine)
        let searchFeedModel =  SearchNewsFeedModel.init(fetching: fetching)
        
        searchFeedModel.letSearch(keyword: "What is") { (search) in
            searchFeedModel.checkServer(page: 0, search: search, beginUpdateView: {
                
            }, failed: {
                
            }, completion: { (page) in
                
                XCTAssertTrue(searchFeedModel.list().count > 0 ,"have news")
                let aNews:NewsFeed = searchFeedModel.itemForRow(at: IndexPath(row:0,section:0)) as! NewsFeed
                XCTAssertTrue(aNews.id == "5920e49b95d0e024b5871fe0" ,"same ID")
                let engine = NetworkEngineMockAfter()
                let fetching =  Fetching(engine:engine)
                let searchFeedModel =  SearchNewsFeedModel.init(fetching: fetching)
                searchFeedModel.letSearch(keyword: "What is") { (search) in
                    searchFeedModel.checkServer(page: 0, search: search, beginUpdateView: {
                        
                    }, failed: {
                        
                    }, completion: { (page) in
                        
                        XCTAssertTrue(searchFeedModel.list().count > 0 ,"have news")
                        let aNews:NewsFeed = searchFeedModel.itemForRow(at: IndexPath(row:0,section:0)) as! NewsFeed
                        XCTAssertTrue(aNews.id == "5920e49b95d0e024b5871f9" ,"same ID")
                        searchFeedModel.checkServer(page: 0, search: search, beginUpdateView: {
                            
                        }, failed: {
                            
                        }, completion: { (page) in
                        })
                        searchFeedModel.checkServer(page: 1, search: search, beginUpdateView: {
                            
                        }, failed: {
                            
                        }, completion: { (page) in
                            XCTAssertTrue(searchFeedModel.list().count > 0 ,"have news")
                            let aNews:NewsFeed = searchFeedModel.itemForRow(at: IndexPath(row:0,section:0)) as! NewsFeed
                            XCTAssertTrue(aNews.id == "5920e49b95d0e024b5871f9" ,"same ID")
                        })

                    })
                }

            })
        }

        
        
    }
    
}
