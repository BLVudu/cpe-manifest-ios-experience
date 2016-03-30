//
//  SceneDetailCollectionViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit

class SceneDetailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate {
    
    struct SegueIdentifier {
        static let ShowGallery = "showGallery"
        static let ShowShop = "showShop"
        static let ShowMap = "showMap"
    }
    
    struct Constants {
        static let ItemsPerRow: CGFloat = 2.0
        static let ItemSpacing: CGFloat = 5.0
        static let UpdateInterval: Double = 15000.0
    }
    
    private var _didChangeTimeObserver: NSObjectProtocol!
    private var _currentTime = -1.0
    private var _currentProductFrameTime = -1.0
    private var _currentProductSessionDataTask: NSURLSessionDataTask?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(_didChangeTimeObserver)
        if let currentTask = _currentProductSessionDataTask {
            currentTask.cancel()
        }
        
        _currentProductSessionDataTask = nil
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.collectionView?.alpha = 0
        self.collectionView?.registerNib(UINib(nibName: String(MapSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: MapSceneDetailCollectionViewCell.ReuseIdentifier)
        self.collectionView?.registerNib(UINib(nibName: String(ImageSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: ImageSceneDetailCollectionViewCell.ReuseIdentifier)
        self.collectionView?.registerNib(UINib(nibName: String(TextSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: TextSceneDetailCollectionViewCell.ReuseIdentifier)
        
        _didChangeTimeObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidChangeTime, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            if let strongSelf = self, userInfo = notification.userInfo, time = userInfo["time"] as? Double {
                strongSelf._currentTime = time
                strongSelf.updateCollectionView()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView?.alpha = 1
        self.collectionViewLayout.invalidateLayout()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.collectionViewLayout.invalidateLayout()
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
        if let experience = cell.experience {
            updateCollectionViewCell(cell, experience: experience, timedEvent: experience.timedEventSequence?.timedEvent(_currentTime))
        }
    }
    
    func updateCollectionViewCell(cell: SceneDetailCollectionViewCell, experience: NGDMExperience, timedEvent: NGDMTimedEvent?) {
        if let timedEvent = timedEvent {
            if cell.timedEvent == nil || timedEvent != cell.timedEvent {
                cell.timedEvent = timedEvent
            }
            
            if timedEvent.isProduct(kTheTakeIdentifierNamespace) {
                if let cell = cell as? ImageSceneDetailCollectionViewCell {
                    let newFrameTime = TheTakeAPIUtil.sharedInstance.closestFrameTime(_currentTime)
                    if _currentProductFrameTime < 0 || newFrameTime - _currentProductFrameTime >= Constants.UpdateInterval {
                        _currentProductFrameTime = newFrameTime
                        
                        if let currentTask = _currentProductSessionDataTask {
                            currentTask.cancel()
                        }
                        
                        _currentProductSessionDataTask = TheTakeAPIUtil.sharedInstance.getFrameProducts(_currentProductFrameTime, successBlock: { [weak self] (products) -> Void in
                            dispatch_async(dispatch_get_main_queue(), {
                                if products.count > 0 {
                                    cell.theTakeProducts = products
                                }
                            })
                            
                            if let strongSelf = self {
                                strongSelf._currentProductSessionDataTask = nil
                            }
                        })
                    }
                }
            } else if (timedEvent.isTextItem() && ((timedEvent.hasImage(experience) && cell.reuseIdentifier != ImageSceneDetailCollectionViewCell.ReuseIdentifier) || (!timedEvent.hasImage(experience) && cell.reuseIdentifier != TextSceneDetailCollectionViewCell.ReuseIdentifier))) ||
                        (timedEvent.isLocation() && cell.reuseIdentifier != MapSceneDetailCollectionViewCell.ReuseIdentifier) {
                if let indexPath = self.collectionView?.indexPathForCell(cell) {
                    self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                }
            }
        } else {
            cell.timedEvent = nil
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NextGenDataManager.sharedInstance.mainExperience.syncedExperience.childExperiences.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let experience = NextGenDataManager.sharedInstance.mainExperience.syncedExperience.childExperiences[indexPath.row]
        let timedEvent = experience.timedEventSequence?.timedEvent(_currentTime)
        var reuseIdentifier = ImageSceneDetailCollectionViewCell.ReuseIdentifier
        if let timedEvent = timedEvent {
            if timedEvent.isTextItem() {
                reuseIdentifier = TextSceneDetailCollectionViewCell.ReuseIdentifier
            } else if timedEvent.isLocation() {
                reuseIdentifier = MapSceneDetailCollectionViewCell.ReuseIdentifier
            }
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SceneDetailCollectionViewCell
        cell.experience = experience
        updateCollectionViewCell(cell, experience: experience, timedEvent: timedEvent)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((CGRectGetWidth(collectionView.frame) / Constants.ItemsPerRow) - (Constants.ItemSpacing / Constants.ItemsPerRow), 250)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.ItemSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.ItemSpacing
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SceneDetailCollectionViewCell, experience = cell.experience, timedEvent = cell.timedEvent {
            if timedEvent.isProduct() {
                if let cell = cell as? ImageSceneDetailCollectionViewCell {
                    if cell.theTakeProducts != nil {
                        self.performSegueWithIdentifier(SegueIdentifier.ShowShop, sender: cell.theTakeProducts)
                    }
                }
            } else if timedEvent.isGallery() {
                if let galleryViewController = UIStoryboard.getMainStoryboardViewController(ExtrasImageGalleryViewController) as? ExtrasImageGalleryViewController, gallery = timedEvent.getGallery(experience) {
                    galleryViewController.gallery = gallery
                    galleryViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
                    galleryViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                    galleryViewController.transitioningDelegate = self
                    self.presentViewController(galleryViewController, animated: true, completion: nil)
                }
            } else if timedEvent.isAudioVisual() {
                self.performSegueWithIdentifier(SegueIdentifier.ShowGallery, sender: timedEvent.getAudioVisual(experience))
            } else if timedEvent.isAppGroup() {
                if let experienceApp = timedEvent.getExperienceApp(experience), appGroup = timedEvent.appGroup, url = appGroup.url {
                    let webViewController = WebViewController(title: experienceApp.title, url: url)
                    let navigationController = UINavigationController(rootViewController: webViewController)
                    self.presentViewController(navigationController, animated: true, completion: nil)
                }
            } else if timedEvent.isLocation() {
                self.performSegueWithIdentifier(SegueIdentifier.ShowMap, sender: timedEvent)
            }
        }
    }
    
    // MARK: Storyboard Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.ShowGallery {
            let galleryDetailViewController = segue.destinationViewController as! GalleryDetailViewController
            
            if let gallery = sender as? NGDMGallery {
                galleryDetailViewController.gallery = gallery
            } else if let audioVisual = sender as? NGDMAudioVisual {
                galleryDetailViewController.audioVisual = audioVisual
            }
        } else if segue.identifier == SegueIdentifier.ShowShop {
            let shopDetailViewController = segue.destinationViewController as! ShoppingDetailViewController
            shopDetailViewController.products = sender as! [TheTakeProduct]
            shopDetailViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
            shopDetailViewController.transitioningDelegate = self
        } else if segue.identifier == SegueIdentifier.ShowMap {
            let mapDetailViewController = segue.destinationViewController as! MapDetailViewController
            mapDetailViewController.timedEvent = sender as! NGDMTimedEvent
        }
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
    
    // MARK: UIViewControllerTransitioningDelegate
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return InteriorExperiencePresentationController(presentedViewController: presented, presentingViewController: presentingViewController!)
    }
    
}
