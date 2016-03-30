//
//  FilmCollectionViewCell.swift
//  NextGen
//
//  Created by Alec Ananian on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class FilmCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var film: TalentFilm? {
        didSet {
            if let imageURL = film?.imageURL {
                imageView.setImageWithURL(imageURL)
            } else {
                imageView.image = UIImage(named: "Blank Poster")
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        film = nil
    }
    
    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            if newValue {
                super.selected = true
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.whiteColor().CGColor
                
            } else if newValue == false {
                
                self.layer.borderWidth = 0
            }
        }
    }
    
}
