//
//  MockingTestNetwork.swift
//  NYNews
//
//  Created by David Trivian S on 5/20/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import XCTest
import CoreData
@testable import NYNews

class MockingTestNetwork: XCTestCase {
    
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
        let aNewsFeedModel =  NewsFeedModel.init(fetcher: fetching)
        aNewsFeedModel.cancelOperation()
        aNewsFeedModel.checkServer(page: 0, beginUpdateView: {
            
        }, failed: {
            
        }) { (page) in
            
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
        let aNewsFeedModel =  NewsFeedModel.init(fetcher: fetching)
        aNewsFeedModel.checkServer(page: 0, beginUpdateView: {
            
        }, failed: {
            
        }) { (page) in
            
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
        let aNewsFeedModel =  NewsFeedModel.init(fetcher: fetching)
        
        aNewsFeedModel.checkServer(page: 0, beginUpdateView: {
            
        }, failed: {
            
        }) { (page) in
            
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
        let aNewsFeedModel =  NewsFeedModel.init(fetcher: fetching)
        
        aNewsFeedModel.checkServer(page: 0, beginUpdateView: {
            
        }, failed: {
            
        }) { (page) in
            
        }
        
    }
     
    func testServerInvalidDataResponseValid(){
        class NetworkEngineMock: NetworkEngine {
            typealias Handler = NetworkEngine.Handler
            
            var requestedURL: URL?
            
            func performRequest(for url: URL, completionHandler: @escaping Handler) {
                requestedURL = url
                var dictionary:[String:AnyObject] = [String:AnyObject]()
                
                var dictItem:[String:AnyObject]  = ["web_url":"https://www.nytimes.com/reuters/2017/05/20/world/americas/20reuters-mexico-violence-russian.html" as AnyObject,"snippet":"A mob of angry Mexicans attacked a Russian man in the Caribbean resort of Cancun with sticks and rocks over his repeated insults against locals, and the 42-year-old man was accused of fatally stabbing a youth in the melee, authorities said on Satu..." as AnyObject,"multimedia":"" as AnyObject,"pub_date":"2017-05-21T00:51:34+0000" as AnyObject,"_id":"5920e49b95d0e024b5871fe3" as AnyObject,"sample": NSNull() as AnyObject]
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
        let aNewsFeedModel =  NewsFeedModel.init(fetcher: fetching)
        aNewsFeedModel.checkServer(page: 0, beginUpdateView: {
            
        }, failed: {
            
        }) { (page) in
            
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
        let aNewsFeedModel =  NewsFeedModel.init(fetcher: fetching)
        aNewsFeedModel.checkServer(page: 0, beginUpdateView: {
            
        }, failed: {
            debugPrint("Np parsing")
            
        }) { (page) in
            XCTAssertTrue(page == 0 , "must true")
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
        let aNewsFeedModel =  NewsFeedModel.init(fetcher: fetching)
        aNewsFeedModel.checkServer(page: 0, beginUpdateView: {
            
        }, failed: {
            debugPrint("Np parsing")
            
        }) { (page) in
            XCTAssertTrue(page == 0 , "must true")
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
        
        let engine = NetworkEngineMockBefore()
        let fetching =  Fetching(engine:engine)
        let aNewsFeedModel =  NewsFeedModel.init(fetcher: fetching)
        
        aNewsFeedModel.checkServer(page: 0, beginUpdateView: {
            
        }, failed: {
            
        }) { (page) in
            let engine = NetworkEngineMockAfter()
            let fetching =  Fetching(engine:engine)
            let aNewsFeedModel =  NewsFeedModel.init(fetcher: fetching)
            
            aNewsFeedModel.checkServer(page: 0, beginUpdateView: {
                
            }, failed: {
                
            }) { (page) in
                aNewsFeedModel.checkServer(page: 0, beginUpdateView: {
                    
                }, failed: {
                    
                }) { (page) in
                    
                } 
            }
        }
        
    }
    
    
}



/* var dictionary:[String:AnyObject] = [String:AnyObject]()
 
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
 let data: Data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
 let data = (try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted))
 let Urlresponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion:nil , headerFields: nil)*/
