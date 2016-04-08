//
//  ShoppingDetailViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/3/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class ShoppingDetailCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "ShoppingDetailCellReuseIdentifier"
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    var product: TheTakeProduct? {
        didSet {
            productBrandLabel.text = product?.brand
            productNameLabel.text = product?.name
            if let imageURL = product?.productImageURL {
                productImageView.setImageWithURL(imageURL, completion: { (image) -> Void in
                    self.productImageView.backgroundColor = image?.getPixelColor(CGPoint.zero)
                })
            } else {
                productImageView.image = nil
                productImageView.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    override var selected: Bool {
        didSet {
            self.layer.borderColor = UIColor.whiteColor().CGColor
            self.layer.borderWidth = (self.selected ? 2 : 0)
        }
    }
    
}

class ShoppingDetailViewController: SceneDetailViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
    
    var currentProduct: TheTakeProduct? {
        didSet {
            productMatchIcon.backgroundColor = currentProduct != nil ? (currentProduct!.exactMatch ? UIColor(netHex: 0x2c97de) : UIColor(netHex: 0xf1c115)) : UIColor.clearColor()
            productMatchLabel.text = currentProduct != nil ? (currentProduct!.exactMatch ? "Exact match" : "Close match") : nil
            productBrandLabel.text = currentProduct?.brand
            productNameLabel.text = currentProduct?.name
            productPriceLabel.text = currentProduct?.price
            if let imageURL = currentProduct?.productImageURL {
                productImageView.setImageWithURL(imageURL, completion: { (image) -> Void in
                    self.productImageView.backgroundColor = image?.getPixelColor(CGPoint.zero)
                })
            } else {
                productImageView.image = nil
                productImageView.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productMatchIcon.layer.cornerRadius = CGRectGetWidth(productMatchIcon.frame) / 2
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        productsCollectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.Top)
        collectionView(productsCollectionView, didSelectItemAtIndexPath: indexPath)
    }
    
    
    // MARK: Actions
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onShop(sender: AnyObject) {
        if let product = currentProduct {
            product.theTakeURL.promptLaunchBrowser()
        }
    }
    
    @IBAction func onSendLink(sender: AnyObject) {
        if let button = sender as? UIButton, product = currentProduct {
            let activityViewController = UIActivityViewController(activityItems: [product.shareText], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = button
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ShoppingDetailCell.ReuseIdentifier, forIndexPath: indexPath) as! ShoppingDetailCell
        cell.product = products[indexPath.row]
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let product = products[indexPath.row]
        if product != currentProduct {
            currentProduct = product
        }
    }
    
}