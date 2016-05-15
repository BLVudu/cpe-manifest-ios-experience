//
//  ExtrasSceneLocationsViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 5/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit

struct MapAppDataItem {
    var appData: NGDMAppData!
    var marker: MultiMapMarker!
}

class ExtrasSceneLocationsViewController: MenuedViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var mapView: MultiMapView!
    @IBOutlet weak var collectionViewTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    private var markers = [String: MultiMapMarker]() // ExperienceID: MultiMapMarker
    private var selectedExperience: NGDMExperience?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.backgroundColor = UIColor.clearColor()
        collectionViewTitleLabel.text = experience.title.uppercaseString
        collectionView.registerNib(UINib(nibName: String(MapItemCell), bundle: nil), forCellWithReuseIdentifier: MapItemCell.ReuseIdentifier)
        
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
        var selectedMarkers = [MultiMapMarker]()
        for childExperience in experience.childExperiences {
            if let childChildExperience = childExperience.childExperiences.first where childChildExperience.isLocation {
                for childChildExperience in childExperience.childExperiences {
                    if let marker = markers[childChildExperience.id] {
                        selectedMarkers.append(marker)
                    }
                }
            } else if let marker = markers[childExperience.id] {
                selectedMarkers.append(marker)
            }
        }
        
        mapView.zoomToFitMarkers(selectedMarkers)
        selectedExperience = experience
        collectionView.reloadData()
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
            selectExperience(experience)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth: CGFloat = (CGRectGetWidth(collectionView.frame) / 4)
        return CGSizeMake(itemWidth, itemWidth + 30)
    }
    
}
