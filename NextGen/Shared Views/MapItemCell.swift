//
//  MapItemCell.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 5/9/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit



class MapItemCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "MapItemCellReuseIdentifier"
    
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var childLocationsCount: UILabel!
    
    var experience: NGDMExperience? {
        didSet {
            if let appData = experience?.appData {
                locationName.text = appData.title
                
                if let imageURL = appData.imageURL {
                    locationImage.setImageWithURL(imageURL)
                } else {
                    locationImage.image = nil
                }
                
                childLocationsCount.text = nil
            } else {
                locationName.text = experience?.title
                
                if let imageURL = experience?.imageURL {
                    locationImage.setImageWithURL(imageURL)
                } else {
                    locationImage.image = nil
                }
                
                if let childExperiences = experience?.childExperiences {
                    if childExperiences.count > 0 && childExperiences.first?.appData == nil {
                        childLocationsCount.text = String(childExperiences.count) + (childExperiences.count == 1 ? " location" : " locations")
                    } else {
                        childLocationsCount.text = nil
                    }
                } else {
                    childLocationsCount.text = nil
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        locationName.text = nil
        locationImage.image = nil
        childLocationsCount.text = nil
    }
    
}