//
//  VideoPlayerViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 1/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import FBSDKShareKit
import FBSDKCoreKit
import TwitterKit
import MessageUI

let kVideoPlayerTimeDidChange = "kVideoPlayerTimeDidChange"
let kVideoPlayerIsPlayingMainExperience = "kVideoPlayerIsPlayingMainExperience"
let kVideoPlayerShouldPause = "kVideoPlayerShouldPause"
let kVideoPlayerShouldResume = "kVideoPlayerShouldResume"

class VideoPlayerViewController: WBVideoPlayerViewController {
    
    var showsTopToolbar = true
    let shared = FBSDKShareLinkContent()
    var fullScreen = false
    var showCountdownTimer = false
    
    var shouldPlayMainExperience = false
    private var _didPlayInterstitial = false
    
    @IBOutlet weak var shareContent: UIButton!
    @IBOutlet weak var commentaryBtn: UIButton!
    @IBOutlet weak var toolbar: UIView!
    var commentaryPopover: UIPopoverController!
    @IBOutlet weak var countdown: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(kVideoPlayerShouldPause, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.pauseVideo()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(kVideoPlayerShouldResume, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.playVideo()
        }
        
        if shouldPlayMainExperience {
            playMainExperience()
        }
    }
    
    func playMainExperience() {
        self.playerControlsVisible = false
        self.lockPlayerControls = !_didPlayInterstitial
        if _didPlayInterstitial {
            if let audioVisual = NextGenDataManager.sharedInstance.mainExperience.audioVisual {
                NSNotificationCenter.defaultCenter().postNotificationName(kVideoPlayerIsPlayingMainExperience, object: nil)
                self.playVideoWithURL(audioVisual.videoURL)
            }
        } else {
            self.playVideoWithURL(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("mos-nextgen-interstitial", ofType: "mov")!))
        }
    }
    
    override func playerItemDidReachEnd(notification: NSNotification!) {
        super.playerItemDidReachEnd(notification)
        
        if shouldPlayMainExperience && !_didPlayInterstitial {
            _didPlayInterstitial = true
            playMainExperience()
        }
    }
    
    override func done(sender: AnyObject?) {
        super.done(sender)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func commentary(sender: AnyObject) {
        let cpo = self.storyboard?.instantiateViewControllerWithIdentifier("commentary")
        self.commentaryPopover = UIPopoverController.init(contentViewController: cpo!)
        self.commentaryPopover.popoverContentSize = CGSizeMake(320.0, 300.0)
        self.commentaryPopover.backgroundColor = UIColor.blackColor()
        self.commentaryPopover.presentPopoverFromRect(CGRectMake(sender.frame.origin.x,200,1,1), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection(rawValue: 0), animated: true)
    }
    
    override func syncScrubber() {
        super.syncScrubber()
        
        if player != nil {
            var currentTime = 0.0
            if shouldPlayMainExperience && _didPlayInterstitial {
                currentTime = CMTimeGetSeconds(player.currentTime())
                if currentTime.isNaN {
                    currentTime = 0.0
                }
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(kVideoPlayerTimeDidChange, object: nil, userInfo: ["time": Double(currentTime)])
            /*if (self.currentScene?.canShare == false){
                self.shareContent.alpha = 0.5
            } else{
                self.shareContent.alpha = 1
            }
            self.shareContent.userInteractionEnabled = (self.currentScene?.canShare)!*/
        }
    }
    
    
    @IBAction func showFullScreen(sender: AnyObject) {
        
        self.fullScreen = !self.fullScreen
        NSNotificationCenter.defaultCenter().postNotificationName("fullScreen", object: nil,userInfo: ["toggleFS": self.fullScreen])
   
    }
    

    @IBAction func shareClip(sender: UIButton) {

        
        if UIDevice.currentDevice().orientation.isLandscape {
        
            let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let styledTitle = NSAttributedString(string: "Rotate device to share clip", attributes: [NSForegroundColorAttributeName: UIColor.yellowColor()])
            alert.setValue(styledTitle, forKey: "_attributedTitle")
            let pop = UIPopoverController.init(contentViewController: alert)
            pop.backgroundColor = UIColor.blackColor()
            let anchor = self.view.frame.size.height - 100
            pop.presentPopoverFromRect(CGRectMake(sender.frame.origin.x,anchor, 300, 100), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection(rawValue: 0), animated: true)
            alert.view.tintColor = UIColor.yellowColor()

    }
        else if UIDevice.currentDevice().orientation.isPortrait{
            
            self.performSegueWithIdentifier("showShare", sender: nil)
        }
    }
    
   
    
  


}

