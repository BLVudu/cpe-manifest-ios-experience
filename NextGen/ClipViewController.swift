//
//  ClipViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/25/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import FBSDKShareKit
import FBSDKCoreKit
import TwitterKit
import MessageUI

class ClipViewController: UIViewController {
    
      @IBOutlet weak var player: UIView!
    
    var experience: NGEExperienceType!
    var clipURL: NSURL!
    var clipThumbnail: NSURL!
    var clipCaption: String!
    
   

    var shareContent: NSURL!
    let shared = FBSDKShareLinkContent()
    var clip: Clip? = nil {
        didSet {
            clipURL = clip?.url
            clipThumbnail = clip?.thumbnailImage
            clipCaption = (clip?.text)!
            
        }
    }
    
    

    override func viewDidLoad() {
        
        super.viewDidLoad()

         clip = DataManager.sharedInstance.content?.allClips[0]
        
        
        if let videoURL = self.clip?.url, videoPlayerViewController = videoPlayerViewController() {
            if let player = videoPlayerViewController.player {
                player.removeAllItems()
            }
            
            videoPlayerViewController.curIndex = 0
            videoPlayerViewController.indexMax = 1
            videoPlayerViewController.playerControlsVisible = false
            videoPlayerViewController.lockTopToolbar = true
            videoPlayerViewController.playVideoWithURL(videoURL)
            self.shareContent = videoURL
            
            
            
        }
 
    }
    
        /*
        NSNotificationCenter.defaultCenter().addObserverForName("playNextItem", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
        
        if let userInfo = notification.userInfo{
        let index = userInfo["index"]as! Int
        if index >= 1{
        } else {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        self.tableView(self.tableView, didSelectRowAtIndexPath: indexPath)
        
        
        
        }
        }
        
        
        }
        
        */
    
    
    
    @IBAction func close(sender: AnyObject) {
        
        //self.performSegueWithIdentifier("showCollection", sender: nil)
        
        NSNotificationCenter.defaultCenter().postNotificationName("resumeMovie", object: nil)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    @IBAction func shareClip(sender: AnyObject) {
        
        
        let activityViewController = UIActivityViewController(activityItems: [self.shareContent], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as? UIView
        self.presentViewController(activityViewController, animated: true, completion: nil)
    

    }
    
    func videoPlayerViewController() -> VideoPlayerViewController? {
        for viewController in self.childViewControllers {
            if viewController is VideoPlayerViewController {
                return viewController as? VideoPlayerViewController
            }
        }
        
        return nil
    }
    
    
    
    
    
    @IBAction func shareTW(sender: AnyObject) {
        let compose = TWTRComposer()
        compose.setURL(self.shareContent)
        compose.setText("Check out this clip from Man of Steel")
        
        compose.showFromViewController(self) { result in
            if (result == TWTRComposerResult.Cancelled) {
                print("Tweet composition cancelled")
            }
            else if result == TWTRComposerResult.Done {
                //self.performSegueWithIdentifier("showCollection", sender: nil)
            }
            
            
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
    
    
}

