//
//  MapDetailViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/29/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit


class MapDetailViewController: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapCollectionView: UICollectionView!
    
    var initialLocation = CLLocation(latitude: 0, longitude: 0)
    let regionRadius: CLLocationDistance = 2000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMapOnLocation(initialLocation, region: regionRadius)
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named:"extras_bg.jpg")!)
    }
    
    
    func centerMapOnLocation(location: CLLocation, region: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            region * 2.0, region * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    
    @IBAction func close(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
