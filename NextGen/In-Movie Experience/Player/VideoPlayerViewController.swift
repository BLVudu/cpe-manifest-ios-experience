//
//  VideoPlayerViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 1/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import Foundation
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

typealias Task = (cancel : Bool) -> ()

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

  
    
    @IBOutlet weak var toolbar: UIView!


    @IBOutlet weak var countdown: CircularProgressView!
    var countdownTimer: NSTimer!
    var nextItemTask: Task?
    private var _clipAvaliable = false
    var commentaryIndex = 0
    var alertController: UIAlertController!
    
    private var _shouldPauseAllOtherObserver: NSObjectProtocol!
    private var _shouldUpdateShareButtonObserver: NSObjectProtocol!
    private var _updateCommentaryButton: NSObjectProtocol!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(_shouldPauseAllOtherObserver)
        NSNotificationCenter.defaultCenter().removeObserver(_shouldUpdateShareButtonObserver)
        NSNotificationCenter.defaultCenter().removeObserver(_updateCommentaryButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.countdown.hidden = true
        
        
        // Localizations
        _homeButton.setTitle(String.localize("label.home"), forState: UIControlState.Normal)
        _commentaryButton.setTitle(String.localize("label.commentary"), forState: UIControlState.Normal)
        _commentaryView.hidden = true
        shareButton.enabled = true
        alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        _shouldPauseAllOtherObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.ShouldPauseAllOtherVideos, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self, userInfo = notification.userInfo, masterVideoPlayerViewController = userInfo[strongSelf.kMasterVideoPlayerViewControllerKey] as? VideoPlayerViewController {
                if masterVideoPlayerViewController != strongSelf && strongSelf._didPlayInterstitial {
                    strongSelf.pauseVideo()
                }
            }
        })
        
        
        _shouldUpdateShareButtonObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.ShouldUpdateShareButton, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self {
                if let userInfo = notification.userInfo, avaliable = userInfo["clipAvaliable"] as? Bool {
                        strongSelf._clipAvaliable = avaliable
                    } else {
                        strongSelf._clipAvaliable = false

                }
            }
        })
        
        _updateCommentaryButton = NSNotificationCenter.defaultCenter().addObserverForName(kDidSelectCommetaryOption, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self]
            (notification) in
            if let strongSelf = self{
                if let userInfo = notification.userInfo, index = userInfo["option"] as? Int{
                    strongSelf.commentaryIndex = index
                    strongSelf._commentaryButton.setTitle(index > 0 ? String.localize("label.commentary.on") : String.localize("label.commentary"), forState: .Normal)
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
            self.topToolbar.removeFromSuperview()
            
            if mode == VideoPlayerMode.SupplementalInMovie {
                self.fullScreenButton.removeFromSuperview()
            }
        }
    }
    
    // MARK: Video Playback
    override func playVideoWithURL(url: NSURL!) {
        super.playVideoWithURL(url)
        
        SettingsManager.setVideoAsWatched(url)
    }
    
    func playMainExperience() {
        self.playerControlsVisible = false
        if _didPlayInterstitial {
            if let audioVisual = CurrentManifest.mainExperience.audioVisual {
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
            nextItemTask = delay(delayInSeconds){
            NSNotificationCenter.defaultCenter().postNotificationName(kWBVideoPlayerWillPlayNextItem, object:self,userInfo:["index": NSNumber(int: self.curIndex)])
            self.countdown.hidden = true;
            self.countdownTimer.invalidate()
            self.countdownTimer = nil
            self.countdownSeconds = 5;
            self.countdown.countdownString = "  \(self.countdownSeconds) sec"
            
            }

        }
        
        super.playerItemDidReachEnd(notification)
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
    
    @IBAction override func share(sender: AnyObject!) {
        alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let anchor = self.view.frame.size.height - 120
        if _clipAvaliable == false {
            
            alertController.setValue(NSAttributedString(string: String.localize("clipshare.next_clip"), attributes: [NSForegroundColorAttributeName: UIColor.themePrimaryColor(), NSFontAttributeName: UIFont.themeCondensedFont(19)]), forKey: "_attributedTitle")
            
        } else if _clipAvaliable == true{
            
            if UIDevice.currentDevice().orientation.isLandscape {
            
            alertController.setValue(NSAttributedString(string: String.localize("clipshare.rotate"), attributes: [NSForegroundColorAttributeName: UIColor.themePrimaryColor(), NSFontAttributeName: UIFont.themeCondensedFont(19)]), forKey: "_attributedTitle")
        } else{
            
            NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.DidTapShare, object: nil)
            }

        }
        
        alertController.view.tintColor = UIColor.themePrimaryColor()
        _sharePopoverController = UIPopoverController.init(contentViewController: alertController)
        _sharePopoverController.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        _sharePopoverController.delegate = self
        
        _sharePopoverController.presentPopoverFromRect(CGRectMake(sender.frame.origin.x,anchor, 300, 100), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection(rawValue: 0), animated: true)
        if((self.playerControlsAutoHideTimer) != nil){
            self.playerControlsAutoHideTimer.invalidate()
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


