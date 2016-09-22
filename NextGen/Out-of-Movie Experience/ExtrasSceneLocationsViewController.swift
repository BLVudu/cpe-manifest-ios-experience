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
    
    @IBOutlet weak private var locationDetailView: UIView!
    @IBOutlet weak private var videoContainerView: UIView!
    private var videoPlayerViewController: VideoPlayerViewController?
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
    
    deinit {
        let center = NotificationCenter.default
        
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
        
        videoPlayerDidEndVideoObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: VideoPlayerNotification.DidEndVideo), object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            if let strongSelf = self {
                strongSelf.closeDetailView(animated: true)
            }
        })
        
        galleryDidToggleFullScreenObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ImageGalleryNotification.DidToggleFullScreen), object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            if let strongSelf = self, let isFullScreen = (notification as NSNotification).userInfo?["isFullScreen"] as? Bool {
                strongSelf.closeButton?.isHidden = isFullScreen
                strongSelf.galleryPageControl.isHidden = isFullScreen
            }
        })
        
        galleryDidScrollToPageObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ImageGalleryNotification.DidScrollToPage), object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            if let strongSelf = self, let page = (notification as NSNotification).userInfo?["page"] as? Int {
                strongSelf.galleryPageControl.currentPage = page
            }
        })
        
        galleryScrollView.allowsFullScreen = false
        
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
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if DeviceType.IS_IPAD || (galleryScrollView.isHidden && videoPlayerViewController == nil) {
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
        
        if let selectedExperience = selectedExperience {
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
    }
    
    @IBAction func onPageControlValueChanged() {
        galleryScrollView.gotoPage(galleryPageControl.currentPage, animated: true)
    }
    
    // MARK: MultiMapViewDelegate
    func mapView(_ mapView: MultiMapView, didTapMarker marker: MultiMapMarker) {
        for (experienceId, locationMarker) in markers {
            if marker == locationMarker {
                selectedExperience = NGDMExperience.getById(experienceId)
                return
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let selectedExperience = selectedExperience {
            return selectedExperience.appDataMediaCount 
        }
        
        return locationExperiences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapItemCell.ReuseIdentifier, for: indexPath) as! MapItemCell
        cell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        if let selectedExperience = selectedExperience {
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
