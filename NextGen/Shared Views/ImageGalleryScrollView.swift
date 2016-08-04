//
//  ImageGalleryScrollView.swift
//

import UIKit
import NextGenDataManager
import QuartzCore

struct ImageGalleryNotification {
    static let DidScrollToPage = "kImageGalleryNotificationDidScrollToPage"
    static let DidToggleFullScreen = "kImageGalleryNotificationDidToggleFullScreen"
}

class ImageGalleryScrollView: UIScrollView, UIScrollViewDelegate {
    
    private struct Constants {
        static let ToolbarHeight: CGFloat = (DeviceType.IS_IPAD ? 40 : 35)
        static let CloseButtonSize: CGFloat = 44
        static let CloseButtonPadding: CGFloat = 15
    }
    
    var gallery: NGDMGallery?
    private var toolbar: UIToolbar?
    private var originalFrame: CGRect?
    private var originalContainerFrame: CGRect?
    private var closeButton: UIButton!
    private var sessionDataTasks = [NSURLSessionDataTask]()
    
    var isFullScreen = false {
        didSet {
            if isFullScreen != oldValue {
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
            } else {
                layoutPages()
            }
        }
    }
    
    private var scrollViewPageWidth: CGFloat = 0
    var currentPage = 0 {
        didSet {
            sessionDataTasks.forEach({ $0.cancel() })
            sessionDataTasks.removeAll()
            
            if gallery != nil && !gallery!.isTurntable {
                loadGalleryImageForPage(currentPage)
                loadGalleryImageForPage(currentPage + 1)
                NSNotificationCenter.defaultCenter().postNotificationName(ImageGalleryNotification.DidScrollToPage, object: nil, userInfo: ["page": currentPage])
                
                if let toolbarItems = toolbar?.items, captionLabel = toolbarItems.first?.customView as? UILabel {
                    captionLabel.text = gallery?.getPictureForPage(currentPage)?.caption
                }
            }
        }
    }
    
