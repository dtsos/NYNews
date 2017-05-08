//
//  NewsFeedModel.swift
//  NewsFeed
//
//  Created by David Trivian S on 5/3/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import Foundation
import CoreData
class NewsModel {
    private let fetcher: Fetching
    
    
    init(fetcher: Fetching, dictionary: [String: AnyObject],search:Search,context:NSManagedObjectContext) {
        self.fetcher = fetcher
        
        self.context =  context
        
        self.news =  NewsFeed(context:context)
        self.id =  dictionary["_id"] as? String ?? ""
        if let headline = dictionary["headline"]{
            self.title = headline["main"] as? String ?? ""
        }
        
        if let multimedia:[[String:AnyObject]] =  dictionary["multimedia"] as? [[String : AnyObject]] {
            if multimedia.count > 0 {
                
                self.imageUrl = multimedia[multimedia.count > 1 ? multimedia.count  - 2:0]["url"] as? String ?? ""
                
            }else{
                self.imageUrl = ""
            }
            
            
            
        }else{
            self.imageUrl = ""
        }
        
        self.url = dictionary["web_url"] as? String ?? ""
        self.date = dictionary["pub_date"] as? String ?? ""
        self.snippet = dictionary["snippet"] as? String ?? ""
        datePostDate()
        
        self.news?.whichSearch =  search
        
        
        
        
        
    }
    
    init(fetcher: Fetching, dictionary: [String: AnyObject],context:NSManagedObjectContext) {
        self.fetcher = fetcher
        
        self.context =  context
        self.news =  NewsFeed(context:context)
        self.id =  dictionary["_id"] as? String ?? ""
        if let headline = dictionary["headline"]{
            self.title = headline["main"] as? String ?? ""
        }
        if let multimedia:[[String:AnyObject]] =  dictionary["multimedia"] as? [[String : AnyObject]] {
            if multimedia.count > 0 {
                
                self.imageUrl = multimedia[multimedia.count > 1 ? multimedia.count  - 2:0]["url"] as? String ?? ""
                
            }else{
                self.imageUrl = ""
            }
            
            
            
        }else{
            self.imageUrl = ""
        }
        
        self.url = dictionary["web_url"] as? String ?? ""
        self.date = dictionary["pub_date"] as? String ?? ""
        self.snippet = dictionary["snippet"] as? String ?? ""
        
        datePostDate()
        
        
        
        
        
        
        
        
    }
    var id:String? {
        willSet {
            self.news?.id = newValue
        }
    }
    var imageDataNews:Data? =  nil
    var imagePlaceholder:Data? =  nil
    var imageDataProfile:Data? = nil
    
    var news:NewsFeed?
    var context:NSManagedObjectContext?
    
    var title:String?{
        willSet {
            self.news?.title =  newValue ?? ""
        }
    }
    var date:String?{
        willSet {
            self.news?.date =  newValue ?? ""
        }
    }
    
    init(_ newsFeed:NewsFeed, context:NSManagedObjectContext,fetcher:Fetching) {
        self.news = newsFeed
        
        self.title =  self.news?.title
        self.url =  self.news?.url
        self.date =  self.news?.date
        self.imageUrl = self.news?.imageUrl
        self.snippet  = self.news?.snippet
        
        self.context = context
        self.fetcher = fetcher
    }
    
    
    
    var imageUrl: String?{
        willSet{
            self.news?.imageUrl =  newValue ?? ""
        }
    }
    
    var snippet: String?{
        willSet {
            self.news?.snippet = newValue ?? ""
        }
    }
    
    var url: String?{
        willSet {
            self.news?.url = newValue ?? ""
        }
    }
    
    
    
    func createNewsFeed(){
        if news == nil {
            news = NewsFeed(context:self.context!)
        }
        news?.title = self.title ?? ""
        news?.url = self.url ?? ""
        news?.imageUrl = self.imageUrl ?? ""
        news?.date = self.date ?? ""
        news?.snippet =  self.snippet ?? ""
        datePostDate()
    }
    func datePostDate(){
        if self.date == nil {
            return
        }
        let noaaDate = self.date
        let format="yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = format
        let newreadableDate = dateFmt.date(from: noaaDate!)
        self.news?.pubDate = newreadableDate! as NSDate
        
    }
    func saveCoreData(){
        self.news?.dateModified = NSDate()
        do {
            try context?.save()
        } catch   {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
    }
    func save(){
        createNewsFeed()
        saveCoreData()
    }
}
protocol NewsFeedProtocol {
    func numberOfRows(inSection section: Int) -> Int
    func checkServer(page:Int16,beginUpdateView: @escaping () -> Void,failed: @escaping () -> Void,completion: @escaping (_ page:Int16) -> Void)
}
class NewsFeedModel : NewsFeedProtocol {
    func getNewsModel(index: Int) -> NewsModel? {
        if  index > items.count - 1  {
            return nil
        }
        return items[index]
    }
    
