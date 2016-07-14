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
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            galleryDidScrollToPageObserver = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        galleryScrollView?.cleanInvisibleImages()
    }
    
    // MARK: View Lifecycle
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let timedEvent = timedEvent {
            if timedEvent.isType(.AudioVisual) {
                galleryScrollView?.removeFromSuperview()
                pageControl?.removeFromSuperview()
                shareButton?.removeFromSuperview()
                galleryScrollView = nil
                pageControl = nil
                shareButton = nil
                
                if let audioVisual = timedEvent.audioVisual, videoURL = audioVisual.videoURL {
                    descriptionLabel.text = audioVisual.metadata?.description != nil ? audioVisual.metadata?.description : audioVisual.metadata?.title
                    
                    if let videoContainerView = videoContainerView, videoPlayerViewController = UIStoryboard.getNextGenViewController(VideoPlayerViewController) as? VideoPlayerViewController {
                        videoPlayerViewController.mode = VideoPlayerMode.SupplementalInMovie
                        
                        videoPlayerViewController.view.frame = videoContainerView.bounds
                        videoContainerView.addSubview(videoPlayerViewController.view)
                        self.addChildViewController(videoPlayerViewController)
                        videoPlayerViewController.didMoveToParentViewController(self)
                        
                        videoPlayerViewController.playVideoWithURL(videoURL)
                    }
                }
            } else if let gallery = timedEvent.gallery {
                videoContainerView?.removeFromSuperview()
                videoContainerView = nil
                
                galleryScrollView?.gallery = gallery
                descriptionLabel.text = gallery.description
                
                if gallery.isSubType(.Turntable) {
                    shareButton?.removeFromSuperview()
                    shareButton = nil
                } else {
                    shareButton?.setTitle(String.localize("gallery.share_button").uppercaseString, forState: .Normal)
                    galleryScrollView?.removeToolbar()
                    pageControl?.numberOfPages = gallery.pictures?.count ?? 0
                    if pageControl != nil && pageControl!.numberOfPages > 0 {
                        galleryDidScrollToPageObserver = NSNotificationCenter.defaultCenter().addObserverForName(ImageGalleryNotification.DidScrollToPage, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
                            if let strongSelf = self, page = notification.userInfo?["page"] as? Int {
                                strongSelf.pageControl?.currentPage = page
                            }
                        })
                    }
                }
            }
        }
    }
    
    // MARK: Actions
    @IBAction func onShare(sender: UIButton?) {
        if let galleryScrollView = galleryScrollView, url = galleryScrollView.currentImageURL, title = NGDMManifest.sharedInstance.mainExperience?.title {
            let activityViewController = UIActivityViewController(activityItems: [String.localize("gallery.share_message", variables: ["movie_name": title, "url": url.absoluteString])], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = sender
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
 
}
