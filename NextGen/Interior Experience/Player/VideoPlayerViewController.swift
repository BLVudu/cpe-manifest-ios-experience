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
    static let ShouldPauseAllOtherVideos = "VideoPlayerNotificationShouldPauseAllOtherVideos"
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
    var currentClip: Clip?
    
    @IBOutlet weak var commentaryView: UIView!
    @IBOutlet weak var commentaryBtn: UIButton!
    @IBOutlet weak var toolbar: UIView!
    private var _sharePopoverController: UIPopoverController!
    @IBOutlet weak var countdown: UIView!
    
    private var _shouldPauseAllOtherObserver: NSObjectProtocol!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(_shouldPauseAllOtherObserver)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentaryView.hidden = true
        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.setValue(NSAttributedString(string: String.localize("clipshare.rotate"), attributes: [NSForegroundColorAttributeName: UIColor.yellowColor(), NSFontAttributeName: UIFont(name: "RobotoCondensed-Regular",size: 19)!]), forKey: "_attributedTitle")
        alertController.view.tintColor = UIColor.yellowColor()
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
        
        if mode == VideoPlayerMode.MainFeature {
            self.fullScreenButton.removeFromSuperview()
            playMainExperience()
        } else {
            _didPlayInterstitial = true
            self.shareButton.removeFromSuperview()
            self.playerControlsVisible = false
            self.lockTopToolbar = true
            
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
            
            if let newClip = DataManager.sharedInstance.content?.clipToShareAtTime(currentTime) {
                if newClip != currentClip {
                    currentClip = newClip
                    shareButton.enabled = true
                }
            } else {
                shareButton.enabled = false
            }
            
            if _lastNotifiedTime != currentTime {
                _lastNotifiedTime = currentTime
                NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.DidChangeTime, object: nil, userInfo: ["time": Double(currentTime)])
            }
        }
    }
    
    override func playerItemDidReachEnd(notification: NSNotification!) {
        super.playerItemDidReachEnd(notification)
        
        if !_didPlayInterstitial {
            _didPlayInterstitial = true
            playMainExperience()
        }
    }
    
    
    // MARK: Actions
    override func done(sender: AnyObject?) {
        super.done(sender)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func commentary(sender: AnyObject) {
        self.commentaryView.hidden = !self.commentaryView.hidden
        
        if !self.commentaryView.hidden {
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
            NSNotificationCenter.defaultCenter().postNotificationName(StoryboardSegue.ShowShare, object: nil, userInfo: ["clip": self.currentClip!])
        }
    }
    
    override func handleTap(gestureRecognizer: UITapGestureRecognizer!) {
        if !_controlsAreLocked {
            if !_didPlayInterstitial {
                skipInterstitial()
            }
            
            if commentaryView.hidden && !_sharePopoverController.popoverVisible {
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

