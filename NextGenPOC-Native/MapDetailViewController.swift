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
    
}


class MapDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapCollectionView: UICollectionView!
    
    var initialLocation = CLLocation(latitude: 0, longitude: 0)
    var locationName: String!
    let regionRadius: CLLocationDistance = 2000
    var locationImages = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMapOnLocation(initialLocation, region: regionRadius)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = initialLocation.coordinate
        annotation.title = locationName
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        
        self.imageView.hidden = true

    }
    
    
    func centerMapOnLocation(location: CLLocation, region: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            region * 2.0, region * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    
    @IBAction func close(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("mapCell", forIndexPath: indexPath) as! MapDetailCell
        let imgData = NSData(contentsOfURL:NSURL(string: locationImages[indexPath.row] as! String)!)
        cell.mapImage.image = UIImage(data: imgData!)
        print(locationImages[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return locationImages.count
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let imgData = NSData(contentsOfURL:NSURL(string: locationImages[indexPath.row] as! String)!)
        self.imageView.hidden = false
        self.mapView.alpha = 0.5
        self.imageView.image = UIImage(data: imgData!)
        
    }
    
    
}
