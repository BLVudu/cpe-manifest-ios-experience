//
//  VideoPlayerViewController.swift
//  NextGen
//
//  Created by Alec Ananian on 1/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import DropDown
import FBSDKShareKit
import FBSDKCoreKit
import TwitterKit
import MessageUI

let kVideoPlayerTimeDidChange = "kVideoPlayerTimeDidChange"
let kVideoPlayerIsPlayingPrimaryVideo = "kVideoPlayerIsPlayingPrimaryVideo"

class VideoPlayerViewController: WBVideoPlayerViewController {
    
    var didPlayInterstitial = false
    var showsTopToolbar = true
    let shared = FBSDKShareLinkContent()
    var fullScreen = false
    var shouldPlayInterstitial = false
    var showCountdownTimer = false
    var mainFeatureIsPlaying = false
    
    
    @IBOutlet weak var shareContent: UIButton!
    @IBOutlet weak var commentaryBtn: UIButton!
    @IBOutlet weak var toolbar: UIView!
    var commentaryPopover: UIPopoverController!
    @IBOutlet weak var countdown: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName("pauseMovie", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.pauseVideo()
            self.isExtras = true
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("resumeMovie", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.playVideo()
            self.isExtras = false
            
        }
        
        if shouldPlayInterstitial {
            self.playerControlsVisible = false
            self.lockPlayerControls = true
            self.playVideoWithURL(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("mos-nextgen-interstitial", ofType: "mp4")!))
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("playMainFeature", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            
            if !self.didPlayInterstitial {
                self.playPrimaryVideo()
                self.didPlayInterstitial = true
            }
            
        }
    }
    
    func playPrimaryVideo() {
        self.lockPlayerControls = false
        self.mainFeatureIsPlaying = true
        /*if let audioVisual = NextGenDataManager.sharedInstance.mainExperience.audioVisual {
            self.playVideoWithURL(audioVisual.videoURL)
        }*/
        
        NSNotificationCenter.defaultCenter().postNotificationName(kVideoPlayerIsPlayingPrimaryVideo, object: nil)
        self.playVideoWithURL(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("man-of-steel-trailer3", ofType: "mp4")!))
    }
    /*
    override func playerItemDidReachEnd(notification: NSNotification!) {
        
        if !self.didPlayInterstitial {
            self.playPrimaryVideo()
            self.didPlayInterstitial = true
        }

    }
*/

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
            var curTime = (CMTimeGetSeconds(player.currentTime()))
            if (curTime.isNaN == true) {
                curTime = 0.0
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(kVideoPlayerTimeDidChange, object: nil, userInfo: ["time": Double(curTime)])
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showShare"{
            let shareVC = segue.destinationViewController as! SharingViewController
            shareVC.clip = DataManager.sharedInstance.content?.clip

        }
    }
    
        
    
    


}

