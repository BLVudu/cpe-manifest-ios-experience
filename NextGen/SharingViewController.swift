//
//  SharingViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/1/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import FBSDKShareKit
import FBSDKCoreKit
import TwitterKit
import MessageUI


class SharingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FBSDKSharingDelegate,MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var player: UIView!
    
    var experience: NGEExperienceType!
    
    @IBOutlet weak var fbShare: FBSDKShareButton!
    var shareContent: NSURL!
    let shared = FBSDKShareLinkContent()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        experience = NextGenDataManager.sharedInstance.outOfMovieExperienceCategories()[3]
        print(experience.childExperiences().count)
        
        self.tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: VideoCell.ReuseIdentifier)
        
        let selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        self.tableView(self.tableView, didSelectRowAtIndexPath: selectedIndexPath)
        
        fbShare.shareContent = shared
        NSNotificationCenter.defaultCenter().postNotificationName("pauseMovie", object: nil)
        
    }
    
    
    @IBAction func close(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("resumeMovie", object: nil)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(VideoCell.ReuseIdentifier, forIndexPath: indexPath) as! VideoCell
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        
        let thisExperience = experience.childExperiences()[indexPath.row]
        
        cell.caption.text = thisExperience.metadata()?.fullTitle()
        if let thumbnailPath = thisExperience.thumbnailImagePath() {
            cell.thumbnail.setImageWithURL(NSURL(string: thumbnailPath)!)
        } else {
            cell.thumbnail.image = nil
        }
        
        return cell

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }

    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experience.childExperiences().count
    }
    
    func videoPlayerViewController() -> VideoPlayerViewController? {
        for viewController in self.childViewControllers {
            if viewController is VideoPlayerViewController {
                return viewController as? VideoPlayerViewController
            }
        }
        
        return nil
    }
    

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let thisExperience = experience.childExperiences()[indexPath.row]
        
        if let videoURL = thisExperience.videoURL(), videoPlayerViewController = videoPlayerViewController() {
            if let player = videoPlayerViewController.player {
                player.removeAllItems()
            }
            
            videoPlayerViewController.playerControlsVisible = false
            videoPlayerViewController.lockTopToolbar = true
            videoPlayerViewController.playVideoWithURL(videoURL)
            self.shareContent = videoURL
            //NSNotificationCenter.defaultCenter().addObserverForName("endClip", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
                
              //  videoPlayerViewController.player.seekToTime(CMTimeMake(0, 1))
               // videoPlayerViewController.pauseVideo()
                
                
            //}

            
            
        }
    }
    
    @IBAction func shareTW(sender: AnyObject) {
        let compose = TWTRComposer()
        compose.setURL(self.shareContent)
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
    

}

    @IBAction func shareSMS(sender: AnyObject) {
        
        let sms = MFMessageComposeViewController()
        sms.messageComposeDelegate = self
        sms.body = "Check out this clip from Man of Steel " + String(self.shareContent)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        self.presentViewController(sms, animated: true, completion: nil)

    }
    @IBAction func shareEmail(sender: AnyObject) {
        
        let email = MFMailComposeViewController()
        email.mailComposeDelegate = self
        email.setSubject("Man of Steel")
        email.setMessageBody("Check out this clip from Man of Steel "  + String(self.shareContent), isHTML: true)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        self.presentViewController(email, animated: true, completion: nil)
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
