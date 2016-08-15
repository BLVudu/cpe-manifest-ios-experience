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
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
                    if let strongSelf = self {
                        strongSelf.setImageSessionDataTask = strongSelf.imageView.setImageWithURL(url, completion: nil)
                    }
                }
            } else {
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