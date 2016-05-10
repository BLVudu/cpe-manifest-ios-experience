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
    
    var childCount = 0
    
    var appData: NGDMAppData? {
        didSet {
            setNeedsLayout()
        }
    }
    
    var appDataType: NGDMAppData? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let appDataType = appDataType {
            locationName.text = appDataType.type
            locationImage.image = appDataType.thumbnailImage
            childLocationsCount.text = childCount > 0 ? "\(childCount) locations" : nil
        } else {
            locationName.text = appData?.location?.name
            locationImage.image = appData?.thumbnailImage
            childLocationsCount.text = nil
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        locationName.text = nil
        locationImage.image = nil
        childLocationsCount.text = nil
        childCount = 0
    }
    
}