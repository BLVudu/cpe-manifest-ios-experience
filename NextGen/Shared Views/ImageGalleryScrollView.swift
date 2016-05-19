//
//  ImageGalleryScrollView.swift
//  NextGen
//
//  Created by Alec Ananian on 5/16/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

struct ImageGalleryNotification {
    static let DidScrollToPage = "kImageGalleryNotificationDidScrollToPage"
    static let DidToggleFullScreen = "kImageGalleryNotificationDidToggleFullScreen"
}

class ImageGalleryScrollView: UIScrollView, UIScrollViewDelegate {
    
    private struct Constants {
        static let ToolbarHeight: CGFloat = 44
        static let CloseButtonSize: CGFloat = 44
        static let CloseButtonPadding: CGFloat = 15
    }
    
    private var toolbar: UIToolbar!
    private var isFullScreen = false
    private var originalFrame: CGRect?
    private var originalContainerFrame: CGRect?
    private var closeButton: UIButton!
    
    private var scrollViewPageWidth: CGFloat = 0
    private var currentPage = 0 {
        didSet {
            loadGalleryImageForPage(currentPage)
            loadGalleryImageForPage(currentPage + 1)
            NSNotificationCenter.defaultCenter().postNotificationName(ImageGalleryNotification.DidScrollToPage, object: nil, userInfo: ["page": currentPage])
        }
    }
    
    var gallery: NGDMGallery? {
        didSet {
            // Reset gallery
            for subview in self.subviews {
                if let subview = subview as? UIImageView {
                    subview.removeFromSuperview()
                }
            }
            
            if let frame = originalContainerFrame {
                self.superview?.frame = frame
            }
            
            if let frame = originalFrame {
                self.frame = frame
            }
            
            isFullScreen = false
            toolbar.hidden = isFullScreen
            closeButton.hidden = !isFullScreen
            currentPage = 0
            layoutPages()
        }
    }
    
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.delegate = self
        
        toolbar = UIToolbar()
        toolbar.barStyle = .Black
        toolbar.translucent = true
        
        let fullScreenButton = UIButton(frame: CGRectMake(0, 0, Constants.ToolbarHeight, Constants.ToolbarHeight))
        fullScreenButton.tintColor = UIColor.whiteColor()
        fullScreenButton.setImage(UIImage(named: "Maximize"), forState: .Normal)
        fullScreenButton.setImage(UIImage(named: "Maximize Highlighted"), forState: .Highlighted)
        fullScreenButton.addTarget(self, action: #selector(self.toggleFullScreen), forControlEvents: .TouchUpInside)
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(customView: fullScreenButton)]
        
        closeButton = UIButton()
        closeButton.tintColor = UIColor.whiteColor()
        closeButton.alpha = 0.75
        closeButton.hidden = true
        closeButton.setImage(UIImage(named: "Close"), forState: .Normal)
        closeButton.addTarget(self, action: #selector(self.toggleFullScreen), forControlEvents: .TouchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var toolbarFrame = toolbar.frame
        toolbarFrame.origin.x = self.contentOffset.x
        toolbar.frame = toolbarFrame
        self.bringSubviewToFront(toolbar)
        
        var closeButtonFrame = closeButton.frame
        closeButtonFrame.origin.x = self.contentOffset.x + CGRectGetWidth(self.frame) - Constants.CloseButtonSize - Constants.CloseButtonPadding
        closeButton.frame = closeButtonFrame
        self.bringSubviewToFront(closeButton)
    }
    
    func layoutPages() {
        let numPictures = gallery?.pictures?.count ?? 0
        var imageViewX: CGFloat = 0
        scrollViewPageWidth = CGRectGetWidth(self.bounds)
        for i in 0 ..< numPictures {
            if let imageView = self.viewWithTag(i + 1) as? UIImageView {
                imageView.frame = CGRectMake(imageViewX, 0, scrollViewPageWidth, CGRectGetHeight(self.frame))
            } else {
                let imageView = UIImageView()
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                imageView.frame = CGRectMake(imageViewX, 0, scrollViewPageWidth, CGRectGetHeight(self.frame))
                imageView.clipsToBounds = true
                imageView.tag = i + 1
                self.addSubview(imageView)
            }
            
            imageViewX += scrollViewPageWidth
        }
        
        self.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * CGFloat(numPictures), CGRectGetHeight(self.frame))
        self.contentOffset.x = scrollViewPageWidth * CGFloat(currentPage)
        
        toolbar.frame = CGRectMake(self.contentOffset.x, CGRectGetHeight(self.frame) - Constants.ToolbarHeight, CGRectGetWidth(self.frame), Constants.ToolbarHeight)
        self.addSubview(toolbar)
        
        closeButton.frame = CGRectMake(self.contentOffset.x + CGRectGetWidth(self.frame) - Constants.CloseButtonSize - Constants.CloseButtonPadding, Constants.CloseButtonPadding, Constants.CloseButtonSize, Constants.CloseButtonSize)
        self.addSubview(closeButton)
        
        loadGalleryImageForPage(currentPage)
    }
    
    // MARK: Actions
    func toggleFullScreen() {
        isFullScreen = !isFullScreen
        toolbar.hidden = isFullScreen
        closeButton.hidden = !isFullScreen
        
        if isFullScreen {
            if let superview = self.superview {
                originalContainerFrame = superview.frame
                superview.frame = UIScreen.mainScreen().bounds
            }
            
            originalFrame = self.frame
            
            // FIXME: I have no idea why this hack works
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.frame = UIScreen.mainScreen().bounds
                self.layoutPages()
            }
        } else {
            if let frame = originalContainerFrame {
                self.superview?.frame = frame
                originalContainerFrame = nil
            }
            
            if let frame = originalFrame {
                self.frame = frame
                originalFrame = nil
            }
            
            layoutPages()
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(ImageGalleryNotification.DidToggleFullScreen, object: nil, userInfo: ["isFullScreen": isFullScreen])
    }
    
    // MARK: Image Gallery
    private func loadGalleryImageForPage(page: Int) {
        if let pictures = gallery?.pictures where pictures.count > page {
            if let imageView = self.viewWithTag(page + 1) as? UIImageView where imageView.image == nil {
                if let imageURL = pictures[page].imageURL {
                    imageView.setImageWithURL(imageURL)
                }
            }
        }
    }
    
    func cleanInvisibleImages() {
        let page = Int(self.contentOffset.x / scrollViewPageWidth)
        for subview in self.subviews {
            if subview.tag != page + 1, let imageView = subview as? UIImageView {
                imageView.image = nil
            }
        }
    }
    
    
    // MARK: UIScrollViewDelegate
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        currentPage = Int(targetContentOffset.memory.x / scrollViewPageWidth)
    }

}
