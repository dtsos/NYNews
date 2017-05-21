//
//  NewsFeedModel.swift
//  NewsFeed
//
//  Created by David Trivian S on 5/3/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import Foundation
import CoreData
import UIKit
class NewsModel {
    private let fetcher: Fetching
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    init(fetcher: Fetching, dictionary: [String: AnyObject],search:Search) {
        self.fetcher = fetcher
        
        
        
        self.news =  NewsFeed(context:self.context!)
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
    
    init(fetcher: Fetching, dictionary: [String: AnyObject]) {
        self.fetcher = fetcher
        
        
        self.news =  NewsFeed(context:self.context!)
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
    
    var news:NewsFeed?
    var context:NSManagedObjectContext? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
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
    
    
    // create News Feed
    func createNewsFeed(){
        
        news?.id =  self.id ?? ""
        news?.title = self.title ?? ""
        news?.url = self.url ?? ""
        news?.imageUrl = self.imageUrl ?? ""
        news?.date = self.date ?? ""
        news?.snippet =  self.snippet ?? ""
        datePostDate()
    }
    //    convert string to date
    func datePostDate(){
        if self.date == nil {
            return
        }
        let stringDate = self.date
        let format="yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = format
        let newreadableDate = dateFmt.date(from: stringDate!)
        if newreadableDate != nil{
            self.news?.pubDate = newreadableDate! as NSDate
        }
    }
    func saveCoreData(){
        self.news?.dateModified = NSDate()
        
        (try! context?.save())
        
        
    }
    
    //save and create news feed to coredata
    func save(){
        createNewsFeed()
        saveCoreData()
    }
}
protocol NewsFeedDelegate {
    func updateListNewsView()
    
}
class NewsFeedModel : NSObject {
    var delegate:NewsFeedDelegate?
    var page:Int16
    var stillDownload:Bool = false
    
    fileprivate var items : [NewsFeed] = [NewsFeed]()
    var context:NSManagedObjectContext? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    private let fetcher: Fetching
    
    
    init(fetcher: Fetching){
        self.fetcher = fetcher
        
        
        
        self.page = 0
        
    }
    
    //    private get array
    @objc private func getArray(){
        
        self.items = listNews(page: self.page)!
    }
    func listNews(page:Int16) -> [NewsFeed]?{
        
        let fetchRequest : NSFetchRequest<NewsFeed> = NewsFeed.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateModified", ascending: false)
        
        fetchRequest.predicate = NSPredicate(format: "page = \(page) AND isHeadline = true")
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var result :[NewsFeed]?
        
        result = (try! self.context?.fetch(fetchRequest))
        
        
        return result!
    }
    
    // inital array list items
    func readyVC() {
        getArray()
    }
    
    // needUpdate compare array from coredata and from server if first NewsFeed on this page it will delete and insert list news for this page
    func isNeedUpdateServer(dictionary:[String:AnyObject]?,page:Int16 ) -> (update: Bool, items: [NewsFeed]?) {
        var tempitems:[NewsFeed]? = [NewsFeed]()
        if dictionary == nil {
            tempitems = listNews(page: page)!
            return (false, tempitems)
        }
        
//        if self.page != page {
            tempitems = listNews(page: page)!
            
            
//        }else{
//            
//        }
        
        
        if tempitems?.count == 0 {
            return (true, tempitems)
        }else{
            //            let index = Int(10 * page)
            //            if index >= (tempitems?.count)!{
            //                return (true, tempitems)
            //            }
            
            
            
            let firstNews:NewsFeed = (tempitems?.first)!
            guard let id:String = dictionary!["_id"] as? String else{
                return (false, tempitems)
            }
            if  firstNews.id != id{
                return (true,tempitems)
            }
            
        }
        return (false, tempitems)
        
        
    }
    
    //last fetch server string url
    var lastStringQuery:String?
    
    //cancel operation
    func cancelOperation()
    {
        URLSession.shared.cancelOperation(stringUrl: lastStringQuery)
    }
    
    
    //check server if have different list news or is empty will insert new data
    func checkServer(page:Int16,beginUpdateView:  @escaping () -> Void,failed:  @escaping () -> Void,completion: @escaping (_ page:Int16) -> Void){
        if stillDownload == true  {
            
            return
        }
        stillDownload = true
        
        
        lastStringQuery =  "\(Constant.URLArticleSearch)\(Constant.paramAPIKeyValue)&page=\(page)&sort=newest"
        
       
        
        fetcher.fetch(withQueryString: lastStringQuery!, failure: { (error) in
            
            self.stillDownload =  false
            failed()
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
            
            
            let checkUpdate =  self.isNeedUpdateServer(dictionary: itemDictionaries.first, page: page)
            
            if checkUpdate.update == true{
                beginUpdateView()
                let items = checkUpdate.items
                let indexStart = 0
                debugPrint(items!)
                if items != nil {
                    if  (indexStart < (items?.count)!) {
                        self.context?.performAndWait {
                            
                            
                            for i in indexStart..<(items?.count)!{
                                let aNewsFeed:NewsFeed? = items?[i]
                                if aNewsFeed != nil {
                                    
                                    self.context?.delete(aNewsFeed!)
                                    
                                    
                                    //                                        self.context?.refreshAllObjects()
                                    (try! self.context?.save())
                                    
                                }
                            }
                        }
                    }
                }
                if page == 0{
                    
                    self.items.removeAll()
                    
                }
                self.context?.performAndWait {
                    for aData in itemDictionaries {
                        
                        let newsModel =  NewsModel.init(fetcher: self.fetcher,  dictionary: aData)
                        
                        newsModel.news?.isHeadline = true
                        newsModel.news?.page = page
                        newsModel.news?.dateModified = NSDate()
                        newsModel.save()
                        debugPrint(newsModel.news!)
                        let news = newsModel.news!
                        self.items.append(news)
                        
                        
                        
                    }
                    
                }
            }else{
                let arrayNews:[NewsFeed] =  checkUpdate.items!
                self.items.append(contentsOf: arrayNews)
            }
            
            self.page = page
            self.delegate?.updateListNewsView()
            self.stillDownload = false
            completion(page)
            
        }
        
    }
    func numberOfSections() -> Int {
        
        return 1
        
        
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        return self.items.count
    }
    
    
    func itemForRow(at indexPath: IndexPath) -> NewsFeed {
        
        
        return self.items[indexPath.row]
        
    }
    func list()->[NewsFeed]{
        return self.items
    }
    
}
