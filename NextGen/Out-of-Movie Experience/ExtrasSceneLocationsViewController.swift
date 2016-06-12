//
//  ExtrasSceneLocationsViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 5/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit
import NextGenDataManager

class ExtrasSceneLocationsViewController: MenuedViewController, MultiMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
    private var locationExperienceMapping = [String: NGDMExperience]() // ExperienceID: Parent Experience
    private var selectedExperience: NGDMExperience? {
        didSet {
            if let experience = selectedExperience {
                if let appDataExperience = experience.childExperiences?.first, appData = appDataExperience.appData, location = appData.location {
                    mapView.selectedMarker = markers[appDataExperience.id]
                    mapView.setLocation(CLLocationCoordinate2DMake(location.latitude, location.longitude), zoomLevel: appData.zoomLevel, animated: true)
                } else {
                    var selectedMarkers = [MultiMapMarker]()
                    if experience == self.experience {
                        selectedMarkers = Array(markers.values)
                    } else if let childExperiences = experience.childExperiences {
                        for childExperience in childExperiences {
                            if let childChildExperiences = childExperience.childExperiences {
                                for childChildExperience in childChildExperiences {
                                    if let marker = markers[childChildExperience.id] {
                                        selectedMarkers.append(marker)
                                    }
                                }
                            }
                        }
                    }
                    
                    if let childExperiences = experience.childExperiences where childExperiences.count > 1 && selectedMarkers.count > 1 {
                        mapView.selectedMarker = nil
                        mapView.zoomToFitMarkers(selectedMarkers)
                    } else if let appDataExperience = experience.childExperiences?.first?.childExperiences?.first, appData = appDataExperience.appData, location = appData.location {
                        mapView.selectedMarker = markers[appDataExperience.id]
                        mapView.setLocation(CLLocationCoordinate2DMake(location.latitude, location.longitude), zoomLevel: appData.zoomLevel, animated: true)
                    }
                    
                    menuSections.first?.title = experience == self.experience ? String.localize("locations.full_map") : experience.title
                    self.menuTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                }
                
                collectionViewTitleLabel.text = experience.title.uppercaseString
            }
            
            collectionView.reloadData()
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
        
        let info = NSMutableDictionary()
        info[MenuSection.Keys.Title] = String.localize("locations.full_map")
        
        var rows = [[String: String]]()
        rows.append([MenuItem.Keys.Title: String.localize("locations.full_map"), MenuItem.Keys.Value: experience.id])
        
        if let categoryExperiences = experience.childExperiences {
            for categoryExperience in categoryExperiences {
                rows.append([MenuItem.Keys.Title: categoryExperience.title, MenuItem.Keys.Value: categoryExperience.id])
                
                if let subcategoryExperiences = categoryExperience.childExperiences {
                    for subcategoryExperience in subcategoryExperiences {
                        if let locationExperiences = subcategoryExperience.childExperiences {
                            for locationExperience in locationExperiences {
                                if let location = locationExperience.appData?.location {
                                    let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                    markers[locationExperience.id] = mapView.addMarker(center, title: location.name, subtitle: location.address, icon: UIImage(named: "MOSMapPin"), autoSelect: false)
                                    locationExperienceMapping[locationExperience.id] = subcategoryExperience
                                }
                            }
                        }
                    }
                }
            }
        }
        
        info[MenuSection.Keys.Rows] = rows
        menuSections.append(MenuSection(info: info))
        
        selectedExperience = experience
        mapView.zoomToFitAllMarkers()
        mapView.delegate = self
    }
    
    func playVideo(videoURL: NSURL) {
        closeDetailView()
        
        if let videoPlayerViewController = UIStoryboard.getMainStoryboardViewController(VideoPlayerViewController) as? VideoPlayerViewController {
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
        if let experienceId = markers.filter({ $0.1 == marker }).map({ $0.0 }).first, experience = locationExperienceMapping[experienceId] where experience != selectedExperience {
            selectedExperience = experience
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
        
        if let experienceId = (tableView.cellForRowAtIndexPath(indexPath) as? MenuItemCell)?.menuItem?.value, experience = NGDMExperience.getById(experienceId) {
            selectedExperience = experience
        }
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedExperience?.childExperiences?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MapItemCell.ReuseIdentifier, forIndexPath: indexPath) as! MapItemCell
        cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        cell.experience = selectedExperience?.childExperiences?[indexPath.row]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let experience = (collectionView.cellForItemAtIndexPath(indexPath) as? MapItemCell)?.experience {
            if let appData = experience.appData {
                if let videoURL = appData.presentation?.videoURL {
                    playVideo(videoURL)
                } else if let gallery = appData.gallery {
                    showGallery(gallery)
                }
            } else {
                selectedExperience = experience
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((CGRectGetWidth(collectionView.frame) / 4), CGRectGetHeight(collectionView.frame))
    }
}

    
     