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

protocol MultiMapViewDelegate {
    func mapView(mapView: MultiMapView, didTapMarker marker: MultiMapMarker)
}

class MultiMapMarker: NSObject {
    var appleMapAnnotation: MKAnnotation?
    var googleMapMarker: GMSMarker?
    var location: CLLocationCoordinate2D!
}

class MultiMapView: UIView, MKMapViewDelegate, GMSMapViewDelegate {
    
    struct Constants {
        static let MarkerAnnotationViewReuseIdentifier = "kMarkerAnnotationViewReuseIdentifier"
    }
    
    private var appleMapView: MKMapView?
    private var googleMapView: GMSMapView?
    private var mapIconImage: UIImage?
    private var mapMarkers = [MultiMapMarker]()
    var delegate: MultiMapViewDelegate?
    
    var selectedMarker: MultiMapMarker? {
        didSet {
            if let mapView = googleMapView {
                mapView.selectedMarker = selectedMarker?.googleMapMarker
            } else if let mapView = appleMapView, marker = selectedMarker?.appleMapAnnotation {
                mapView.selectAnnotation(marker, animated: true)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        if ConfigManager.sharedInstance.hasGoogleMaps && googleMapView == nil {
            googleMapView = GMSMapView(frame: self.bounds)
            googleMapView?.delegate = self
            googleMapView?.mapType = kGMSTypeHybrid
            self.addSubview(googleMapView!)
        } else if appleMapView == nil {
            appleMapView = MKMapView(frame: self.bounds)
            appleMapView?.delegate = self
            appleMapView?.mapType = MKMapType.Hybrid
            self.addSubview(appleMapView!)
        }
    }
    
    func destroy() {
        delegate = nil
        googleMapView = nil
        appleMapView = nil
    }

    func setLocation(location: CLLocationCoordinate2D, zoomLevel: Float, animated: Bool) {
        if let mapView = googleMapView {
            mapView.camera = GMSCameraPosition(target: location, zoom: zoomLevel, bearing: 0, viewingAngle: 0)
        } else if let mapView = appleMapView {
            let span = MKCoordinateSpanMake(0, 360 / pow(2.0, Double(zoomLevel)) * Double(CGRectGetWidth(mapView.frame)) / 256);
            mapView.setRegion(MKCoordinateRegionMake(location, span), animated: animated)
        }
    }
    
    func addMarker(location: CLLocationCoordinate2D, title: String?, subtitle: String?) -> MultiMapMarker {
        return addMarker(location, title: title, subtitle: subtitle, icon: nil, autoSelect: false)
    }
    
    func addMarker(location: CLLocationCoordinate2D, title: String?, subtitle: String?, icon: UIImage?, autoSelect: Bool) -> MultiMapMarker {
        let multiMapMarker = MultiMapMarker()
        multiMapMarker.location = location
        
        if let mapView = googleMapView {
            let marker = GMSMarker(position: location)
            marker.title = title
            marker.icon = icon
            marker.snippet = subtitle
            marker.map = mapView
            multiMapMarker.googleMapMarker = marker
            
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
            multiMapMarker.appleMapAnnotation = annotation
            
            if autoSelect {
                mapView.selectAnnotation(annotation, animated: true)
            }
        }
        
        mapMarkers.append(multiMapMarker)
        return multiMapMarker
    }
    
    func zoomToFitAllMarkers() {
        zoomToFitMarkers(mapMarkers)
    }
    
    func zoomToFitMarkers(markers: [MultiMapMarker]) {
        if let mapView = googleMapView {
            var bounds = GMSCoordinateBounds()
            for marker in markers {
                if let mapMarker = marker.googleMapMarker {
                    bounds = bounds.includingCoordinate(mapMarker.position)
                }
            }
            
            mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 40))
        }
    }
    
    
    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.MarkerAnnotationViewReuseIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.MarkerAnnotationViewReuseIdentifier)
            annotationView?.image = mapIconImage
        }
        
        annotationView?.annotation = annotation
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        /*if let delegate = delegate {
            var selectedMarker: MultiMapMarker
            for mapMarker in mapMarkers {
                if mapMarker.appleMapAnnotation == view.annotation {
                    selectedMarker = mapMarker
                    break
                }
            }
            
            delegate.didTapMarker(selectedMarker)
        }*/
    }
    
    // MARK: GMSMapViewDelegate
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if let delegate = delegate {
            var selectedMarker: MultiMapMarker?
            for mapMarker in mapMarkers {
                if mapMarker.googleMapMarker == marker {
                    selectedMarker = mapMarker
                    break
                }
            }
            
            if let marker = selectedMarker {
                delegate.mapView(self, didTapMarker: marker)
            }
        }
        
        return true
    }
    
    /*func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let customView = UIView(frame: CGRectMake(0, 0, 230, 80))
        customView.backgroundColor = UIColor.whiteColor()
        
        let titleLabel = UILabel(frame: CGRectMake(10, 5, 200, 30))
        titleLabel.text = marker.title
        titleLabel.font = UIFont.themeFont(17)
        
        let addressLabel = UILabel(frame: CGRectMake(10, 30, 200, 50))
        addressLabel.text = marker.snippet
        addressLabel.font = UIFont.themeCondensedFont(15)
        addressLabel.numberOfLines = 3
        
        customView.addSubview(addressLabel)
        customView.addSubview(titleLabel)
        customView.layer.cornerRadius = 5
        customView.layer.masksToBounds = true
        customView.layer.shadowColor = UIColor.blackColor().CGColor
        customView.layer.shadowRadius = 10
        customView.layer.shadowOpacity = 1
        customView.layer.shadowOffset = CGSizeMake(0, 0)
 
        return customView
    }*/
    
}
