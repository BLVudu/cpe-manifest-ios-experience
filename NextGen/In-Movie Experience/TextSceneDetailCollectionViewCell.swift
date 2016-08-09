//
//  TextSceneDetailCollectionViewCell.swift
//

import Foundation
import UIKit

class TextSceneDetailCollectionViewCell: SceneDetailCollectionViewCell {
    
    static let ReuseIdentifier = "TextSceneDetailCollectionViewCellReuseIdentifier"
    
    override internal var descriptionText: String? {
        set {
            super.descriptionText = newValue
            descriptionLabel.sizeToFit()
        }
        
        get {
            return super.descriptionText
        }
    }
    
}
