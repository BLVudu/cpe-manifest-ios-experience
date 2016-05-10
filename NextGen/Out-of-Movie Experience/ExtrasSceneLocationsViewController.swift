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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    private var mapAppDataItems = [String: [MapAppDataItem]]()
    private var selectedAppDataItems: [MapAppDataItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.backgroundColor = UIColor.clearColor()
        collectionView.registerNib(UINib(nibName: String(MapItemCell), bundle: nil), forCellWithReuseIdentifier: MapItemCell.ReuseIdentifier)
        
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
    
    func selectAppDataType(appDataType: String) {
        if let mapAppDataItems = mapAppDataItems[appDataType] {
            mapView.zoomToFitMarkers(mapAppDataItems.map({ $0.marker }))
            selectedAppDataItems = mapAppDataItems
            collectionView.reloadData()
        }
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
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuItemCell, appDataType = cell.menuItem?.value {
            selectAppDataType(appDataType)
        }
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let selectedAppDataItems = selectedAppDataItems {
            return selectedAppDataItems.count
        }
        
        return mapAppDataItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MapItemCell.ReuseIdentifier, forIndexPath: indexPath) as! MapItemCell
        cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        if let appData = selectedAppDataItems?[indexPath.row].appData {
            cell.appDataType = nil
            cell.appData = appData
        } else {
            let mapAppDataItemList = Array(mapAppDataItems.values)[indexPath.row]
            cell.childCount = mapAppDataItemList.count
            cell.appDataType = mapAppDataItemList.first?.appData
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MapItemCell {
            if let appDataType = cell.appDataType?.type {
                selectAppDataType(appDataType)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth: CGFloat = (CGRectGetWidth(collectionView.frame) / 4)
        return CGSizeMake(itemWidth, itemWidth + 30)
    }
    
}
