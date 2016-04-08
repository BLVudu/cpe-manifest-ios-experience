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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var playBtn: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var isVideo = false
    
    var location: NGDMLocation? {
        didSet {
            if let location = location {
                mapView.setLocation(location.latitude, longitude: location.longitude, zoomLevel: 15, animated: false)
                playBtn.hidden = true
            } else {
                mapView.hidden = true
            }
        }
    }
    
    override var selected: Bool {
        get {
            return super.selected
        }
        
        set {
            super.selected = true
            
            /*if newValue {
                self.playBtn.hidden = true
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.whiteColor().CGColor

            } else if newValue == false {
                if isVideo == true{
                    self.playBtn.hidden = false
                    
                } else {
                    self.playBtn.hidden = true
                }
                    
                self.layer.borderWidth = 0
            }*/
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        location = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mapView.mapType = MKMapType.Hybrid
    }
    
}

class MapDetailViewController: SceneDetailViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var mapAnnotation: MKPointAnnotation!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapCollectionView: UICollectionView!
    
    var timedEvent: NGDMTimedEvent!
    
    var location: NGDMLocation!
    var locationImages = []
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        location = timedEvent.location!
        mapView.mapType = MKMapType.Hybrid
        let center = setInitialMapLocation(animated: false)
        mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = center
        mapAnnotation.title = location.name
        mapAnnotation.subtitle = location.address
        mapView.addAnnotation(mapAnnotation)
        mapView.selectAnnotation(mapAnnotation, animated: true)
        
        self.imageView.hidden = true
       
    }
    
    func setInitialMapLocation(animated animated: Bool) -> CLLocationCoordinate2D {
        return mapView.setLocation(location.latitude, longitude: location.longitude, zoomLevel: 15, animated: animated)
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
        
        if indexPath.row == 0 { // Map thumbnail
            cell.location = location
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 { // Map thumbnail
            setInitialMapLocation(animated: true)
            mapView.selectAnnotation(mapAnnotation, animated: true)
        }
        
        /*if (indexPath.row == locationImages.count+1){
            self.mapView.alpha = 0.5
            NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.PlayerShouldPause, object: nil)
            self.videoView.hidden = false
            self.imageView.hidden = true
            let thisExperience = experience.childExperiences()[0]
            if let videoURL = thisExperience.videoURL(), videoPlayerViewController = videoPlayerViewController() {
                if let player = videoPlayerViewController.player {
                    player.removeAllItems()
                }
                
                videoPlayerViewController.playerControlsVisible = false
                videoPlayerViewController.lockTopToolbar = true
                videoPlayerViewController.playVideoWithURL(videoURL)
            }
        } else if (indexPath.row == 0){
            self.imageView.alpha = 0
            self.videoView.hidden = true
            self.mapView.alpha = 1
        } else {
            self.mapView.alpha = 0.5
            self.imageView.hidden = false
            self.imageView.alpha = 1
            self.videoView.hidden = true
            let imgData = NSData(contentsOfURL:NSURL(string: locationImages[indexPath.row-1] as! String)!)
            self.imageView.image = UIImage(data: imgData!)
        }*/
    }
    
    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "SceneDetailMapPoint")
        annotationView.image = UIImage(named: "MOSMapPin")
        annotationView.canShowCallout = true
        return annotationView
    }
    
}
