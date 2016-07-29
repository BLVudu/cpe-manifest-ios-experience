//
//  ExtrasSceneLocationsViewController.swift
//

import UIKit
import MapKit
import NextGenDataManager

class ExtrasSceneLocationsViewController: ExtrasExperienceViewController, MultiMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private struct Constants {
        static let ItemAspectRatio: CGFloat = 249 / 170
    }
    
    @IBOutlet weak private var mapView: MultiMapView!
    @IBOutlet weak private var breadcrumbsPrimaryButton: UIButton!
    @IBOutlet weak private var breadcrumbsSecondaryArrowImageView: UIImageView!
    @IBOutlet weak private var breadcrumbsSecondaryLabel: UILabel!
    @IBOutlet weak private var collectionView: UICollectionView!
    
    @IBOutlet weak private var locationDetailView: UIView!
    @IBOutlet weak private var videoContainerView: UIView!
    private var videoPlayerViewController: VideoPlayerViewController?
    private var videoPlayerDidEndVideoObserver: NSObjectProtocol?
    
    @IBOutlet weak private var galleryScrollView: ImageGalleryScrollView!
    @IBOutlet weak private var galleryPageControl: UIPageControl!
    @IBOutlet weak private var closeButton: UIButton!
    private var galleryDidToggleFullScreenObserver: NSObjectProtocol?
    private var galleryDidScrollToPageObserver: NSObjectProtocol?
    
    private var locationExperiences = [NGDMExperience]()
    private var markers = [String: MultiMapMarker]() // ExperienceID: MultiMapMarker
    private var selectedExperience: NGDMExperience? {
        didSet {
            if let selectedExperience = selectedExperience {
                if let marker = markers[selectedExperience.id] {
                    if let appData = selectedExperience.appData {
                        mapView.maxZoomLevel = appData.zoomLevel
                        mapView.setLocation(marker.location, zoomLevel: appData.zoomLevel, animated: true)
                    }
                    
                    mapView.selectedMarker = marker
                }
            } else {
                mapView.selectedMarker = nil
                
                var lowestZoomLevel = MAXFLOAT
                for locationExperience in locationExperiences {
                    if let appData = locationExperience.appData where appData.zoomLevel < lowestZoomLevel {
                        lowestZoomLevel = appData.zoomLevel
                    }
                }
                
                mapView.maxZoomLevel = lowestZoomLevel
                mapView.zoomToFitAllMarkers()
                
            }
            
            reloadBreadcrumbs()
            collectionView.reloadData()
            collectionView.contentOffset = CGPointZero
        }
    }
    
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        
        if let observer = videoPlayerDidEndVideoObserver {
            center.removeObserver(observer)
            videoPlayerDidEndVideoObserver = nil
        }
        
        if let observer = galleryDidToggleFullScreenObserver {
            center.removeObserver(observer)
            galleryDidToggleFullScreenObserver = nil
        }
        
        if let observer = galleryDidScrollToPageObserver {
            center.removeObserver(observer)
            galleryDidScrollToPageObserver = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        galleryScrollView.cleanInvisibleImages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let childExperiences = experience.childExperiences {
            locationExperiences = childExperiences
        }
        
        breadcrumbsPrimaryButton.setTitle(experience.title.uppercaseString, forState: .Normal)
        collectionView.registerNib(UINib(nibName: String(MapItemCell), bundle: nil), forCellWithReuseIdentifier: MapItemCell.ReuseIdentifier)
        closeButton.titleLabel?.font = UIFont.themeCondensedFont(17)
        closeButton.setTitle(String.localize("label.close"), forState: UIControlState.Normal)
        closeButton.setImage(UIImage(named: "Close"), forState: UIControlState.Normal)
        closeButton.contentEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0)
        closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25)
        closeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 110, 0, 0)
        
        breadcrumbsSecondaryArrowImageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
        videoPlayerDidEndVideoObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidEndVideo, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self {
                strongSelf.closeDetailView(animated: true)
            }
        })
        
        galleryDidToggleFullScreenObserver = NSNotificationCenter.defaultCenter().addObserverForName(ImageGalleryNotification.DidToggleFullScreen, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self, isFullScreen = notification.userInfo?["isFullScreen"] as? Bool {
                strongSelf.closeButton.hidden = isFullScreen
                strongSelf.galleryPageControl.hidden = isFullScreen
            }
        })
        
        galleryDidScrollToPageObserver = NSNotificationCenter.defaultCenter().addObserverForName(ImageGalleryNotification.DidScrollToPage, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self, page = notification.userInfo?["page"] as? Int {
                strongSelf.galleryPageControl.currentPage = page
            }
        })
        
        // Set up map markers
        for locationExperience in locationExperiences {
            if let location = locationExperience.appData?.location {
                markers[locationExperience.id] = mapView.addMarker(CLLocationCoordinate2DMake(location.latitude, location.longitude), title: location.name, subtitle: location.address, icon: location.iconImage, autoSelect: false)
            }
        }
        
        mapView.addControls()
        mapView.delegate = self
        
        selectedExperience = nil
    }
    
    func playVideo(videoURL: NSURL) {
        let shouldAnimateOpen = locationDetailView.hidden
        closeDetailView(animated: false)
        
        if let videoPlayerViewController = UIStoryboard.getNextGenViewController(VideoPlayerViewController) as? VideoPlayerViewController {
            videoPlayerViewController.mode = VideoPlayerMode.Supplemental
            
            videoPlayerViewController.view.frame = videoContainerView.bounds
            videoContainerView.addSubview(videoPlayerViewController.view)
            self.addChildViewController(videoPlayerViewController)
            videoPlayerViewController.didMoveToParentViewController(self)
            
            self.videoPlayerViewController = videoPlayerViewController
            
            locationDetailView.alpha = 0
            locationDetailView.hidden = false
            
            if shouldAnimateOpen {
                UIView.animateWithDuration(0.25, animations: {
                    self.locationDetailView.alpha = 1
                }, completion: { (_) in
                    self.videoPlayerViewController?.playVideoWithURL(videoURL)
                })
            } else {
                locationDetailView.alpha = 1
                self.videoPlayerViewController?.playVideoWithURL(videoURL)
            }
        }
    }
    
    func showGallery(gallery: NGDMGallery) {
        let shouldAnimateOpen = locationDetailView.hidden
        closeDetailView(animated: false)
        
        galleryScrollView.loadGallery(gallery)
        galleryScrollView.hidden = false
        
        if gallery.isTurntable {
            galleryPageControl.hidden = true
        } else {
            galleryPageControl.hidden = false
            galleryPageControl.numberOfPages = gallery.totalCount
            galleryPageControl.currentPage = 0
        }
        
        locationDetailView.alpha = 0
        locationDetailView.hidden = false
        
        if shouldAnimateOpen {
            UIView.animateWithDuration(0.25, animations: {
                self.locationDetailView.alpha = 1
            })
        } else {
            locationDetailView.alpha = 1
        }
    }
    
    @IBAction func closeDetailView() {
        closeDetailView(animated: true)
    }
    
    private func closeDetailView(animated animated: Bool) {
        let hideViews = {
            self.locationDetailView.hidden = true
            
            self.galleryScrollView.destroyGallery()
            self.galleryScrollView.hidden = true
            self.galleryPageControl.hidden = true
            
            self.videoPlayerViewController?.willMoveToParentViewController(nil)
            self.videoPlayerViewController?.view.removeFromSuperview()
            self.videoPlayerViewController?.removeFromParentViewController()
            self.videoPlayerViewController = nil
        }
        
        if animated {
            UIView.animateWithDuration(0.2, animations: { 
                self.locationDetailView.alpha = 0
            }, completion: { (_) in
                hideViews()
            })
        } else {
            hideViews()
        }
    }
    
    func reloadBreadcrumbs() {
        breadcrumbsPrimaryButton.userInteractionEnabled = false
        breadcrumbsSecondaryArrowImageView.hidden = true
        breadcrumbsSecondaryLabel.hidden = true
        
        if let selectedExperience = selectedExperience {
            breadcrumbsSecondaryLabel.text = selectedExperience.title.uppercaseString
            breadcrumbsSecondaryLabel.sizeToFit()
            breadcrumbsSecondaryLabel.frame.size.height = CGRectGetHeight(breadcrumbsPrimaryButton.frame)
            breadcrumbsSecondaryArrowImageView.hidden = false
            breadcrumbsSecondaryLabel.hidden = false
            breadcrumbsPrimaryButton.userInteractionEnabled = true
        }
    }
    
    // MARK: Actions
    override func close() {
        mapView.destroy()
        mapView = nil
        
        super.close()
    }
    
    @IBAction func onTapBreadcrumb(sender: UIButton) {
        closeDetailView(animated: false)
        selectedExperience = nil
    }
    
    @IBAction func onPageControlValueChanged() {
        galleryScrollView.gotoPage(galleryPageControl.currentPage, animated: true)
    }
    
    // MARK: MultiMapViewDelegate
    func mapView(mapView: MultiMapView, didTapMarker marker: MultiMapMarker) {
        for (experienceId, locationMarker) in markers {
            if marker == locationMarker {
                selectedExperience = NGDMExperience.getById(experienceId)
                return
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let selectedExperience = selectedExperience {
            return selectedExperience.appDataMediaCount ?? 0
        }
        
        return locationExperiences.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MapItemCell.ReuseIdentifier, forIndexPath: indexPath) as! MapItemCell
        cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        if let selectedExperience = selectedExperience {
            if let experience = selectedExperience.appDataMediaAtIndex(indexPath.row) {
                cell.playButtonVisible = experience.isType(.AudioVisual)
                cell.imageURL = experience.imageURL
                cell.title = experience.title
            }
        } else {
            let experience = locationExperiences[indexPath.row]
            cell.playButtonVisible = false
            cell.imageURL = experience.imageURL
            cell.title = experience.title
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let selectedExperience = selectedExperience {
            if let experience = selectedExperience.appDataMediaAtIndex(indexPath.row) {
                if let videoURL = experience.videoURL {
                    playVideo(videoURL)
                } else if let gallery = experience.gallery {
                    showGallery(gallery)
                }
            }
        } else {
            selectedExperience = locationExperiences[indexPath.row]
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemHeight = CGRectGetHeight(collectionView.frame)
        return CGSizeMake(itemHeight * Constants.ItemAspectRatio, itemHeight)
    }
    
}