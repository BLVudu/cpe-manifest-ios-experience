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
}

class ImageGalleryScrollView: UIScrollView, UIScrollViewDelegate {
    
    private var scrollViewPageWidth: CGFloat = 0
    
    var gallery: NGDMGallery? {
        didSet {
            for subview in self.subviews {
                subview.removeFromSuperview()
            }
            
            self.contentOffset = CGPointZero
            
            let numPictures = gallery?.pictures?.count ?? 0
            if numPictures > 0 {
                var imageViewX: CGFloat = 0
                scrollViewPageWidth = CGRectGetWidth(self.bounds)
                for i in 0 ..< numPictures {
                    let imageView = UIImageView()
                    imageView.contentMode = UIViewContentMode.ScaleAspectFit
                    imageView.frame = CGRectMake(imageViewX, 0, scrollViewPageWidth, CGRectGetHeight(self.bounds))
                    imageView.clipsToBounds = true
                    imageView.tag = i + 1
                    self.addSubview(imageView)
                    imageViewX += scrollViewPageWidth
                }
                
                self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * CGFloat(numPictures), CGRectGetHeight(self.bounds))
                loadGalleryImageForPage(0)
            }
        }
    }
    
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.delegate = self
    }
    
    
    // MARK: Image Gallery
    private func loadGalleryImageForPage(page: Int) {
        if let imageView = self.viewWithTag(page + 1) as? UIImageView where imageView.image == nil {
            if let imageURL = gallery?.pictures?[page].imageURL {
                imageView.setImageWithURL(imageURL)
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(ImageGalleryNotification.DidScrollToPage, object: nil, userInfo: ["page": page])
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
        loadGalleryImageForPage(Int(targetContentOffset.memory.x / scrollViewPageWidth))
    }

}
