//
//  ExtrasSceneLocationsViewController.swift
//

import UIKit
import MapKit
import NextGenDataManager

class ExtrasSceneLocationsViewController: ExtrasExperienceViewController, MultiMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private struct Constants {
        static let CollectionViewItemSpacing: CGFloat = (DeviceType.IS_IPAD ? 12 : 5)
        static let CollectionViewLineSpacing: CGFloat = (DeviceType.IS_IPAD ? 12 : 15)
        static let CollectionViewPadding: CGFloat = (DeviceType.IS_IPAD ? 15 : 10)
        static let CollectionViewImageAspectRatio: CGFloat = 16 / 9
        static let CollectionViewLabelHeight: CGFloat = (DeviceType.IS_IPAD ? 35 : 30)
    }
    
    @IBOutlet weak private var mapView: MultiMapView!
    @IBOutlet weak private var breadcrumbsPrimaryButton: UIButton!
    @IBOutlet weak private var breadcrumbsSecondaryArrowImageView: UIImageView!
    @IBOutlet weak private var breadcrumbsSecondaryLabel: UILabel!
    @IBOutlet weak private var collectionView: UICollectionView!
    private var mapTypeDidChangeObserver: NSObjectProtocol?
    
    @IBOutlet weak private var locationDetailView: UIView!
    @IBOutlet weak private var videoContainerView: UIView!
    private var videoPlayerViewController: VideoPlayerViewController?
    private var videoPlayerDidToggleFullScreenObserver: NSObjectProtocol?
    private var videoPlayerDidEndVideoObserver: NSObjectProtocol?
    
    @IBOutlet weak private var galleryScrollView: ImageGalleryScrollView!
    @IBOutlet weak private var galleryPageControl: UIPageControl!
    @IBOutlet weak private var closeButton: UIButton?
    private var galleryDidToggleFullScreenObserver: NSObjectProtocol?
    private var galleryDidScrollToPageObserver: NSObjectProtocol?
    
    @IBOutlet private var containerTopConstraint: NSLayoutConstraint?
    @IBOutlet private var containerBottomConstraint: NSLayoutConstraint?
    @IBOutlet private var containerAspectRatioConstraint: NSLayoutConstraint?
    @IBOutlet private var containerBottomInnerConstraint: NSLayoutConstraint?
    
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
                    if let appData = locationExperience.appData , appData.zoomLevel < lowestZoomLevel {
                        lowestZoomLevel = appData.zoomLevel
                    }
                }
                
                mapView.maxZoomLevel = lowestZoomLevel
                mapView.zoomToFitAllMarkers()
            }
            
            reloadBreadcrumbs()
            collectionView.reloadData()
            collectionView.contentOffset = CGPoint.zero
        }
    }
    
    private var currentGallery: NGDMGallery?
    private var currentVideo: NGDMVideo?
    
    deinit {
        let center = NotificationCenter.default
        
        if let observer = mapTypeDidChangeObserver {
            center.removeObserver(observer)
            mapTypeDidChangeObserver = nil
        }
        
        if let observer = videoPlayerDidToggleFullScreenObserver {
            center.removeObserver(observer)
            videoPlayerDidToggleFullScreenObserver = nil
        }
        
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
        
        breadcrumbsPrimaryButton.setTitle(experience.title.uppercased(), for: .normal)
        collectionView.register(UINib(nibName: "MapItemCell", bundle: nil), forCellWithReuseIdentifier: MapItemCell.ReuseIdentifier)
        closeButton?.titleLabel?.font = UIFont.themeCondensedFont(17)
        closeButton?.setTitle(String.localize("label.close"), for: UIControlState())
        closeButton?.setImage(UIImage(named: "Close"), for: UIControlState())
        closeButton?.contentEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0)
        closeButton?.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25)
        closeButton?.imageEdgeInsets = UIEdgeInsetsMake(0, 110, 0, 0)
        
        breadcrumbsSecondaryArrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        
        mapTypeDidChangeObserver = NotificationCenter.default.addObserver(forName: .locationsMapTypeDidChange, object: nil, queue: OperationQueue.main, using: { (notification) in
            if let mapType = notification.userInfo?[NotificationConstants.mapType] as? MultiMapType {
                NextGenHook.logAnalyticsEvent(.extrasSceneLocationsAction, action: .setMapType, itemName: (mapType == .satellite ? NextGenAnalyticsLabel.satellite : NextGenAnalyticsLabel.road))
            }
        })
        
        videoPlayerDidToggleFullScreenObserver = NotificationCenter.default.addObserver(forName: .videoPlayerDidToggleFullScreen, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            if let isFullScreen = notification.userInfo?[NotificationConstants.isFullScreen] as? Bool, isFullScreen {
                NextGenHook.logAnalyticsEvent(.extrasSceneLocationsAction, action: .setVideoFullScreen, itemId: self?.currentVideo?.id)
            }
        })
        
        videoPlayerDidEndVideoObserver = NotificationCenter.default.addObserver(forName: .videoPlayerDidEndVideo, object: nil, queue: OperationQueue.main, using: { [weak self] (_) in
            self?.closeDetailView(animated: true)
        })
        
        galleryDidToggleFullScreenObserver = NotificationCenter.default.addObserver(forName: .imageGalleryDidToggleFullScreen, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            if let isFullScreen = notification.userInfo?[NotificationConstants.isFullScreen] as? Bool {
                self?.closeButton?.isHidden = isFullScreen
                self?.galleryPageControl.isHidden = isFullScreen
                
                if isFullScreen {
                    NextGenHook.logAnalyticsEvent(.extrasSceneLocationsAction, action: .setImageGalleryFullScreen, itemId: self?.currentGallery?.id)
                }
            }
        })
        
        galleryDidScrollToPageObserver = NotificationCenter.default.addObserver(forName: .imageGalleryDidScrollToPage, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            if let page = notification.userInfo?[NotificationConstants.page] as? Int {
                self?.galleryPageControl.currentPage = page
                NextGenHook.logAnalyticsEvent(.extrasSceneLocationsAction, action: .selectImage, itemId: self?.currentGallery?.id)
            }
        })
        
        galleryScrollView.allowsFullScreen = DeviceType.IS_IPAD
        
        // Set up map markers
        for locationExperience in locationExperiences {
            if let location = locationExperience.appData?.location {
                markers[locationExperience.id] = mapView.addMarker(CLLocationCoordinate2DMake(location.latitude, location.longitude), title: location.name, subtitle: location.address, icon: location.iconImage, autoSelect: false)
            }
        }
        
        mapView.addControls()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.layoutIfNeeded()
        selectedExperience = nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let toLandscape = (size.width > size.height)
        containerAspectRatioConstraint?.isActive = !toLandscape
        containerTopConstraint?.constant = (toLandscape ? 0 : ExtrasExperienceViewController.Constants.TitleImageHeight)
        containerBottomConstraint?.isActive = !toLandscape
        containerBottomInnerConstraint?.isActive = !toLandscape
        
        coordinator.animate(alongsideTransition: nil, completion: { (_) in
            self.galleryScrollView.layoutPages()
        })
        
        if toLandscape {
            if let gallery = currentGallery {
                NextGenHook.logAnalyticsEvent(.extrasSceneLocationsAction, action: .selectImage, itemId: gallery.id)
            } else if let video = currentVideo {
                NextGenHook.logAnalyticsEvent(.extrasSceneLocationsAction, action: .setVideoFullScreen, itemId: video.id)
            }
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if DeviceType.IS_IPAD || (currentGallery == nil && currentVideo == nil) {
            return super.supportedInterfaceOrientations
        }
        
        return .all
    }
    
    func playVideo(_ videoURL: URL) {
        let shouldAnimateOpen = locationDetailView.isHidden
        closeDetailView(animated: false)
        
        if let videoPlayerViewController = UIStoryboard.getNextGenViewController(VideoPlayerViewController.self) as? VideoPlayerViewController {
            videoPlayerViewController.mode = VideoPlayerMode.supplemental
            
            videoPlayerViewController.view.frame = videoContainerView.bounds
            videoContainerView.addSubview(videoPlayerViewController.view)
            self.addChildViewController(videoPlayerViewController)
            videoPlayerViewController.didMove(toParentViewController: self)
            
            if !DeviceType.IS_IPAD && videoPlayerViewController.fullScreenButton != nil {
                videoPlayerViewController.fullScreenButton.removeFromSuperview()
            }
            
            self.videoPlayerViewController = videoPlayerViewController
            
            locationDetailView.alpha = 0
            locationDetailView.isHidden = false
            
            if shouldAnimateOpen {
                UIView.animate(withDuration: 0.25, animations: {
                    self.locationDetailView.alpha = 1
                }, completion: { (_) in
                    self.videoPlayerViewController?.playVideo(with: videoURL)
                })
            } else {
                locationDetailView.alpha = 1
                self.videoPlayerViewController?.playVideo(with: videoURL)
            }
        }
    }
    
    func showGallery(_ gallery: NGDMGallery) {
        let shouldAnimateOpen = locationDetailView.isHidden
        closeDetailView(animated: false)
        
        galleryScrollView.loadGallery(gallery)
        galleryScrollView.isHidden = false
        
        if gallery.isTurntable {
            galleryPageControl.isHidden = true
        } else {
            galleryPageControl.isHidden = false
            galleryPageControl.numberOfPages = gallery.totalCount
            galleryPageControl.currentPage = 0
        }
        
        locationDetailView.alpha = 0
        locationDetailView.isHidden = false
        
        if shouldAnimateOpen {
            UIView.animate(withDuration: 0.25, animations: {
                self.locationDetailView.alpha = 1
            })
        } else {
            locationDetailView.alpha = 1
        }
    }
    
    @IBAction func closeDetailView() {
        closeDetailView(animated: true)
    }
    
    private func closeDetailView(animated: Bool) {
        let hideViews = {
            self.locationDetailView.isHidden = true
            
            self.galleryScrollView.destroyGallery()
            self.galleryScrollView.isHidden = true
            self.galleryPageControl.isHidden = true
            
            self.videoPlayerViewController?.willMove(toParentViewController: nil)
            self.videoPlayerViewController?.view.removeFromSuperview()
            self.videoPlayerViewController?.removeFromParentViewController()
            self.videoPlayerViewController = nil
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: { 
                self.locationDetailView.alpha = 0
            }, completion: { (_) in
                hideViews()
            })
        } else {
            hideViews()
        }
    }
    
    func reloadBreadcrumbs() {
        breadcrumbsPrimaryButton.isUserInteractionEnabled = false
        breadcrumbsSecondaryArrowImageView.isHidden = true
        breadcrumbsSecondaryLabel.isHidden = true
        
        if let selectedExperience = selectedExperience, selectedExperience.appDataMediaCount > 0 {
            breadcrumbsSecondaryLabel.text = selectedExperience.title.uppercased()
            breadcrumbsSecondaryLabel.sizeToFit()
            breadcrumbsSecondaryLabel.frame.size.height = breadcrumbsPrimaryButton.frame.height
            breadcrumbsSecondaryArrowImageView.isHidden = false
            breadcrumbsSecondaryLabel.isHidden = false
            breadcrumbsPrimaryButton.isUserInteractionEnabled = true
        }
    }
    
    // MARK: Actions
    override func close() {
        if !locationDetailView.isHidden && !DeviceType.IS_IPAD {
            closeDetailView()
        } else {
            mapView.destroy()
            mapView = nil
            super.close()
        }
    }
    
    @IBAction func onTapBreadcrumb(_ sender: UIButton) {
        closeDetailView(animated: false)
        selectedExperience = nil
        currentVideo = nil
        currentGallery = nil
    }
    
    @IBAction func onPageControlValueChanged() {
        galleryScrollView.gotoPage(galleryPageControl.currentPage, animated: true)
    }
    
    // MARK: MultiMapViewDelegate
    func mapView(_ mapView: MultiMapView, didTapMarker marker: MultiMapMarker) {
        for (experienceId, locationMarker) in markers {
            if marker == locationMarker {
                selectedExperience = NGDMExperience.getById(experienceId)
                NextGenHook.logAnalyticsEvent(.extrasSceneLocationsAction, action: .selectLocationMarker, itemId: experienceId)
                return
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let selectedExperience = selectedExperience, selectedExperience.appDataMediaCount > 0 {
            return selectedExperience.appDataMediaCount 
        }
        
        return locationExperiences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapItemCell.ReuseIdentifier, for: indexPath) as! MapItemCell
        cell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        if let selectedExperience = selectedExperience, selectedExperience.appDataMediaCount > 0 {
            if let experience = selectedExperience.appDataMediaAtIndex(indexPath.row) {
                cell.playButtonVisible = experience.isType(.audioVisual)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentVideo = nil
        currentGallery = nil
        
        if let selectedExperience = selectedExperience, selectedExperience.appDataMediaCount > 0 {
            if let experience = selectedExperience.appDataMediaAtIndex(indexPath.row) {
                if let video = experience.video, let videoURL = video.url {
                    playVideo(videoURL)
                    currentVideo = video
                    NextGenHook.logAnalyticsEvent(.extrasSceneLocationsAction, action: .selectVideo, itemId: video.id)
                } else if let gallery = experience.gallery {
                    showGallery(gallery)
                    currentGallery = gallery
                    NextGenHook.logAnalyticsEvent(.extrasSceneLocationsAction, action: .selectImageGallery, itemId: gallery.id)
                }
            }
        } else {
            selectedExperience = locationExperiences[indexPath.row]
            NextGenHook.logAnalyticsEvent(.extrasSceneLocationsAction, action: .selectLocationThumbnail, itemId: selectedExperience?.id)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if DeviceType.IS_IPAD {
            let itemHeight = collectionView.frame.height
            return CGSize(width: (itemHeight - Constants.CollectionViewLabelHeight) * Constants.CollectionViewImageAspectRatio, height: itemHeight)
        }
        
        let itemWidth = (collectionView.frame.width - (Constants.CollectionViewPadding * 2) - Constants.CollectionViewItemSpacing) / 2
        return CGSize(width: itemWidth, height: (itemWidth / Constants.CollectionViewImageAspectRatio) + Constants.CollectionViewLabelHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.CollectionViewLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.CollectionViewItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(Constants.CollectionViewPadding, Constants.CollectionViewPadding, Constants.CollectionViewPadding, Constants.CollectionViewPadding)
    }
    
}
