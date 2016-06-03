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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        image = nil
        
        if let task = setImageSessionDataTask {
            task.cancel()
            setImageSessionDataTask = nil
        }
    }

}
