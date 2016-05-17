//
//  MapDetailViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/29/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit

class MapDetailViewController: SceneDetailViewController {
    
    @IBOutlet weak var mapView: MultiMapView!
    @IBOutlet weak var mapDescriptionLabel: UILabel?
    
    var timedEvent: NGDMTimedEvent!
    var appData: NGDMAppData!
    var location: NGDMLocation!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appData = timedEvent.appData!
        location = appData.location!
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        mapView.setLocation(center, zoomLevel: appData.zoomLevel, animated: false)
        mapView.addMarker(center, title: location.name, subtitle: location.address, icon: UIImage(named: "MOSMapPin"), autoSelect: true)
        
        if let text = appData.displayText {
            mapDescriptionLabel?.text = text
            mapDescriptionLabel?.sizeToFit()
        } else {
            mapDescriptionLabel?.removeFromSuperview()
        }
    }
    
}
