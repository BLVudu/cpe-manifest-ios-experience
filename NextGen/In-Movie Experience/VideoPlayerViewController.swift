//
//  VideoPlayerViewController.swift
//

import Foundation
import UIKit
import MessageUI
import CoreMedia
import NextGenDataManager
import UAProgressView

struct VideoPlayerNotification {
    static let DidChangeTime = "VideoPlayerNotificationDidChangeTime"
    static let DidPlayMainExperience = "VideoPlayerNotificationDidPlayMainExperience"
    static let DidPlayVideo = "VideoPlayerNotificationDidPlayVideo"
    static let DidEndLastVideo = "kVideoPlayerNotificationDidEndLastVideo"
    static let WillPlayNextItem = "kNextGenVideoPlayerWillPlayNextItem"
    static let UserInfoVideoURL = "kVideoPlayerNotificationVideoURL"
}

public enum VideoPlayerMode {
    case MainFeature
    case Supplemental
    case SupplementalInMovie
}

typealias Task = (cancel : Bool) -> ()

class VideoPlayerViewController: NextGenVideoPlayerViewController, UIPopoverControllerDelegate {
    
    private struct Constants {
        static let CountdownTimeInterval: CGFloat = 1
        static let CountdownTotalTime: CGFloat = 5
    }
    
    var mode = VideoPlayerMode.Supplemental
    
    private var _didPlayInterstitial = false
    private var _lastNotifiedTime = -1.0
    private var _controlsAreLocked = false
    private var manuallyPaused = false
    
    @IBOutlet weak private var _commentaryView: UIView!
    @IBOutlet weak private var _commentaryButton: UIButton!
    @IBOutlet weak private var _homeButton: UIButton!
    var commentaryIndex = 0
    
    // Countdown/Queue
    var queueTotalCount = 0
    var queueCurrentIndex = 0
    private var countdownSeconds: CGFloat = 0 {
        didSet {
            countdownLabel.text = String.localize("label.time.seconds", variables: ["count": String(Int(Constants.CountdownTotalTime - countdownSeconds))])
            countdownProgressView?.setProgress(((countdownSeconds + 1) / Constants.CountdownTotalTime), animated: true)
        }
    }
    
    private var countdownTimer: NSTimer?
    private var countdownProgressView: UAProgressView?
    @IBOutlet weak private var countdownLabel: UILabel!
    
    // Skip interstitial
    @IBOutlet weak private var skipContainerView: UIView!
    @IBOutlet weak private var skipCountdownContainerView: UIView!
    @IBOutlet private var skipContainerLandscapeHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var skipContainerPortraitHeightConstraint: NSLayoutConstraint!
    
    // Notifications
    private var playerItemDurationDidLoadObserver: NSObjectProtocol?
    private var shouldPauseAllOtherObserver: NSObjectProtocol?
    private var updateCommentaryButtonObserver: NSObjectProtocol?
    private var sceneDetailWillCloseObserver: NSObjectProtocol?
    
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        
        if let observer = playerItemDurationDidLoadObserver {
            center.removeObserver(observer)
            playerItemDurationDidLoadObserver = nil
        }
        
        if let observer = shouldPauseAllOtherObserver {
            center.removeObserver(observer)
            shouldPauseAllOtherObserver = nil
        }
        
        if let observer = updateCommentaryButtonObserver {
            center.removeObserver(observer)
            updateCommentaryButtonObserver = nil
        }
        
        if let observer = sceneDetailWillCloseObserver {
            center.removeObserver(observer)
            sceneDetailWillCloseObserver = nil
        }
        
