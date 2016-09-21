//
//  ContentCell.swift
//

import UIKit
import NextGenDataManager

class TitledImageCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "TitledImageCellReuseIdentifier"
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    
    private var setImageSessionDataTask: URLSessionDataTask?
    
    var experience: NGDMExperience? {
        didSet {
            title = experience?.metadata?.title
            imageURL = experience?.imageURL
        }
    }
    
    var title: String? {
        set {
            titleLabel.text = newValue?.uppercased()
        }
        
        get {
            return titleLabel.text
        }
    }
    
    var imageURL: URL? {
        set {
            if let task = setImageSessionDataTask {
                task.cancel()
                setImageSessionDataTask = nil
            }
            
            if let url = newValue {
                imageView.sd_setImage(with: url)
            } else {
                imageView.sd_cancelCurrentImageLoad()
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
