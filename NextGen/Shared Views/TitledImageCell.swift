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
            titleLabel.text = experience?.metadata?.title?.uppercaseString
            
            if let imageURL = experience?.imageURL {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
                    if let strongSelf = self {
                        strongSelf.setImageSessionDataTask = strongSelf.imageView.setImageWithURL(imageURL, completion: nil)
                    }
                }
            } else {
                imageView.image = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        experience = nil
        if let task = setImageSessionDataTask {
            task.cancel()
            setImageSessionDataTask = nil
        }
    }
    
}