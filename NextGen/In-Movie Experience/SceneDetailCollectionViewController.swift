//
//  SceneDetailCollectionViewController.swift
//

import UIKit
import MapKit
import NextGenDataManager

struct ExperienceCellData {
    var experience: NGDMExperience!
    var timedEvent: NGDMTimedEvent!
    
    init(experience: NGDMExperience, timedEvent: NGDMTimedEvent) {
        self.experience = experience
        self.timedEvent = timedEvent
    }
}

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
    
    private var _didChangeTimeObserver: NSObjectProtocol!
    
    private var _currentTime: Double = -1
    private var _currentTimedEvents = [NGDMTimedEvent]()
    private var _isProcessingTimedEvents = false
    
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(_didChangeTimeObserver)
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.collectionView?.alpha = 0
        self.collectionView?.registerNib(UINib(nibName: String(ImageSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: ImageSceneDetailCollectionViewCell.ReuseIdentifier)
        self.collectionView?.registerNib(UINib(nibName: "ClipShareSceneDetailCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: ImageSceneDetailCollectionViewCell.ClipShareReuseIdentifier)
        self.collectionView?.registerNib(UINib(nibName: String(MapSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: MapSceneDetailCollectionViewCell.ReuseIdentifier)
        self.collectionView?.registerNib(UINib(nibName: String(ShoppingSceneDetailCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: ShoppingSceneDetailCollectionViewCell.ReuseIdentifier)
        
        _didChangeTimeObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidChangeTime, object: nil, queue: nil) { [weak self] (notification) -> Void in
            if let strongSelf = self, userInfo = notification.userInfo, time = userInfo["time"] as? Double {
                if time != strongSelf._currentTime && !strongSelf._isProcessingTimedEvents {
                    strongSelf._isProcessingTimedEvents = true
                    strongSelf.processTimedEvents(time)
                }
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
    
    func processTimedEvents(time: Double) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            self._currentTime = time
            
            var deleteIndexPaths = [NSIndexPath]()
            var insertIndexPaths = [NSIndexPath]()
            var reloadIndexPaths = [NSIndexPath]()
            
            var newTimedEvents = [NGDMTimedEvent]()
            for timedEvent in NGDMTimedEvent.findByTimecode(time, type: .Any) {
                if timedEvent.experience == nil || !timedEvent.experience!.isType(.TalentData) {
                    let indexPath = NSIndexPath(forItem: newTimedEvents.count, inSection: 0)
                    
                    if newTimedEvents.count < self._currentTimedEvents.count {
                        if self._currentTimedEvents[newTimedEvents.count] != timedEvent {
                            reloadIndexPaths.append(indexPath)
                        } else if timedEvent.isType(.Product) {
                            if let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as? ShoppingSceneDetailCollectionViewCell {
                                cell.currentTime = self._currentTime
                            }
                        }
                    } else {
                        insertIndexPaths.append(indexPath)
                    }
                    
                    newTimedEvents.append(timedEvent)
                }
            }
            
            if self._currentTimedEvents.count > newTimedEvents.count {
                for i in newTimedEvents.count ..< self._currentTimedEvents.count {
                    deleteIndexPaths.append(NSIndexPath(forItem: i, inSection: 0))
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self._currentTimedEvents = newTimedEvents
                
                self.collectionView?.performBatchUpdates({
                    if deleteIndexPaths.count > 0 {
                        self.collectionView?.deleteItemsAtIndexPaths(deleteIndexPaths)
                    }
                    
                    if insertIndexPaths.count > 0 {
                        self.collectionView?.insertItemsAtIndexPaths(insertIndexPaths)
                    }
                    
                    if reloadIndexPaths.count > 0 {
                        self.collectionView?.reloadItemsAtIndexPaths(reloadIndexPaths)
                    }
                }, completion: { (completed) in
                    self._isProcessingTimedEvents = false
                })
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _currentTimedEvents.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let timedEvent = _currentTimedEvents[indexPath.row]
        
        var reuseIdentifier: String
        if timedEvent.isType(.Location) {
            reuseIdentifier = MapSceneDetailCollectionViewCell.ReuseIdentifier
        } else if timedEvent.isType(.Product) {
            reuseIdentifier = ShoppingSceneDetailCollectionViewCell.ReuseIdentifier
        } else if timedEvent.isType(.ClipShare) {
            reuseIdentifier = ImageSceneDetailCollectionViewCell.ClipShareReuseIdentifier
        } else {
            reuseIdentifier = ImageSceneDetailCollectionViewCell.ReuseIdentifier
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SceneDetailCollectionViewCell
        cell.timedEvent = timedEvent
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
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SceneDetailCollectionViewCell, timedEvent = cell.timedEvent {
            if timedEvent.isType(.AppGroup) {
                if let experienceApp = timedEvent.experienceApp, url = timedEvent.appGroup?.url {
                    let webViewController = WebViewController(title: experienceApp.title, url: url)
                    let navigationController = LandscapeNavigationController(rootViewController: webViewController)
                    self.presentViewController(navigationController, animated: true, completion: nil)
                }
            } else {
                var segueIdentifier: String?
                if timedEvent.isType(.AudioVisual) || timedEvent.isType(.Gallery) {
                    segueIdentifier = SegueIdentifier.ShowGallery
                } else if timedEvent.isType(.ClipShare) {
                    segueIdentifier = SegueIdentifier.ShowShare
                } else if timedEvent.isType(.Location) {
                    segueIdentifier = SegueIdentifier.ShowMap
                } else if timedEvent.isType(.Product) {
                    segueIdentifier = SegueIdentifier.ShowShop
                } else if timedEvent.isType(.TextItem) {
                    segueIdentifier = SegueIdentifier.ShowLargeText
                }
                
                if let identifier = segueIdentifier {
                    self.performSegueWithIdentifier(identifier, sender: cell)
                }
            }
        }
 
    }
    
    // MARK: Storyboard Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? SceneDetailCollectionViewCell, timedEvent = cell.timedEvent, experience = timedEvent.experience {
            if segue.identifier == SegueIdentifier.ShowShop {
                if let cell = cell as? ShoppingSceneDetailCollectionViewCell, products = cell.theTakeProducts {
                    let shopDetailViewController = segue.destinationViewController as! ShoppingDetailViewController
                    shopDetailViewController.experience = experience
                    shopDetailViewController.products = products
                }
            } else if let sceneDetailViewController = segue.destinationViewController as? SceneDetailViewController {
                sceneDetailViewController.experience = experience
                sceneDetailViewController.timedEvent = timedEvent
            }
        }
    }
    
}