        cancelCountdown()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skipContainerView.hidden = true
        skipContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapSkip)))
        
        // Localizations
        _homeButton.setTitle(String.localize("label.home"), forState: UIControlState.Normal)
        _commentaryButton.setTitle(String.localize("label.commentary"), forState: UIControlState.Normal)
        _commentaryView.hidden = true
        
        // Notifications
        playerItemDurationDidLoadObserver = NSNotificationCenter.defaultCenter().addObserverForName(kNextGenVideoPlayerItemDurationDidLoadNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self, duration = notification.userInfo?["duration"] as? Double where strongSelf.countdownProgressView == nil {
                let progressView = UAProgressView(frame: strongSelf.skipCountdownContainerView.frame)
                progressView.borderWidth = 0
                progressView.lineWidth = 2
                progressView.fillOnTouch = false
                progressView.tintColor = UIColor.whiteColor()
                progressView.animationDuration = duration
                strongSelf.skipContainerView.addSubview(progressView)
                strongSelf.countdownProgressView = progressView
                strongSelf.countdownProgressView?.setProgress(1, animated: true)
            }
        })
        
        shouldPauseAllOtherObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidPlayVideo, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self where strongSelf._didPlayInterstitial {
                if let videoURL = notification.userInfo?[VideoPlayerNotification.UserInfoVideoURL] as? NSURL where videoURL != strongSelf.URL {
                    strongSelf.pauseVideo()
                }
            }
        })
        
        updateCommentaryButtonObserver = NSNotificationCenter.defaultCenter().addObserverForName(kDidSelectCommetaryOption, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self]
            (notification) in
            if let strongSelf = self {
                if let userInfo = notification.userInfo, index = userInfo["option"] as? Int {
                    strongSelf.commentaryIndex = index
                    strongSelf._commentaryButton.setTitle(index > 0 ? String.localize("label.commentary.on") : String.localize("label.commentary"), forState: .Normal)
                }
            }
        })
        
        sceneDetailWillCloseObserver = NSNotificationCenter.defaultCenter().addObserverForName(SceneDetailNotification.WillClose, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self where strongSelf.mode == .MainFeature && !strongSelf.manuallyPaused {
                strongSelf.playVideo()
            }
        })

        if mode == VideoPlayerMode.MainFeature {
            self.fullScreenButton.removeFromSuperview()
            playMainExperience()
        } else {
            _didPlayInterstitial = true
            self.playerControlsVisible = false
            self.topToolbar.removeFromSuperview()
            
            if mode == VideoPlayerMode.SupplementalInMovie {
                self.fullScreenButton.removeFromSuperview()
            }
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if _didPlayInterstitial {
            self.playerControlsVisible = true
            self.initAutoHideTimer()
        } else {
            countdownProgressView?.frame = skipCountdownContainerView.frame
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if !_didPlayInterstitial {
            skipContainerLandscapeHeightConstraint.active = UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
            skipContainerPortraitHeightConstraint.active = !skipContainerLandscapeHeightConstraint.active
            countdownProgressView?.frame = skipCountdownContainerView.frame
        }
    }
    
    // MARK: Actions
    override func pause(sender: AnyObject!) {
        super.pause(sender)
        
        manuallyPaused = true
    }
    
    // MARK: Video Playback
    override func playVideoWithURL(url: NSURL!) {
        cancelCountdown()
        
        if _didPlayInterstitial {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                SettingsManager.setVideoAsWatched(url)
                NextGenHook.delegate?.getProcessedVideoURL(url, mode: self.mode, completion: { (url) in
                    if let url = url {
                        dispatch_async(dispatch_get_main_queue()) {
                            super.playVideoWithURL(url)
                        }
                    }
                })
            }
        } else {
            super.playVideoWithURL(url)
        }
    }
    
    func playMainExperience() {
        self.playerControlsVisible = false
        countdownProgressView?.removeFromSuperview()
        countdownProgressView = nil
        
        if _didPlayInterstitial {
            skipContainerView.hidden = true
            
            if let audioVisual = NGDMManifest.sharedInstance.mainExperience?.audioVisual {
                NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.DidPlayMainExperience, object: nil)
                self.playVideoWithURL(audioVisual.videoURL)
            }
        } else {
            skipContainerView.hidden = !SettingsManager.didWatchInterstitial
            SettingsManager.didWatchInterstitial = true
            self.playVideoWithURL(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("MOS_INTERSTITIAL_v2", ofType: "mp4")!))
        }
    }
    
    func skipInterstitial() {
        self.pauseVideo()
        self.player?.removeAllItems()
        self._didPlayInterstitial = true
        self.playMainExperience()
    }
    
    override func playVideo() {
        super.playVideo()
        
        manuallyPaused = false
        NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.DidPlayVideo, object: nil, userInfo: [VideoPlayerNotification.UserInfoVideoURL: self.URL])
    }
    
    override func syncScrubber() {
        super.syncScrubber()
        
        if player != nil && mode == VideoPlayerMode.MainFeature {
            var currentTime = _didPlayInterstitial ? CMTimeGetSeconds(self.player?.currentTime() ?? kCMTimeZero) : 0
            if currentTime.isNaN {
                currentTime = 0.0
            }
            
            if _lastNotifiedTime != currentTime {
                _lastNotifiedTime = currentTime
                NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.DidChangeTime, object: nil, userInfo: ["time": Double(currentTime)])
            }
        }
    }
    
    override func playerItemDidReachEnd(notification: NSNotification!) {
        if !_didPlayInterstitial {
            _didPlayInterstitial = true
            playMainExperience()
        }
        
        queueCurrentIndex += 1
        if queueCurrentIndex < queueTotalCount {
            self.pauseVideo()
            
            countdownLabel.hidden = false
            
            let progressView = UAProgressView(frame: countdownLabel.frame)
            progressView.centralView = countdownLabel
            progressView.borderWidth = 0
            progressView.lineWidth = 2
            progressView.fillOnTouch = false
            progressView.tintColor = UIColor.themePrimaryColor()
            progressView.animationDuration = Double(Constants.CountdownTimeInterval)
            self.view.addSubview(progressView)
            countdownProgressView = progressView
            
            countdownSeconds = 0
            countdownTimer = NSTimer.scheduledTimerWithTimeInterval(Double(Constants.CountdownTimeInterval), target: self, selector: #selector(self.onCountdownTimerFired), userInfo: nil, repeats: true)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.DidEndLastVideo, object: nil)
        }

        if mode == .Supplemental {
            super.playerItemDidReachEnd(notification)
        }
    }
    
    func onCountdownTimerFired() {
        countdownSeconds += Constants.CountdownTimeInterval
        
        if countdownSeconds >= Constants.CountdownTotalTime {
            if let timer = countdownTimer {
                timer.invalidate()
                countdownTimer = nil
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(Constants.CountdownTimeInterval) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.cancelCountdown()
                NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.WillPlayNextItem, object: nil, userInfo: ["index": self.queueCurrentIndex])
            }
        }
    }
    
    func cancelCountdown() {
        if let timer = countdownTimer {
            timer.invalidate()
            countdownTimer = nil
        }
        
        countdownLabel.hidden = true
        countdownProgressView?.removeFromSuperview()
        countdownProgressView = nil
    }
    
    // MARK: Actions
    override func done(sender: AnyObject?) {
        super.done(sender)
        
        NextGenHook.delegate?.videoPlayerWillClose(mode)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func commentary(sender: UIButton) {
        
        sender.imageView!.image? = (sender.imageView!.image?.imageWithRenderingMode(.AlwaysTemplate))!
        _commentaryView.hidden = !_commentaryView.hidden
        
        if !_commentaryView.hidden {
            
            sender.tintColor = UIColor.themePrimaryColor()
            
            if let timer = self.playerControlsAutoHideTimer {
                timer.invalidate()
            }
        } else {
            if commentaryIndex == 0 {
                sender.tintColor = UIColor.whiteColor()
            }
            
            self.initAutoHideTimer()
        }
    }
    
    override func handleTap(gestureRecognizer: UITapGestureRecognizer!) {
        if !_controlsAreLocked && _didPlayInterstitial {
            if _commentaryView.hidden {
                super.handleTap(gestureRecognizer)
            } else {
                commentary(_commentaryButton)
            }
        }
    }
    
    func onTapSkip() {
        if !_controlsAreLocked && !_didPlayInterstitial {
            skipInterstitial()
        }
    }
    
    // MARK: UIPopoverControllerDelegate
    func popoverControllerShouldDismissPopover(popoverController: UIPopoverController) -> Bool {
        if popoverController.popoverVisible {
            self.initAutoHideTimer()
            return true
        }
        
        return false
    }
    
}