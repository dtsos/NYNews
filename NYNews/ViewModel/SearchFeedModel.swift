
//
//  SearchFeed.swift
//  NYNews
//
//  Created by David Trivian S on 5/5/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import Foundation
import UIKit
import CoreData
@objc protocol SearchFeedModelDelegate {
    func updateView()
    @objc optional func updateSection(section:IndexSet,type: NSFetchedResultsChangeType)
    @objc optional func updateRow(oldIndexPath:IndexPath?,newIndexPath:IndexPath?,type: NSFetchedResultsChangeType)
}
class SearchModel{
    var context:NSManagedObjectContext? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    init() {
        
        let fetchRequest : NSFetchRequest<Search> = Search.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var result :[Search]?
        
        result = (try! self.context?.fetch(fetchRequest))
        
        
        self.listSearch = result
        
    }
    var listSearch:[Search]?
    
    
}
class SearchNewsFeedModel:NSObject {
    var delegate:SearchFeedModelDelegate?
    var itemsNewsFeed:[NewsFeed] = [NewsFeed]()
    var itemsSearch:[Search] = [Search]()
    var search:Search?
    var fetcher:Fetching
    var context:NSManagedObjectContext? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    
    init(fetching:Fetching) {
        
        
        self.fetcher =  fetching
        let aSearchModel =  SearchModel.init()
        self.itemsSearch = aSearchModel.listSearch!
        
        
        
    }
    var isNews:Bool = false
    var page:Int16 = 0
    var stillDownload:Bool = false
    
    //func needUpdate News
    func isNeedUpdateServer(dictionary:[String:AnyObject]?,page:Int16 ) -> Bool {
        guard dictionary != nil else {
            return false
        }
        
        guard (search?.listNews?.allObjects.count)! > 0 else {
            return true
        }
        
        
        var tempitems:[NewsFeed] = search?.listNews?.allObjects as! [NewsFeed]
        tempitems = tempitems.filter{ ($0 as NewsFeed).page == page }
        if tempitems.count == 0 {
            return true
        }else{
            let index = 0
            
            
            
            
            let firstNews:NewsFeed = tempitems[index]
            guard let id:String = dictionary!["_id"] as? String else{
                return false
            }
           
            if  firstNews.id != id{
                return true
                
            }
        }
        return false
        
        
    }
    func createListNews(){
        self.itemsNewsFeed.removeAll()
        let arrayAllNews: [NewsFeed] = self.search!.listNews?.allObjects as! [NewsFeed]
        let arrayNews = arrayAllNews.filter{ ($0 as NewsFeed).page == 0 }
        self.itemsNewsFeed.append(contentsOf: arrayNews )
    }
    // check server if item diffrent update
    func checkServer(page:Int16,search:Search,beginUpdateView: @escaping () -> Void,failed: @escaping () -> Void,completion: @escaping (_ page:Int16) -> Void){
        //        if page == 0 {
        //            self.cancelOperation()
        //        }
        weak var weakSelf =  self
        if stillDownload == true  && page > 0 {
            
            return
        }
        stillDownload = true
        self.isNews = true
        lastStringQuery =  "\(Constant.URLArticleSearch)\(Constant.paramAPIKeyValue)&page=\(page)&q=\(search.keyword!)&sort=newest"
        fetcher.fetch(withQueryString: lastStringQuery!, failure: { (error) in
            weakSelf?.stillDownload =  false
           
            failed()
            
        }) { (dictionary) in
            
            
            guard let response: [String:AnyObject] =  dictionary["response"] as? [String:AnyObject] else{
                weakSelf?.stillDownload = false
                failed()
                
                return
            }
            guard let data: [[String:AnyObject]] = response["docs"] as? [[String : AnyObject]]  else {
                weakSelf?.stillDownload = false
                failed()
                return
            }
            
            
            let itemDictionaries: [[String:AnyObject]] = data
            
            let dictListnews:[String:AnyObject]? =  (itemDictionaries.count >= 1 ?  itemDictionaries.first : nil )
            
            if (weakSelf?.isNeedUpdateServer(dictionary:dictListnews, page: page))! || itemDictionaries.count == 0{
                beginUpdateView()
                if let listNews = search.listNews  {
                    var items:[NewsFeed] = listNews.allObjects as! [NewsFeed]
                    items = items.sorted(by: {$0.dateModified?.compare(($1.dateModified as Date?)!) == ComparisonResult.orderedDescending})
                    items = items.filter({$0.page == page})
                    let indexStart = 0
                    
                    if indexStart < (items.count) {
                        weakSelf?.context?.performAndWait {
                            for i in indexStart..<items.count{
                                //                for aNewsFeed in items! {
                                
                                let aNewsFeed:NewsFeed = items[i]
                                weakSelf?.context?.delete(aNewsFeed)
                                
                                
                                (try! weakSelf?.context?.save())
                                
                            }
                        }
                    }
                    if page == 0{
                        weakSelf?.itemsNewsFeed.removeAll()
                    }
                    weakSelf?.context?.performAndWait {
                        for aData in itemDictionaries {
                            
                            let newsModel =  NewsModel.init(fetcher: (weakSelf?.fetcher)!,  dictionary: aData,search:search)
                            
                            newsModel.news?.isHeadline = false
                            newsModel.news?.page = page
                            newsModel.news?.whichSearch = search
                            newsModel.news?.dateModified = NSDate() as Date
                            //                    search.add(newsModel)
                            
                            newsModel.save()
                            
                            weakSelf?.itemsNewsFeed.append(newsModel.news!)
                            
                            
                        }
                    }
                }
            }else{
                let arrayAllNews: [NewsFeed] = search.listNews?.allObjects as! [NewsFeed]
                let arrayNews = arrayAllNews.filter{ ($0 as NewsFeed).page == page }
                weakSelf?.itemsNewsFeed.append(contentsOf: arrayNews )
                
            }
            weakSelf?.page = page
            weakSelf?.delegate?.updateView()
            weakSelf?.stillDownload = false
            completion(page)
            
        }
        
    }
    
