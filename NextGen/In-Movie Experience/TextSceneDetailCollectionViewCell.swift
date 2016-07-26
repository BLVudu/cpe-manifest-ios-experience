//
//  TextSceneDetailCollectionViewCell.swift
//

import Foundation
import UIKit

class TextSceneDetailCollectionViewCell: SceneDetailCollectionViewCell {
    
    static let ReuseIdentifier = "TextSceneDetailCollectionViewCellReuseIdentifier"
    
    override internal var _descriptionText: String? {
        didSet {
            descriptionLabel.text = _descriptionText
            descriptionLabel.sizeToFit()
        }
    }
    
}
