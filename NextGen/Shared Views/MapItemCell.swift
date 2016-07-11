//
//  MapItemCell.swift
//

import UIKit
import NextGenDataManager

class MapItemCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "MapItemCellReuseIdentifier"
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var playButton: UIButton!
    private var setImageSessionDataTask: NSURLSessionDataTask?
    
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        
        get {
            return titleLabel.text
        }
    }
    
    var subtitle: String? {
        set {
            subtitleLabel.text = newValue
        }
        
        get {
            return subtitleLabel.text
        }
    }
    
    var imageURL: NSURL? {
        set {
            if let imageURL = newValue {
                setImageSessionDataTask = imageView.setImageWithURL(imageURL, completion: nil)
            } else {
                imageView.image = nil
            }
        }
        
        get {
            return nil
        }
    }
    
    var playButtonVisible: Bool {
        set {
            playButton.hidden = !newValue
        }
        
        get {
            return !playButton.hidden
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        title = nil
        subtitle = nil
        imageURL = nil
        playButton.hidden = true
        
        if let task = setImageSessionDataTask {
            task.cancel()
            setImageSessionDataTask = nil
        }
    }
    
}