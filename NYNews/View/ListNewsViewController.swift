//
//  ListNewsViewController.swift
//  NYNews
//
//  Created by David Trivian S on 5/5/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import UIKit
import CoreData

class SearchCell : UICollectionViewCell {
    @IBOutlet weak var labelKeyword: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        
    }
    
}
class NewsCell : UICollectionViewCell {
    
    var cache:NSCache<AnyObject, AnyObject>!
    
    @IBOutlet weak var imageviewNews: UIImageView!
    @IBOutlet weak var imageviewLike: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    
    @IBOutlet weak var labelComment: UILabel!
    @IBOutlet weak var imageviewComment: UIImageView!
    @IBOutlet weak var labelLike: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var imageviewProfile: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        
    }
    
}
class ListNewsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,NSFetchedResultsControllerDelegate,UISearchBarDelegate,UISearchControllerDelegate,UICollectionViewDelegateFlowLayout,UISearchResultsUpdating,SearchFreeModelDelegate {
    
    static let ID = "ListNewsVC"
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var collectionView: UICollectionView!
    var stringKeyword:String = ""
    
    /// Secondary search results table view.

    var searchFeed:SearchFeedModel?
    
    var newsModel:NewsFeedModel?
    let fetcher:Fetching = Fetching()
    var page:Int16 = 0
    let refreshControl:UIRefreshControl = UIRefreshControl()
    var cache:NSCache<AnyObject, AnyObject>!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cache = NSCache()
        collectionView.delegate = self
        collectionView.dataSource =  self
        
        self.navigationController?.navigationBar.topItem?.title = "NY Times"

        
        let cellWidth : CGFloat = UIScreen.main.bounds.size.width
        let cellheight : CGFloat = UIScreen.main.bounds.size.width * (3/4)
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        newsModel = NewsFeedModel.init(fetcher: self.fetcher, fetchNewsController: self.fetchedResultsController)
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView.refreshControl =  refreshControl
        let attributes = [NSForegroundColorAttributeName: UIColor.black]
        let attributedTitle = NSAttributedString(string: "Refreshing News Feed", attributes: attributes)
        refreshControl.attributedTitle =  attributedTitle
        refreshControl.beginRefreshing()
        
