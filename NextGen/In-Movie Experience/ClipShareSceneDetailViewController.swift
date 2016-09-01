//
//  ClipShareSceneDetailViewController.swift
//

import UIKit
import NextGenDataManager

class ClipShareSceneDetailViewController: SceneDetailViewController {
    
    @IBOutlet weak private var clipShareTitleLabel: UILabel!
    @IBOutlet weak private var previousButton: UIButton!
    @IBOutlet weak private var nextButton: UIButton!
    @IBOutlet weak private var videoContainerView: UIView!
    @IBOutlet weak private var previewImageView: UIImageView!
    @IBOutlet weak private var previewPlayButton: UIButton!
    @IBOutlet weak private var clipNameLabel: UILabel!
    @IBOutlet weak private var shareButton: UIButton!
    
    private var videoPlayerViewController: VideoPlayerViewController?
    private var previousTimedEvent: NGDMTimedEvent?
    private var nextTimedEvent: NGDMTimedEvent?
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
        reloadClipViews()
        
        // Localizations
        clipShareTitleLabel.text = String.localize("clipshare.select_clip_title").uppercaseString
        shareButton.setTitle(String.localize("clipshare.share_button").uppercaseString, forState: UIControlState.Normal)
    }
    
    private func reloadClipViews() {
        videoPlayerViewController?.willMoveToParentViewController(nil)
        videoPlayerViewController?.view.removeFromSuperview()
        videoPlayerViewController?.removeFromParentViewController()
        videoPlayerViewController = nil
        videoContainerView.hidden = true
        previewImageView.hidden = false
        previewPlayButton.hidden = false
        
        if let imageURL = timedEvent?.imageURL {
            previewImageView.af_setImageWithURL(imageURL)
        } else {
            previewImageView.af_cancelImageRequest()
            previewImageView.image = nil
        }
        
        videoContainerView.hidden = true
        clipNameLabel.text = timedEvent?.descriptionText
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            self.previousTimedEvent = self.timedEvent?.previousTimedEventOfType(.ClipShare)
            self.nextTimedEvent = self.timedEvent?.nextTimedEventOfType(.ClipShare)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.previousButton.hidden = self.previousTimedEvent == nil
                self.nextButton.hidden = self.nextTimedEvent == nil
            }
        }
    }
    
    // MARK: Actions
    @IBAction private func onPlay() {
        previewImageView.hidden = true
        previewPlayButton.hidden = true
        
        if let videoURL = timedEvent?.audioVisual?.videoURL, videoPlayerViewController = UIStoryboard.getNextGenViewController(VideoPlayerViewController) as? VideoPlayerViewController  {
            if let player = videoPlayerViewController.player {
                player.removeAllItems()
            }
            
            videoPlayerViewController.queueTotalCount = 1
            videoPlayerViewController.queueCurrentIndex = 0
            videoPlayerViewController.mode = .SupplementalInMovie
            videoPlayerViewController.view.frame = videoContainerView.bounds
            
            videoContainerView.hidden = false
            videoContainerView.addSubview(videoPlayerViewController.view)
            self.addChildViewController(videoPlayerViewController)
            videoPlayerViewController.didMoveToParentViewController(self)
            
            videoPlayerViewController.playVideoWithURL(videoURL)
            self.videoPlayerViewController = videoPlayerViewController
        }
    }
    
    @IBAction private func onTapPrevious() {
        if let timedEvent = previousTimedEvent {
            self.timedEvent = timedEvent
            reloadClipViews()
        }
    }
    
    @IBAction private func onTapNext() {
        if let timedEvent = nextTimedEvent {
            self.timedEvent = timedEvent
            reloadClipViews()
        }
    }
    
    @IBAction private func onShare(sender: UIButton) {
        if let url = timedEvent?.audioVisual?.videoURL, title = NGDMManifest.sharedInstance.mainExperience?.title {
            let activityViewController = UIActivityViewController(activityItems: [String.localize("clipshare.share_message", variables: ["movie_name": title, "url": url.absoluteString])], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = sender
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
}