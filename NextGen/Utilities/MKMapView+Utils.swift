//
//  MKMapView+Utils.swift
//  NextGen
//
//  Created by Alec Ananian on 3/15/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import MapKit

extension MKMapView {
    
    func setLocation(latitude: Double, longitude: Double, zoomLevel: Double, animated: Bool) -> CLLocationCoordinate2D {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpanMake(0, 360 / pow(2.0, zoomLevel) * Double(CGRectGetWidth(self.frame)) / 256);
        self.setRegion(MKCoordinateRegionMake(center, span), animated: animated)
        return center
    }
    
}