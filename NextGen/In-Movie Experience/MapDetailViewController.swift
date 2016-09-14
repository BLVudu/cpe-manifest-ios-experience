//
//  MapDetailViewController.swift
//

import UIKit
import MapKit
import NextGenDataManager

class MapDetailViewController: SceneDetailViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak fileprivate var mapView: MultiMapView!
    @IBOutlet fileprivate var mapContainerAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var mediaCollectionView: UICollectionView?
    @IBOutlet weak fileprivate var descriptionLabel: UILabel?
    
    @IBOutlet weak var locationDetailView: UIView!
    @IBOutlet weak var videoContainerView: UIView!
    fileprivate var videoPlayerViewController: VideoPlayerViewController?
    
    @IBOutlet weak var galleryScrollView: ImageGalleryScrollView!
    
    fileprivate var appData: NGDMAppData!
    fileprivate var location: NGDMLocation!
    fileprivate var marker: MultiMapMarker!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        galleryScrollView.cleanInvisibleImages()
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appData = timedEvent!.appData!
        location = appData.location!
        
        if appData.mediaCount > 0 {
            mediaCollectionView?.register(UINib(nibName: "SimpleMapCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SimpleMapCollectionViewCell.ReuseIdentifier)
            mediaCollectionView?.register(UINib(nibName: "SimpleImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SimpleImageCollectionViewCell.BaseReuseIdentifier)
        } else {
            mediaCollectionView?.removeFromSuperview()
            mapContainerAspectRatioConstraint.isActive = false
        }
        
        if let text = appData.description {
            descriptionLabel?.text = text
            descriptionLabel?.isHidden = false
        } else {
            descriptionLabel?.removeFromSuperview()
        }
        
        galleryScrollView.allowsFullScreen = false
        galleryScrollView.removeToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        mapView.setLocation(center, zoomLevel: appData.zoomLevel, animated: false)
        marker = mapView.addMarker(center, title: location.name, subtitle: location.address, icon: location.iconImage, autoSelect: true)
        mapView.addControls()
        mapView.maxZoomLevel = appData.zoomLevel
    }
    
    fileprivate func animateToCenter() {
        let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        mapView.setLocation(center, zoomLevel: appData.zoomLevel, animated: true)
        mapView.selectedMarker = marker
    }
    
    // MARK: Actions
    fileprivate func playVideo(_ videoURL: URL) {
        closeDetailView()
        
        if let videoPlayerViewController = UIStoryboard.getNextGenViewController(VideoPlayerViewController.self) as? VideoPlayerViewController {
            videoPlayerViewController.mode = VideoPlayerMode.supplementalInMovie
            
            videoPlayerViewController.view.frame = videoContainerView.bounds
            videoContainerView.addSubview(videoPlayerViewController.view)
            self.addChildViewController(videoPlayerViewController)
            videoPlayerViewController.didMove(toParentViewController: self)
            
            videoPlayerViewController.playVideo(with: videoURL)
            
            locationDetailView.isHidden = false
            self.videoPlayerViewController = videoPlayerViewController
        }
    }
    
    fileprivate func showGallery(_ gallery: NGDMGallery) {
        closeDetailView()
        
        galleryScrollView.loadGallery(gallery)
        galleryScrollView.isHidden = false
        
        locationDetailView.isHidden = false
    }
    
    fileprivate func closeDetailView() {
        locationDetailView.isHidden = true
        
        galleryScrollView.destroyGallery()
        galleryScrollView.isHidden = true
        
        videoPlayerViewController?.willMove(toParentViewController: nil)
        videoPlayerViewController?.view.removeFromSuperview()
        videoPlayerViewController?.removeFromParentViewController()
        videoPlayerViewController = nil
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appData.mediaCount > 0 ? appData.mediaCount + 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimpleMapCollectionViewCell.ReuseIdentifier, for: indexPath) as! SimpleMapCollectionViewCell
            cell.setLocation(CLLocationCoordinate2DMake(location.latitude, location.longitude), zoomLevel: appData.zoomLevel - 4)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimpleImageCollectionViewCell.BaseReuseIdentifier, for: indexPath) as! SimpleImageCollectionViewCell
        
        if let experience = appData.mediaAtIndex(indexPath.row - 1) {
            cell.playButtonVisible = experience.isType(.audioVisual)
            cell.imageURL = experience.imageURL
        } else {
            cell.playButtonVisible = false
            cell.imageURL = nil
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            closeDetailView()
            animateToCenter()
        } else if let experience = appData.mediaAtIndex(indexPath.row - 1) {
            if let videoURL = experience.videoURL {
                playVideo(videoURL)
            } else if let gallery = experience.gallery {
                showGallery(gallery)
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 4), height: collectionView.frame.height)
    }
    
}
