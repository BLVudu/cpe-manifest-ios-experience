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
    
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var mapThumbnail: MKMapView!
    
    @IBOutlet weak var playBtn: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var isVideo = false
    
    
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
    
    var experience: NGEExperienceType!
    var initialLocation = CLLocation(latitude: 0, longitude: 0)
    var locationName: String!
    let regionRadius: CLLocationDistance = 2000
    var locationImages = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMapOnLocation(initialLocation, region: regionRadius, view:mapView)
        //experience = NextGenDataManager.sharedInstance.outOfMovieExperienceCategories()[2]
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = initialLocation.coordinate
        annotation.title = locationName
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

    
    
    func centerMapOnLocation(location: CLLocation, region: CLLocationDistance, view: MKMapView) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            region * 2.0, region * 2.0)
        view.setRegion(coordinateRegion, animated: true)
    }

    
    @IBAction func close(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("endClip",object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("resumeMovie", object: nil)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //let thisExperience = experience.childExperiences()[0]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("mapCell", forIndexPath: indexPath) as! MapDetailCell

        
        if indexPath.row == 0 {
            centerMapOnLocation(initialLocation, region: regionRadius, view: cell.mapThumbnail)
            cell.isVideo = false
            cell.mapImage.hidden = true
            cell.label.hidden = false
            cell.playBtn.hidden = true
        }
         else if indexPath.row == locationImages.count+1 {
            /*let imgData = NSData(contentsOfURL:NSURL(string: (thisExperience.thumbnailImagePath()! as String))!)
            cell.isVideo = true
            cell.mapImage.image = UIImage(data: imgData!)
            cell.mapThumbnail.hidden = true
            cell.label.hidden = true
            cell.playBtn.hidden = false*/
            
        } else {
        let imgData = NSData(contentsOfURL:NSURL(string: locationImages[indexPath.row-1] as! String)!)
        cell.mapImage.image = UIImage(data: imgData!)
        cell.isVideo = false
        cell.mapThumbnail.hidden = true
        cell.label.hidden = true
        cell.playBtn.hidden = true
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return locationImages.count+2
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        
        if (indexPath.row == locationImages.count+1){
            self.mapView.alpha = 0.5
            NSNotificationCenter.defaultCenter().postNotificationName("pauseMovie", object: nil)
            self.videoView.hidden = false
            self.imageView.hidden = true
            /*let thisExperience = experience.childExperiences()[0]
            if let videoURL = thisExperience.videoURL(), videoPlayerViewController = videoPlayerViewController() {
                if let player = videoPlayerViewController.player {
                    player.removeAllItems()
                }
                
                videoPlayerViewController.playerControlsVisible = false
                videoPlayerViewController.lockTopToolbar = true
                videoPlayerViewController.playVideoWithURL(videoURL)
                
                NSNotificationCenter.defaultCenter().addObserverForName("endClip", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
                    
                    videoPlayerViewController.pauseVideo()
                    videoPlayerViewController.player.removeAllItems()
  
                }
 
            }*/
        
        }
        else if (indexPath.row == 0){
            NSNotificationCenter.defaultCenter().postNotificationName("resumeMovie", object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("endClip",object: nil)
            self.imageView.alpha = 0
            self.videoView.hidden = true
            self.mapView.alpha = 1
        
        }else{
        NSNotificationCenter.defaultCenter().postNotificationName("resumeMovie", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("endClip",object: nil)
        self.mapView.alpha = 0.5
        self.imageView.hidden = false
        self.imageView.alpha = 1
        self.videoView.hidden = true
        let imgData = NSData(contentsOfURL:NSURL(string: locationImages[indexPath.row-1] as! String)!)
        self.imageView.image = UIImage(data: imgData!)
        
    }
    }
    
    
}
