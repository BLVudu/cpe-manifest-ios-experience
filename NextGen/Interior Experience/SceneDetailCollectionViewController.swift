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
        var timedEvent: NGDMTimedEvent?
        
        init(experience: NGDMExperience) {
            self.experience = experience
        }
    }
    
    private var _didChangeTimeObserver: NSObjectProtocol!
    private var _currentTime = -1.0
    private var _currentProductFrameTime = -1.0
    private var _currentProductSessionDataTask: NSURLSessionDataTask?
    
    private var _experienceCellData = [ExperienceCellData]()
    var activeExperienceCellData: [ExperienceCellData] {
        get {
            return _experienceCellData.filter({ (cellData) -> Bool in
                cellData.timedEvent != nil
            })
        }
    }
    
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
        
        for experience in NextGenDataManager.sharedInstance.mainExperience.syncedExperience.childExperiences {
            _experienceCellData.append(ExperienceCellData(experience: experience))
        }
        
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
    
    func rowForExperience(experience: NGDMExperience) -> Int? {
        return activeExperienceCellData.indexOf({ (cellData) -> Bool in
            cellData.experience == experience
        })
    }
    
    func processExperiencesForTime(time: Double) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var deleteIndexPaths = [NSIndexPath]()
            var insertIndexPaths = [NSIndexPath]()
            var updateIndexPaths = [NSIndexPath]()
            
            var currentRow = 0
            for i in 0 ..< self._experienceCellData.count {
                var cellData = self._experienceCellData[i]
                let experienceRow = self.rowForExperience(cellData.experience)
                let oldTimedEvent = cellData.timedEvent
                let newTimedEvent = cellData.experience.timedEventSequence?.timedEvent(time)
                if newTimedEvent != nil {
                    if newTimedEvent != oldTimedEvent {
                        if experienceRow != nil {
                            updateIndexPaths.append(NSIndexPath(forRow: experienceRow!, inSection: 0))
                        } else {
                            insertIndexPaths.append(NSIndexPath(forRow: currentRow, inSection: 0))
                        }
                    } else if newTimedEvent!.isProduct() {
                        updateIndexPaths.append(NSIndexPath(forRow: experienceRow!, inSection: 0))
                    }
                    
                    cellData.timedEvent = newTimedEvent
                    currentRow += 1
                } else if experienceRow != nil {
                    cellData.timedEvent = nil
                    deleteIndexPaths.append(NSIndexPath(forRow: experienceRow!, inSection: 0))
                }
                
                self._experienceCellData[i] = cellData
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                for indexPath in updateIndexPaths {
                    if let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as? SceneDetailCollectionViewCell {
                        cell.timedEvent = self.activeExperienceCellData[indexPath.row].timedEvent
                        cell.currentTime = time
                    }
                }
                
                self.collectionView?.performBatchUpdates({
                    if deleteIndexPaths.count > 0 {
                        self.collectionView?.deleteItemsAtIndexPaths(deleteIndexPaths)
                    }
                    
                    if insertIndexPaths.count > 0 {
                        self.collectionView?.insertItemsAtIndexPaths(insertIndexPaths)
                    }
                }, completion: nil)
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activeExperienceCellData.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellData = activeExperienceCellData[indexPath.row]
        let timedEvent = cellData.timedEvent!
        
        var reuseIdentifier: String
        if timedEvent.isLocation() {
            reuseIdentifier = MapSceneDetailCollectionViewCell.ReuseIdentifier
        } else if timedEvent.isProduct() {
            reuseIdentifier = ShoppingSceneDetailCollectionViewCell.ReuseIdentifier
        } else {
            reuseIdentifier = ImageSceneDetailCollectionViewCell.ReuseIdentifier
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SceneDetailCollectionViewCell
        cell.experience = cellData.experience
        cell.timedEvent = timedEvent
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
