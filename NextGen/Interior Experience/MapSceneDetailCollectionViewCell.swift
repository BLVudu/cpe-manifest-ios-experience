//
//  MapSceneDetailCollectionViewCell.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import MapKit

class MapSceneDetailCollectionViewCell: SceneDetailCollectionViewCell, MKMapViewDelegate {
    
    static let ReuseIdentifier = "MapSceneDetailCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func timedEventDidChange() {
        super.timedEventDidChange()
        
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
    
    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "SceneDetailMapPoint")
        annotationView.image = UIImage(named: "MOSMapPin")
        return annotationView
    }
    
}
