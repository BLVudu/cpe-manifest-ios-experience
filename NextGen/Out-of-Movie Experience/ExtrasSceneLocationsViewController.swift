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
    
    var childLocations = [LocationObject]()
    required init(info: NSDictionary){
        name = info["name"] as! String
        latitude = info["lat"] as! Double
        longitude = info ["long"] as! Double
        
        
         if let childLocationsData = info["more"] as? NSArray{
            for childLocation in childLocationsData{
                if let childData = childLocation as? NSDictionary{
                    childLocations.append(LocationObject(info: childData))
         }
         }
         
         
         }
         
        

    }
    
}

class ExtrasSceneLocationsViewController: MenuedViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var mapView: MultiMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
  
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var locations = [LocationObject]()
  
    var locationInfo = [
        ["name": "Metropolis",
        "lat" : 41.8781,
        "long" : -87.6298,
        "more" :
            [["name": "Union Station",
              "lat" : 41.8787,
              "long" : -87.6403],
             ["name": "The Daily Planet",
              "lat" : 41.5241,
              "long" : -87.3756],
             ["name": "Wells St",
                "lat" : 41.5315,
                "long" : -87.3802],
             ["name": "Richard J Daly Center",
              "lat" : 41.8843,
              "long" : -87.6303]]
            
        ],

        
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
        
        collectionView.registerNib(UINib(nibName: String(MapItemCell), bundle: nil), forCellWithReuseIdentifier: MapItemCell.ReuseIdentifier)
        mapView.setLocation(CLLocationCoordinate2DMake(39.50, -98.35), zoomLevel: 5, animated: true)
        
        let info = NSMutableDictionary()
        info[MenuSection.Keys.Title] = "Location : Full Map"
        var rows: [Dictionary<String, String>] = []
        
        let locationalData = NSArray(array: locationInfo)
        
        for location in locationalData  {
            if let locationData = location as? NSDictionary{
                let location = LocationObject(info: locationData)
                rows.append([MenuItem.Keys.Title:location.name, MenuItem.Keys.Latitude: String(location.latitude), MenuItem.Keys.Longitude: String(location.longitude)])
                let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                mapView.addMarker(center, title: location.name, subtitle: "", icon: UIImage(named: "MOSMapPin"), autoSelect: false)
                locations.append(location)
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
   
    //MARK: Overriding MenuedViewController functions
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
       
        /*
         if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuItemCell, menuItem = cell.menuItem, latitude = menuItem.latitude, longitude = menuItem.longitude{
         
            mapView.setLocation(CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!), zoomLevel: 15, animated: true)
            
            //menuSection.title = menuItem.title
            
            
        }
        */
        let selectedIndex = NSIndexPath(forRow: indexPath.row-1, inSection: 0)
        if indexPath.row > 0 {
         if let cell = self.collectionView.cellForItemAtIndexPath(selectedIndex) as? MapItemCell, latitude = cell.latitude, longitude = cell.longitude{
            
            mapView.setLocation(CLLocationCoordinate2DMake(latitude,longitude), zoomLevel: 12, animated: true)
            
            if cell.childLocations?.count > 0{
                locations = cell.childLocations!
                for child in cell.childLocations!{
                    mapView.addMarker(CLLocationCoordinate2DMake(child.latitude, child.longitude), title: child.name, subtitle: "", icon: UIImage(named: "MOSMapPin"), autoSelect: false)
                }
                collectionView.reloadData()
            }
            
            
            }

            
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return locations.count
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MapItemCell.ReuseIdentifier, forIndexPath: indexPath) as! MapItemCell
        cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        cell.locationName.text = locations[indexPath.row].name
        cell.latitude = locations[indexPath.row].latitude
        cell.longitude = locations[indexPath.row].longitude
        cell.childLocations = locations[indexPath.row].childLocations
        cell.childLocationsCount.text = "\(locations[indexPath.row].childLocations.count) locations"
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MapItemCell, latitude = cell.latitude, longitude = cell.longitude{
            
            mapView.setLocation(CLLocationCoordinate2DMake(latitude,longitude), zoomLevel: 12, animated: true)
            
            if cell.childLocations?.count > 0{
                locations = cell.childLocations!
                for child in cell.childLocations!{
                    mapView.addMarker(CLLocationCoordinate2DMake(child.latitude, child.longitude), title: child.name, subtitle: "", icon: UIImage(named: "MOSMapPin"), autoSelect: false)
                }
                collectionView.reloadData()
            }
            
            
        }
    }

    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth: CGFloat = (CGRectGetWidth(collectionView.frame) / 4)
        return CGSizeMake(itemWidth, itemWidth+30)
    }
    

    
    
}
