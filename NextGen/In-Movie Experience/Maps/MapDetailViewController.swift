//
//  MapDetailViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/29/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit

class MapDetailCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "MapDetailCellReuseIdentifier"
    
    @IBOutlet weak var mapView: MultiMapView!
    @IBOutlet weak var mapLabel: UILabel!
    
    var location: NGDMLocation? {
        didSet {
            if let location = location {
                let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                mapView.setLocation(center, zoomLevel: 15, animated: false)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        location = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mapView.userInteractionEnabled = false
    }
    
}

class MapDetailViewController: SceneDetailViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var mapView: MultiMapView!
    @IBOutlet weak var mapCollectionView: UICollectionView!
    
    var timedEvent: NGDMTimedEvent!
    
    var location: NGDMLocation!
    var center: CLLocationCoordinate2D!
    var locationImages = []
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        location = timedEvent.location!
        center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        mapView.setLocation(center, zoomLevel: 15, animated: false)
        mapView.addMarker(center, title: location.name, subtitle: location.address, icon: experience?.appearance?.buttonImage, autoSelect: true)
    }
    
    func videoPlayerViewController() -> VideoPlayerViewController? {
        for viewController in self.childViewControllers {
            if viewController is VideoPlayerViewController {
                return viewController as? VideoPlayerViewController
            }
        }
        
        return nil
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MapDetailCell.ReuseIdentifier, forIndexPath: indexPath) as! MapDetailCell
        cell.location = location
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        mapView.setLocation(center, zoomLevel: 15, animated: true)
    }
    
}
