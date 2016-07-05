//
//  ExtrasSceneLocationsViewController.swift
//

import UIKit
import MapKit
import NextGenDataManager

class ExtrasSceneLocationsViewController: MenuedViewController, MultiMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
    
    @IBOutlet weak var mapView: MultiMapView!
    @IBOutlet weak var collectionViewTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var locationDetailView: UIView!
    @IBOutlet weak var videoContainerView: UIView!
    private var videoPlayerViewController: VideoPlayerViewController?
    
    @IBOutlet weak var galleryScrollView: ImageGalleryScrollView!
    @IBOutlet weak var closeButton: UIButton!
    private var _galleryDidToggleFullScreenObserver: NSObjectProtocol?
    
    private var markers = [String: MultiMapMarker]() // ExperienceID: MultiMapMarker
    private var sceneLocations = [SceneLocation]()
    private var selectedSceneLocation: SceneLocation? {
        didSet {
            if let selectedSceneLocation = selectedSceneLocation {
                var markers = [MultiMapMarker]()
                var zoomLevel: Float = 21
                for childSceneLocation in selectedSceneLocation.childSceneLocations {
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
        }
    }
    
    private var selectedChildSceneLocation: ChildSceneLocation? {
        didSet {
            if let marker = selectedChildSceneLocation?.mapMarker {
                mapView.selectedMarker = marker
                
                if let appData = selectedChildSceneLocation?.childAppData.first {
                    mapView.setLocation(marker.location, zoomLevel: appData.zoomLevel, animated: true)
                }
            }
        }
    }
    
    deinit {
        if let observer = _galleryDidToggleFullScreenObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        galleryScrollView.cleanInvisibleImages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.backgroundColor = UIColor.clearColor()
        collectionViewTitleLabel.text = experience.title.uppercaseString
        collectionView.registerNib(UINib(nibName: String(MapItemCell), bundle: nil), forCellWithReuseIdentifier: MapItemCell.ReuseIdentifier)
        closeButton.titleLabel?.font = UIFont.themeCondensedFont(17)
        closeButton.setTitle(String.localize("label.close"), forState: UIControlState.Normal)
        closeButton.setImage(UIImage(named: "Close"), forState: UIControlState.Normal)
        closeButton.contentEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0)
        closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25)
        closeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 110, 0, 0)
        
        _galleryDidToggleFullScreenObserver = NSNotificationCenter.defaultCenter().addObserverForName(ImageGalleryNotification.DidToggleFullScreen, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self, isFullScreen = notification.userInfo?["isFullScreen"] as? Bool {
                strongSelf.closeButton.hidden = isFullScreen
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
        
        // Set up menu
        let info = NSMutableDictionary()
        info[MenuSection.Keys.Title] = String.localize("locations.full_map")
        
        var rows = [[String: String]]()
        for i in 0 ..< sceneLocations.count {
            rows.append([MenuItem.Keys.Title: sceneLocations[i].title, MenuItem.Keys.Value: String(i)])
            
            // Set up map markers
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
        
        info[MenuSection.Keys.Rows] = rows
        menuSections.append(MenuSection(info: info))
        
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
        
        galleryScrollView.gallery = gallery
        galleryScrollView.hidden = false
        
        locationDetailView.hidden = false
    }
    
    @IBAction func closeDetailView() {
        locationDetailView.hidden = true
        
        galleryScrollView.gallery = nil
        galleryScrollView.hidden = true
        
        videoPlayerViewController?.willMoveToParentViewController(nil)
        videoPlayerViewController?.view.removeFromSuperview()
        videoPlayerViewController?.removeFromParentViewController()
        videoPlayerViewController = nil
    }
    
    // MARK: Actions
    override func close() {
        mapView.destroy()
        mapView = nil
        
        super.close()
    }
    
    // MARK: MultiMapViewDelegate
    func mapView(mapView: MultiMapView, didTapMarker marker: MultiMapMarker) {
        if let dataDictionary = marker.dataObject as? [String: Int], sceneLocationIndex = dataDictionary["sceneLocationIndex"], childSceneLocationIndex = dataDictionary["childSceneLocationIndex"] {
            if sceneLocations.count > sceneLocationIndex && sceneLocations[sceneLocationIndex].childSceneLocations.count > childSceneLocationIndex {
                selectedChildSceneLocation = sceneLocations[sceneLocationIndex].childSceneLocations[childSceneLocationIndex]
                collectionView.reloadData()
            }
        }
    }
   
    // MARK: Overriding MenuedViewController functions
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            cell.backgroundColor = UIColor.init(netHex: 0xba0f0f)
        } else {
            cell.backgroundColor = UIColor.blackColor()
        }
        
        
        tableViewHeight.constant += cell.frame.height
        //tableViewBottomSpace.constant -= cell.frame.height
        tableView.updateConstraints()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(menuTableView, didSelectRowAtIndexPath: indexPath)
        
        if indexPath.row > 0 && sceneLocations.count > indexPath.row - 1 {
            selectedChildSceneLocation = nil
            selectedSceneLocation = sceneLocations[indexPath.row - 1]
            collectionView.reloadData()
        }
    }
    
    //MARK: UICollectionViewDataSource
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
            cell.playButtonVisible = appData.audioVisual != nil
            cell.imageURL = appData.videoThumbnailImageURL
            cell.title = appData.displayText
            cell.subtitle = nil
        } else if let appData = selectedSceneLocation?.childSceneLocations[indexPath.row].childAppData.first {
            cell.playButtonVisible = false
            cell.imageURL = appData.locationImageURL
            cell.title = appData.location?.name
            cell.subtitle = nil
        } else if let appData = sceneLocations[indexPath.row].childSceneLocations.first?.childAppData.first {
            cell.playButtonVisible = false
            cell.imageURL = appData.locationImageURL
            cell.title = appData.title
            cell.subtitle = String.localizePlural("locations.count.one", pluralKey: "locations.count.other", count: sceneLocations[indexPath.row].childSceneLocations.count)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let appData = selectedChildSceneLocation?.childAppData[indexPath.row] {
            if let videoURL = appData.presentation?.videoURL {
                playVideo(videoURL)
            } else if let gallery = appData.gallery {
                showGallery(gallery)
            }
        } else if let selectedChildSceneLocation = selectedSceneLocation?.childSceneLocations[indexPath.row] {
            self.selectedChildSceneLocation = selectedChildSceneLocation
            collectionView.reloadData()
        } else {
            selectedSceneLocation = sceneLocations[indexPath.row]
            collectionView.reloadData()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((CGRectGetWidth(collectionView.frame) / 4), CGRectGetHeight(collectionView.frame))
    }
    
}

    
     