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
    static let ShouldPause = "VideoPlayerNotificationShouldPause"
    static let ShouldResume = "VideoPlayerNotificationShouldResume"
}

enum VideoPlayerMode {
    case MainFeature
    case Supplemental
}

class VideoPlayerViewController: WBVideoPlayerViewController {
    
    struct StoryboardSegue {
        static let ShowShare = "showShare"
    }
    
    var mode = VideoPlayerMode.Supplemental
    
    private var _didPlayInterstitial = false
    private var _lastNotifiedTime = -1.0
    
    var showCountdownTimer = false
    var currentClip: Clip?
    
    @IBOutlet weak var commentaryView: UIView!
    @IBOutlet weak var commentaryBtn: UIButton!
    @IBOutlet weak var toolbar: UIView!
    var commentaryPopover: UIPopoverController!
    @IBOutlet weak var countdown: UIView!
    
    private var _shouldPauseObserver: NSObjectProtocol!
    private var _shouldResumeObserver: NSObjectProtocol!
    
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(_shouldPauseObserver)
        center.removeObserver(_shouldResumeObserver)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentaryView.hidden = true
        
        _shouldPauseObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.ShouldPause, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            if let strongSelf = self {
                if strongSelf._didPlayInterstitial {
                    strongSelf.pauseVideo()
                }
            }
        }
        
        _shouldResumeObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.ShouldResume, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            if let strongSelf = self {
                if strongSelf._didPlayInterstitial {
                    strongSelf.playVideo()
                }
            }
        }
        
        if mode == VideoPlayerMode.MainFeature {
            self.fullScreenButton.removeFromSuperview()
            playMainExperience()
        } else {
            _didPlayInterstitial = true
            self.shareButton.removeFromSuperview()
            self.playerControlsVisible = false
            self.lockTopToolbar = true
        }
    }
    
    func playMainExperience() {
        self.playerControlsVisible = false
        self.lockPlayerControls = !_didPlayInterstitial
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
    
    override func playerItemDidReachEnd(notification: NSNotification!) {
        super.playerItemDidReachEnd(notification)
        
       

        if !_didPlayInterstitial {
            _didPlayInterstitial = true
            playMainExperience()
        }
    }
    
    override func done(sender: AnyObject?) {
        super.done(sender)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func commentary(sender: AnyObject) {
        self.commentaryView.hidden = !self.commentaryView.hidden
       

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
    
    @IBAction override func share(sender: AnyObject!) {
        if UIDevice.currentDevice().orientation.isLandscape {
            let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let styledTitle = NSAttributedString(string: "Rotate device to share clip", attributes: [NSForegroundColorAttributeName: UIColor.yellowColor(), NSFontAttributeName: UIFont(name: "RobotoCondensed-Regular",size: 19)!])

            alert.setValue(styledTitle, forKey: "_attributedTitle")
            let pop = UIPopoverController.init(contentViewController: alert)
            pop.backgroundColor = UIColor.blackColor()
            let anchor = self.view.frame.size.height - 100
            pop.presentPopoverFromRect(CGRectMake(sender.frame.origin.x,anchor, 300, 100), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection(rawValue: 0), animated: true)
            alert.view.tintColor = UIColor.yellowColor()
        } else {
            
            NSNotificationCenter.defaultCenter().postNotificationName(StoryboardSegue.ShowShare, object: nil, userInfo: ["clip": self.currentClip!])

        }
    }
    
    
    override func handleTap(gestureRecognizer: UITapGestureRecognizer!) {
        super.handleTap(gestureRecognizer)
        
        
        if self.commentaryView.hidden == false{
            self.commentaryView.hidden = true
        }
        
        if !_didPlayInterstitial {
            skipInterstitial()
        }
    }
    
    /*
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !_didPlayInterstitial {
            skipInterstitial()
        }
    }
*/

}

