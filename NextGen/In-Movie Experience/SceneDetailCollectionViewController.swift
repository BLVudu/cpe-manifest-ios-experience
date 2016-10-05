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
    
    private struct SegueIdentifier {
        static let ShowGallery = "ShowGallerySegueIdentifier"
        static let ShowShopping = "ShowShoppingSegueIdentifier"
        static let ShowMap = "ShowMapSegueIdentifier"
        static let ShowClipShare = "ShowClipShareSegueIdentifier"
        static let ShowLargeText = "ShowLargeTextSegueIdentifier"
    }
    
    private struct Constants {
        static let ItemsPerRow: CGFloat = (DeviceType.IS_IPAD ? 2 : 1)
        static let ItemSpacing: CGFloat = 10
        static let LineSpacing: CGFloat = 10
        static let ItemImageAspectRatio: CGFloat = 16 / 9
        static let ItemTitleHeight: CGFloat = 35
        static let ItemCaptionHeight: CGFloat = 30
    }
    
    private var _didChangeTimeObserver: NSObjectProtocol!
    
    private var _currentTime: Double = -1
    private var _currentTimedEvents = [NGDMTimedEvent]()
    private var _isProcessingTimedEvents = false
    
    deinit {
        let center = NotificationCenter.default
        center.removeObserver(_didChangeTimeObserver)
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.clear
        self.collectionView?.alpha = 0
        self.collectionView?.register(UINib(nibName: "TextSceneDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: TextSceneDetailCollectionViewCell.ReuseIdentifier)
        self.collectionView?.register(UINib(nibName: "ImageSceneDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ImageSceneDetailCollectionViewCell.ReuseIdentifier)
        self.collectionView?.register(UINib(nibName: "ClipShareSceneDetailCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: ImageSceneDetailCollectionViewCell.ClipShareReuseIdentifier)
        self.collectionView?.register(UINib(nibName: "MapSceneDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: MapSceneDetailCollectionViewCell.ReuseIdentifier)
        self.collectionView?.register(UINib(nibName: "ShoppingSceneDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ShoppingSceneDetailCollectionViewCell.ReuseIdentifier)
        
        _didChangeTimeObserver = NotificationCenter.default.addObserver(forName: .videoPlayerDidChangeTime, object: nil, queue: nil) { [weak self] (notification) -> Void in
            if let strongSelf = self, let time = notification.userInfo?[NotificationConstants.time] as? Double {
                if time != strongSelf._currentTime && !strongSelf._isProcessingTimedEvents {
                    strongSelf._isProcessingTimedEvents = true
                    strongSelf.processTimedEvents(time)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView?.alpha = 1
        self.collectionViewLayout.invalidateLayout()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.collectionViewLayout.invalidateLayout()
    }
    
    func processTimedEvents(_ time: Double) {
        DispatchQueue.global(qos: .userInitiated).async {
            self._currentTime = time
            
            var deleteIndexPaths = [IndexPath]()
            var insertIndexPaths = [IndexPath]()
            var reloadIndexPaths = [IndexPath]()
            
            var newTimedEvents = [NGDMTimedEvent]()
            for timedEvent in NGDMTimedEvent.findByTimecode(time, type: .any) {
                if timedEvent.experience == nil || !timedEvent.experience!.isType(.talentData) {
                    let indexPath = IndexPath(item: newTimedEvents.count, section: 0)
                    
                    if newTimedEvents.count < self._currentTimedEvents.count {
                        if self._currentTimedEvents[newTimedEvents.count] != timedEvent {
                            reloadIndexPaths.append(indexPath)
                        } else if timedEvent.isType(.product), let cell = self.collectionView?.cellForItem(at: indexPath) as? ShoppingSceneDetailCollectionViewCell {
                            cell.currentTime = self._currentTime
                        }
                    } else {
                        insertIndexPaths.append(indexPath)
                    }
                    
                    newTimedEvents.append(timedEvent)
                }
            }
            
            if self._currentTimedEvents.count > newTimedEvents.count {
                for i in newTimedEvents.count ..< self._currentTimedEvents.count {
                    deleteIndexPaths.append(IndexPath(item: i, section: 0))
                }
            }
            
            DispatchQueue.main.async {
                self._currentTimedEvents = newTimedEvents
                
                self.collectionView?.performBatchUpdates({
                    if deleteIndexPaths.count > 0 {
                        self.collectionView?.deleteItems(at: deleteIndexPaths)
                    }
                    
                    if insertIndexPaths.count > 0 {
                        self.collectionView?.insertItems(at: insertIndexPaths)
                    }
                    
                    if reloadIndexPaths.count > 0 {
                        self.collectionView?.reloadItems(at: reloadIndexPaths)
                    }
                }, completion: { (completed) in
                    self._isProcessingTimedEvents = false
                })
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _currentTimedEvents.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let timedEvent = _currentTimedEvents[indexPath.row]
        
        var reuseIdentifier: String
        if timedEvent.isType(.location) {
            reuseIdentifier = MapSceneDetailCollectionViewCell.ReuseIdentifier
        } else if timedEvent.isType(.product) {
            reuseIdentifier = ShoppingSceneDetailCollectionViewCell.ReuseIdentifier
        } else if timedEvent.isType(.clipShare) {
            reuseIdentifier = ImageSceneDetailCollectionViewCell.ClipShareReuseIdentifier
        } else if timedEvent.imageURL != nil {
            reuseIdentifier = ImageSceneDetailCollectionViewCell.ReuseIdentifier
        } else {
            reuseIdentifier = TextSceneDetailCollectionViewCell.ReuseIdentifier
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SceneDetailCollectionViewCell
        cell.timedEvent = timedEvent
        cell.currentTime = _currentTime
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth: CGFloat = (collectionView.frame.width / Constants.ItemsPerRow) - (Constants.ItemSpacing / Constants.ItemsPerRow)
        let itemHeight = (itemWidth / Constants.ItemImageAspectRatio) + Constants.ItemTitleHeight + Constants.ItemCaptionHeight
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.LineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.ItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: Constants.LineSpacing, right: 0)
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SceneDetailCollectionViewCell, let timedEvent = cell.timedEvent {
            if timedEvent.isType(.appGroup) {
                if let experienceApp = timedEvent.experienceApp, let url = timedEvent.appGroup?.url {
                    let webViewController = WebViewController(title: experienceApp.title, url: url)
                    let navigationController = LandscapeNavigationController(rootViewController: webViewController)
                    self.present(navigationController, animated: true, completion: nil)
                    NextGenHook.logAnalyticsEvent(.imeExtrasAction, action: .selectApp, itemId: experienceApp.id)
                }
            } else {
                var segueIdentifier: String?
                if timedEvent.isType(.audioVisual) {
                    segueIdentifier = SegueIdentifier.ShowGallery
                    NextGenHook.logAnalyticsEvent(.imeExtrasAction, action: .selectVideo, itemId: timedEvent.id)
                } else if timedEvent.isType(.gallery) {
                    segueIdentifier = SegueIdentifier.ShowGallery
                    NextGenHook.logAnalyticsEvent(.imeExtrasAction, action: .selectImageGallery, itemId: timedEvent.id)
                } else if timedEvent.isType(.clipShare) {
                    segueIdentifier = SegueIdentifier.ShowClipShare
                    NextGenHook.logAnalyticsEvent(.imeExtrasAction, action: .selectClipShare, itemId: timedEvent.id)
                } else if timedEvent.isType(.location) {
                    segueIdentifier = SegueIdentifier.ShowMap
                    NextGenHook.logAnalyticsEvent(.imeExtrasAction, action: .selectLocation, itemId: timedEvent.id)
                } else if timedEvent.isType(.product) {
                    segueIdentifier = SegueIdentifier.ShowShopping
                    NextGenHook.logAnalyticsEvent(.imeExtrasAction, action: .selectShopping, itemId: timedEvent.id)
                } else if timedEvent.isType(.textItem) {
                    segueIdentifier = SegueIdentifier.ShowLargeText
                    NextGenHook.logAnalyticsEvent(.imeExtrasAction, action: .selectTrivia, itemId: timedEvent.id)
                }
                
                if let identifier = segueIdentifier {
                    self.performSegue(withIdentifier: identifier, sender: cell)
                }
            }
        }
 
    }
    
    // MARK: Storyboard Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? SceneDetailCollectionViewCell, let timedEvent = cell.timedEvent, let experience = timedEvent.experience {
            if segue.identifier == SegueIdentifier.ShowShopping {
                if let cell = cell as? ShoppingSceneDetailCollectionViewCell, let products = cell.theTakeProducts {
                    let shopDetailViewController = segue.destination as! ShoppingDetailViewController
                    shopDetailViewController.experience = experience
                    shopDetailViewController.products = products
                }
            } else if let sceneDetailViewController = segue.destination as? SceneDetailViewController {
                sceneDetailViewController.experience = experience
                sceneDetailViewController.timedEvent = timedEvent
            }
        }
    }
    
}
