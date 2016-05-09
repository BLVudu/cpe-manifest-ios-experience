//
//  ExtrasImageGalleryViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 3/19/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

struct GalleryNotification {
    
    static let reloadGallery = "galleryShouldReload"
    static let updatePageControl = "galleryPageControlShouldUpdate"
    static let showPageControl = "galleryPageControlShouldDisplay"
}

class ExtrasImageGalleryViewController: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var galleryPageLabel: UILabel!
    @IBOutlet weak var galleryScrollView: UIScrollView!

    @IBOutlet weak var fullScreenButton: UIButton!

    var originalFrame: CGRect!
    var originalScrollViewFrame: CGRect!
    var currentIndex = 0
    var gallery: NGDMGallery?

    @IBOutlet weak var galleryPageControl: UIPageControl!
    private var _scrollViewPageWidth: CGFloat = 0
    var isFullScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryPageControl.hidden = true
        galleryPageLabel.hidden = true
        titleLabel.hidden = true

        
        NSNotificationCenter.defaultCenter().addObserverForName(GalleryNotification.reloadGallery, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {[weak self] (notification) -> Void in
            
            if let strongSelf = self{
                    strongSelf.viewDidLayoutSubviews()
                    strongSelf.currentIndex = 0
  
                }
            })
       
    }
     override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         self.view.backgroundColor = UIColor.blackColor()
        
        if self.isFullScreen {
            
            self.view.superview!.frame = UIScreen.mainScreen().bounds

        }

        
        if gallery == nil {
            return
        } else {
            
            for view in galleryScrollView.subviews{
                if view.isKindOfClass(UIImageView){
                    view.removeFromSuperview()
                }
            }
            
        titleLabel.text = gallery!.metadata?.title
        let numPictures = gallery!.pictures != nil ? gallery!.pictures!.count : 0
        var imageViewX: CGFloat = 0
        _scrollViewPageWidth = CGRectGetWidth(galleryScrollView.bounds)
        for i in 0 ..< numPictures {
            let imageView = UIImageView()
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            imageView.frame = CGRectMake(imageViewX, 0, _scrollViewPageWidth, CGRectGetHeight(galleryScrollView.bounds))
            imageView.clipsToBounds = true
            imageView.tag = i + 1
            galleryScrollView.addSubview(imageView)
            imageViewX += _scrollViewPageWidth
        }
        galleryPageControl.numberOfPages = (gallery!.pictures?.count)!
        
        
        galleryScrollView.contentSize = CGSizeMake(CGRectGetWidth(UIScreen.mainScreen().bounds) * CGFloat(numPictures), CGRectGetHeight(UIScreen.mainScreen().bounds))
        loadImageForPage(currentIndex)
        galleryScrollView.setContentOffset(CGPointMake(CGFloat(currentIndex) * _scrollViewPageWidth, 0), animated: false)

        }

    }
    
    func loadImageForPage(page: Int) {
        
        if let imageView = galleryScrollView.viewWithTag(page + 1) as? UIImageView, pictures = gallery!.pictures {
            if imageView.image == nil {
                if let imageURL = pictures[page].imageURL {
                    imageView.setImageWithURL(imageURL)
                    imageView.userInteractionEnabled = true
                }
            }
            
            galleryPageControl.currentPage = page
            galleryPageLabel.text = "\(page+1) /\(pictures.count)"
            
        }
        
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / _scrollViewPageWidth)
        loadImageForPage(page)
        currentIndex = page
        NSNotificationCenter.defaultCenter().postNotificationName(GalleryNotification.updatePageControl, object: nil, userInfo: ["currentPage" : currentIndex])
            }
    
 
    //MARK: Actions
    @IBAction func toggleFullScreen(sender: AnyObject) {
        self.isFullScreen = !self.isFullScreen
        self.titleLabel.hidden = !self.isFullScreen
        self.galleryPageControl.hidden = !self.isFullScreen
        self.galleryPageLabel.hidden = !self.isFullScreen
        self.fullScreenButton.setImage(UIImage(named: self.isFullScreen ? "Minimize" :"Maximize"), forState: .Normal)
        self.fullScreenButton.setImage(UIImage(named: self.isFullScreen ? "Minimize Highlighted" : "Maximize Highlighted"), forState: .Highlighted)
        
        NSNotificationCenter.defaultCenter().postNotificationName(GalleryNotification.showPageControl, object: nil, userInfo: ["showPageControl" : self.isFullScreen])
        
        UIView.animateWithDuration(0.25, animations: {
            let galleryContainerView = self.view.superview
            let galleryScrollView = self.galleryScrollView.superview
            if self.isFullScreen {
                    self.view.bringSubviewToFront(galleryScrollView!)
                    self.originalFrame = galleryContainerView?.frame
                    self.originalScrollViewFrame = galleryScrollView?.frame
                    //galleryScrollView?.frame = UIScreen.mainScreen().bounds
                    galleryContainerView?.frame = UIScreen.mainScreen().bounds
                    //self.galleryScrollView.contentSize = CGSizeMake(CGRectGetWidth((UIScreen.mainScreen().bounds)) * CGFloat(self.gallery!.pictures!.count), CGRectGetHeight(UIScreen.mainScreen().bounds))

            } else {
                
                //galleryScrollView?.frame = self.originalScrollViewFrame
                galleryContainerView?.frame = self.originalFrame

            }
                
            
          
        })
}
}