    var currentImageURL: NSURL? {
        set {
            
        }
        
        get {
            return gallery?.getImageURLForPage(currentPage)
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
        toolbar!.barStyle = .Default
        toolbar!.setBackgroundImage(UIImage(named: "ToolbarBackground"), forToolbarPosition: .Any, barMetrics: .Default)
        
        closeButton = UIButton()
        closeButton.tintColor = UIColor.whiteColor()
        closeButton.alpha = 0.75
        closeButton.hidden = true
        closeButton.setImage(UIImage(named: "Close"), forState: .Normal)
        closeButton.addTarget(self, action: #selector(self.toggleFullScreen), forControlEvents: .TouchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let toolbar = toolbar where !toolbar.hidden {
            var toolbarFrame = toolbar.frame
            toolbarFrame.origin.x = self.contentOffset.x
            toolbarFrame.origin.y = self.contentOffset.y + (CGRectGetHeight(self.frame) - Constants.ToolbarHeight) + 1
            toolbar.frame = toolbarFrame
            self.bringSubviewToFront(toolbar)
            
            if let toolbarItems = toolbar.items {
                if let turntableSlider = toolbarItems.first?.customView as? UISlider {
                    turntableSlider.frame.size.width = CGRectGetWidth(toolbarFrame) - 35 - (isFullScreen || toolbarItems.count == 1 ? 0 : Constants.ToolbarHeight)
                } else if let captionLabel = toolbarItems.first?.customView as? UILabel {
                    captionLabel.frame.size.width = CGRectGetWidth(toolbarFrame) - 35 - (isFullScreen || toolbarItems.count == 1 ? 0 : Constants.ToolbarHeight)
                }
            }
        }
        
        if !closeButton.hidden {
            var closeButtonFrame = closeButton.frame
            closeButtonFrame.origin.x = self.contentOffset.x + CGRectGetWidth(self.frame) - Constants.CloseButtonSize - Constants.CloseButtonPadding
            closeButton.frame = closeButtonFrame
            self.bringSubviewToFront(closeButton)
        }
    }
    
    func loadGallery(gallery: NGDMGallery) {
        self.gallery = gallery
        
        resetScrollView()
        
        if gallery.isTurntable {
            for i in 0 ..< gallery.totalCount {
                loadGalleryImageForPage(i)
            }
        }
    }
    
    func destroyGallery() {
        gallery = nil
        resetScrollView()
    }
    
    func removeToolbar() {
        toolbar?.removeFromSuperview()
        toolbar = nil
    }
    
    private func resetScrollView() {
        for subview in self.subviews {
            if let subview = subview as? UIScrollView {
                subview.removeFromSuperview()
            }
        }
        
        if let frame = originalContainerFrame {
            self.superview?.frame = frame
        }
        
        if let frame = originalFrame {
            self.frame = frame
        }
        
        if let toolbar = toolbar {
            toolbar.items = nil
            
            var toolbarItems = [UIBarButtonItem]()
            if gallery != nil && gallery!.isTurntable {
                let turntableSlider = UISlider(frame: CGRectMake(0, 0, CGRectGetWidth(self.frame) - Constants.ToolbarHeight - 35, Constants.ToolbarHeight))
                turntableSlider.minimumValue = 0
                turntableSlider.maximumValue = max(Float(gallery!.totalCount - 1), 0)
                turntableSlider.value = 0
                turntableSlider.addTarget(self, action: #selector(self.turntableSliderValueChanged), forControlEvents: .ValueChanged)
                toolbarItems.append(UIBarButtonItem(customView: turntableSlider))
            } else {
                let captionLabel = UILabel(frame: CGRectMake(0, 0, CGRectGetWidth(self.frame) - Constants.ToolbarHeight - 35, Constants.ToolbarHeight))
                captionLabel.textColor = UIColor.whiteColor()
                captionLabel.font = UIFont.themeCondensedFont(DeviceType.IS_IPAD ? 16 : 14)
                captionLabel.layer.shadowColor = UIColor.blackColor().CGColor
                captionLabel.layer.shadowOpacity = 1
                captionLabel.layer.shadowRadius = 2
                captionLabel.layer.shadowOffset = CGSizeMake(0, 1)
                captionLabel.layer.masksToBounds = false
                captionLabel.layer.shouldRasterize = true
                toolbarItems.append(UIBarButtonItem(customView: captionLabel))
            }
            
            let fullScreenButton = UIButton(frame: CGRectMake(0, 0, Constants.ToolbarHeight, Constants.ToolbarHeight))
            fullScreenButton.tintColor = UIColor.whiteColor()
            fullScreenButton.setImage(UIImage(named: "Maximize"), forState: .Normal)
            fullScreenButton.setImage(UIImage(named: "Maximize Highlighted"), forState: .Highlighted)
            fullScreenButton.addTarget(self, action: #selector(self.toggleFullScreen), forControlEvents: .TouchUpInside)
            toolbarItems.append(UIBarButtonItem(customView: fullScreenButton))
            
            toolbar.items = toolbarItems
        }
        
        self.scrollEnabled = gallery != nil && !gallery!.isTurntable
        isFullScreen = false
        toolbar?.hidden = false
        closeButton.hidden = true
        currentPage = 0
        layoutPages()
    }
    
    func layoutPages() {
        if let gallery = gallery {
            scrollViewPageWidth = CGRectGetWidth(self.bounds)
            for i in 0 ..< gallery.totalCount {
                var pageView = self.viewWithTag(i + 1) as? UIScrollView
                var imageView = pageView?.subviews.first as? UIImageView
                if pageView == nil {
                    pageView = UIScrollView()
                    pageView!.delegate = self
                    pageView!.clipsToBounds = true
                    pageView!.minimumZoomScale = 1
                    pageView!.maximumZoomScale = 3
                    pageView!.bounces = false
                    pageView!.bouncesZoom = false
                    pageView!.showsVerticalScrollIndicator = false
                    pageView!.showsHorizontalScrollIndicator = false
                    pageView!.tag = i + 1
                    
                    imageView = UIImageView()
                    imageView!.contentMode = UIViewContentMode.ScaleAspectFit
                    pageView!.addSubview(imageView!)
                    
                    self.addSubview(pageView!)
                }
                
                pageView!.zoomScale = 1
                pageView!.frame = CGRectMake(CGFloat(i) * scrollViewPageWidth, 0, scrollViewPageWidth, CGRectGetHeight(self.frame))
                imageView!.frame = pageView!.bounds
            }
            
            self.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * CGFloat(gallery.totalCount), CGRectGetHeight(self.frame))
            self.contentOffset.x = scrollViewPageWidth * CGFloat(currentPage)
            
            if let toolbar = toolbar {
                toolbar.frame = CGRectMake(self.contentOffset.x, CGRectGetHeight(self.frame) - Constants.ToolbarHeight, CGRectGetWidth(self.frame), Constants.ToolbarHeight)
                self.addSubview(toolbar)
            }
            
            closeButton.frame = CGRectMake(self.contentOffset.x + CGRectGetWidth(self.frame) - Constants.CloseButtonSize - Constants.CloseButtonPadding, Constants.CloseButtonPadding, Constants.CloseButtonSize, Constants.CloseButtonSize)
            self.addSubview(closeButton)
            
            loadGalleryImageForPage(currentPage)
        }
    }
    
    // MARK: Actions
    func toggleFullScreen() {
        isFullScreen = !isFullScreen
    }
    
    func turntableSliderValueChanged(slider: UISlider!) {
        gotoPage(Int(floor(slider.value)), animated: false)
    }
    
    // MARK: Image Gallery
    private func loadGalleryImageForPage(page: Int) {
        if let url = gallery?.getImageURLForPage(page), imageView = (self.viewWithTag(page + 1) as? UIScrollView)?.subviews.first as? UIImageView where imageView.image == nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { [weak self] in
                if let strongSelf = self, sessionDataTask = imageView.setImageWithURL(url, completion: nil) {
                    strongSelf.sessionDataTasks.append(sessionDataTask)
                }
            }
        }
    }
    
    private func imageViewForPage(page: Int) -> UIImageView? {
        if let pageView = self.viewWithTag(page + 1) as? UIScrollView {
            return pageView.subviews.first as? UIImageView
        }
        
        return nil
    }
    
    func cleanInvisibleImages() {
        for subview in self.subviews {
            if subview.tag != currentPage + 1, let imageView = subview.subviews.first as? UIImageView {
                imageView.image = nil
            }
        }
    }
    
    func gotoPage(page: Int, animated: Bool) {
        self.setContentOffset(CGPointMake(CGFloat(page) * scrollViewPageWidth, 0), animated: animated)
        currentPage = page
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == self && scrollViewPageWidth > 0 {
            currentPage = Int(targetContentOffset.memory.x / scrollViewPageWidth)
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageViewForPage(currentPage)
    }
 
}
