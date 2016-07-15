//
//  ExtrasSceneLocationsViewController.swift
//

import UIKit
import MapKit
import NextGenDataManager

class ExtrasSceneLocationsViewController: ExtrasExperienceViewController, MultiMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private struct SceneLocation {
        var title: String!
        var childSceneLocations = [ChildSceneLocation]()
        
        init(title: String) {
            self.title = title
        }
    }
    
    private struct ChildSceneLocation {
        var subtitle: String!
        var childAppData = [NGDMAppData]()
        var mapMarker: MultiMapMarker?
        
        init(subtitle: String) {
            self.subtitle = subtitle
        }
        
        mutating func addAppData(appData: NGDMAppData) {
            childAppData.append(appData)
        }
    }
    
    @IBOutlet weak private var mapView: MultiMapView!
    @IBOutlet weak private var breadcrumbsPrimaryButton: UIButton!
    @IBOutlet weak private var breadcrumbsSecondaryArrowImageView: UIImageView!
    @IBOutlet weak private var breadcrumbsSecondaryButton: UIButton!
    @IBOutlet weak private var breadcrumbsTertiaryArrowImageView: UIImageView!
    @IBOutlet weak private var breadcrumbsTertiaryLabel: UILabel!
    @IBOutlet weak private var collectionView: UICollectionView!
    
    @IBOutlet weak private var locationDetailView: UIView!
    @IBOutlet weak private var videoContainerView: UIView!
    private var videoPlayerViewController: VideoPlayerViewController?
    
    @IBOutlet weak private var galleryScrollView: ImageGalleryScrollView!
    @IBOutlet weak private var galleryPageControl: UIPageControl!
    @IBOutlet weak private var closeButton: UIButton!
    private var galleryDidToggleFullScreenObserver: NSObjectProtocol?
    private var galleryDidScrollToPage: NSObjectProtocol?
    
    private var markers = [String: MultiMapMarker]() // ExperienceID: MultiMapMarker
    private var sceneLocations = [SceneLocation]()
    private var selectedSceneLocation: SceneLocation? {
        didSet {
            if let selectedSceneLocation = selectedSceneLocation {
                zoomToFitSceneLocationMarkers(selectedSceneLocation)
            }
            
            reloadBreadcrumbs()
        }
    }
    
    private var selectedChildSceneLocation: ChildSceneLocation? {
        didSet {
            if let marker = selectedChildSceneLocation?.mapMarker {
                if let appData = selectedChildSceneLocation?.childAppData.first {
                    mapView.setLocation(marker.location, zoomLevel: appData.zoomLevel, animated: true)
                }
                
                mapView.selectedMarker = marker
            }
            
            reloadBreadcrumbs()
        }
    }
    
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        
        if let observer = galleryDidToggleFullScreenObserver {
            center.removeObserver(observer)
        }
        
        if let observer = galleryDidScrollToPage {
            center.removeObserver(observer)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        galleryScrollView.cleanInvisibleImages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        breadcrumbsPrimaryButton.setTitle(experience.title.uppercaseString, forState: .Normal)
        collectionView.registerNib(UINib(nibName: String(MapItemCell), bundle: nil), forCellWithReuseIdentifier: MapItemCell.ReuseIdentifier)
        closeButton.titleLabel?.font = UIFont.themeCondensedFont(17)
        closeButton.setTitle(String.localize("label.close"), forState: UIControlState.Normal)
        closeButton.setImage(UIImage(named: "Close"), forState: UIControlState.Normal)
        closeButton.contentEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0)
        closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25)
        closeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 110, 0, 0)
        
        breadcrumbsSecondaryArrowImageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        breadcrumbsTertiaryArrowImageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
        galleryDidToggleFullScreenObserver = NSNotificationCenter.defaultCenter().addObserverForName(ImageGalleryNotification.DidToggleFullScreen, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self, isFullScreen = notification.userInfo?["isFullScreen"] as? Bool {
                strongSelf.closeButton.hidden = isFullScreen
                strongSelf.galleryPageControl.hidden = isFullScreen
            }
        })
        
        galleryDidScrollToPage = NSNotificationCenter.defaultCenter().addObserverForName(ImageGalleryNotification.DidScrollToPage, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self, page = notification.userInfo?["page"] as? Int {
                strongSelf.galleryPageControl.currentPage = page
            }
        })
        
        if let experiences = experience.childExperiences {
            for experience in experiences {
                if let appData = experience.appData, title = appData.title, subtitle = appData.subtitle {
                    // Set up data structures to power the full view
                    addAppDataToChildSceneLocation(appData, title: title, subtitle: subtitle)
                }
            }
        }
        
        // Set up map markers
        for i in 0 ..< sceneLocations.count {
            for j in 0 ..< sceneLocations[i].childSceneLocations.count {
                if let location = sceneLocations[i].childSceneLocations[j].childAppData.first?.location {
                    let marker = mapView.addMarker(CLLocationCoordinate2DMake(location.latitude, location.longitude),
                                                   title: location.name,
                                                   subtitle: location.address,
                                                   icon: UIImage(named: "MOSMapPin"),
                                                   autoSelect: false)
                    
                    marker.dataObject = ["sceneLocationIndex": i, "childSceneLocationIndex": j]
                    sceneLocations[i].childSceneLocations[j].mapMarker = marker
                }
            }
        }
        
        mapView.addControls()
        mapView.zoomToFitAllMarkers()
        mapView.delegate = self
    }
    
    private func addAppDataToChildSceneLocation(appData: NGDMAppData, title: String, subtitle: String) {
        for i in 0 ..< sceneLocations.count {
            if sceneLocations[i].title == title {
                for j in 0 ..< sceneLocations[i].childSceneLocations.count {
                    if sceneLocations[i].childSceneLocations[j].subtitle == subtitle {
                        sceneLocations[i].childSceneLocations[j].addAppData(appData)
                        return
                    }
                }
                
                var childSceneLocation = ChildSceneLocation(subtitle: subtitle)
                childSceneLocation.addAppData(appData)
                sceneLocations[i].childSceneLocations.append(childSceneLocation)
                return
            }
        }
        
        let sceneLocation = SceneLocation(title: title)
        sceneLocations.append(sceneLocation)
        addAppDataToChildSceneLocation(appData, title: title, subtitle: subtitle)
    }
    
    func playVideo(videoURL: NSURL) {
        closeDetailView()
        
        if let videoPlayerViewController = UIStoryboard.getNextGenViewController(VideoPlayerViewController) as? VideoPlayerViewController {
            videoPlayerViewController.mode = VideoPlayerMode.Supplemental
            
            videoPlayerViewController.view.frame = videoContainerView.bounds
            videoContainerView.addSubview(videoPlayerViewController.view)
            self.addChildViewController(videoPlayerViewController)
            videoPlayerViewController.didMoveToParentViewController(self)
            
            videoPlayerViewController.playVideoWithURL(videoURL)
            
            locationDetailView.hidden = false
            self.videoPlayerViewController = videoPlayerViewController
        }
    }
    
    func showGallery(gallery: NGDMGallery) {
        closeDetailView()
        
        galleryScrollView.loadGallery(gallery)
        galleryScrollView.hidden = false
        
        if gallery.isSubType(.Turntable) {
            galleryPageControl.hidden = true
        } else {
            galleryPageControl.hidden = false
            galleryPageControl.numberOfPages = galleryScrollView.imageURLs.count
            galleryPageControl.currentPage = 0
        }
        
        locationDetailView.hidden = false
    }
    
    @IBAction func closeDetailView() {
        locationDetailView.hidden = true
        
        galleryScrollView.destroyGallery()
        galleryScrollView.hidden = true
        galleryPageControl.hidden = true
        
        videoPlayerViewController?.willMoveToParentViewController(nil)
        videoPlayerViewController?.view.removeFromSuperview()
        videoPlayerViewController?.removeFromParentViewController()
        videoPlayerViewController = nil
    }
    
    func reloadBreadcrumbs() {
        breadcrumbsPrimaryButton.userInteractionEnabled = false
        breadcrumbsSecondaryArrowImageView.hidden = true
        breadcrumbsSecondaryButton.hidden = true
        breadcrumbsSecondaryButton.userInteractionEnabled = true
        breadcrumbsTertiaryArrowImageView.hidden = true
        breadcrumbsTertiaryLabel.hidden = true
        
        if let sceneLocation = selectedSceneLocation {
            breadcrumbsSecondaryButton.setTitle(sceneLocation.title.uppercaseString, forState: .Normal)
            breadcrumbsSecondaryButton.setTitleColor(selectedChildSceneLocation != nil ? UIColor.whiteColor() : UIColor.themePrimaryColor(), forState: .Normal)
            breadcrumbsSecondaryButton.sizeToFit()
            breadcrumbsSecondaryButton.frame.size.height = CGRectGetHeight(breadcrumbsPrimaryButton.frame)
            breadcrumbsSecondaryArrowImageView.hidden = false
            breadcrumbsSecondaryButton.hidden = false
            
            if let childSceneLocation = selectedChildSceneLocation {
                if sceneLocation.title != childSceneLocation.subtitle {
                    breadcrumbsTertiaryLabel.text = childSceneLocation.subtitle.uppercaseString
                    breadcrumbsTertiaryLabel.sizeToFit()
                    breadcrumbsTertiaryLabel.frame.size.height = CGRectGetHeight(breadcrumbsPrimaryButton.frame)
                    breadcrumbsTertiaryArrowImageView.hidden = false
                    breadcrumbsTertiaryLabel.hidden = false
                } else {
                    breadcrumbsSecondaryButton.setTitleColor(UIColor.themePrimaryColor(), forState: .Normal)
                    breadcrumbsSecondaryButton.userInteractionEnabled = false
                }
            }
            
            breadcrumbsPrimaryButton.userInteractionEnabled = true
        }
    }
    
    private func zoomToFitSceneLocationMarkers(sceneLocation: SceneLocation) {
        var markers = [MultiMapMarker]()
        var zoomLevel: Float = 21
        for childSceneLocation in sceneLocation.childSceneLocations {
            if let marker = childSceneLocation.mapMarker {
                markers.append(marker)
            }
            
            if let appData = childSceneLocation.childAppData.first where appData.zoomLevel < zoomLevel {
                zoomLevel = appData.zoomLevel
            }
        }
        
        if markers.count > 1 {
            mapView.zoomToFitMarkers(markers)
        } else if let marker = markers.first {
            mapView.setLocation(marker.location, zoomLevel: zoomLevel, animated: true)
            mapView.selectedMarker = marker
        }
    }
    
    // MARK: Actions
    override func close() {
        mapView.destroy()
        mapView = nil
        
        super.close()
    }
    
    @IBAction func onTapBreadcrumb(sender: UIButton) {
        closeDetailView()
        selectedChildSceneLocation = nil
        mapView.selectedMarker = nil
        
        if sender == breadcrumbsPrimaryButton {
            selectedSceneLocation = nil
            mapView.zoomToFitAllMarkers()
        } else if let sceneLocation = selectedSceneLocation {
            zoomToFitSceneLocationMarkers(sceneLocation)
        }
        
        collectionView.reloadData()
    }
    
    // MARK: MultiMapViewDelegate
    func mapView(mapView: MultiMapView, didTapMarker marker: MultiMapMarker) {
        if let dataDictionary = marker.dataObject as? [String: Int], sceneLocationIndex = dataDictionary["sceneLocationIndex"], childSceneLocationIndex = dataDictionary["childSceneLocationIndex"] {
            if sceneLocations.count > sceneLocationIndex && sceneLocations[sceneLocationIndex].childSceneLocations.count > childSceneLocationIndex {
                selectedSceneLocation = sceneLocations[sceneLocationIndex]
                selectedChildSceneLocation = selectedSceneLocation!.childSceneLocations[childSceneLocationIndex]
                collectionView.reloadData()
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let selectedChildSceneLocation = selectedChildSceneLocation {
            return selectedChildSceneLocation.childAppData.count
        }
        
        if let selectedSceneLocation = selectedSceneLocation {
            return selectedSceneLocation.childSceneLocations.count
        }
        
        return sceneLocations.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MapItemCell.ReuseIdentifier, forIndexPath: indexPath) as! MapItemCell
        cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        if let appData = selectedChildSceneLocation?.childAppData[indexPath.row] {
            cell.playButtonVisible = appData.hasVideo
            cell.imageURL = appData.getImageURL(.MediaThumbnail)
            cell.title = appData.displayText
            cell.subtitle = nil
        } else if let appData = selectedSceneLocation?.childSceneLocations[indexPath.row].childAppData.first {
            cell.playButtonVisible = false
            cell.imageURL = appData.getImageURL(.Location)
            cell.title = appData.location?.name
            cell.subtitle = nil
        } else if let appData = sceneLocations[indexPath.row].childSceneLocations.first?.childAppData.first {
            cell.playButtonVisible = false
            cell.imageURL = appData.getImageURL(.Location)
            cell.title = appData.title
            cell.subtitle = String.localizePlural("locations.count.one", pluralKey: "locations.count.other", count: sceneLocations[indexPath.row].childSceneLocations.count)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let appData = selectedChildSceneLocation?.childAppData[indexPath.row] {
            if let videoURL = appData.videoURL {
                playVideo(videoURL)
            } else if let gallery = appData.gallery {
                showGallery(gallery)
            }
        } else if let selectedChildSceneLocation = selectedSceneLocation?.childSceneLocations[indexPath.row] {
            self.selectedChildSceneLocation = selectedChildSceneLocation
            collectionView.reloadData()
        } else {
            selectedSceneLocation = sceneLocations[indexPath.row]
            if let childSceneLocations = selectedSceneLocation?.childSceneLocations where childSceneLocations.count == 1 {
                selectedChildSceneLocation = childSceneLocations.first
            }
            
            collectionView.reloadData()
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((CGRectGetWidth(collectionView.frame) / 4), CGRectGetHeight(collectionView.frame))
    }
    
}