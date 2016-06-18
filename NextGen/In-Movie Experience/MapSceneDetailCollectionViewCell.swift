//
//  MapSceneDetailCollectionViewCell.swift
//

import MapKit

class MapSceneDetailCollectionViewCell: SceneDetailCollectionViewCell {
    
    static let ReuseIdentifier = "MapSceneDetailCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak var mapView: MultiMapView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mapView.removeControls()
    }
    
    override func timedEventDidChange() {
        super.timedEventDidChange()
        
        if let appData = timedEvent?.appData, location = appData.location {
            let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            mapView.setLocation(center, zoomLevel: appData.zoomLevel, animated: false)
            mapView.addMarker(center, title: location.name, subtitle: location.address, icon: UIImage(named: "MOSMapPin"), autoSelect: false)
        }
        
        mapView.userInteractionEnabled = false
    }
    
}
