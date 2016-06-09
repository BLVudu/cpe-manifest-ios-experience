//
//  ContentCell.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/21/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import NextGenDataManager

class TitledImageCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "TitledImageCellReuseIdentifier"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private var _setImageSessionDataTask: NSURLSessionDataTask?
    
    var experience: NGDMExperience? {
        didSet {
            titleLabel.text = experience?.metadata?.title?.uppercaseString
            
            if let imageURL = experience?.imageURL {
                _setImageSessionDataTask = imageView.setImageWithURL(imageURL)
            } else {
                imageView.image = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        experience = nil
        if let task = _setImageSessionDataTask {
            task.cancel()
            _setImageSessionDataTask = nil
        }
    }
    
}