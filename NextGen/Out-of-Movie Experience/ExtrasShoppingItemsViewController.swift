//
//  ExtrasShoppingItemsViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 4/18/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class ExtrasShoppingItemsViewController: ExtrasExperienceViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    
    private var _products: [TheTakeProduct]?
    private var _productListSessionDataTask: NSURLSessionDataTask?
 
    override func viewDidLoad() {
        
        
        productsCollectionView.registerNib(UINib(nibName: String(ShoppingSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: ShoppingSceneDetailCollectionViewCell.ReuseIdentifier)
        
        reloadItems(String.localize("label.all"))
        
        NSNotificationCenter.defaultCenter().addObserverForName("reloadCategory", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self, userInfo = notification.userInfo{
                strongSelf.reloadItems(userInfo["category"] as! String)
                
            }
        })
        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        productsCollectionView.collectionViewLayout.invalidateLayout()
    }
    
     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let products = _products {
            
            return products.count
        }
        
        return 0
    }
    
    func reloadItems(categoryId: String){
        
        if let currentTask = _productListSessionDataTask {
            currentTask.cancel()
        }
   
        productsCollectionView.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(productsCollectionView, animated: true)
        _productListSessionDataTask = TheTakeAPIUtil.sharedInstance.getCategoryProducts(categoryId, successBlock: { (products) in
            dispatch_async(dispatch_get_main_queue(), {
                self._products = products
                self.productsCollectionView.reloadData()
                self.productsCollectionView.userInteractionEnabled = true
                MBProgressHUD.hideAllHUDsForView(self.productsCollectionView, animated: true)
            })
            
            self._productListSessionDataTask = nil
        })

        
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
        if let shoppingDetailViewController = UIStoryboard.getMainStoryboardViewController(ShoppingDetailViewController) as? ShoppingDetailViewController, cell = collectionView.cellForItemAtIndexPath(indexPath) as? ShoppingSceneDetailCollectionViewCell {
            shoppingDetailViewController.experience = experience
            shoppingDetailViewController.products = cell.theTakeProducts
            shoppingDetailViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            shoppingDetailViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            self.presentViewController(shoppingDetailViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((CGRectGetWidth(collectionView.bounds) / 3) - 5, 190)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
}
