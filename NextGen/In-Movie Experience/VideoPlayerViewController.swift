//
//  VideoPlayerViewController.swift
//

import Foundation
import UIKit
import MessageUI
import CoreMedia
import NextGenDataManager

struct VideoPlayerNotification {
    static let DidChangeTime = "VideoPlayerNotificationDidChangeTime"
    static let DidPlayMainExperience = "VideoPlayerNotificationDidPlayMainExperience"
    static let DidPlayVideo = "VideoPlayerNotificationDidPlayVideo"
    static let DidEndLastVideo = "kVideoPlayerNotificationDidEndLastVideo"
    static let UserInfoVideoURL = "kVideoPlayerNotificationVideoURL"
}

public enum VideoPlayerMode {
    case MainFeature
    case Supplemental
    case SupplementalInMovie
}

typealias Task = (cancel : Bool) -> ()

class VideoPlayerViewController: NextGenVideoPlayerViewController, UIPopoverControllerDelegate {
    
    var mode = VideoPlayerMode.Supplemental
    var showCountdownTimer = false
    var curIndex = 0
    var indexMax = 0
    
    private var _didPlayInterstitial = false
    private var _lastNotifiedTime = -1.0
    private var _controlsAreLocked = false
    
    @IBOutlet weak private var _commentaryView: UIView!
    @IBOutlet weak private var _commentaryButton: UIButton!
    @IBOutlet weak private var _homeButton: UIButton!
    
    @IBOutlet weak var countdown: CircularProgressView!
    var countdownTimer: NSTimer!
    private var countdownSeconds = 0
    var nextItemTask: Task?
    var commentaryIndex = 0
    
    private var manuallyPaused = false
    
    private var shouldPauseAllOtherObserver: NSObjectProtocol?
    private var updateCommentaryButtonObserver: NSObjectProtocol?
    private var sceneDetailWillCloseObserver: NSObjectProtocol?
    
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.countdown.hidden = true
        
        
        // Localizations
        _homeButton.setTitle(String.localize("label.home"), forState: UIControlState.Normal)
        _commentaryButton.setTitle(String.localize("label.commentary"), forState: UIControlState.Normal)
        _commentaryView.hidden = true
        
        // Notifications
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
                if let userInfo = notification.userInfo, index = userInfo["option"] as? Int{
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
            self.playerControlsVisible = true;
            self.initAutoHideTimer()
        }
    }
    
    // MARK: Actions
    override func pause(sender: AnyObject!) {
        super.pause(sender)
        
        manuallyPaused = true
    }
    
    // MARK: Video Playback
    override func playVideoWithURL(url: NSURL!) {
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
        if _didPlayInterstitial {
            if let audioVisual = NGDMManifest.sharedInstance.mainExperience?.audioVisual {
                NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.DidPlayMainExperience, object: nil)
                self.playVideoWithURL(audioVisual.videoURL)
            }
        } else {
            self.playVideoWithURL(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("mos-nextgen-interstitial", ofType: "mov")!))
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
        
        self.curIndex += 1
        if (self.curIndex < self.indexMax) {
            self.pauseVideo()
            self.countdownSeconds = 5;
            self.countdown.hidden = false
            self.countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.subtractTime), userInfo: nil, repeats: true)
            self.countdown.animateTimer()
            nextItemTask = delay(5) {
                NSNotificationCenter.defaultCenter().postNotificationName(kNextGenVideoPlayerWillPlayNextItem, object:self, userInfo:["index": self.curIndex])
                self.countdown.hidden = true;
                self.countdownTimer.invalidate()
                self.countdownTimer = nil
                self.countdownSeconds = 5;
                self.countdown.countdownString = "  \(self.countdownSeconds) sec"
            }
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.DidEndLastVideo, object: nil)
        }

        if mode == .Supplemental {
            super.playerItemDidReachEnd(notification)
        }
    }
    
    func delay(delay:Double, block:()->()) -> Task {
       
        func dispatch_later(block:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), block)
    }
        var closureBlock: dispatch_block_t? = block
        var result: Task?
        
        let delayedClosure: Task = {
            cancel in
            if let internalClosure = closureBlock {
                if (cancel == false) {
                    dispatch_async(dispatch_get_main_queue(), internalClosure);
                }
            }
            closureBlock = nil
            result = nil
        }
        
        result = delayedClosure
        
        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(cancel: false)
            }
        }
        
        return result!
    }
    
    func cancel(task:Task?) {
        if(self.countdownTimer !== nil){
            self.countdownTimer.invalidate()
        }
        self.countdownSeconds = 5
        self.countdown.countdownString = "  \(self.countdownSeconds) sec"
        self.countdown.hidden = true
        task?(cancel: true)
            }
        
            
    func subtractTime(){
        
        if (self.countdownSeconds == 0) {
            self.countdownTimer.invalidate()
            self.countdownTimer = nil
            self.countdownSeconds = 5
            self.countdown.countdownString = "  \(self.countdownSeconds) sec"
        } else {
            self.countdownSeconds -= 1
            self.countdown.countdownString = "  \(self.countdownSeconds) sec"
            }
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
        if !_controlsAreLocked {
            if !_didPlayInterstitial {
                skipInterstitial()
            }
            
            if _commentaryView.hidden{
                super.handleTap(gestureRecognizer)
            } else {
                commentary(_commentaryButton)
            }
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