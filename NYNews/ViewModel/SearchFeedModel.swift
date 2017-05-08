//
//  SearchFeed.swift
//  NYNews
//
//  Created by David Trivian S on 5/5/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import Foundation
import CoreData
@objc protocol SearchFreeModelDelegate {
    func updateView()
     @objc optional func updateSection(section:IndexSet,type: NSFetchedResultsChangeType)
     @objc optional func updateRow(oldIndexPath:IndexPath?,newIndexPath:IndexPath?,type: NSFetchedResultsChangeType)
}
class SearchFeedModel:NSObject,NSFetchedResultsControllerDelegate {
    var delegate:SearchFreeModelDelegate?
    fileprivate var itemsNewsFeed:[NewsFeed] = [NewsFeed]()
    fileprivate var itemsSearch:[Search] =  [Search]()
    var search:Search?
    var fetcher:Fetching
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    init(fetching:Fetching,managedContext:NSManagedObjectContext) {
        self.managedObjectContext = managedContext
        self.fetcher =  fetching
        
        
        
        
    }
    var isNews:Bool = false
    var page:Int16 = 0
    var stillDownload:Bool = false
    
    //func needUpdate News
    func isNeedUpdateServer(dictionary:[String:AnyObject]?,page:Int16 ) -> Bool {
        
        
        
        
        
        let tempitems:[NewsFeed] = search?.listNews?.allObjects as! [NewsFeed]
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
    
    // check server if item diffrent update
    func checkServer(page:Int16,search:Search,beginUpdateView: @escaping () -> Void,failed: @escaping () -> Void,completion: @escaping (_ page:Int16) -> Void){
        
        if stillDownload == true  && page > 0 {
            
            return
        }
        stillDownload = true
        self.isNews = true
        lastStringQuery =  "\(Constant.URLArticleSearch)\(Constant.paramAPIKeyValue)&page=\(page)&q=\(search.keyword!)&sort=newest"
        fetcher.fetch(withQueryString: lastStringQuery!, failure: { (error) in
            self.stillDownload =  false
            failed()
            
        }) { (dictionary) in
            guard let response: [String:AnyObject] =  dictionary["response"] as? [String:AnyObject] else{
                self.stillDownload = false
                failed()
                
                return
            }
            guard let data: [[String:AnyObject]] = response["docs"] as? [[String : AnyObject]]  else {
                self.stillDownload = false
                failed()
                return
            }
            
            
            let itemDictionaries: [[String:AnyObject]] = data
            if (itemDictionaries.count <= 0){
                self.delegate?.updateView()
                completion(page > 1 ? page - 1 :0)
                return
            }
            if self.isNeedUpdateServer(dictionary: itemDictionaries.first!, page: page){
                beginUpdateView()
                
                var items:[NewsFeed] = search.listNews?.allObjects as! [NewsFeed]
               items = items.sorted(by: {$0.dateModified?.compare(($1.dateModified as Date?)!) == ComparisonResult.orderedDescending})
                items = items.filter({$0.page == page})
                let indexStart = 0
                if indexStart < (items.count) {
                    
                    for i in indexStart..<items.count{
                        //                for aNewsFeed in items! {
                        
                        let aNewsFeed:NewsFeed = items[i]
                        self.managedObjectContext?.delete(aNewsFeed)
                        
                        do {
                            try self.managedObjectContext?.save()
                        }catch{
                            print(error)
                        }
                    }
                    
                }
                if page == 0{
                    self.itemsNewsFeed.removeAll()
                }
                for aData in itemDictionaries {
                    
                    let newsModel =  NewsModel.init(fetcher: self.fetcher,  dictionary: aData,search:search, context: self.managedObjectContext!)
                    
                    newsModel.news?.isHeadline = false
                    newsModel.news?.page = page
                    newsModel.news?.whichSearch = search
                    newsModel.news?.dateModified = NSDate()
                    //                    search.add(newsModel)
                    
                    newsModel.save()
                    
                    self.itemsNewsFeed.append(newsModel.news!)
                    
                    
                    
                }
            }else{
                let arrayAllNews: [NewsFeed] = search.listNews?.allObjects as! [NewsFeed]
                let arrayNews = arrayAllNews.filter{ ($0 as NewsFeed).page == page }
                self.itemsNewsFeed.append(contentsOf: arrayNews )

            }
            self.page = page
            self.delegate?.updateView()
            completion(page)
            self.stillDownload = false
        }
        
    }
    var lastStringQuery:String?
    func cancelOperation()
    {
        URLSession.shared.getTasksWithCompletionHandler { (dataStacks, uploadStacks, downloadStacks) in
            for dataStack in dataStacks {
                if self.lastStringQuery != nil {
                    if dataStack.originalRequest?.url?.absoluteString == self.lastStringQuery {
                dataStack.cancel()
                        return
                    }
                }
            }
        }
    }
    
    func createNewSearch(keyword:String) -> Search?{
        let search:Search = Search(context:self.managedObjectContext!)
        search.keyword = keyword
        search.date =  NSDate()
        do {
            try self.managedObjectContext?.save()
        } catch  {
            return nil
        }
        return search
    }
    func arrayAllSearch() -> [Search]? {
        let fetchRequest : NSFetchRequest<Search> = Search.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false) 
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var result :[Search]?
        do {
            result = try self.managedObjectContext?.fetch(fetchRequest)
        } catch {
            
        }
        self.itemsSearch.removeAll()
        self.itemsSearch = result!
        return result
        
    }
    func rearrange<T>(array: inout Array<T>, fromIndex: Int, toIndex: Int){
        
        let element = array.remove(at: fromIndex)
        array.insert(element, at: toIndex)
        
        
    }
    public func letSearch(keyword:String,completion: @escaping (_ search:Search) -> Void) {
        if self.itemsSearch.count == 0 {
            self.itemsSearch = arrayAllSearch()!
        }
        var items = self.itemsSearch
        if items.count == 0 {
            let aSearch = createNewSearch(keyword: keyword)!
            itemsSearch.append(aSearch)
            
            delegate?.updateView()
            
            completion(aSearch)
            return
            
        }
        let aSearch:Search
        if let i = items.index(where: { $0.keyword == keyword}) {
            
            aSearch =  items[i]
            aSearch.date = NSDate()
            do {
                try self.managedObjectContext?.save()
            } catch  {
                
            }
            if  i != 0 {
                rearrange(array: &items, fromIndex: i, toIndex: 0)
            }
            
            
            
            
            
        }else{
            aSearch = createNewSearch(keyword: keyword)!
            items.insert(aSearch, at: 0)
            
        }
        
        if (items.count) > 10 {
            let lastSearch = items.last
            self.managedObjectContext?.delete(lastSearch!)
            self.itemsSearch.removeLast()
            do {
                try self.managedObjectContext?.save()
            } catch  {
                
            }
            
        }
        delegate?.updateView()
        completion(aSearch)
        
    }
    
    //    fetch search
    func checkCoreData(){
        //        if self.itemsSearch.count == 0 {
        self.itemsSearch =  arrayAllSearch()!
        
        
        
        //        }
        delegate?.updateView()
    }
    
    // return number sections
    func numberOfSections() -> Int {
        if isNews == true {
            return 1
        }else{
            return 1
        }
        
    }
    
    //return number row
    func numberOfRows(inSection section: Int) -> Int {
        
        
        if isNews == true {
            return self.itemsNewsFeed.count
        }else{
            return self.itemsSearch.count
        }
        
    }
    //get Article
    func itemForRow(at indexPath: IndexPath) -> Any {
        
        if isNews == true {
            
            return self.itemsNewsFeed[indexPath.row]
            
        }
        
        return self.itemsSearch[indexPath.row]
        
    }
    
    func list()->[NewsFeed]{
        return self.itemsNewsFeed
    }
    
    
    
}
