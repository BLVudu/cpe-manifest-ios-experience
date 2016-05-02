//
//  MultiMapView.swift
//  NextGen
//
//  Created by Alec Ananian on 4/11/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class MultiMapView: UIView, MKMapViewDelegate {
    
    struct Constants {
        static let MarkerAnnotationViewReuseIdentifier = "kMarkerAnnotationViewReuseIdentifier"
    }
    
    var appleMapView: MKMapView?
    var googleMapView: GMSMapView?
    var mapIconImage: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        if ConfigManager.sharedInstance.hasGoogleMaps {
            googleMapView = GMSMapView(frame: self.bounds)
            googleMapView?.mapType = kGMSTypeHybrid
            self.addSubview(googleMapView!)
        } else {
            appleMapView = MKMapView(frame: self.bounds)
            appleMapView?.delegate = self
            appleMapView?.mapType = MKMapType.Hybrid
            self.addSubview(appleMapView!)
        }
    }

    func setLocation(location: CLLocationCoordinate2D, zoomLevel: Float, animated: Bool) {
        if let mapView = googleMapView {
            mapView.camera = GMSCameraPosition(target: location, zoom: zoomLevel, bearing: 0, viewingAngle: 0)
        } else if let mapView = appleMapView {
            let span = MKCoordinateSpanMake(0, 360 / pow(2.0, Double(zoomLevel)) * Double(CGRectGetWidth(mapView.frame)) / 256);
            mapView.setRegion(MKCoordinateRegionMake(location, span), animated: animated)
        }
    }
    
    func addMarker(location: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        addMarker(location, title: title, subtitle: subtitle, icon: nil, autoSelect: false)
    }
    
    func addMarker(location: CLLocationCoordinate2D, title: String?, subtitle: String?, icon: UIImage?, autoSelect: Bool) {
        if let mapView = googleMapView {
            let marker = GMSMarker(position: location)
            marker.title = title
            marker.icon = icon
            marker.snippet = subtitle
            marker.map = mapView
            
            if autoSelect {
                mapView.selectedMarker = marker
            }
        } else if let mapView = appleMapView {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = title
            annotation.subtitle = subtitle
            mapIconImage = icon
            mapView.addAnnotation(annotation)
            
            if autoSelect {
                mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.MarkerAnnotationViewReuseIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.MarkerAnnotationViewReuseIdentifier)
            annotationView?.image = mapIconImage
            annotationView?.canShowCallout = true
        }
        
        annotationView?.annotation = annotation
        
        return annotationView
    }

}
