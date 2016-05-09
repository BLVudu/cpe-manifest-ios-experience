//
//  MapSceneDetailCollectionViewCell.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import MapKit

class MapSceneDetailCollectionViewCell: SceneDetailCollectionViewCell {
    
    static let ReuseIdentifier = "MapSceneDetailCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak var mapView: MultiMapView!
    
    override func timedEventDidChange() {
        super.timedEventDidChange()
        
        if let event = timedEvent, location = event.location {
            let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            mapView.setLocation(center, zoomLevel: 14, animated: false)
            mapView.addMarker(center, title: location.name, subtitle: location.address, icon: UIImage(named: "MOSMapPin"), autoSelect: false)
        }
        
        mapView.userInteractionEnabled = false
    }
    
}