    private var items : [NewsModel] = [NewsModel]()
    var context:NSManagedObjectContext?
    var fetchNewsController:NSFetchedResultsController<NewsFeed>?
    //    var fetchSearchController:NSFetchedResultsController<Search>?
    private let fetcher: Fetching
    init(fetcher: Fetching,fetchNewsController:NSFetchedResultsController<NewsFeed>){
        self.fetcher = fetcher
        self.fetchNewsController =  fetchNewsController
        self.context = fetchNewsController.managedObjectContext
        for aNewsFeed in (self.fetchNewsController?.fetchedObjects)! {
            let newsModel:NewsModel = NewsModel.init(aNewsFeed, context:self.context!,fetcher:fetcher)
            
            self.items.append(newsModel)
        }
        self.page = -1
        
    }
    func numberOfRows(inSection section: Int) -> Int {
        return self.items.count
    }
    func checkArrayHaveUrl(_ url:String) -> (isFound :Bool,newsModel:NewsModel?){
        guard  url.characters.count >= 0 else{
            return (false,nil)
        }
        
        if let i = self.items.index(where: { $0.url == url }) {
            
            return (true,self.items[i])
        }        else {
            //  not
            
            return (false,nil)
        }
    }
    
    //    var searchFeed:Search?
    //    func findKeyword(_ keyword:String) -> (succes:Bool, search:Search?){
    //        if self.searchFeed == nil {
    //            return(false, nil)
    //        }
    //
    //        self.fetchSearchController?.fetchRequest.predicate = NSPredicate(format: "keyword == %@", keyword)
    //
    //        do {
    //            try self.fetchSearchController?.performFetch()
    //        } catch{
    //            return (false,nil)
    //        }
    //        guard (self.fetchSearchController?.fetchedObjects?.count)! > 0 else {
    //            return (false,nil)
    //        }
    //        self.searchFeed = self.fetchSearchController?.fetchedObjects!.first
    //        return(true , self.searchFeed)
    //
    //
    //    }
    var page:Int16
    var stillDownload:Bool = false
    
    func isNeedUpdateServer(dictionary:[String:AnyObject]?,page:Int16 ) -> Bool {
        
        
        //        if self.fe {
        //            <#code#>
        //        }
        if self.page != page {
            
            
            self.fetchNewsController?.fetchRequest.predicate = NSPredicate(format: "page <= \(page) AND isHeadline = true")
            
            
            do {
                NSFetchedResultsController<NewsFeed>.deleteCache(withName:nil)
                try self.fetchNewsController?.performFetch()
            } catch {
                print(error)
                //                return true
            }
        }
        
        let tempitems:[NewsFeed] = (self.fetchNewsController?.fetchedObjects)!
        if tempitems.count == 0 {
            return true
        }else{
            let index = Int(10 * page)
            if index >= tempitems.count{
                return true
            }
            if  dictionary != nil {
                
                
                let firstNews:NewsFeed = tempitems[index]
                let id:String = dictionary!["_id"] as! String
                if  firstNews.id != id{
                    return true
                }
            }
        }
        return false
        
        
    }
    func checkServer(page:Int16,beginUpdateView: @escaping () -> Void,failed: @escaping () -> Void,completion: @escaping (_ page:Int16) -> Void){
        if stillDownload == true  {
            
            return
        }
        stillDownload = true
        let  stringQuery =  "\(Constant.URLArticleSearch)\(Constant.paramAPIKeyValue)&page=\(page)&sort=newest"
        fetcher.fetch(withQueryString: stringQuery, failure: { (error) in
            self.stillDownload =  false
        }) { (dictionary) in
            guard let response: [String:AnyObject] =  dictionary["response"] as? [String:AnyObject] else{
                failed()
                self.stillDownload = false
                return
            }
            guard let data: [[String:AnyObject]] = response["docs"] as? [[String : AnyObject]]  else {
                self.stillDownload = false
                failed()
                return
            }
            
            let itemDictionaries: [[String:AnyObject]] = data
            if (itemDictionaries.count <= 0){
                completion(page > 1 ? page - 1 :0)
                return
            }
            if self.isNeedUpdateServer(dictionary: itemDictionaries.first!, page: page){
                beginUpdateView()
                let items = self.fetchNewsController?.fetchedObjects
                let indexStart = Int(page*10)
                if indexStart < (items?.count)! {
                    
                    for i in indexStart..<(items?.count)!{
                        
                        if let aNewsFeed:NewsFeed? = items?[i] {
                            self.context?.delete(aNewsFeed!)
                            
                            do {
                                try self.context?.save()
                            }catch{
                                print(error)
                            }
                        }
                    }
                }
                if page == 0{
                    self.items.removeAll()
                }
                for aData in itemDictionaries {
                    
                    let newsModel =  NewsModel.init(fetcher: self.fetcher,  dictionary: aData, context: self.context!)
                    
                    newsModel.news?.isHeadline = true
                    newsModel.news?.page = page
                    newsModel.save()
                    self.items.append(newsModel)
                    
                    
                    
                }
            }
            self.page = page
            completion(page)
            self.stillDownload = false
        }
        
    }
    
}
