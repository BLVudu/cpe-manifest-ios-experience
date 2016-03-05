//
//  ActorGalleryViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/4/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class ActorGalleryViewController: UIViewController{
    
    var images = [String]()
    func mediaGalleryViewController() -> MediaGalleryViewController? {
        for viewController in self.childViewControllers {
            if viewController is MediaGalleryViewController {
                return viewController as? MediaGalleryViewController
            }
        }
        
        return nil
    }
    
    

    
    override func viewDidLoad() {
        let mediaViewController = mediaGalleryViewController()
        mediaViewController?.imageGallery = images

    }
    
    @IBAction func close(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

