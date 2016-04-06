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
        static let ItemSpacing: CGFloat = 10.0
    }
    
    struct ExperienceCellData {
        var experience: NGDMExperience!
        var timedEvent: NGDMTimedEvent!
        
        init(experience: NGDMExperience, timedEvent: NGDMTimedEvent) {
            self.experience = experience
            self.timedEvent = timedEvent
        }
    }
    
    private var _didChangeTimeObserver: NSObjectProtocol!
    private var _currentExperienceCellData = [ExperienceCellData]()
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
        self.collectionView?.registerNib(UINib(nibName: String(ShoppingSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: ShoppingSceneDetailCollectionViewCell.ReuseIdentifier)
        
        _didChangeTimeObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidChangeTime, object: nil, queue: nil) { [weak self] (notification) -> Void in
            if let strongSelf = self, userInfo = notification.userInfo, time = userInfo["time"] as? Double {
                strongSelf.processExperiencesForTime(time)
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
    
    func currentIndexPathForExperience(experience: NGDMExperience) -> NSIndexPath? {
        for i in 0 ..< _currentExperienceCellData.count {
            if _currentExperienceCellData[i].experience == experience {
                return NSIndexPath(forItem: i, inSection: 0)
            }
        }
        
        return nil
    }
    
    func currentCellDataForExperience(experience: NGDMExperience) -> ExperienceCellData? {
        for cellData in _currentExperienceCellData {
            if cellData.experience == experience {
                return cellData
            }
        }
        
        return nil
    }
    
    func processExperiencesForTime(time: Double) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var deleteIndexPaths = [NSIndexPath]()
            var insertIndexPaths = [NSIndexPath]()
            var reloadIndexPaths = [NSIndexPath]()
            var moveIndexPaths = [(NSIndexPath, NSIndexPath)]()
            
            let allExperiences = NextGenDataManager.sharedInstance.mainExperience.syncedExperience.childExperiences
            var currentExperienceCellData = [ExperienceCellData]()
            for i in 0 ..< allExperiences.count {
                let experience = allExperiences[i]
                let oldCellData = self.currentCellDataForExperience(experience)
                let oldIndexPath = self.currentIndexPathForExperience(experience)
                
                if let newTimedEvent = experience.timedEventSequence?.timedEvent(time) {
                    currentExperienceCellData.append(ExperienceCellData(experience: experience, timedEvent: newTimedEvent))
                    let newIndexPath = NSIndexPath(forItem: currentExperienceCellData.count - 1, inSection: 0)
                    if oldCellData != nil {
                        if oldIndexPath!.row != newIndexPath.row {
                            moveIndexPaths.append((oldIndexPath!, newIndexPath))
                        } else if oldCellData!.timedEvent != newTimedEvent {
                            reloadIndexPaths.append(oldIndexPath!)
                        } else if newTimedEvent.isProduct() {
                            if let cell = self.collectionView?.cellForItemAtIndexPath(oldIndexPath!) as? ShoppingSceneDetailCollectionViewCell {
                                cell.currentTime = time
                            }
                        }
                    } else {
                        insertIndexPaths.append(newIndexPath)
                    }
                } else if oldIndexPath != nil {
                    deleteIndexPaths.append(oldIndexPath!)
                }
            }
            
            self._currentExperienceCellData = currentExperienceCellData
            
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView?.performBatchUpdates({
                    if deleteIndexPaths.count > 0 {
                        self.collectionView?.deleteItemsAtIndexPaths(deleteIndexPaths)
                    }
                    
                    if insertIndexPaths.count > 0 {
                        self.collectionView?.insertItemsAtIndexPaths(insertIndexPaths)
                    }
                    
                    for indexPaths in moveIndexPaths {
                        self.collectionView?.moveItemAtIndexPath(indexPaths.0, toIndexPath: indexPaths.1)
                    }
                    
                    if reloadIndexPaths.count > 0 {
                        self.collectionView?.reloadItemsAtIndexPaths(reloadIndexPaths)
                    }
                }, completion: nil)
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _currentExperienceCellData.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellData = _currentExperienceCellData[indexPath.row]
        
        var reuseIdentifier: String
        if cellData.timedEvent.isLocation() {
            reuseIdentifier = MapSceneDetailCollectionViewCell.ReuseIdentifier
        } else if cellData.timedEvent.isProduct() {
            reuseIdentifier = ShoppingSceneDetailCollectionViewCell.ReuseIdentifier
        } else {
            reuseIdentifier = ImageSceneDetailCollectionViewCell.ReuseIdentifier
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SceneDetailCollectionViewCell
        cell.experience = cellData.experience
        cell.timedEvent = cellData.timedEvent
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        let isShopping = (cell != nil && cell!.isKindOfClass(ShoppingSceneDetailCollectionViewCell))
        return CGSizeMake((CGRectGetWidth(collectionView.frame) / Constants.ItemsPerRow) - (Constants.ItemSpacing / Constants.ItemsPerRow), (isShopping ? 245 : 225))
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
                self.performSegueWithIdentifier(SegueIdentifier.ShowShop, sender: cell)
            } else if timedEvent.isGallery() {
                if let galleryViewController = UIStoryboard.getMainStoryboardViewController(ExtrasImageGalleryViewController) as? ExtrasImageGalleryViewController, gallery = timedEvent.getGallery(experience) {
                    galleryViewController.gallery = gallery
                    galleryViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
                    galleryViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                    galleryViewController.transitioningDelegate = self
                    self.presentViewController(galleryViewController, animated: true, completion: nil)
                }
            } else if timedEvent.isAudioVisual() {
                self.performSegueWithIdentifier(SegueIdentifier.ShowGallery, sender: cell)
            } else if timedEvent.isAppGroup() {
                if let experienceApp = timedEvent.getExperienceApp(experience), appGroup = timedEvent.appGroup, url = appGroup.url {
                    let webViewController = WebViewController(title: experienceApp.title, url: url)
                    let navigationController = UINavigationController(rootViewController: webViewController)
                    self.presentViewController(navigationController, animated: true, completion: nil)
                }
            } else if timedEvent.isLocation() {
                self.performSegueWithIdentifier(SegueIdentifier.ShowMap, sender: cell)
            }
        }
    }
    
    // MARK: Storyboard Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? SceneDetailCollectionViewCell, experience = cell.experience, timedEvent = cell.timedEvent {
            if segue.identifier == SegueIdentifier.ShowGallery {
                let galleryDetailViewController = segue.destinationViewController as! GalleryDetailViewController
                if timedEvent.isGallery() {
                    galleryDetailViewController.gallery = timedEvent.getGallery(experience)
                } else if timedEvent.isAudioVisual() {
                    galleryDetailViewController.audioVisual = timedEvent.getAudioVisual(experience)
                }
            } else if segue.identifier == SegueIdentifier.ShowShop {
                if let cell = cell as? ShoppingSceneDetailCollectionViewCell, products = cell.theTakeProducts {
                    let shopDetailViewController = segue.destinationViewController as! ShoppingDetailViewController
                    shopDetailViewController.experience = experience
                    shopDetailViewController.products = products
                    shopDetailViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
                    shopDetailViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                    shopDetailViewController.transitioningDelegate = self
                }
            } else if segue.identifier == SegueIdentifier.ShowMap {
                let mapDetailViewController = segue.destinationViewController as! MapDetailViewController
                mapDetailViewController.experience = experience
                mapDetailViewController.timedEvent = timedEvent
                mapDetailViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
                mapDetailViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                mapDetailViewController.transitioningDelegate = self
            }
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