        newsModel?.checkServer(page: self.page,beginUpdateView: update, failed: failed, completion: completion)
        
        
        searchFeed =  SearchFeedModel.init(fetching: self.fetcher, managedContext: self.managedObjectContext!)
        searchFeed?.delegate = self
        
        
        
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.tintColor = UIColor.red
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder  = "Keyword"
    }
    
    
    //MARK: UICollectionViewDelegate
    
    
    @objc private func didPullToRefresh() {
        if self.searchController.isActive {
            if (searchFeed?.isNews)! && searchFeed?.search != nil {
                self.searchFeed?.checkServer(page: 0, search: (searchFeed?.search)!, beginUpdateView: update, failed: failed, completion: completion)
            }else{
                refreshControl.endRefreshing()
            }
        }else{
            newsModel?.checkServer(page: 0,beginUpdateView: update, failed: failed, completion: completion)
        }
        
    }
    private func update() {
        if(self.searchController.isActive){
            
        }else{
            if collectionView.numberOfItems(inSection: 0) != fetchedResultsController.fetchedObjects?.count {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.collectionView.reloadData()
                })
            }
        }
    }
    private func failed() {
    }
    private func completion(_ page:Int16) {
        self.page = page
        
        refreshControl.endRefreshing()
        
    }
    
    //cache
    func cacheImage(stringURl:String?, completionHandler:  @escaping (Bool,UIImage?) -> Swift.Void){
        if (self.cache.object(forKey:stringURl as AnyObject) != nil){
           
            // Use Image from cache
            completionHandler(true, self.cache.object(forKey: stringURl as AnyObject) as? UIImage)
        }else{
            
            guard let stringURl = stringURl else {
                completionHandler(false,nil)
                return
            }
            //try download images
            let url:URL! = URL(string: stringURl)
            let urlRequest = URLRequest(url: url)
            URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
                
                if let response = response, let data = data, response.isHTTPResponseValid() {
                    DispatchQueue.main.async(execute: { () -> Void in
                        let img:UIImage! = UIImage(data: data)
                        if img != nil {
                        self.cache.setObject(img, forKey: stringURl as AnyObject)
                            completionHandler(true,img)
                        }else{
                            completionHandler(false,nil)
                        }
                        
                    })
                }else{
                    
                }
                
            }).resume()
            
        }
        
    }
    
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (searchFeed?.isNews)! || !searchController.isActive {
            searchController.isActive = false
            let detailNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailNewsVC") as! DetailNewsViewController
            detailNewsVC.indexStart = indexPath
            detailNewsVC.arrayNews =  searchFeed?.isNews == true ?searchFeed?.list():self.fetchedResultsController.fetchedObjects
            self.navigationController?.pushViewController(detailNewsVC, animated: true)
            
        }else{
            let search:Search = searchFeed?.itemForRow(at: indexPath) as! Search
            self.search(keyword: search.keyword!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    //MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if searchController.isActive {
            
            return (searchFeed?.numberOfSections())!
        }
        return _fetchedResultsController!.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchController.isActive {
            return (searchFeed?.numberOfRows(inSection: section))!
        }
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if searchController.isActive && self.searchFeed?.isNews == false {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellSearch", for: indexPath)
            
            configureCell(cell as! SearchCell, withSearch: (searchFeed?.itemForRow(at: indexPath) as! Search), index: indexPath)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath)
            configureCell(cell as! NewsCell, withFeed: searchController.isActive ?  (searchFeed?.itemForRow(at: indexPath) as! NewsFeed): self.fetchedResultsController.fetchedObjects?[indexPath.row],index:indexPath)
            
            return cell
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if searchController.isActive && self.searchFeed?.isNews == false {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellSearch", for: indexPath)
            
            configureCell(cell as! SearchCell, withSearch: (searchFeed?.itemForRow(at: indexPath) as! Search), index: indexPath)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath)
            configureCell(cell as! NewsCell, withFeed: searchController.isActive ?  (searchFeed?.itemForRow(at: indexPath) as! NewsFeed): self.fetchedResultsController.fetchedObjects?[indexPath.row],index:indexPath)
            return cell
        }
    }
    //configure Cell
    func configureCell(_ cell: NewsCell, withFeed newsFeed: NewsFeed?,index:IndexPath) {
        
        cell.labelUsername.text =  newsFeed?.title
        cell.labelTime.text =  newsFeed?.pubDate?.dateDiff()
        cell.labelMessage.text =  newsFeed?.snippet
//        let aNewsModel = newsModel?.getNewsModel(index: index.row)
//        if aNewsModel?.imageDataNews == nil{
//            

//            cell.imageviewNews.loadImageURL(URL(string:("\(Constant.RootServerImage)\((newsFeed?.imageUrl)!)")), placeholderImage: "nytime") { (success, data, image) in
//                if(success){
//                    aNewsModel?.imageDataNews = data
//                    
//                }
//                cell.imageviewNews.image = image
//                
//                
//            }
//        }else{
//            cell.imageviewNews.image = UIImage(data:(aNewsModel?.imageDataNews)!)
//        }
                    cell.imageviewNews.image = UIImage(named:"nytime")
        cacheImage(stringURl: "\(Constant.RootServerImage)\((newsFeed?.imageUrl)!)") { (success,image ) in
            if success {
                cell.imageviewNews.image = image
            }
        }
        
        
    }
    
    
    func configureCell(_ cell: SearchCell, withSearch search: Search?,index:IndexPath) {
        
        cell.labelKeyword.text =  search?.keyword
        
        
        
    }
    //    NSFetch
    var managedObjectContext: NSManagedObjectContext? = nil
    
    
    
    
    var fetchedResultsController: NSFetchedResultsController<NewsFeed> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<NewsFeed> = NewsFeed.fetchRequest()
        
        
        fetchRequest.fetchBatchSize = 20
        fetchRequest.predicate = NSPredicate(format: "page <= \(page) AND isHeadline = true")
        
        
        
        
        
        let sortDescriptor = NSSortDescriptor(key: "dateModified", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName:nil)
        aFetchedResultsController.delegate = self
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            collectionView.insertSections(IndexSet(integer: sectionIndex))
        case .delete:
            collectionView.deleteSections(IndexSet(integer: sectionIndex))
        default:
            return
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if (self.searchController.isActive){
            
        }else{
            switch type {
            case .insert:
                collectionView.insertItems(at: [newIndexPath!])
            case .delete:
                
                collectionView.deleteItems(at: [indexPath!])
            case .update:
                
                collectionView.reloadItems(at: [indexPath!])
                
            case .move:
                
                collectionView.moveItem(at: indexPath!, to: newIndexPath!)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if searchController.isActive && !(searchFeed?.isNews)! {
            return CGSize(width: UIScreen.main.bounds.size.width, height:42)
        }
        return CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * (3/4));
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    //delegate scrollview infinite scroll
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        
        if scrollView.isAtBottom {
            if self.searchController.isActive && searchFeed?.isNews == true {
                searchFeed?.checkServer(page: self.page + 1, search: (searchFeed?.search)!, beginUpdateView: update, failed: failed, completion: completion)
            }else if !self.searchController.isActive{
                newsModel?.checkServer(page: self.page + 1,beginUpdateView: update, failed: failed, completion: completion)
            }
        }
    }
    
    //search
    
    @IBAction func actionSearch(_ sender: UIBarButtonItem) {
        searchFeed?.checkCoreData()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        self.collectionView.reloadData()
        self.present(searchController, animated: true, completion: nil)
    }
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func search(keyword:String)  {
        self.collectionView.reloadData()
        self.searchController.searchBar.text = keyword
        guard (keyword.characters.count) > 0 else {
            return
        }
        searchFeed?.search(keyword: keyword, completion: { search in
            if self.searchFeed?.search != search {
                self.searchFeed?.cancelOperation()
                self.searchFeed?.search = search
                
                self.searchFeed?.checkServer(page: 0, search: search, beginUpdateView: self.update, failed: self.failed, completion: self.completion)
            }
        })
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        self.search(keyword: searchController.searchBar.text!)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        self.searchFeed?.search = nil
        self.searchFeed?.isNews = false
        self.collectionView.reloadData()
    }
    
    
    
    // Delagate Search
    func updateView(){
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.collectionView.reloadData()
            
        })
        
    }
    func updateSection(section:IndexSet,type: NSFetchedResultsChangeType){
        switch type {
        case .insert:
            collectionView.insertSections(section)
        case .delete:
            collectionView.deleteSections(section)
        default:
            return
        }
    }
    func updateRow(oldIndexPath:IndexPath?,newIndexPath:IndexPath?,type: NSFetchedResultsChangeType){
        if self.searchFeed?.isNews == true {
            return
        }
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            
            collectionView.deleteItems(at: [oldIndexPath!])
        case .update:
            
            collectionView.reloadItems(at: [oldIndexPath!])
            
        case .move:
            
            collectionView.moveItem(at: oldIndexPath!, to: newIndexPath!)
        }
    }
}
