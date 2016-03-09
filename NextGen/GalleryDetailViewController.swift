//
//  GalleryDetailViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/29/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class GalleryDetailViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var gallery: NGDMGallery!
    
    func imageGalleryViewController() -> ImageGalleryViewController? {
        for viewController in self.childViewControllers {
            if viewController is ImageGalleryViewController {
                return viewController as? ImageGalleryViewController
            }
        }
        
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageGalleryViewController = imageGalleryViewController() {
            imageGalleryViewController.gallery = gallery
            pageControl.numberOfPages = gallery.pictures.count
            
            NSNotificationCenter.defaultCenter().addObserverForName("updateControl", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
                if let userInfo = notification.userInfo, index = userInfo["index"] as? Int {
                    self.pageControl.currentPage = index
                }
            }
        }
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
