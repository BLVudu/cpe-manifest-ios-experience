//
//  ContentCell.swift
//

import UIKit
import NextGenDataManager

class TitledImageCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "TitledImageCellReuseIdentifier"
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    
    private var setImageSessionDataTask: NSURLSessionDataTask?
    
    var experience: NGDMExperience? {
        didSet {
            title = experience?.metadata?.title
            imageURL = experience?.imageURL
        }
    }
    
    var title: String? {
        set {
            titleLabel.text = newValue?.uppercaseString
        }
        
        get {
            return titleLabel.text
        }
    }
    
    var imageURL: NSURL? {
        set {
            if let task = setImageSessionDataTask {
                task.cancel()
                setImageSessionDataTask = nil
            }
            
            if let url = newValue {
                imageView.af_setImageWithURL(url)
            } else {
                imageView.af_cancelImageRequest()
                imageView.image = nil
            }
        }
        
        get {
            return nil
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        experience = nil
    }
    
}