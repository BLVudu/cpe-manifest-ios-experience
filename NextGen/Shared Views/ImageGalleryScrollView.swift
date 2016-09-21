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
    var allowsFullScreen = true
    private var toolbar: UIToolbar?
    private var originalFrame: CGRect?
    private var originalContainerFrame: CGRect?
    private var closeButton: UIButton!
    
    var isFullScreen = false {
        didSet {
            if isFullScreen != oldValue {
                closeButton.isHidden = !isFullScreen
                
                if isFullScreen {
                    if let superview = self.superview {
                        originalContainerFrame = superview.frame
                        superview.frame = UIScreen.main.bounds
                    }
                    
                    originalFrame = self.frame
                    
                    // FIXME: I have no idea why this hack works
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                        self.frame = UIScreen.main.bounds
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
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: ImageGalleryNotification.DidToggleFullScreen), object: nil, userInfo: ["isFullScreen": isFullScreen])
            } else {
                layoutPages()
            }
        }
    }
    
    private var scrollViewPageWidth: CGFloat = 0
    var currentPage = 0 {
        didSet {
            if gallery != nil && !gallery!.isTurntable {
                loadGalleryImageForPage(currentPage)
                loadGalleryImageForPage(currentPage + 1)
                NotificationCenter.default.post(name: Notification.Name(rawValue: ImageGalleryNotification.DidScrollToPage), object: nil, userInfo: ["page": currentPage])
                
                if let toolbarItems = toolbar?.items, let captionLabel = toolbarItems.first?.customView as? UILabel {
                    if let caption = gallery?.getPictureForPage(currentPage)?.caption {
                        toolbar?.isHidden = false
                        captionLabel.text = caption
                    } else {
                        captionLabel.text = nil
                        
                        if !allowsFullScreen {
                            toolbar?.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    var currentImageURL: URL? {
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
        toolbar!.barStyle = .default
        toolbar!.setBackgroundImage(UIImage(named: "ToolbarBackground"), forToolbarPosition: .any, barMetrics: .default)
        
        closeButton = UIButton()
        closeButton.tintColor = UIColor.white
        closeButton.alpha = 0.75
        closeButton.isHidden = true
        closeButton.setImage(UIImage(named: "Close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(self.toggleFullScreen), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let toolbar = toolbar , !toolbar.isHidden {
            var toolbarFrame = toolbar.frame
            toolbarFrame.origin.x = self.contentOffset.x
            toolbarFrame.origin.y = self.contentOffset.y + (self.frame.height - Constants.ToolbarHeight) + 1
            toolbar.frame = toolbarFrame
            self.bringSubview(toFront: toolbar)
            
            if let toolbarItems = toolbar.items {
                if let turntableSlider = toolbarItems.first?.customView as? UISlider {
                    turntableSlider.frame.size.width = toolbarFrame.width - 35 - (isFullScreen || toolbarItems.count == 1 ? 0 : Constants.ToolbarHeight)
                } else if let captionLabel = toolbarItems.first?.customView as? UILabel {
                    captionLabel.frame.size.width = toolbarFrame.width - 35 - (isFullScreen || toolbarItems.count == 1 ? 0 : Constants.ToolbarHeight)
                }
            }
        }
        
        if !closeButton.isHidden {
            var closeButtonFrame = closeButton.frame
            closeButtonFrame.origin.x = self.contentOffset.x + self.frame.width - Constants.CloseButtonSize - Constants.CloseButtonPadding
            closeButton.frame = closeButtonFrame
            self.bringSubview(toFront: closeButton)
        }
    }
    
    func loadGallery(_ gallery: NGDMGallery) {
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
                let turntableSlider = UISlider(frame: CGRect(x: 0, y: 0, width: self.frame.width - Constants.ToolbarHeight - 35, height: Constants.ToolbarHeight))
                turntableSlider.minimumValue = 0
                turntableSlider.maximumValue = max(Float(gallery!.totalCount - 1), 0)
                turntableSlider.value = 0
                turntableSlider.addTarget(self, action: #selector(self.turntableSliderValueChanged), for: .valueChanged)
                toolbarItems.append(UIBarButtonItem(customView: turntableSlider))
            } else {
                let captionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width - Constants.ToolbarHeight - 35, height: Constants.ToolbarHeight))
                captionLabel.textColor = UIColor.white
                captionLabel.font = UIFont.themeCondensedFont(DeviceType.IS_IPAD ? 16 : 14)
                captionLabel.layer.shadowColor = UIColor.black.cgColor
                captionLabel.layer.shadowOpacity = 1
                captionLabel.layer.shadowRadius = 2
                captionLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
                captionLabel.layer.masksToBounds = false
                captionLabel.layer.shouldRasterize = true
                toolbarItems.append(UIBarButtonItem(customView: captionLabel))
            }
            
            if allowsFullScreen {
                let fullScreenButton = UIButton(frame: CGRect(x: 0, y: 0, width: Constants.ToolbarHeight, height: Constants.ToolbarHeight))
                fullScreenButton.tintColor = UIColor.white
                fullScreenButton.setImage(UIImage(named: "Maximize"), for: UIControlState())
                fullScreenButton.setImage(UIImage(named: "Maximize Highlighted"), for: .highlighted)
                fullScreenButton.addTarget(self, action: #selector(self.toggleFullScreen), for: .touchUpInside)
                toolbarItems.append(UIBarButtonItem(customView: fullScreenButton))
            }
            
            toolbar.items = toolbarItems
        }
        
        self.isScrollEnabled = gallery != nil && !gallery!.isTurntable
        isFullScreen = false
        toolbar?.isHidden = false
        closeButton.isHidden = true
        currentPage = 0
        layoutPages()
    }
    
    func layoutPages() {
        if let gallery = gallery {
            scrollViewPageWidth = self.bounds.width
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
                    imageView!.contentMode = .scaleAspectFit
                    pageView!.addSubview(imageView!)
                    
                    self.addSubview(pageView!)
                }
                
                pageView!.zoomScale = 1
                pageView!.frame = CGRect(x: CGFloat(i) * scrollViewPageWidth, y: 0, width: scrollViewPageWidth, height: self.frame.height)
                imageView!.frame = pageView!.bounds
            }
            
            self.contentSize = CGSize(width: self.frame.width * CGFloat(gallery.totalCount), height: self.frame.height)
            self.contentOffset.x = scrollViewPageWidth * CGFloat(currentPage)
            
            if let toolbar = toolbar {
                toolbar.frame = CGRect(x: self.contentOffset.x, y: self.frame.height - Constants.ToolbarHeight, width: self.frame.width, height: Constants.ToolbarHeight)
                self.addSubview(toolbar)
            }
            
            closeButton.frame = CGRect(x: self.contentOffset.x + self.frame.width - Constants.CloseButtonSize - Constants.CloseButtonPadding, y: Constants.CloseButtonPadding, width: Constants.CloseButtonSize, height: Constants.CloseButtonSize)
            self.addSubview(closeButton)
            
            loadGalleryImageForPage(currentPage)
        }
    }
    
    // MARK: Actions
    func toggleFullScreen() {
        isFullScreen = !isFullScreen
    }
    
    func turntableSliderValueChanged(_ slider: UISlider!) {
        gotoPage(Int(floor(slider.value)), animated: false)
    }
    
    // MARK: Image Gallery
    private func loadGalleryImageForPage(_ page: Int) {
        if let url = gallery?.getImageURLForPage(page), let imageView = (self.viewWithTag(page + 1) as? UIScrollView)?.subviews.first as? UIImageView , imageView.image == nil {
            imageView.sd_setImage(with: url)
        }
    }
    
    private func imageViewForPage(_ page: Int) -> UIImageView? {
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
    
    func gotoPage(_ page: Int, animated: Bool) {
        self.setContentOffset(CGPoint(x: CGFloat(page) * scrollViewPageWidth, y: 0), animated: animated)
        currentPage = page
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == self && scrollViewPageWidth > 0 {
            currentPage = Int(targetContentOffset.pointee.x / scrollViewPageWidth)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageViewForPage(currentPage)
    }
 
}
