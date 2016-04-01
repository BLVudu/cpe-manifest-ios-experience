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
    
    var gallery: NGDMGallery?
    var audioVisual: NGDMAudioVisual?
    
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
            if let gallery = gallery {
                imageGalleryViewController.gallery = gallery
                pageControl.numberOfPages = gallery.pictures.count
            } else if let audioVisual = audioVisual {
                imageGalleryViewController.audioVisual = audioVisual
                pageControl.numberOfPages = 1
            }
            
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
