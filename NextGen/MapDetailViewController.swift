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
            if newValue {
                super.selected = true
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
            }
        }
    }
    
}

class MapDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapCollectionView: UICollectionView!
    @IBOutlet weak var videoView: UIView!
    
    var location: NGDMLocation!
    var timedEvent: NGDMTimedEvent! {
        didSet {
            if let eventLocation = timedEvent.location {
                location = eventLocation
            }
        }
    }
    
    var initialLocation = CLLocation(latitude: 0, longitude: 0)
    let regionRadius: CLLocationDistance = 2000
    var locationImages = []
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = mapView.setLocation(location.latitude, longitude: location.longitude, zoomLevel: 13, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = location.name
        annotation.subtitle = location.address
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        
        self.imageView.hidden = true
        self.videoView.hidden = true
    }
    
    func videoPlayerViewController() -> VideoPlayerViewController? {
        for viewController in self.childViewControllers {
            if viewController is VideoPlayerViewController {
                return viewController as? VideoPlayerViewController
            }
        }
        
        return nil
    }
    
    // MARK: Actions
    @IBAction func close(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(kVideoPlayerShouldResume, object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
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
        /*if (indexPath.row == locationImages.count+1){
            self.mapView.alpha = 0.5
            NSNotificationCenter.defaultCenter().postNotificationName(kVideoPlayerShouldPause, object: nil)
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
    
}
