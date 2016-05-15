//
//  ExtrasSceneLocationsViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 5/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit

class ExtrasSceneLocationsViewController: MenuedViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var mapView: MultiMapView!
    @IBOutlet weak var collectionViewTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var locationDetailView: UIView!
    @IBOutlet weak var locationDetailContainerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    private var videoPlayerViewController: VideoPlayerViewController?
    
    private var markers = [String: MultiMapMarker]() // ExperienceID: MultiMapMarker
    private var selectedExperience: NGDMExperience?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.hidden = true
        menuTableView.backgroundColor = UIColor.clearColor()
        collectionViewTitleLabel.text = experience.title.uppercaseString
        collectionView.registerNib(UINib(nibName: String(MapItemCell), bundle: nil), forCellWithReuseIdentifier: MapItemCell.ReuseIdentifier)
        closeButton.titleLabel?.font = UIFont.themeCondensedFont(17)
        closeButton.setTitle(String.localize("label.close"), forState: UIControlState.Normal)
        closeButton.setImage(UIImage(named: "Close"), forState: UIControlState.Normal)
        closeButton.contentEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0)
        closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25)
        closeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 110, 0, 0)
        
        if childGalleryItems != nil{
            let selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            collectionView.selectItemAtIndexPath(selectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.Left)
            
        }
        
        let info = NSMutableDictionary()
        info[MenuSection.Keys.Title] = "Location: Full Map"
        
        var rows = [[String: String]]()
        for categoryExperience in experience.childExperiences {
            rows.append([MenuItem.Keys.Title: categoryExperience.title, MenuItem.Keys.Value: categoryExperience.id])
            
            for subcategoryExperience in categoryExperience.childExperiences {
                for locationExperience in subcategoryExperience.childExperiences {
                    if let location = locationExperience.appData?.location {
                        let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                        markers[locationExperience.id] = mapView.addMarker(center, title: location.name, subtitle: "", icon: UIImage(named: "MOSMapPin"), autoSelect: false)
                    }
                }
            }
        }
        
        info[MenuSection.Keys.Rows] = rows
        menuSections.append(MenuSection(info: info))
        
        selectedExperience = experience
        mapView.zoomToFitAllMarkers()
    }
    
    func selectExperience(experience: NGDMExperience) {
        if experience.childExperiences.count <= 1 {
            var appData = experience.childExperiences.first?.appData
            if appData == nil {
                appData = experience.childExperiences.first?.childExperiences.first?.appData
            }
            
            if let appData = appData, location = appData.location {
                mapView.setLocation(CLLocationCoordinate2DMake(location.latitude, location.longitude), zoomLevel: appData.zoomLevel, animated: true)
            }
        } else {
            var selectedMarkers = [MultiMapMarker]()
            for childExperience in experience.childExperiences {
                for childChildExperience in childExperience.childExperiences {
                    if let marker = markers[childChildExperience.id] {
                        selectedMarkers.append(marker)
                    }
                }
            }
            
            mapView.zoomToFitMarkers(selectedMarkers)
        }
        
        collectionViewTitleLabel.text = experience.title.uppercaseString
        selectedExperience = experience
        collectionView.reloadData()
    }
    
    func playVideo(videoURL: NSURL) {
        if let videoPlayerViewController = UIStoryboard.getMainStoryboardViewController(VideoPlayerViewController) as? VideoPlayerViewController {
            videoPlayerViewController.mode = VideoPlayerMode.Supplemental
            
            videoPlayerViewController.view.frame = locationDetailContainerView.bounds
            locationDetailContainerView.addSubview(videoPlayerViewController.view)
            self.addChildViewController(videoPlayerViewController)
            videoPlayerViewController.didMoveToParentViewController(self)
            
            videoPlayerViewController.playVideoWithURL(videoURL)
            
            locationDetailView.hidden = false
            self.videoPlayerViewController = videoPlayerViewController
        }
    }
    
    @IBAction func closeDetailView() {
        locationDetailView.hidden = true
        
        videoPlayerViewController?.willMoveToParentViewController(nil)
        videoPlayerViewController?.view.removeFromSuperview()
        videoPlayerViewController?.removeFromParentViewController()
        videoPlayerViewController = nil
    }
   
    //MARK: Overriding MenuedViewController functions
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            cell.backgroundColor = UIColor.init(netHex: 0xba0f0f)
        } else {
            cell.backgroundColor = UIColor.blackColor()
        }
        
        tableViewHeight.constant += cell.frame.height
        
        tableView.setNeedsUpdateConstraints()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(menuTableView, didSelectRowAtIndexPath: indexPath)
        
        if let experienceId = (tableView.cellForRowAtIndexPath(indexPath) as? MenuItemCell)?.menuItem?.value, experience = NGDMExperience.getById(experienceId) {
            selectExperience(experience)
        }
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedExperience?.childExperiences.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MapItemCell.ReuseIdentifier, forIndexPath: indexPath) as! MapItemCell
        cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        cell.experience = selectedExperience?.childExperiences[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let experience = (collectionView.cellForItemAtIndexPath(indexPath) as? MapItemCell)?.experience {
            if let appData = experience.appData {
                if let videoURL = appData.presentation?.videoURL {
                    playVideo(videoURL)
                } else if let gallery = appData.gallery {
                    print(gallery)
                }
            } else {
                selectExperience(experience)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((CGRectGetWidth(collectionView.frame) / 4), CGRectGetHeight(collectionView.frame))
    }
    
    func loadChildGallery(appData: NGDMAppData){
        childGalleryItems = []
        if appData.displayText != nil {
            childGalleryItems?.append(appData)
        }
        tempSelectedAppDataItems = selectedAppDataItems
        selectedAppDataItems = nil
        collectionView.reloadData()
        
    }
    @IBAction func dismissGallery(sender: AnyObject) {
        
        textView.hidden = true
        childGalleryItems = nil
        selectedAppDataItems = tempSelectedAppDataItems
        tempSelectedAppDataItems = nil
        collectionView.reloadData()
    }
    
}
