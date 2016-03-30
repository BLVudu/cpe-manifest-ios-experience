//
//  SceneDetailCollectionViewCell.swift
//  NextGen
//
//  Created by Alec Ananian on 2/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class SceneDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var extraDescriptionLabel: UILabel?
    
    var title: String? {
        get {
            return titleLabel?.text
        }
        
        set(v) {
            if let text = v {
                titleLabel?.text = text.uppercaseString
            } else {
                titleLabel?.text = nil
            }
        }
    }
    
    var descriptionText: String? {
        get {
            return descriptionLabel.text
        }
        
        set(v) {
            descriptionLabel.text = v
        }
    }
    
    var extraDescriptionText: String? {
        get {
            return extraDescriptionLabel?.text
        }
        
        set(v) {
            extraDescriptionLabel?.text = v
        }
    }
    
    private var _experience: NGDMExperience!
    var experience: NGDMExperience? {
        get {
            return _experience
        }
        
        set (v) {
            _experience = v
            
            if let experience = _experience {
                title = experience.metadata?.title
            } else {
                title = nil
            }
        }
    }
    
    internal var _timedEvent: NGDMTimedEvent!
    var timedEvent: NGDMTimedEvent? {
        get {
            return _timedEvent
        }
        
        set(v) {
            if v == nil {
                descriptionText = nil
                extraDescriptionText = nil
                _timedEvent = nil
            } else if _timedEvent != v {
                _timedEvent = v
                
                if let event = _timedEvent, experience = experience {
                    descriptionText = event.getDescriptionText(experience)
                    extraDescriptionText = event.extraDescriptionText
                } else {
                    descriptionText = nil
                    extraDescriptionText = nil
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        experience = nil
        timedEvent = nil
    }
}
