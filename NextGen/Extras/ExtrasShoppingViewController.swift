//
//  ExtrasShoppingViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 3/25/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import RFQuiltLayout

class ExtrasShoppingViewController: MenuedViewController, UICollectionViewDataSource, UICollectionViewDelegate, RFQuiltLayoutDelegate {
    
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    var experience: NGDMExperience!
    
    private var _products: [TheTakeProduct]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showsSelectedMenuItem = false
        
        for category in TheTakeAPIUtil.sharedInstance.productCategories {
            let info = NSMutableDictionary()
            info[MenuSection.Keys.Title] = category.name
            info[MenuSection.Keys.Value] = String(category.id)
            
            if let children = category.children {
                if children.count > 1 {
                    var rows = [[MenuItem.Keys.Title: "All", MenuItem.Keys.Value: String(category.id)]]
                    for child in children {
                        rows.append([MenuItem.Keys.Title: child.name, MenuItem.Keys.Value: String(child.id)])
                    }
                    
                    info[MenuSection.Keys.Rows] = rows
                }
            }
            
            menuSections.append(MenuSection(info: info))
        }
        
        productsCollectionView.backgroundColor = UIColor.clearColor()
        productsCollectionView.registerNib(UINib(nibName: String(ImageSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: ImageSceneDetailCollectionViewCell.ReuseIdentifier)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let layout = productsCollectionView.collectionViewLayout as? RFQuiltLayout {
            layout.direction = UICollectionViewScrollDirection.Vertical
            layout.blockPixels = CGSizeMake((CGRectGetWidth(productsCollectionView.bounds) / 3), (CGRectGetWidth(productsCollectionView.bounds) / 3))
        }
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuItemCell, menuItem = cell.menuItem, categoryId = menuItem.value {
            TheTakeAPIUtil.sharedInstance.getCategoryProducts(categoryId, successBlock: { (products) in
                dispatch_async(dispatch_get_main_queue(),{
                    self._products = products
                    self.productsCollectionView.reloadData()
                })
            })
        }
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let products = _products {
            return products.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageSceneDetailCollectionViewCell.ReuseIdentifier, forIndexPath: indexPath) as! ImageSceneDetailCollectionViewCell
        cell.title = nil
        
        if let product = _products?[indexPath.row] {
            cell.theTakeProducts = [product]
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: RFQuiltLayoutDelegate
    func blockSizeForItemAtIndexPath(indexPath: NSIndexPath!) -> CGSize {
        return CGSizeMake(1, 1)
    }
    
    func insetsForItemAtIndexPath(indexPath: NSIndexPath!) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }

}
