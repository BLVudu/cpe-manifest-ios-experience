//
//  LargeTextSceneDetailViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 4/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class LargeTextSceneDetailViewController: SceneDetailViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var timedEvent: NGDMTimedEvent!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textLabel.text = timedEvent.descriptionText
        
        if let imageURL = timedEvent.imageURL {
            imageView.setImageWithURL(imageURL)
        } else {
            imageView.image = UIImage.themeDefaultImage16By9()
        }
    }

}
