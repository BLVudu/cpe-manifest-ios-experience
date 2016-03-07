//
//  ShoppingDetailViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/3/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MessageUI

class ShoppingDetailCell: UICollectionViewCell{
    @IBOutlet weak var itemThumbnail: UIImageView!
    
    @IBOutlet weak var itemBrand: UILabel!
    
    @IBOutlet weak var itemName: UILabel!
    
    
    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            if newValue {
                super.selected = true
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.whiteColor().CGColor
                
            } else if newValue == false {
                
                self.layer.borderWidth = 0
            }
        }
    }

    
}


class ShoppingDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MFMailComposeViewControllerDelegate, UICollectionViewDelegateFlowLayout{
    
    var items = [Shopping]()
    var curItem = 0
    
    @IBOutlet weak var itemView: UIImageView!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var theTake: UIButton!
    @IBOutlet weak var emailLink: UIButton!

    @IBOutlet weak var buttonSpacing: NSLayoutConstraint!

    
    
    
    @IBOutlet weak var shoppingItems: UICollectionView!
    
        @IBAction func close(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        

        if self.view.frame.width == 768{
           self.buttonSpacing.constant = -97
        } else {
            self.buttonSpacing.constant = -150
        }
        
        
        print(self.shoppingItems.frame.height)
       
        
        self.brandName.text = items[curItem].itemBrand
        self.itemName.text = items[curItem].itemName
        self.price.text = items[curItem].itemPrice
        self.itemView.setImageWithURL(NSURL(string: items[curItem].itemimage)!)
  

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(250, self.shoppingItems.frame.height)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCellWithReuseIdentifier("shop", forIndexPath: indexPath) as! ShoppingDetailCell
        
        cell.itemBrand.text = items[indexPath.row].itemBrand
        cell.itemName.text = items[indexPath.row].itemName
        cell.itemThumbnail.setImageWithURL(NSURL(string: items[indexPath.row].itemimage)!)
        
        return cell
    }
    
   
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return items.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        curItem = indexPath.row
        self.brandName.text = items[curItem].itemBrand
        self.itemName.text = items[curItem].itemName
        self.price.text = items[curItem].itemPrice
        self.itemView.setImageWithURL(NSURL(string: items[curItem].itemimage)!)
    }
    @IBAction func shopTheTake(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Are you sure you want to leave the movie and visit THETAKE.COM ", message: "Click 'Cancel' to continuue watching your movie or click 'OK' to continue watching your movie", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: self.items[self.curItem].itemLink)!)

        }))
        
        alertController.show()

        
        
        
    }
    @IBAction func sendLink(sender: AnyObject) {
        
        
        let email = MFMailComposeViewController()
        email.mailComposeDelegate = self
        email.setSubject("Man of Steel")
        email.setMessageBody("Check out this item from Man of Steel "  + String(items[curItem].itemLink), isHTML: true)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        self.presentViewController(email, animated: true, completion: nil)

    }
}