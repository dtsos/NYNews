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
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    //MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayNews!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellDetail", for: indexPath)
        configureCell(cell: cell as! DetailCell, forItemAt: indexPath)
        return cell
    }
    
    func configureCell(cell: DetailCell, forItemAt indexPath: IndexPath) {
        let newsFeed =  self.arrayNews?[indexPath.row]
        let urlRequest = URLRequest(url:URL(string:(newsFeed?.url!)!)!)
        cell.webview.loadRequest(urlRequest)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CellDetail", for: indexPath) as UIView
        return view as! UICollectionReusableView
    }
    
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//       
//        return CGSize(width: UIScreen.main.bounds.size.width - 20, height: self.view.bounds.size.height);
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        
//        return UIEdgeInsetsMake(0, 10, 0, 0)
//    }

    
    
}
