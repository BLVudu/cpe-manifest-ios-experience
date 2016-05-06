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
        
        if let event = timedEvent, appData = event.appData, location = appData.location {
            let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            mapView.setLocation(center, zoomLevel: appData.zoomLevel, animated: false)
            mapView.addMarker(center, title: location.name, subtitle: location.address)
        }
        
        mapView.userInteractionEnabled = false
    }
    
}
