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
    
    @IBOutlet weak var mapView: MKMapView!
    
    override var timedEvent: NGDMTimedEvent? {
        get {
            return super.timedEvent
        }
        
        set(v) {
            if _timedEvent != v {
                super.timedEvent = v
                
                if let event = _timedEvent, location = event.location {
                    let center = mapView.setLocation(location.latitude, longitude: location.longitude, zoomLevel: 14, animated: false)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = center
                    annotation.title = location.name
                    annotation.subtitle = location.address
                    
                    mapView.addAnnotation(annotation)
                }
                
                mapView.userInteractionEnabled = false
            }
        }
    }
    
}
