//
//  SimpleMapCollectionViewCell.swift
//

import UIKit
import MapKit

class SimpleMapCollectionViewCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "SimpleMapCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak private var mapView: MultiMapView!
    @IBOutlet weak private var mapTextLabel: UILabel?
    
    func setLocation(_ location: CLLocationCoordinate2D, zoomLevel: Float) {
        mapView.setLocation(location, zoomLevel: zoomLevel, animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mapTextLabel?.text = String.localize("locations.map")
    }
    
}
