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
            setTitle(experience?.metadata?.title)
            setImageURL(experience?.imageURL)
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
    
    func setTitle(title: String?) {
        titleLabel.text = title?.uppercaseString
    }
    
    func setImageURL(url: NSURL?) {
        if let url = url {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
                if let strongSelf = self {
                    strongSelf.setImageSessionDataTask = strongSelf.imageView.setImageWithURL(url, completion: nil)
                }
            }
        } else {
            imageView.image = nil
        }
    }
    
}