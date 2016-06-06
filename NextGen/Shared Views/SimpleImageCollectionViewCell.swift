//
//  SimpleImageCollectionViewCell.swift
//  NextGenExample
//
//  Created by Alec Ananian on 6/3/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class SimpleImageCollectionViewCell: UICollectionViewCell {
    
    static let BaseReuseIdentifier = "SimpleImageCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak private var imageView: UIImageView!
    private var setImageSessionDataTask: NSURLSessionDataTask?
    
    var showsSelectedBorder = false
    
    var imageURL: NSURL? {
        didSet {
            if let url = imageURL {
                setImageSessionDataTask = imageView.setImageWithURL(url)
            } else {
                image = UIImage(named: "Blank Poster")
            }
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        
        set {
            imageView.image = image
        }
    }
    
    override var selected: Bool {
        didSet {
            if self.selected && showsSelectedBorder {
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.whiteColor().CGColor
            } else {
                self.layer.borderWidth = 0
                self.layer.borderColor = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.selected = false
        
        image = nil
        
        if let task = setImageSessionDataTask {
            task.cancel()
            setImageSessionDataTask = nil
        }
    }

}
