//
//  GallerySceneDetailViewController.swift
//

import UIKit
import NextGenDataManager

class GallerySceneDetailViewController: SceneDetailViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var galleryScrollView: UIScrollView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var timedEvent: NGDMTimedEvent!
    var gallery: NGDMGallery?
    private var _scrollViewPageWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if timedEvent.isType(.AudioVisual) {
            galleryScrollView.removeFromSuperview()
            if let audioVisual = timedEvent.audioVisual, videoURL = audioVisual.videoURL {
                descriptionLabel.text = audioVisual.metadata?.description != nil ? audioVisual.metadata?.description : audioVisual.metadata?.title
                
                if let videoPlayerViewController = UIStoryboard.getNextGenViewController(VideoPlayerViewController) as? VideoPlayerViewController {
                    videoPlayerViewController.mode = VideoPlayerMode.SupplementalInMovie
                    
                    videoPlayerViewController.view.frame = videoContainerView.bounds
                    videoContainerView.addSubview(videoPlayerViewController.view)
                    self.addChildViewController(videoPlayerViewController)
                    videoPlayerViewController.didMoveToParentViewController(self)
                    
                    videoPlayerViewController.playVideoWithURL(videoURL)
                }
            }
        } else {
            videoContainerView.removeFromSuperview()
            gallery = timedEvent.gallery
            descriptionLabel.text = gallery?.description
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let gallery = gallery, pictures = gallery.pictures {
            let numPictures = pictures.count
            pageControl.numberOfPages = numPictures
            
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
            
            galleryScrollView.contentSize = CGSizeMake(CGRectGetWidth(galleryScrollView.bounds) * CGFloat(numPictures), CGRectGetHeight(galleryScrollView.bounds))
        }
        
        loadImageForPage(0)
    }
    
    func loadImageForPage(page: Int) {
        if let gallery = gallery, imageView = galleryScrollView.viewWithTag(page + 1) as? UIImageView, pictures = gallery.pictures {
            if imageView.image == nil {
                if let imageURL = pictures[page].imageURL {
                    imageView.setImageWithURL(imageURL)
                }
            }
            
            pageControl.currentPage = page
        }
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(targetContentOffset.memory.x / _scrollViewPageWidth)
        loadImageForPage(page)
    }
 
}
