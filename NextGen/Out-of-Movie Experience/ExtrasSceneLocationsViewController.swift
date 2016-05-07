//
//  ExtrasSceneLocationsViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 5/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit

class LocationObject: NSObject{
    
    var name: String!
    var latitude: Double!
    var longitude: Double!
    
    
    required init(info: NSDictionary){
        name = info["name"] as! String
        latitude = info["lat"] as! Double
        longitude = info ["long"] as! Double
    }
    
}

class ExtrasSceneLocationsViewController: MenuedViewController{
    
    
    @IBOutlet weak var mapView: MultiMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
  
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
  
    var locationInfo = [
        ["name": "Metropolis",
        "lat" : 41.8781,
        "long" : -87.6298],
        
        ["name": "Smallville",
        "lat" : 41.630501,
        "long" : -88.438485],
        
        ["name": "US Northcom",
        "lat" : 38.8239,
        "long" : -104.7001],
        
       ["name": "Artic Circle",
        "lat" : 49.282729,
        "long" : -123.120738]
    ]
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let info = NSMutableDictionary()
        info[MenuSection.Keys.Title] = "Location : Full Map"
        var rows: [Dictionary<String, String>] = []
        
        let locations = NSArray(array: locationInfo)
        
        for location in locations  {
            if let locationData = location as? NSDictionary{
                let location = LocationObject(info: locationData)
                rows.append([MenuItem.Keys.Title:location.name, MenuItem.Keys.Latitude: String(location.latitude), MenuItem.Keys.Longitude: String(location.longitude)])
                let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                mapView.addMarker(center, title: location.name, subtitle: "", icon: UIImage(named: "MOSMapPin"), autoSelect: false)
            }
        }
        
             /*
        for location in locations{
            rows.append([MenuSection.Keys.Title:location.name])
            let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            mapView.addMarker(center, title: location.name, subtitle: "", icon: UIImage(named: "MOSMapPin"), autoSelect: false)
            
        }
        */
 
        info[MenuSection.Keys.Rows] = rows
        menuSections.append(MenuSection(info: info))
        
        menuTableView.backgroundColor = UIColor.clearColor()
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0{
            cell.backgroundColor = UIColor.init(netHex: 0xba0f0f)
        } else {
            cell.backgroundColor = UIColor.blackColor()
        }
        
        
        tableViewHeight.constant += cell.frame.height
        
        tableView.setNeedsUpdateConstraints()

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(menuTableView, didSelectRowAtIndexPath: indexPath)
        let menuSection = self.menuSections[indexPath.section]
         if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuItemCell, menuItem = cell.menuItem, latitude = menuItem.latitude, longitude = menuItem.longitude{
         
            mapView.setLocation(CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!), zoomLevel: 15, animated: true)
            
            //menuSection.title = menuItem.title
            
            
        }
        
        
    }
    
 
    
    
}
