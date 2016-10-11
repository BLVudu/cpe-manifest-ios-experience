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
        
        nextButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        
        reloadClipViews()
        
        // Localizations
        clipShareTitleLabel.text = String.localize("clipshare.select_clip_title").uppercased()
        shareButton.setTitle(String.localize("clipshare.share_button").uppercased(), for: UIControlState())
    }
    
    private func reloadClipViews() {
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
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.previousTimedEvent = self.timedEvent?.previousTimedEventOfType(.clipShare)
            self.nextTimedEvent = self.timedEvent?.nextTimedEventOfType(.clipShare)
            
            DispatchQueue.main.async {
                self.previousButton.isHidden = self.previousTimedEvent == nil
                self.nextButton.isHidden = self.nextTimedEvent == nil
            }
        }
    }
    
    // MARK: Actions
    @IBAction private func onPlay() {
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
            
            NextGenHook.logAnalyticsEvent(.imeClipShareAction, action: .selectVideo, itemId: timedEvent?.id)
        }
    }
    
    @IBAction private func onTapPrevious() {
        if let timedEvent = previousTimedEvent {
            self.timedEvent = timedEvent
            reloadClipViews()
            NextGenHook.logAnalyticsEvent(.imeClipShareAction, action: .selectPrevious, itemId: timedEvent.id)
        }
    }
    
    @IBAction private func onTapNext() {
        if let timedEvent = nextTimedEvent {
            self.timedEvent = timedEvent
            reloadClipViews()
            NextGenHook.logAnalyticsEvent(.imeClipShareAction, action: .selectNext, itemId: timedEvent.id)
        }
    }
    
    @IBAction private func onShare(_ sender: UIButton) {
        if let url = timedEvent?.videoURL, let title = NGDMManifest.sharedInstance.mainExperience?.title {
            let showShareDialog = { [weak self] (url: URL) in
                let activityViewController = UIActivityViewController(activityItems: [String.localize("clipshare.share_message", variables: ["movie_name": title, "url": url.absoluteString])], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = sender
                self?.present(activityViewController, animated: true, completion: nil)
                
                NextGenHook.logAnalyticsEvent(.imeClipShareAction, action: .shareVideo, itemId: self?.timedEvent?.id)
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
    
}
