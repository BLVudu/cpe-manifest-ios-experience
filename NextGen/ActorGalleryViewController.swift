//
//  ActorGalleryViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/4/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class ActorGalleryCell: UICollectionViewCell{
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    
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





class ActorGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var caroselView: UIView!
    var images = [String]()
    func mediaGalleryViewController() -> MediaGalleryViewController? {
        for viewController in self.childViewControllers {
            if viewController is MediaGalleryViewController {
                return viewController as? MediaGalleryViewController
            }
        }
        
        return nil
    }
    
    
   
    
    override func viewDidLoad() {
        let mediaViewController = mediaGalleryViewController()
        mediaViewController?.imageGallery = images

    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("thumbnail", forIndexPath: indexPath)as! ActorGalleryCell
        
        cell.thumbnail.setImageWithURL(NSURL(string: images[indexPath.row])!)
        
        return cell
    
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(100, 100)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }


    
   

    
    @IBAction func close(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

