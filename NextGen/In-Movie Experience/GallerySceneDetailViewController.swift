//
//  GallerySceneDetailViewController.swift
//

import UIKit
import NextGenDataManager

class GallerySceneDetailViewController: SceneDetailViewController, UIScrollViewDelegate {
    
    @IBOutlet weak fileprivate var videoContainerView: UIView?
    @IBOutlet weak fileprivate var galleryScrollView: ImageGalleryScrollView?
    @IBOutlet weak fileprivate var descriptionLabel: UILabel!
    @IBOutlet weak fileprivate var pageControl: UIPageControl?
    @IBOutlet weak fileprivate var shareButton: UIButton?
    
    fileprivate var galleryDidScrollToPageObserver: NSObjectProtocol?
    
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
                        galleryDidScrollToPageObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ImageGalleryNotification.DidScrollToPage), object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
                            if let strongSelf = self, let page = (notification as NSNotification).userInfo?["page"] as? Int {
                                strongSelf.pageControl?.currentPage = page
                            }
                        })
                    }
                }
            }
        }
    }
    
    // MARK: Actions
    @IBAction func onShare(_ sender: UIButton?) {
        if let galleryScrollView = galleryScrollView, let url = galleryScrollView.currentImageURL, let title = NGDMManifest.sharedInstance.mainExperience?.title {
            let activityViewController = UIActivityViewController(activityItems: [String.localize("gallery.share_message", variables: ["movie_name": title, "url": url.absoluteString])], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = sender
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onPageControlValueChanged() {
        if let pageControl = pageControl {
            galleryScrollView?.gotoPage(pageControl.currentPage, animated: true)
        }
    }
 
}