    //string url last fetch server
    var lastStringQuery:String?
    
    //cancel connection
    func cancelOperation()
    {
        URLSession.shared.cancelOperation(stringUrl: lastStringQuery)
    }
    
    //create new search
    func createNewSearch(keyword:String) -> Search?{
        let search:Search = Search(context:self.context!)
        search.keyword = keyword
        search.date =  NSDate() as Date
        
        (try! self.context?.save())
        
        return search
    }
    
    //get list search
    
    // move array search to index
    func rearrange<T>(array: inout Array<T>, fromIndex: Int, toIndex: Int){
        
        let element = array.remove(at: fromIndex)
        array.insert(element, at: toIndex)
        
        
    }
    
    //search newsfeed
    public func letSearch(keyword:String,completion: @escaping (_ search:Search) -> Void) {
        if self.search?.keyword ==  keyword {
            self.isNews =  true
            self.stillDownload =  false
            self.cancelOperation()
            completion(self.search!)
            
            return
        }
        var items = self.itemsSearch
        if items.count == 0 {
            let aSearch = createNewSearch(keyword: keyword)!
            itemsSearch.append(aSearch)
            
            delegate?.updateView()
            self.search =  aSearch
            self.stillDownload =  false
            self.cancelOperation()
            
            createListNews()
            self.isNews =  false
            completion(aSearch)
            return
            
        }
        let aSearch:Search
        if let i = items.index(where: { $0.keyword == keyword}) {
            
            aSearch =  (items[i])
            aSearch.date = NSDate() as Date
            
            ( try! self.context?.save())
            
            
            
            if  i != 0 {
                rearrange(array: &items, fromIndex: i, toIndex: 0)
            }
            
            
            
            
            
        }else{
            aSearch = createNewSearch(keyword: keyword)!
            items.insert(aSearch, at: 0)
            
        }
        
        if (items.count) > 10 {
            let lastSearch = items.last
            self.context?.delete(lastSearch!)
            items.removeLast()
            
            (try! self.context?.save())
            
        }
        self.search =  aSearch
        
        self.stillDownload =  false
        self.cancelOperation()
        createListNews()
        self.isNews =  false
        self.itemsSearch = items
        delegate?.updateView()
        completion(aSearch)
        
    }
    
    
    // return number sections
    func numberOfSections() -> Int {
        if isNews == true {
            return 1
        }
        
        return 1
        
        
    }
    
    //return number row
    func numberOfRows(inSection section: Int) -> Int {
        
        
        if isNews == true {
            //            if self.itemsNewsFeed.count == 0 {
            //                return 0
            //            }
            return self.itemsNewsFeed.count
        }
        
        return self.itemsSearch.count
        
        
    }
    //get Article
    func itemForRow(at indexPath: IndexPath) -> Any? {
        
        if isNews == true {
            //            if self.itemsNewsFeed.count == 0 {
            //                return nil
            //            }
            return self.itemsNewsFeed[indexPath.row]
            
        }
        
        return self.itemsSearch[indexPath.row]
        
    }
    
    func list()->[NewsFeed]{
        return self.itemsNewsFeed
    }
    
    
    
}
