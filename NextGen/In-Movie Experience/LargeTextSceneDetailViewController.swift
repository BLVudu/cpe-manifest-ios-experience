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
            imageView?.af_setImageWithURL(imageURL)
        } else {
            imageView?.af_cancelImageRequest()
            imageView?.removeFromSuperview()
        }
    }

}
