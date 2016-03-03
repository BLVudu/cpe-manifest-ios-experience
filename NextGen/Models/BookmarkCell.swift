
//
//  BookmarkCell.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/2/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit




class BookmarkCell: UICollectionViewCell, UIGestureRecognizerDelegate{
    


    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var mediaType: UILabel!
    @IBOutlet weak var caption: UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

   
    
    
}
