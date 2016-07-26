//
//  MultiMapView.swift
//

import UIKit
import MapKit
import GoogleMaps
import NextGenDataManager

protocol MultiMapViewDelegate {
    func mapView(mapView: MultiMapView, didTapMarker marker: MultiMapMarker)
}

class MultiMapMarker: NSObject {
    var dataObject: AnyObject?
    var appleMapAnnotation: MKAnnotation?
    var googleMapMarker: GMSMarker?
    var location: CLLocationCoordinate2D!
}
    
enum MultiMapType: Int {
    case Map = 0
    case Satellite = 1
}

class MultiMapView: UIView, MKMapViewDelegate, GMSMapViewDelegate {
    
    struct Constants {
        static let MarkerAnnotationViewReuseIdentifier = "kMarkerAnnotationViewReuseIdentifier"
        static let ControlsPadding: CGFloat = 18
        static let SegmentedControlWidth: CGFloat = 185
        static let ZoomButtonWidth: CGFloat = 30
    }
    
    private var appleMapView: MKMapView?
    private var googleMapView: GMSMapView?
    private var mapTypeSegmentedControl: UISegmentedControl?
    private var zoomInButton: UIButton?
    private var zoomOutButton: UIButton?
    private var mapIconImage: UIImage?
    private var mapMarkers = [MultiMapMarker]()
    var delegate: MultiMapViewDelegate?
    var maxZoomLevel: Float = -1 {
        didSet {
            if let mapView = googleMapView {
                mapView.setMinZoom(kGMSMinZoomLevel, maxZoom: (maxZoomLevel > 0 ? maxZoomLevel : kGMSMaxZoomLevel))
            }
        }
    }
    
    var selectedMarker: MultiMapMarker? {
        didSet {
            if let mapView = googleMapView {
                mapView.selectedMarker = selectedMarker?.googleMapMarker
            } else if let mapView = appleMapView, marker = selectedMarker?.appleMapAnnotation {
                mapView.selectAnnotation(marker, animated: true)
            }
        }
    }
    
    var mapType: MultiMapType = .Map {
        didSet {
            if let mapView = googleMapView {
                mapView.mapType = (mapType == .Satellite ? kGMSTypeSatellite : kGMSTypeNormal)
                self.addSubview(googleMapView!)
            } else if let mapView = appleMapView {
                mapView.mapType = (mapType == .Satellite ? MKMapType.Satellite : MKMapType.Standard)
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
        if NGDMConfiguration.mapService == .GoogleMaps && googleMapView == nil {
            googleMapView = GMSMapView(frame: self.bounds)
            googleMapView?.delegate = self
            self.addSubview(googleMapView!)
        } else if appleMapView == nil {
            appleMapView = MKMapView(frame: self.bounds)
            appleMapView?.delegate = self
            self.addSubview(appleMapView!)
        }
        
        mapType = .Map
    }
    
    func addControls() {
        let segmentedControl = UISegmentedControl(items: [String.localize("locations.map.type_standard"), String.localize("locations.map.type_satellite")])
        let textAttributes = NSDictionary(object: UIFont.themeCondensedFont(16), forKey: NSFontAttributeName)
        segmentedControl.setTitleTextAttributes(textAttributes as [NSObject : AnyObject], forState: UIControlState.Normal)
        segmentedControl.backgroundColor = UIColor.whiteColor()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.layer.cornerRadius = 5
        segmentedControl.addTarget(self, action: #selector(self.onMapTypeChanged), forControlEvents: UIControlEvents.ValueChanged)
        segmentedControl.frame = CGRectMake(Constants.ControlsPadding, Constants.ControlsPadding, Constants.SegmentedControlWidth, CGRectGetHeight(segmentedControl.frame))
        self.addSubview(segmentedControl)
        mapTypeSegmentedControl = segmentedControl
        
        let zoomInButton = UIButton(frame: CGRectMake(Constants.ControlsPadding, CGRectGetMaxY(segmentedControl.frame) + Constants.ControlsPadding, Constants.ZoomButtonWidth, Constants.ZoomButtonWidth))
        zoomInButton.setImage(UIImage(named: "MapZoomIn"), forState: .Normal)
        zoomInButton.addTarget(self, action: #selector(self.zoomIn), forControlEvents: .TouchUpInside)
        self.addSubview(zoomInButton)
        self.zoomInButton = zoomInButton
        
        let zoomOutButton = UIButton(frame: CGRectMake(Constants.ControlsPadding, CGRectGetMaxY(zoomInButton.frame), Constants.ZoomButtonWidth, Constants.ZoomButtonWidth))
        zoomOutButton.setImage(UIImage(named: "MapZoomOut"), forState: .Normal)
        zoomOutButton.addTarget(self, action: #selector(self.zoomOut), forControlEvents: .TouchUpInside)
        self.addSubview(zoomOutButton)
        self.zoomOutButton = zoomOutButton
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        googleMapView?.frame = self.bounds
        appleMapView?.frame = self.bounds
        
        if let mapTypeSegmentedControl = mapTypeSegmentedControl {
            self.bringSubviewToFront(mapTypeSegmentedControl)
        }
        
        if let button = zoomInButton {
            self.bringSubviewToFront(button)
        }
        
        if let button = zoomOutButton {
            self.bringSubviewToFront(button)
        }
    }
    
    func destroy() {
        delegate = nil
        googleMapView = nil
        appleMapView = nil
    }
    
    func clear() {
        if let mapView = googleMapView {
            mapView.clear()
        } else if let mapView = appleMapView {
            mapView.removeAnnotations(mapView.annotations)
        }
    }

    func setLocation(location: CLLocationCoordinate2D, zoomLevel: Float, animated: Bool) {
        if let mapView = googleMapView {
            if animated {
                mapView.animateWithCameraUpdate(GMSCameraUpdate.setTarget(location, zoom: zoomLevel))
            } else {
                mapView.camera = GMSCameraPosition(target: location, zoom: zoomLevel, bearing: mapView.camera.bearing, viewingAngle: mapView.camera.viewingAngle)
            }
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
            
            mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 50))
        } else if let mapView = appleMapView {
            var annotations = [MKAnnotation]()
            for marker in markers {
                if let mapMarker = marker.appleMapAnnotation {
                    annotations.append(mapMarker)
                }
            }
            
            mapView.showAnnotations(annotations, animated: true)
        }
    }
    
    func zoomIn() {
        if let mapView = googleMapView {
            mapView.animateWithCameraUpdate(GMSCameraUpdate.zoomIn())
        }
    }
    
    func zoomOut() {
        if let mapView = googleMapView {
            mapView.animateWithCameraUpdate(GMSCameraUpdate.zoomOut())
        }
    }
    
    // MARK: Actions
    func onMapTypeChanged() {
        if let mapTypeSegmentedControl = mapTypeSegmentedControl, type = MultiMapType(rawValue: mapTypeSegmentedControl.selectedSegmentIndex) {
            mapType = type
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
    
}
