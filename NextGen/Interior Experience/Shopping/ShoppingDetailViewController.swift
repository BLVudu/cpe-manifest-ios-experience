//
//  ShoppingDetailViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/3/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MessageUI

class ShoppingDetailCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "ShoppingDetailCellReuseIdentifier"
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    private var _product: TheTakeProduct?
    var product: TheTakeProduct? {
        get {
            return _product
        }
        
        set(v) {
            _product = v
            
            productBrandLabel.text = _product?.brand
            productNameLabel.text = _product?.name
            if let imageURL = _product?.imageURL {
                productImageView.setImageWithURL(imageURL, completion: { (image) -> Void in
                    self.productImageView.backgroundColor = image?.getPixelColor(CGPoint.zero)
                })
            } else {
                productImageView.image = nil
            }
        }
    }
    
    override var selected: Bool {
        didSet {
            self.layer.borderColor = UIColor.whiteColor().CGColor
            self.layer.borderWidth = (self.selected ? 1 : 0)
        }
    }
    
}

class ShoppingDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MFMailComposeViewControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var productMatchIcon: UIView!
    @IBOutlet weak var productMatchLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    var products: [TheTakeProduct]!
    
    private var _currentProduct: TheTakeProduct?
    var currentProduct: TheTakeProduct? {
        get {
            return _currentProduct
        }

        set(v) {
            _currentProduct = v
            
            productMatchIcon.backgroundColor = _currentProduct != nil ? (_currentProduct!.exactMatch ? UIColor(netHex: 0x2c97de) : UIColor(netHex: 0xf1c115)) : UIColor.clearColor()
            productMatchLabel.text = _currentProduct != nil ? (_currentProduct!.exactMatch ? "Exact match" : "Close match") : nil
            productBrandLabel.text = _currentProduct?.brand
            productNameLabel.text = _currentProduct?.name
            productPriceLabel.text = _currentProduct?.price
            if let imageURL = _currentProduct?.imageURL {
                productImageView.setImageWithURL(imageURL, completion: { (image) -> Void in
                    self.productImageView.backgroundColor = image?.getPixelColor(CGPoint.zero)
                })
            } else {
                productImageView.image = nil
            }
        }
    }
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productMatchIcon.layer.cornerRadius = CGRectGetWidth(productMatchIcon.frame) / 2
        currentProduct = products.first
    }
    
    
    // MARK: Actions
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shopTheTake(sender: AnyObject) {
        let alertController = UIAlertController(title: "Are you sure you want to leave the movie and visit THETAKE.COM ", message: "Click 'Cancel' to continuue watching your movie or click 'OK' to continue watching your movie", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            //UIApplication.sharedApplication().openURL(NSURL(string: self.items[self.curItem].itemLink)!)
            
        }))
        
        alertController.show()
    }
    
    @IBAction func sendLink(sender: AnyObject) {
        let email = MFMailComposeViewController()
        email.mailComposeDelegate = self
        email.setSubject("Man of Steel")
        //email.setMessageBody("Check out this item from Man of Steel "  + String(items[curItem].itemLink), isHTML: true)
        //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        self.presentViewController(email, animated: true, completion: nil)
        
    }
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ShoppingDetailCell.ReuseIdentifier, forIndexPath: indexPath) as! ShoppingDetailCell
        cell.product = products[indexPath.row]
        cell.selected = (cell.product == currentProduct)
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        currentProduct = products[indexPath.row]
    }
    
}