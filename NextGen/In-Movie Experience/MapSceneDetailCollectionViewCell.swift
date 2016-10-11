//
//  MapSceneDetailCollectionViewCell.swift
//

import MapKit

class MapSceneDetailCollectionViewCell: SceneDetailCollectionViewCell {
    
    static let ReuseIdentifier = "MapSceneDetailCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak var mapView: MultiMapView!
    
    override func timedEventDidChange() {
        super.timedEventDidChange()
        
        if let appData = timedEvent?.appData, let location = appData.location {
            let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            mapView.setLocation(center, zoomLevel: appData.zoomLevel - 4, animated: false, adjustView: false)
            _ = mapView.addMarker(center, title: location.name, subtitle: location.address, icon: location.iconImage, autoSelect: false)
        }
        
        mapView.isUserInteractionEnabled = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mapView.clear()
    }
    
}
