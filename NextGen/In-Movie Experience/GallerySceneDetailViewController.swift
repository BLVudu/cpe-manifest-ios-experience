//
//  GallerySceneDetailViewController.swift
//

import UIKit
import NextGenDataManager

class GallerySceneDetailViewController: SceneDetailViewController, UIScrollViewDelegate {
    
    @IBOutlet weak private var videoContainerView: UIView?
    @IBOutlet weak private var galleryScrollView: ImageGalleryScrollView?
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var pageControl: UIPageControl?
    @IBOutlet weak private var shareButton: UIButton?
    
    private var galleryDidScrollToPageObserver: NSObjectProtocol?
    
    // MARK: Initialization
    deinit {
        if let observer = galleryDidScrollToPageObserver {
            NotificationCenter.default.removeObserver(observer)
            galleryDidScrollToPageObserver = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        galleryScrollView?.cleanInvisibleImages()
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryScrollView?.allowsFullScreen = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let timedEvent = timedEvent {
            if timedEvent.isType(.audioVisual) {
                galleryScrollView?.removeFromSuperview()
                pageControl?.removeFromSuperview()
                shareButton?.removeFromSuperview()
                galleryScrollView = nil
                pageControl = nil
                shareButton = nil
                
                if let videoURL = timedEvent.videoURL {
                    descriptionLabel.text = timedEvent.audioVisual?.descriptionText
                    
                    if let videoContainerView = videoContainerView, let videoPlayerViewController = UIStoryboard.getNextGenViewController(VideoPlayerViewController.self) as? VideoPlayerViewController {
                        videoPlayerViewController.mode = VideoPlayerMode.supplementalInMovie
                        
                        videoPlayerViewController.view.frame = videoContainerView.bounds
                        videoContainerView.addSubview(videoPlayerViewController.view)
                        self.addChildViewController(videoPlayerViewController)
                        videoPlayerViewController.didMove(toParentViewController: self)
                        
                        videoPlayerViewController.playVideo(with: videoURL)
                    }
                }
            } else if let gallery = timedEvent.gallery {
                videoContainerView?.removeFromSuperview()
                videoContainerView = nil
                
                galleryScrollView?.loadGallery(gallery)
                descriptionLabel.text = gallery.description
                
                if gallery.isTurntable {
                    shareButton?.removeFromSuperview()
                    shareButton = nil
                } else {
                    shareButton?.setTitle(String.localize("gallery.share_button").uppercased(), for: UIControlState())
                    galleryScrollView?.removeToolbar()
                    pageControl?.numberOfPages = gallery.totalCount
                    if pageControl != nil && pageControl!.numberOfPages > 0 {
                        galleryDidScrollToPageObserver = NotificationCenter.default.addObserver(forName: .imageGalleryDidScrollToPage, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
                            if let strongSelf = self, let page = notification.userInfo?[NotificationConstants.page] as? Int {
                                strongSelf.pageControl?.currentPage = page
                                NextGenHook.logAnalyticsEvent(.imeImageGalleryAction, action: .scrollImageGallery, itemId: gallery.id)
                            }
                        })
                    }
                }
            }
        }
    }
    
    // MARK: Actions
    @IBAction func onShare(_ sender: UIButton?) {
        if let url = galleryScrollView?.currentImageURL, let title = NGDMManifest.sharedInstance.mainExperience?.title {
            let showShareDialog = { [weak self] (url: URL) in
                let activityViewController = UIActivityViewController(activityItems: [String.localize("gallery.share_message", variables: ["movie_name": title, "url": url.absoluteString])], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = sender
                self?.present(activityViewController, animated: true, completion: nil)
                
                NextGenHook.logAnalyticsEvent(.imeImageGalleryAction, action: .shareImage, itemId: self?.timedEvent?.gallery?.id)
                NotificationCenter.default.post(name: .videoPlayerShouldPause, object: nil)
            }
            
            if let delegate = NextGenHook.delegate {
                delegate.urlForSharedContent(url, completion: { (newUrl) in
                    showShareDialog(newUrl ?? url)
                })
            } else {
                showShareDialog(url)
            }
        }
    }
    
    @IBAction func onPageControlValueChanged() {
        if let pageControl = pageControl {
            galleryScrollView?.gotoPage(pageControl.currentPage, animated: true)
        }
    }
 
}
