//
//  SceneDetailCollectionViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit
import RFQuiltLayout

class SceneDetailCollectionViewController: UICollectionViewController, RFQuiltLayoutDelegate {
    
    let kSceneDetailSegueShowGallery = "showGallery"
    let kSceneDetailSegueShowShop = "showShop"
    
    let regionRadius: CLLocationDistance = 2000
    var initialLocation = CLLocation(latitude: 0, longitude: 0)
    var locName = ""
    var locImg = ""
    var galleryID = 0
    
    var currentTime = -1.0
    var currentProductFrameTime = -1.0
    var currentProductSessionDataTask: NSURLSessionDataTask?
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.collectionView?.alpha = 0
        self.collectionView?.registerNib(UINib(nibName: String(MapSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: MapSceneDetailCollectionViewCell.ReuseIdentifier)
        self.collectionView?.registerNib(UINib(nibName: String(ImageSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: ImageSceneDetailCollectionViewCell.ReuseIdentifier)
        
        NSNotificationCenter.defaultCenter().addObserverForName(kVideoPlayerTimeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            if let userInfo = notification.userInfo, time = userInfo["time"] as? Double {
                self.currentTime = time
                self.updateCollectionView()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        layoutCollectionView()
        self.collectionView?.alpha = 1
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        layoutCollectionView()
    }
    
    func layoutCollectionView() {
        let layout = self.collectionView?.collectionViewLayout as! RFQuiltLayout
        layout.direction = UICollectionViewScrollDirection.Vertical
        layout.blockPixels = CGSizeMake((CGRectGetWidth(self.collectionView!.bounds) / 2), (CGRectGetWidth(self.collectionView!.bounds) / 2))
    }
    
    func updateCollectionView() {
        if let visibleCells = self.collectionView?.visibleCells() {
            for cell in visibleCells {
                if let cell = cell as? SceneDetailCollectionViewCell {
                    updateCollectionViewCell(cell)
                }
            }
        }
    }
    
    func updateCollectionViewCell(cell: SceneDetailCollectionViewCell) {
        if let experience = cell.experience, timedEvent = experience.timedEventSequence?.timedEvent(currentTime) {
            if timedEvent.isProduct(kTheTakeIdentifierNamespace) {
                let newFrameTime = TheTakeAPIUtil.sharedInstance.closestFrameTime(currentTime)
                if currentProductFrameTime != newFrameTime {
                    currentProductFrameTime = newFrameTime
                    
                    if let currentTask = currentProductSessionDataTask {
                        currentTask.cancel()
                    }
                    
                    currentProductSessionDataTask = TheTakeAPIUtil.sharedInstance.getFrameProducts(currentProductFrameTime, successBlock: { (products) -> Void in
                        if products.count > 0 {
                            cell.theTakeProducts = products
                        }
                        
                        self.currentProductSessionDataTask = nil
                    })
                }
            } else if cell.timedEvent == nil || timedEvent != cell.timedEvent {
                cell.timedEvent = timedEvent
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NextGenDataManager.sharedInstance.mainExperience.syncedExperience.childExperiences.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //var reuseIdentifier = ImageSceneDetailCollectionViewCell.ReuseIdentifier
        //if indexPath.row == SceneDetailItemType.Location.rawValue {
        //    reuseIdentifier = MapSceneDetailCollectionViewCell.ReuseIdentifier
        //}
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageSceneDetailCollectionViewCell.ReuseIdentifier, forIndexPath: indexPath) as! SceneDetailCollectionViewCell
        let experience = NextGenDataManager.sharedInstance.mainExperience.syncedExperience.childExperiences[indexPath.row]
        cell.experience = experience
        if cell.timedEvent == nil || (cell.timedEvent!.isProduct(kTheTakeIdentifierNamespace) && cell.theTakeProducts == nil) {
            updateCollectionViewCell(cell)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SceneDetailCollectionViewCell, experience = cell.experience {
            if cell.theTakeProducts != nil {
                self.performSegueWithIdentifier(kSceneDetailSegueShowShop, sender: cell.theTakeProducts)
            } else if let timedEvent = cell.timedEvent {
                if timedEvent.isGallery() {
                    self.performSegueWithIdentifier(kSceneDetailSegueShowGallery, sender: timedEvent.getGallery(experience))
                } else if timedEvent.isAudioVisual() {
                    self.performSegueWithIdentifier(kSceneDetailSegueShowGallery, sender: timedEvent.getAudioVisual(experience))
                }
            }
        }
        
        // showMap
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kSceneDetailSegueShowGallery {
            let galleryDetailViewController = segue.destinationViewController as! GalleryDetailViewController
            
            if let gallery = sender as? NGDMGallery {
                galleryDetailViewController.gallery = gallery
            } else if let audioVisual = sender as? NGDMAudioVisual {
                galleryDetailViewController.audioVisual = audioVisual
            }
        } else if segue.identifier == kSceneDetailSegueShowShop {
            let shopDetailViewController = segue.destinationViewController as! ShoppingDetailViewController
            shopDetailViewController.products = sender as! [TheTakeProduct]
        }
        
        /*if segue.identifier == "showMap"{
        
        let mapVC = segue.destinationViewController as! MapDetailViewController
        
            mapVC.initialLocation = self.initialLocation
            mapVC.locationName = self.locName
            //mapVC.locationImages = (self.currentScene?.locationImages)!
            
    } else if segue.identifier == "showGallery"{
            
            let galleryVC = segue.destinationViewController as! GalleryDetailViewController
            
            galleryVC.galleryID = self.galleryID

        } else if segue.identifier == "showShop"{
            
            let shopVC = segue.destinationViewController as! ShoppingDetailViewController

            //shopVC.items = (self.currentScene?.shopping)!
        }*/

    }
    
    func cellForExperience(experience: NGDMExperience) -> SceneDetailCollectionViewCell? {
        if let visibleCells = collectionView?.visibleCells() {
            for cell in visibleCells {
                if let cell = cell as? SceneDetailCollectionViewCell, cellExperience = cell.experience {
                    if cellExperience == experience {
                        return cell
                    }
                }
            }
        }
        
        return nil
    }
    
    
    // MARK: RFQuiltLayoutDelegate
    func blockSizeForItemAtIndexPath(indexPath: NSIndexPath!) -> CGSize {
        return CGSizeMake(1, 1)
    }
    
    func insetsForItemAtIndexPath(indexPath: NSIndexPath!) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
}
