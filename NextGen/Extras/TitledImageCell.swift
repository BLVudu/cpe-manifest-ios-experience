//
//  ContentCell.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/21/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class TitledImageCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "TitledImageCellReuseIdentifier"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var experience: NGDMExperience? {
        didSet {
            if let title = experience?.metadata?.title {
                titleLabel.text = title.uppercaseString
            } else {
                titleLabel.text = nil
            }
            
            if let imageURL = experience?.imageURL {
                imageView.setImageWithURL(imageURL)
            } else {
                imageView.image = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        experience = nil
    }
    
}