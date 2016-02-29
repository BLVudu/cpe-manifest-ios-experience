//
//  VideoPlayerViewController.swift
//  NextGenPOC-Native
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

let kSceneDidChange = "kSceneDidChange"

class VideoPlayerViewController: WBVideoPlayerViewController, FBSDKSharingDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    var video: Video?
    var currentScene: Scene?
    var didPlayInterstitial = false
    var showsTopToolbar = true
    let shared = FBSDKShareLinkContent()
    
    @IBOutlet weak var commentaryBtn: UIButton!
    @IBOutlet weak var toolbar: UIView!
    var commentaryPopover: UIPopoverController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if video != nil {
            if video!.interstitialUrl != nil {
                self.playerControlsVisible = false
                self.lockPlayerControls = true
                // self.playVideoWithURL(video!.interstitialUrl)
                self.playVideoWithURL(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("mos-nextgen-interstitial", ofType: "mp4")!))
            } else {
                playPrimaryVideo()
            }
        }
    }
    
    func playPrimaryVideo() {
        self.lockPlayerControls = false
        // self.playVideoWithURL(video!.url)
        self.playVideoWithURL(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("man-of-steel-trailer3", ofType: "mp4")!))
    }
    
    override func playerItemDidReachEnd(notification: NSNotification!) {
        if !didPlayInterstitial {
            playPrimaryVideo()
            didPlayInterstitial = true
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
            var curTime = (CMTimeGetSeconds(player.currentTime()))
            if (curTime.isNaN == true){
                
                curTime = 0.0
            }
            
            let newScene = DataManager.sharedInstance.content?.sceneAtTime(Int(curTime))
            
            if newScene != self.currentScene {
                currentScene = newScene
                NSNotificationCenter.defaultCenter().postNotificationName(kSceneDidChange, object: nil, userInfo: ["scene": currentScene!])
            }
        
        }
    }

    @IBAction func shareClip(sender: UIButton) {

        
        if UIApplication.sharedApplication().statusBarOrientation.isLandscape {
        
            let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let styledTitle = NSAttributedString(string: "Rotate device to share clip", attributes: [NSForegroundColorAttributeName: UIColor.yellowColor()])
            alert.setValue(styledTitle, forKey: "_attributedTitle")
            let pop = UIPopoverController.init(contentViewController: alert)
            pop.backgroundColor = UIColor.blackColor()
            print(self.view.frame.size.height)
            pop.presentPopoverFromRect(CGRectMake(sender.frame.origin.x,520, 300, 400), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection(rawValue: 0), animated: true)
            alert.view.tintColor = UIColor.yellowColor()

    } else {
        let share = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let fb = UIAlertAction(title: "Facebook", style: UIAlertActionStyle.Default, handler:
                { Void in
                    self.shared.contentURL = self.video?.url
                    FBSDKShareDialog.showFromViewController(self, withContent: self.shared, delegate:self)

            })
        let tw = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default, handler:
            { Void in
                
                let compose = TWTRComposer()
                compose.setURL(self.video?.url)
                compose.setText("Check out this clip from Man of Steel")
                
                compose.showFromViewController(self) { result in
                    if (result == TWTRComposerResult.Cancelled) {
                        print("Tweet composition cancelled")
                    }
                    else {
                        let success = UIAlertView(title: "Success", message: "Your content has been shared!", delegate: nil, cancelButtonTitle: "OK")
                        success.show()
                        }

                
                }
        })
        let sms = UIAlertAction(title: "SMS", style: UIAlertActionStyle.Default, handler:
            { Void in
                
                let sms = MFMessageComposeViewController()
                sms.messageComposeDelegate = self
                sms.body = "Check out this clip from Man of Steel " + String(self.video!.url)
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
                self.presentViewController(sms, animated: true, completion: nil)
                
                
        })
            let email = UIAlertAction(title: "Email", style: UIAlertActionStyle.Default, handler:
                { Void in
                    
                let email = MFMailComposeViewController()
                email.mailComposeDelegate = self
                email.setSubject("Man of Steel")
                email.setMessageBody("Check out this clip from Man of Steel "  + String(self.video!.url), isHTML: true)
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
                self.presentViewController(email, animated: true, completion: nil)
 
                
                
            })
        share.addAction(fb)
        share.addAction(tw)
        share.addAction(sms)
        share.addAction(email)
        let styledTitle = NSAttributedString(string: "Share to", attributes: [NSForegroundColorAttributeName: UIColor.yellowColor()])
        share.setValue(styledTitle, forKey: "_attributedTitle")
        let pop = UIPopoverController.init(contentViewController: share)
        pop.backgroundColor = UIColor.blackColor()
        pop.presentPopoverFromRect(CGRectMake(sender.frame.origin.x,340, 300, 400), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection(rawValue: 0), animated: true)
        share.view.tintColor = UIColor.yellowColor()
        

    
        }
        
        

    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        
        if results.count == 0{
            
            let success = UIAlertView(title: "Success", message: "Your content has been shared!", delegate: nil, cancelButtonTitle: "OK")
            success.show()
            
        }
        
        
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        
        let error = UIAlertView(title: "Error", message: "Please try again", delegate: nil, cancelButtonTitle: "OK")
        error.show()
        print(error)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        switch(result){
        case MessageComposeResultCancelled:
            break
        case MessageComposeResultSent:
            
            let success = UIAlertView(title: "Success", message: "Your content has been shared!", delegate: nil, cancelButtonTitle: "OK")
            success.show()

        case MessageComposeResultFailed:
            break;
        default:
            break
        }
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        switch(result){
        case MFMailComposeResultCancelled:
            break
        case MFMailComposeResultSent:
            let success = UIAlertView(title: "Success", message: "Your content has been shared!", delegate: nil, cancelButtonTitle: "OK")
            success.show()

        case MFMailComposeResultFailed:
            break;
        default:
            break
        }
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        self.dismissViewControllerAnimated(true, completion: nil)
        

    }
    
    


}

