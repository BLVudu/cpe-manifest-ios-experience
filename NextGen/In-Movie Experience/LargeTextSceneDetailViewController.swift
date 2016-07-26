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
            imageView?.setImageWithURL(imageURL, completion: nil)
        } else {
            imageView?.removeFromSuperview()
        }
    }

}
