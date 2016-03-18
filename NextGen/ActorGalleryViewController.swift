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





class ActorGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var carouselView: UICollectionView!
 
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
        
        let selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.carouselView.selectItemAtIndexPath(selectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
        self.collectionView(self.carouselView, didSelectItemAtIndexPath: selectedIndexPath)
        
        NSNotificationCenter.defaultCenter().addObserverForName("updateCarousel", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            if let userInfo = notification.userInfo {
                let viewerIndexPath = NSIndexPath(forRow: userInfo["index"]as! Int, inSection: 0)
                self.carouselView.selectItemAtIndexPath(viewerIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
                
                
            }
        }

        

    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("thumbnail", forIndexPath: indexPath)as! ActorGalleryCell
        
        cell.thumbnail.setImageWithURL(NSURL(string: images[indexPath.row])!)
        
        return cell
    
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("updateViewer", object: nil, userInfo: ["index": indexPath.row])
        
        
    }
    
       func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    

    @IBAction func close(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

