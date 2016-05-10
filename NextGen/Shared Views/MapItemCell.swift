//
//  MapItemCell.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 5/9/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class MapItemCell : UICollectionViewCell{
    
    static let ReuseIdentifier = "MapItemCellReuseIdentifier"
  
    
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var childLocationsCount: UILabel!
    
    var location: NGDMLocation?
    
    var latitude: Double?
    var longitude: Double?
    
    var childLocations :[LocationObject]?
    
    
   
}
