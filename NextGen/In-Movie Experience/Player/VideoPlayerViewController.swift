//
//  VideoPlayerViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 1/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import MessageUI

struct VideoPlayerNotification {
    static let DidChangeTime = "VideoPlayerNotificationDidChangeTime"
    static let DidPlayMainExperience = "VideoPlayerNotificationDidPlayMainExperience"
    static let DidTapShare = "VideoPlayerNotificationDidTapShare"
    static let ShouldPauseAllOtherVideos = "VideoPlayerNotificationShouldPauseAllOtherVideos"
    static let ShouldUpdateShareButton = "VideoPlayerNotificationShouldUpdateShareButton"
}

enum VideoPlayerMode {
    case MainFeature
    case Supplemental
    case SupplementalInMovie
}

class VideoPlayerViewController: WBVideoPlayerViewController, UIPopoverControllerDelegate {
    
    struct StoryboardSegue {
        static let ShowShare = "showShare"
    }
    
    let kMasterVideoPlayerViewControllerKey = "kMasterVideoPlayerViewControllerKey"
    
    var mode = VideoPlayerMode.Supplemental
    
    private var _didPlayInterstitial = false
    private var _lastNotifiedTime = -1.0
    private var _controlsAreLocked = false
    
    var showCountdownTimer = false
    @IBOutlet weak private var _commentaryView: UIView!
    @IBOutlet weak private var _commentaryButton: UIButton!
    @IBOutlet weak private var _homeButton: UIButton!
    private var _sharePopoverController: UIPopoverController!


    var countdownTimer: NSTimer!
    
    @IBOutlet weak var commentaryView: UIView!
    @IBOutlet weak var commentaryBtn: UIButton!
    @IBOutlet weak var toolbar: UIView!

    @IBOutlet weak var countdown: CircularProgressView!

    
    private var _shouldPauseAllOtherObserver: NSObjectProtocol!
    private var _shouldUpdateShareButtonObserver: NSObjectProtocol!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(_shouldPauseAllOtherObserver)
        NSNotificationCenter.defaultCenter().removeObserver(_shouldUpdateShareButtonObserver)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.countdown.hidden = true
        
        // Localizations
        _homeButton.setTitle(String.localize("label.home"), forState: UIControlState.Normal)
        _commentaryButton.setTitle(String.localize("label.commentary"), forState: UIControlState.Normal)
        
        _commentaryView.hidden = true
        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.setValue(NSAttributedString(string: String.localize("clipshare.rotate"), attributes: [NSForegroundColorAttributeName: UIColor.themePrimaryColor(), NSFontAttributeName: UIFont.themeCondensedFont(19)]), forKey: "_attributedTitle")
        alertController.view.tintColor = UIColor.themePrimaryColor()
        _sharePopoverController = UIPopoverController.init(contentViewController: alertController)
        _sharePopoverController.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        _sharePopoverController.delegate = self
        
        _shouldPauseAllOtherObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.ShouldPauseAllOtherVideos, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self, userInfo = notification.userInfo, masterVideoPlayerViewController = userInfo[strongSelf.kMasterVideoPlayerViewControllerKey] as? VideoPlayerViewController {
                if masterVideoPlayerViewController != strongSelf && strongSelf._didPlayInterstitial {
                    strongSelf.pauseVideo()
                }
            }
        })
        
        _shouldUpdateShareButtonObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.ShouldUpdateShareButton, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self {
                if let userInfo = notification.userInfo, enabled = userInfo["enabled"] as? Bool {
                    strongSelf.shareButton.enabled = enabled
                } else {
                    strongSelf.shareButton.enabled = false
                }
            }
        })
        
        if mode == VideoPlayerMode.MainFeature {
            self.fullScreenButton.removeFromSuperview()
            playMainExperience()
        } else {
            _didPlayInterstitial = true
            self.shareButton.removeFromSuperview()
            self.playerControlsVisible = false
            //self.lockTopToolbar = true
            self.toolbar.removeFromSuperview()
            
            if mode == VideoPlayerMode.SupplementalInMovie {
                self.fullScreenButton.removeFromSuperview()
            }
        }
    }
    
    // MARK: Video Playback
    func playMainExperience() {
        self.playerControlsVisible = false
        if _didPlayInterstitial {
            if let audioVisual = NextGenDataManager.sharedInstance.mainExperience.audioVisual {
                NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.DidPlayMainExperience, object: nil)
                self.playVideoWithURL(audioVisual.videoURL)
            }
        } else {
            self.playVideoWithURL(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("mos-nextgen-interstitial", ofType: "mov")!))
        }
    }
    
    func skipInterstitial() {
        self.pauseVideo()
        self.player.removeAllItems()
        self._didPlayInterstitial = true
        self.playMainExperience()
    }
    
    override func playVideo() {
        super.playVideo()
        
        NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.ShouldPauseAllOtherVideos, object: nil, userInfo: [kMasterVideoPlayerViewControllerKey: self])
    }
    
    override func syncScrubber() {
        super.syncScrubber()
        
        if player != nil && mode == VideoPlayerMode.MainFeature {
            var currentTime = _didPlayInterstitial ? CMTimeGetSeconds(player.currentTime()) : 0.0
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
            self.countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.subtractTime), userInfo: nil, repeats: true)
            self.countdown.animateTimer()
            let delayInSeconds = 5.0;
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue(), {
            NSNotificationCenter.defaultCenter().postNotificationName(kWBVideoPlayerWillPlayNextItem, object:self,userInfo:["index": NSNumber(int: self.curIndex)])
            self.countdown.hidden = true;
            self.countdownSeconds = 5;
            
            });

        }
    }
    

    
   

        func subtractTime(){
        
        if (self.countdownSeconds == 0) {
            self.countdownTimer.invalidate();
            self.countdownSeconds = 5;
            self.countdown.countdownString = "  \(self.countdownSeconds) sec"
        } else {
            
            self.countdownSeconds -= 1;
            self.countdown.countdownString = "  \(self.countdownSeconds) sec"
            }
        }

 // MARK: Actions
    override func done(sender: AnyObject?) {
        super.done(sender)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func commentary(sender: AnyObject) {
        _commentaryView.hidden = !_commentaryView.hidden
        
        if !_commentaryView.hidden {
            if let timer = self.playerControlsAutoHideTimer {
                timer.invalidate()
            }
        } else {
            self.initAutoHideTimer()
        }
    }
    
    @IBAction override func share(sender: AnyObject!) {
        if UIDevice.currentDevice().orientation.isLandscape {
            let anchor = self.view.frame.size.height - 120
            _sharePopoverController.presentPopoverFromRect(CGRectMake(sender.frame.origin.x,anchor, 300, 100), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection(rawValue: 0), animated: true)
                if((self.playerControlsAutoHideTimer) != nil){
                    self.playerControlsAutoHideTimer.invalidate()
            }
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.DidTapShare, object: nil)
        }
    }
    


    override func handleTap(gestureRecognizer: UITapGestureRecognizer!) {
        if !_controlsAreLocked {
            if !_didPlayInterstitial {
                skipInterstitial()
            }
            
            if _commentaryView.hidden && !_sharePopoverController.popoverVisible {
                super.handleTap(gestureRecognizer)
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

