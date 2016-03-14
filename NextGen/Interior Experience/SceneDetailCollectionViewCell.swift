//
//  SceneDetailCollectionViewCell.swift
//  NextGen
//
//  Created by Alec Ananian on 2/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit

class SceneDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var extraDescriptionLabel: UILabel?
    @IBOutlet weak var mapView: MKMapView!
    
    var title: String? {
        get {
            return titleLabel.text
        }
        
        set(v) {
            if let text = v {
                titleLabel.text = text.uppercaseString
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var descriptionText: String? {
        get {
            return descriptionLabel.text
        }
        
        set(v) {
            descriptionLabel.text = v
        }
    }
    
    var extraDescriptionText: String? {
        get {
            return extraDescriptionLabel?.text
        }
        
        set(v) {
            extraDescriptionLabel?.text = v
        }
    }
    
    private var _imageURL: NSURL!
    var imageURL: NSURL? {
        get {
            return _imageURL
        }
        
        set(v) {
            _imageURL = v
            
            if let url = _imageURL {
                imageView?.setImageWithURL(url)
            } else {
                imageView?.image = nil
            }
        }
    }
    
    private var _experience: NGDMExperience!
    var experience: NGDMExperience? {
        get {
            return _experience
        }
        
        set (v) {
            _experience = v
            
            if let experience = _experience {
                title = experience.metadata?.title
            } else {
                title = nil
            }
        }
    }
    
    private var _timedEvent: NGDMTimedEvent!
    var timedEvent: NGDMTimedEvent? {
        get {
            return _timedEvent
        }
        
        set(v) {
            if _timedEvent != v {
                _timedEvent = v
                
                if let event = _timedEvent, experience = experience {
                    imageURL = event.getImageURL(experience)
                    descriptionText = event.getDescriptionText(experience)
                    extraDescriptionText = nil
                } else {
                    imageURL = nil
                    descriptionText = nil
                    extraDescriptionText = nil
                }
            }
        }
    }
    
    private var _theTakeProducts: [TheTakeProduct]!
    private var _currentProduct: TheTakeProduct?
    var theTakeProducts: [TheTakeProduct]? {
        get {
            return _theTakeProducts
        }
        
        set(v) {
            _theTakeProducts = v
            
            if let products = _theTakeProducts, product = products.first {
                if _currentProduct != product {
                    _currentProduct = product
                    imageURL = product.imageURL
                    descriptionText = product.brand
                    extraDescriptionText = product.name
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        experience = nil
        timedEvent = nil
    }
    
    func centerMapOnLocation(location: CLLocation, region: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            region * 2.0, region * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}
