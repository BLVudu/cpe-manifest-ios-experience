//
//  LargeTextSceneDetailViewController.swift
//

import UIKit
import NextGenDataManager

class LargeTextSceneDetailViewController: SceneDetailViewController {
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var textLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textLabel.text = timedEvent?.descriptionText
        
        if let imageURL = timedEvent?.imageURL {
            imageView?.sd_setImage(with: imageURL)
        } else {
            imageView?.sd_cancelCurrentImageLoad()
            imageView?.removeFromSuperview()
        }
    }

}
