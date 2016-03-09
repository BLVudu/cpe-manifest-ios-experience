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
    
    let kSceneDetailSegueShowGallery = "kSceneDetailSegueShowGallery"
    
    let regionRadius: CLLocationDistance = 2000
    var initialLocation = CLLocation(latitude: 0, longitude: 0)
    var locName = ""
    var locImg = ""
    var galleryID = 0
    
    var currentTime = 0.0
    var currentTimedEvents = [String: NGDMTimedEvent]() // ExperienceID: TimedEvent
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.collectionView?.registerNib(UINib(nibName: String(MapSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: MapSceneDetailCollectionViewCell.ReuseIdentifier)
        self.collectionView?.registerNib(UINib(nibName: String(ImageSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: ImageSceneDetailCollectionViewCell.ReuseIdentifier)
        
        let layout = self.collectionView?.collectionViewLayout as! RFQuiltLayout
        layout.direction = UICollectionViewScrollDirection.Vertical
        layout.blockPixels = CGSizeMake((CGRectGetWidth(self.collectionView!.bounds) / 8), (CGRectGetWidth(self.collectionView!.bounds)/4))
        
        NSNotificationCenter.defaultCenter().addObserverForName(kVideoPlayerTimeDidChange, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            if let userInfo = notification.userInfo, time = userInfo["time"] as? Double {
                self.currentTime = time
                
                var shouldReloadExperiences = false
                for experience in NextGenDataManager.sharedInstance.mainExperience.syncedExperience.childExperiences {
                    if let timedEvent = experience.timedEventSequence?.timedEvent(self.currentTime) {
                        if self.currentTimedEvents[experience.id] == nil || timedEvent != self.currentTimedEvents[experience.id] {
                            self.currentTimedEvents[experience.id] = timedEvent
                            shouldReloadExperiences = true
                        }
                    } else if self.currentTimedEvents[experience.id] != nil {
                        self.currentTimedEvents.removeValueForKey(experience.id)
                        shouldReloadExperiences = true
                    }
                }
                
                if shouldReloadExperiences {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
   /*
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        let layout = self.collectionView?.collectionViewLayout as! RFQuiltLayout
        layout.direction = UICollectionViewScrollDirection.Vertical
        layout.blockPixels = CGSizeMake((CGRectGetWidth(self.collectionView!.bounds) / 4), 250)
        print(self.collectionView!.bounds)
    }
*/
    
    // MARK: UICollectionViewDataSource
     override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentTimedEvents.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //var reuseIdentifier = ImageSceneDetailCollectionViewCell.ReuseIdentifier
        //if indexPath.row == SceneDetailItemType.Location.rawValue {
        //    reuseIdentifier = MapSceneDetailCollectionViewCell.ReuseIdentifier
        //}
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageSceneDetailCollectionViewCell.ReuseIdentifier, forIndexPath: indexPath) as! SceneDetailCollectionViewCell
        
        let experienceId = Array(currentTimedEvents.keys)[indexPath.row]
        if let experience = NGDMExperience.getById(experienceId), timedEvent = currentTimedEvents[experienceId] {
            cell.experience = experience
            cell.timedEvent = timedEvent
        }
        
        return cell
    }

    
    
     override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SceneDetailCollectionViewCell, experience = cell.experience, timedEvent = cell.timedEvent {
            if timedEvent.isGallery() {
                self.performSegueWithIdentifier(kSceneDetailSegueShowGallery, sender: timedEvent.getGallery(experience))
            }
        }
        
        // showMap
        // showShop
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == kSceneDetailSegueShowGallery {
            let galleryDetailViewController = segue.destinationViewController as! GalleryDetailViewController
            galleryDetailViewController.gallery = sender as? NGDMGallery
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
    
    
    
    // MARK: RFQuiltLayoutDelegate
    func blockSizeForItemAtIndexPath(indexPath: NSIndexPath!) -> CGSize {
        /*
        switch indexPath.row {
        case SceneDetailItemType.Shop.rawValue:
            return CGSizeMake(4, 1)
            
        default:
            return CGSizeMake(2, 1)
        }
*/
        return CGSizeMake(2, 1)
    }
    
    func insetsForItemAtIndexPath(indexPath: NSIndexPath!) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }


}
