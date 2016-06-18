//
//  LargeTextSceneDetailViewController.swift
//

import UIKit
import NextGenDataManager

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
