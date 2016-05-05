//
//  ExtrasSceneLocationsViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 5/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit


class ExtrasSceneLocationsViewController: MenuedViewController{
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
  
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var locations = ["Full Map", "Metropolis","Smallville", "US Northcom", "Artic Circle"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let info = NSMutableDictionary()
        info[MenuSection.Keys.Title] = "Location : \(locations[0])"
        var rows: [Dictionary<String, String>] = []
        
        
        for i in 1...locations.count-1  {
            rows.append([MenuSection.Keys.Title:locations[i]])
        }
        
        info[MenuSection.Keys.Rows] = rows
        menuSections.append(MenuSection(info: info))
        
        menuTableView.backgroundColor = UIColor.clearColor()
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        cell.backgroundColor = UIColor.blackColor()
        tableViewHeight.constant += cell.frame.height
        
        tableView.setNeedsUpdateConstraints()

    }
    
 
    
    
}
