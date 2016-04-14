//
//  SceneDetailCollectionViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit

class SceneDetailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    struct SegueIdentifier {
        static let ShowGallery = "showGallery"
        static let ShowShop = "showShop"
        static let ShowMap = "showMap"
        static let ShowShare = "showShare"
        static let ShowLargeText = "ShowLargeTextSegueIdentifier"
    }
    
    struct Constants {
        static let ItemsPerRow: CGFloat = 2
        static let ItemSpacing: CGFloat = 10
        static let LineSpacing: CGFloat = 10
        static let ItemAspectRatio: CGFloat = 286 / 220
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
    private var _didTapShareObserver: NSObjectProtocol!
    
    private var _currentTime: Double = -1
    private var _currentExperienceCellData = [ExperienceCellData]()
    private var _isProcessingNewExperiences = false
    
    private var _currentClipTimedEvent: NGDMTimedEvent? {
        didSet {
            if _currentClipTimedEvent != oldValue {
                NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.ShouldUpdateShareButton, object: nil, userInfo: ["enabled": _currentClipTimedEvent != nil])
            }
        }
    }
    
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(_didChangeTimeObserver)
        center.removeObserver(_didTapShareObserver)
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
                if time != strongSelf._currentTime && !strongSelf._isProcessingNewExperiences {
                    strongSelf._isProcessingNewExperiences = true
                    strongSelf.processExperiencesForTime(time)
                }
            }
        }
        
        _didTapShareObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidTapShare, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self {
                strongSelf.performSegueWithIdentifier(SegueIdentifier.ShowShare, sender: nil)
            }
        })
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            self._currentTime = time
            
            var deleteIndexPaths = [NSIndexPath]()
            var insertIndexPaths = [NSIndexPath]()
            var reloadIndexPaths = [NSIndexPath]()
            var moveIndexPaths = [(NSIndexPath, NSIndexPath)]()
            
            let allExperiences = NextGenDataManager.sharedInstance.mainExperience.syncedExperience.childExperiences
            var newExperienceCellData = [ExperienceCellData]()
            for i in 0 ..< allExperiences.count {
                let experience = allExperiences[i]
                let timedEvent = experience.timedEventSequence?.timedEvent(self._currentTime)
                
                if experience.isClipAndShare() {
                    self._currentClipTimedEvent = timedEvent
                } else {
                    let oldCellData = self.currentCellDataForExperience(experience)
                    let oldIndexPath = self.currentIndexPathForExperience(experience)
                    
                    if let newTimedEvent = timedEvent {
                        newExperienceCellData.append(ExperienceCellData(experience: experience, timedEvent: newTimedEvent))
                        let newIndexPath = NSIndexPath(forItem: newExperienceCellData.count - 1, inSection: 0)
                        //print("Found \(experience.timedEventSequence!.id)")
                        
                        if oldCellData != nil {
                            if oldIndexPath!.row != newIndexPath.row {
                                moveIndexPaths.append((oldIndexPath!, newIndexPath))
                                //print("Moving \(experience.timedEventSequence!.id)")
                            } else if newTimedEvent.isProduct() || oldCellData!.timedEvent != newTimedEvent {
                                reloadIndexPaths.append(oldIndexPath!)
                                //print("Reloading \(experience.timedEventSequence!.id)")
                            }
                        } else {
                            insertIndexPaths.append(newIndexPath)
                            //print("Inserting \(experience.timedEventSequence!.id)")
                        }
                    } else if oldIndexPath != nil {
                        deleteIndexPaths.append(oldIndexPath!)
                        //print("Deleting \(experience.timedEventSequence!.id)")
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self._currentExperienceCellData = newExperienceCellData
                
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
                    
                    var indexPaths = reloadIndexPaths
                    for i in 0 ..< indexPaths.count {
                        if let cell = self.collectionView?.cellForItemAtIndexPath(indexPaths[i]) as? ShoppingSceneDetailCollectionViewCell, timedEvent = cell.timedEvent {
                            if timedEvent.isProduct() {
                                cell.currentTime = self._currentTime
                                reloadIndexPaths.removeAtIndex(i)
                            }
                        }
                    }
                    
                    if reloadIndexPaths.count > 0 {
                        self.collectionView?.reloadItemsAtIndexPaths(reloadIndexPaths)
                    }
                }, completion: { (completed) in
                    self._isProcessingNewExperiences = false
                })
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
        cell.currentTime = _currentTime
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth: CGFloat = (CGRectGetWidth(collectionView.frame) / Constants.ItemsPerRow) - (Constants.ItemSpacing / Constants.ItemsPerRow)
        return CGSizeMake(itemWidth, itemWidth / Constants.ItemAspectRatio)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.LineSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.ItemSpacing
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //self.performSegueWithIdentifier("showExample", sender: nil)
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SceneDetailCollectionViewCell, experience = cell.experience, timedEvent = cell.timedEvent {
            if timedEvent.isProduct() {
                self.performSegueWithIdentifier(SegueIdentifier.ShowShop, sender: cell)
            } else if timedEvent.isAudioVisual() || timedEvent.isGallery() {
                self.performSegueWithIdentifier(SegueIdentifier.ShowGallery, sender: cell)
            } else if timedEvent.isAppGroup() {
                if let experienceApp = timedEvent.getExperienceApp(experience), appGroup = timedEvent.appGroup, url = appGroup.url {
                    let webViewController = WebViewController(title: experienceApp.title, url: url)
                    let navigationController = UINavigationController(rootViewController: webViewController)
                    self.presentViewController(navigationController, animated: true, completion: nil)
                }
            } else if timedEvent.isLocation() {
                self.performSegueWithIdentifier(SegueIdentifier.ShowMap, sender: cell)
            } else if timedEvent.isTextItem() {
                self.performSegueWithIdentifier(SegueIdentifier.ShowLargeText, sender: cell)
            }
        }
 
    }
    
    // MARK: Storyboard Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.ShowShare {
            let shareDetailViewController = segue.destinationViewController as! SharingViewController
            shareDetailViewController.experience = NextGenDataManager.sharedInstance.mainExperience.syncedExperience.childClipAndShareExperience
            shareDetailViewController.timedEvent = _currentClipTimedEvent!
        } else if let cell = sender as? SceneDetailCollectionViewCell, experience = cell.experience, timedEvent = cell.timedEvent {
            if segue.identifier == SegueIdentifier.ShowGallery {
                let galleryDetailViewController = segue.destinationViewController as! GallerySceneDetailViewController
                galleryDetailViewController.experience = experience
                galleryDetailViewController.timedEvent = timedEvent
            } else if segue.identifier == SegueIdentifier.ShowShop {
                if let cell = cell as? ShoppingSceneDetailCollectionViewCell, products = cell.theTakeProducts {
                    let shopDetailViewController = segue.destinationViewController as! ShoppingDetailViewController
                    shopDetailViewController.experience = experience
                    shopDetailViewController.products = products
                }
            } else if segue.identifier == SegueIdentifier.ShowMap {
                let mapDetailViewController = segue.destinationViewController as! MapDetailViewController
                mapDetailViewController.experience = experience
                mapDetailViewController.timedEvent = timedEvent
            } else if segue.identifier == SegueIdentifier.ShowLargeText {
                let largeTextDetailViewController = segue.destinationViewController as! LargeTextSceneDetailViewController
                largeTextDetailViewController.experience = experience
                largeTextDetailViewController.timedEvent = timedEvent
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
    
}
