//
//  ClipShareSceneDetailViewController.swift
//

import UIKit
import NextGenDataManager

class ClipShareSceneDetailViewController: SceneDetailViewController {
    
    @IBOutlet weak fileprivate var clipShareTitleLabel: UILabel!
    @IBOutlet weak fileprivate var previousButton: UIButton!
    @IBOutlet weak fileprivate var nextButton: UIButton!
    @IBOutlet weak fileprivate var videoContainerView: UIView!
    @IBOutlet weak fileprivate var previewImageView: UIImageView!
    @IBOutlet weak fileprivate var previewPlayButton: UIButton!
    @IBOutlet weak fileprivate var clipNameLabel: UILabel!
    @IBOutlet weak fileprivate var shareButton: UIButton!
    
    fileprivate var videoPlayerViewController: VideoPlayerViewController?
    fileprivate var previousTimedEvent: NGDMTimedEvent?
    fileprivate var nextTimedEvent: NGDMTimedEvent?
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        
        reloadClipViews()
        
        // Localizations
        clipShareTitleLabel.text = String.localize("clipshare.select_clip_title").uppercased()
        shareButton.setTitle(String.localize("clipshare.share_button").uppercased(), for: UIControlState())
    }
    
    fileprivate func reloadClipViews() {
        videoPlayerViewController?.willMove(toParentViewController: nil)
        videoPlayerViewController?.view.removeFromSuperview()
        videoPlayerViewController?.removeFromParentViewController()
        videoPlayerViewController = nil
        videoContainerView.isHidden = true
        previewImageView.isHidden = false
        previewPlayButton.isHidden = false
        
        if let imageURL = timedEvent?.imageURL {
            previewImageView.sd_setImage(with: imageURL)
        } else {
            previewImageView.sd_cancelCurrentImageLoad()
            previewImageView.image = nil
        }
        
        videoContainerView.isHidden = true
        clipNameLabel.text = timedEvent?.descriptionText
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.previousTimedEvent = self.timedEvent?.previousTimedEventOfType(.clipShare)
            self.nextTimedEvent = self.timedEvent?.nextTimedEventOfType(.clipShare)
            
            DispatchQueue.main.async {
                self.previousButton.isHidden = self.previousTimedEvent == nil
                self.nextButton.isHidden = self.nextTimedEvent == nil
            }
        }
    }
    
    // MARK: Actions
    @IBAction fileprivate func onPlay() {
        previewImageView.isHidden = true
        previewPlayButton.isHidden = true
        
        if let videoURL = timedEvent?.videoURL, let videoPlayerViewController = UIStoryboard.getNextGenViewController(VideoPlayerViewController.self) as? VideoPlayerViewController  {
            if let player = videoPlayerViewController.player {
                player.removeAllItems()
            }
            
            videoPlayerViewController.queueTotalCount = 1
            videoPlayerViewController.queueCurrentIndex = 0
            videoPlayerViewController.mode = .supplementalInMovie
            videoPlayerViewController.view.frame = videoContainerView.bounds
            
            videoContainerView.isHidden = false
            videoContainerView.addSubview(videoPlayerViewController.view)
            self.addChildViewController(videoPlayerViewController)
            videoPlayerViewController.didMove(toParentViewController: self)
            
            videoPlayerViewController.playVideo(with: videoURL)
            self.videoPlayerViewController = videoPlayerViewController
        }
    }
    
    @IBAction fileprivate func onTapPrevious() {
        if let timedEvent = previousTimedEvent {
            self.timedEvent = timedEvent
            reloadClipViews()
        }
    }
    
    @IBAction fileprivate func onTapNext() {
        if let timedEvent = nextTimedEvent {
            self.timedEvent = timedEvent
            reloadClipViews()
        }
    }
    
    @IBAction fileprivate func onShare(_ sender: UIButton) {
        if let url = timedEvent?.videoURL, let title = NGDMManifest.sharedInstance.mainExperience?.title {
            let activityViewController = UIActivityViewController(activityItems: [String.localize("clipshare.share_message", variables: ["movie_name": title, "url": url.absoluteString])], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = sender
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
}
