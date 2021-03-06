//
//  DetailNewsViewController.swift
//  NYNews
//
//  Created by David Trivian S on 5/7/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import UIKit
class DetailCell:UICollectionViewCell{
    
    @IBOutlet weak var webview: UIWebView!
    
}
class DetailNewsViewController : UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet  weak var collectionView: UICollectionView!
    var arrayNews :[NewsFeed]?
    var indexStart :IndexPath?
    var searchModel : SearchNewsFeedModel? {
        willSet{
            if (newValue != nil){
                self.newsModel = nil
            }
        }
    }
    var newsModel : NewsFeedModel?{
        willSet{
            if (newValue != nil){
                self.searchModel = nil
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title =  "Detail News"
        collectionView.dataSource = self
        collectionView.delegate = self
        let cellWidth : CGFloat = self.view.bounds.size.width
        let cellheight : CGFloat = self.view.bounds.size.height
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.setCollectionViewLayout(layout, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        collectionView.scrollToItem(at: indexStart!, at: UICollectionViewScrollPosition(rawValue: 0), animated: true)
        
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.newsModel != nil{
            return (self.newsModel?.numberOfRows(inSection: section))!
        }else{
            if self.searchModel != nil {
                return (self.newsModel?.numberOfRows(inSection: section))!
            }
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellDetail", for: indexPath)
        configureCell(cell: cell as! DetailCell, forItemAt: indexPath)
        return cell
    }
    
    func configureCell(cell: DetailCell, forItemAt indexPath: IndexPath) {
        
        
        let aNewsFeed =  newsFeed(at:indexPath)
        if aNewsFeed !=  nil && aNewsFeed?.url != nil {
            let urlRequest = URLRequest(url:URL(string:(aNewsFeed?.url!)!)!)
            cell.webview.loadRequest(urlRequest)
            
        }
        
    }
    
    func newsFeed(at indexPath:IndexPath) -> NewsFeed? {
        if self.newsModel != nil {
            return self.newsModel?.itemForRow(at:indexPath)
        }else{
            if self.searchModel != nil {
                let newsFeed = self.searchModel?.itemForRow(at: indexPath)
                if newsFeed is NewsFeed {
                    return (newsFeed as! NewsFeed)
                }
            }
        }
        return nil
    }
    
    
}
