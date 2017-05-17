//
//  ListNewsViewController.swift
//  NYNews
//
//  Created by David Trivian S on 5/5/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import UIKit


class SearchCell : UICollectionViewCell {
    @IBOutlet weak var labelKeyword: UILabel!
    
    
}
class NewsCell : UICollectionViewCell {
    
    
    
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
class ListNewsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate,UISearchControllerDelegate,UICollectionViewDelegateFlowLayout,UISearchResultsUpdating,SearchFeedModelDelegate,NewsFeedDelegate {
    
    static let ID = "ListNewsVC"
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var collectionView: UICollectionView!
    var stringKeyword:String = ""
    
    
    
    var searchFeed:SearchNewsFeedModel?
    
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
        
        newsModel = NewsFeedModel.init(fetcher: self.fetcher)
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView.refreshControl =  refreshControl
        let attributes = [NSForegroundColorAttributeName: UIColor.black]
        let attributedTitle = NSAttributedString(string: "Refreshing News Feed", attributes: attributes)
        refreshControl.attributedTitle =  attributedTitle
        refreshControl.beginRefreshing()
        
        newsModel?.checkServer(page: self.page,beginUpdateView: update, failed: failed, completion: completion)
        newsModel?.delegate = self
        
        newsModel?.readyVC()
        searchFeed =  SearchNewsFeedModel.init(fetching: self.fetcher)
        searchFeed?.delegate = self
        
        
        
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.tintColor = UIColor.red
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder  = "Keyword"
    }
    
    
    //MARK: UICollectionViewDelegate
    
    
    func didPullToRefresh() {
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
        debugPrint("Update")
    }
    private func failed() {
        debugPrint("failed")
    }
    private func completion(_ page:Int16) {
        self.page = page
        if self.refreshControl.isRefreshing == true {
            DispatchQueue.main.async(execute: { () -> Void in
            self.refreshControl.endRefreshing()
            })
        }
        
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
              searchFeed?.isNews == true ?(detailNewsVC.searchModel = searchFeed):(detailNewsVC.newsModel = newsModel)
            self.navigationController?.pushViewController(detailNewsVC, animated: true)
            
        }else{
            let search:Search = searchFeed?.itemForRow(at: indexPath) as! Search
            self.search(keyword: search.keyword!)
        }
    }
    
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if searchController.isActive {
            
            return (searchFeed?.numberOfSections())!
        }
        return (newsModel?.numberOfSections())!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchController.isActive {
            return (searchFeed?.numberOfRows(inSection: section))!
        }
        
        return (newsModel?.numberOfRows(inSection: section))!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if searchController.isActive && self.searchFeed?.isNews == false {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellSearch", for: indexPath)
            
            configureCell(cell as! SearchCell, withSearch: (searchFeed?.itemForRow(at: indexPath) as! Search), index: indexPath)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath)
            let newsFeed = searchController.isActive ?  (searchFeed?.itemForRow(at: indexPath) as! NewsFeed): (newsModel?.itemForRow(at: indexPath))!
            configureCell(cell as! NewsCell, withFeed: newsFeed,index:indexPath)
            
            return cell
        }
    }
    
    //configure Cell NewsFeed
    func configureCell(_ cell: NewsCell, withFeed newsFeed: NewsFeed?,index:IndexPath) {
        
        cell.labelUsername.text =  newsFeed?.title
        cell.labelTime.text =  newsFeed?.pubDate?.dateDiff()
        cell.labelMessage.text =  newsFeed?.snippet
        cell.imageviewNews.image = UIImage(named:"nytime")
        if newsFeed?.imageUrl != nil {
            cacheImage(stringURl: "\(Constant.RootServerImage)\((newsFeed?.imageUrl)!)") { (success,image ) in
                if success {
                    cell.imageviewNews.image = image
                }
            }
        }
        
        
        
    }
    
    //configure cell search
    func configureCell(_ cell: SearchCell, withSearch search: Search?,index:IndexPath) {
        
        cell.labelKeyword.text =  search?.keyword
        
        
        
    }
    //    NSFetch
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if searchController.isActive && !(searchFeed?.isNews)! {
            return CGSize(width: UIScreen.main.bounds.size.width, height:42)
        }
        return CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * (3/4));
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(0, 0, 0, 0)
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
        newsModel?.cancelOperation()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        self.collectionView.reloadData()
        self.present(searchController, animated: true, completion: nil)
    }
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text?.characters.count == 0 {
            searchFeed?.isNews = false
            self.collectionView.reloadData()
        }
    }
    
    func search(keyword:String)  {
        self.collectionView.reloadData()
        self.searchController.searchBar.text = keyword
        guard (keyword.characters.count) > 0 else {
            return
        }
        searchFeed?.letSearch(keyword: keyword, completion: { search in
            if self.searchFeed?.search != search {
                
                
                self.searchFeed?.search = search
                self.searchFeed?.createListNews()
                self.searchFeed?.checkServer(page: 0, search: search, beginUpdateView: self.update, failed: self.failed, completion: self.completion)
            }else{
        
                self.collectionView.reloadData()
            }
        })
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        self.search(keyword: searchController.searchBar.text!)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        self.searchFeed?.search = nil
        self.searchFeed?.isNews = false
        self.searchFeed?.cancelOperation()
        self.collectionView.reloadData()
    }
    
    
    
    // Delagate Search
    func updateView(){
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.collectionView.reloadData()
            
        })
        
    }
    
    func updateListNewsView(){
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.collectionView.reloadData()
            //            self.collectionView.performBatchUpdates(nil, completion: nil)
        })
        
    }
    
}
