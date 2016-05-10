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

class ExtrasSceneLocationsViewController: MenuedViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var mapView: MultiMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    private var mapAppDataItems = [String: [MapAppDataItem]]()
    private var selectedAppDataItems: [MapAppDataItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.backgroundColor = UIColor.clearColor()
        
        let info = NSMutableDictionary()
        info[MenuSection.Keys.Title] = "Location: Full Map"
        
        var rows = [[String: String]]()
        for experience in self.experience.childExperiences {
            if let appData = experience.appData, type = appData.type, location = appData.location {
                if mapAppDataItems[type] == nil {
                    mapAppDataItems[type] = [MapAppDataItem]()
                    rows.append([MenuItem.Keys.Title: type, MenuItem.Keys.Value: type])
                }
                
                let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                let marker = mapView.addMarker(center, title: location.name, subtitle: "", icon: UIImage(named: "MOSMapPin"), autoSelect: false)
                mapAppDataItems[type]!.append(MapAppDataItem(appData: appData, marker: marker))
            }
        }
        
        info[MenuSection.Keys.Rows] = rows
        menuSections.append(MenuSection(info: info))
        
        mapView.zoomToFitAllMarkers()
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
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuItemCell, appDataType = cell.menuItem?.value, mapAppDataItems = mapAppDataItems[appDataType] {
            mapView.zoomToFitMarkers(mapAppDataItems.map({ $0.marker }))
            selectedAppDataItems = mapAppDataItems
            collectionView.reloadData()
        }
    }
    
    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAppDataItems?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MapItemCellReuseIdentifier", forIndexPath: indexPath) as! MapItemCell
        // TODO: Do something with selectedAppDataItems[indexPath.row]
        
        return cell
    }
    
}
