//
//  SceneDetailCollectionViewCell.swift
//

import UIKit
import NextGenDataManager

class SceneDetailCollectionViewCell: UICollectionViewCell {
    
    struct Constants {
        static let UpdateInterval: Double = 15
    }
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var title: String? {
        set {
            titleLabel?.text = newValue?.uppercased()
        }
        
        get {
            return titleLabel?.text
        }
    }
    
    internal var descriptionText: String? {
        set {
            descriptionLabel.text = newValue
        }
        
        get {
            return descriptionLabel.text
        }
    }
    
    var timedEvent: NGDMTimedEvent? {
        didSet {
            if timedEvent != oldValue {
                timedEventDidChange()
            }
        }
    }
    
    private var lastSavedTime: Double = -1.0
    var currentTime: Double = -1.0 {
        didSet {
            if lastSavedTime == -1 || abs(currentTime - lastSavedTime) >= Constants.UpdateInterval {
                lastSavedTime = currentTime
                currentTimeDidChange()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lastSavedTime = -1.0
        timedEvent = nil
    }
    
    internal func timedEventDidChange() {
        title = timedEvent?.experience?.title
        
        if timedEvent != nil && timedEvent!.isType(.clipShare) {
            descriptionText = String.localize("clipshare.description")
        } else {
            descriptionText = timedEvent?.descriptionText
        }
    }
    
    internal func currentTimeDidChange() {
        // Override
    }
}
