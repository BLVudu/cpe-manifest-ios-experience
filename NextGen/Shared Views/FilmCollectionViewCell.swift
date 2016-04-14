//
//  FilmCollectionViewCell.swift
//  NextGen
//
//  Created by Alec Ananian on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class FilmCollectionViewCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "FilmCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var _setImageSessionDataTask: NSURLSessionDataTask?
    private var _getFilmImageSessionDataTask: NSURLSessionDataTask?
    
    var film: TalentFilm? {
        didSet {
            if film != nil {
                _getFilmImageSessionDataTask = film!.getImageURL({ (imageURL) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if imageURL != nil {
                            self._setImageSessionDataTask = self.imageView.setImageWithURL(imageURL!)
                        } else {
                            self.imageView.image = UIImage(named: "Blank Poster")
                        }
                    })
                })
            } else {
                imageView.image = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        film = nil
        
        if let task = _setImageSessionDataTask {
            task.cancel()
            _setImageSessionDataTask = nil
        }
        
        if let task = _getFilmImageSessionDataTask {
            task.cancel()
            _getFilmImageSessionDataTask = nil
        }
    }
    
}
