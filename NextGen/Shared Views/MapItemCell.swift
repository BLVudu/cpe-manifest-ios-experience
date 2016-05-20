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
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    private var imageDataTask: NSURLSessionDataTask?
    
    var experience: NGDMExperience? {
        didSet {
            if let appData = experience?.appData {
                titleLabel.text = appData.title
                
                if let imageURL = appData.imageURL {
                    imageDataTask = imageView.setImageWithURL(imageURL)
                } else {
                    imageView.image = nil
                }
                
                subtitleLabel.text = nil
            } else {
                titleLabel.text = experience?.title
                
                if let imageURL = experience?.imageURL {
                    imageDataTask = imageView.setImageWithURL(imageURL)
                } else {
                    imageView.image = nil
                }
                
                if let childExperiences = experience?.childExperiences {
                    if childExperiences.count > 0 && childExperiences.first?.appData == nil {
                        subtitleLabel.text = String.localize((childExperiences.count == 1 ? "locations.count.one" : "locations.count.other"), variables: ["count": String(childExperiences.count)])
                    } else {
                        subtitleLabel.text = nil
                    }
                } else {
                    subtitleLabel.text = nil
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        imageView.image = nil
        subtitleLabel.text = nil
        if let task = imageDataTask {
            task.cancel()
            imageDataTask = nil
        }
    }
    
}