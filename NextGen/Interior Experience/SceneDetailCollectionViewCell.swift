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
    
    var title: String? {
        get {
            return titleLabel?.text
        }
        
        set {
            titleLabel?.text = (newValue != nil ? newValue!.uppercaseString : nil)
        }
    }
    
    var descriptionText: String? {
        get {
            return descriptionLabel.text
        }
        
        set {
            descriptionLabel.text = newValue
        }
    }
    
    private var _experience: NGDMExperience!
    var experience: NGDMExperience? {
        get {
            return _experience
        }
        
        set {
            if _experience != newValue {
                _experience = newValue
                experienceDidChange()
            }
        }
    }
    
    internal var _timedEvent: NGDMTimedEvent!
    var timedEvent: NGDMTimedEvent? {
        get {
            return _timedEvent
        }
        
        set {
            if _timedEvent != newValue {
                _timedEvent = newValue
                timedEventDidChange()
            }
        }
    }
    
    internal var currentTime: Double = -1.0
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        experience = nil
        timedEvent = nil
    }
    
    func experienceDidChange() {
        title = experience?.metadata?.title
    }
    
    func timedEventDidChange() {
        if let timedEvent = timedEvent, experience = experience {
            descriptionText = timedEvent.getDescriptionText(experience)
        } else {
            descriptionText = nil
        }
    }
}
