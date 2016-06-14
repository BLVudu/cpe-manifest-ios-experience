//
//  ExtrasShoppingItemsViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 4/18/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class ExtrasShoppingItemsViewController: ExtrasExperienceViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    struct Constants {
        static let ItemSpacing: CGFloat = 12
        static let LineSpacing: CGFloat = 12
        static let Padding: CGFloat = 15
        static let ItemAspectRatio: CGFloat = 338 / 230
    }
    
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    private var _products: [TheTakeProduct]?
    private var _productListSessionDataTask: NSURLSessionDataTask?
    private var _didSelectCategoryObserver: NSObjectProtocol!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(_didSelectCategoryObserver)
    }
 
    override func viewDidLoad() {
        productsCollectionView.registerNib(UINib(nibName: String(ShoppingSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: ShoppingSceneDetailCollectionViewCell.ReuseIdentifier)
        
        _didSelectCategoryObserver = NSNotificationCenter.defaultCenter().addObserverForName(kShoppingNotificationDidSelectCategory, object: nil, queue: nil, usingBlock: { [weak self] (notification) in
            if let strongSelf = self, userInfo = notification.userInfo, categoryId = userInfo["categoryId"] as? String {
                strongSelf.productsCollectionView.userInteractionEnabled = false
                MBProgressHUD.showHUDAddedTo(strongSelf.productsCollectionView, animated: true)
                
                if let currentTask = strongSelf._productListSessionDataTask {
                    currentTask.cancel()
                }
                
                strongSelf._productListSessionDataTask = TheTakeAPIUtil.sharedInstance.getCategoryProducts(categoryId, successBlock: { (products) in
                    dispatch_async(dispatch_get_main_queue(), {
                        strongSelf._products = products
                        strongSelf.productsCollectionView.reloadData()
                        let newIndex = NSIndexPath(forItem: 0, inSection: 0)
                        strongSelf.productsCollectionView.scrollToItemAtIndexPath(newIndex, atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
                        strongSelf.productsCollectionView.userInteractionEnabled = true
                        MBProgressHUD.hideAllHUDsForView(strongSelf.productsCollectionView, animated: true)
                    })
                    
                    strongSelf._productListSessionDataTask = nil
                })
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        productsCollectionView.collectionViewLayout.invalidateLayout()
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ShoppingSceneDetailCollectionViewCell.ReuseIdentifier, forIndexPath: indexPath) as! ShoppingSceneDetailCollectionViewCell
        cell.titleLabel?.removeFromSuperview()
        cell.productImageType = ShoppingSceneDetailCollectionViewCell.ProductImageType.Scene
        
        if let product = _products?[indexPath.row] {
            cell.theTakeProducts = [product]
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
     func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let shoppingDetailViewController = UIStoryboard.getNextGenViewController(ShoppingDetailViewController) as? ShoppingDetailViewController, cell = collectionView.cellForItemAtIndexPath(indexPath) as? ShoppingSceneDetailCollectionViewCell {
            shoppingDetailViewController.experience = experience
            shoppingDetailViewController.products = cell.theTakeProducts
            shoppingDetailViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            shoppingDetailViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            self.presentViewController(shoppingDetailViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth: CGFloat = (CGRectGetWidth(collectionView.frame) / 2) - (Constants.ItemSpacing * 2)
        return CGSizeMake(itemWidth, itemWidth / Constants.ItemAspectRatio)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.LineSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.ItemSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(Constants.Padding, Constants.Padding, Constants.Padding, Constants.Padding)
    }
    
}
