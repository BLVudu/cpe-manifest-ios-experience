//
//  ClipViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/25/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MessageUI

class ClipViewController: UIViewController {
    
      @IBOutlet weak var player: UIView!
    

    var clipURL: NSURL!
    var clipThumbnail: NSURL!
    var clipCaption: String!
    
   

    var shareContent: NSURL!
    var clip: Clip? = nil {
        didSet {
            clipURL = clip?.url
            clipThumbnail = clip?.thumbnailImage
            clipCaption = (clip?.text)!
            
        }
    }
    
    

    override func viewDidLoad() {
        
        super.viewDidLoad()

         //clip = DataManager.sharedInstance.content?.allClips[0]
        
        //kWBVideoPlayerItemDurationDidLoadNotification
        
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
        func videoPlayerViewController() -> VideoPlayerViewController? {
        for viewController in self.childViewControllers {
            if viewController is VideoPlayerViewController {
                return viewController as? VideoPlayerViewController
            }
        }
        
        return nil
    }
    
    
    @IBAction func close(sender: AnyObject) {
        
        self.performSegueWithIdentifier("showCollection", sender: nil)
        
        //NSNotificationCenter.defaultCenter().postNotificationName("resumeMovie", object: nil)
        
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    @IBAction func shareClip(sender: AnyObject) {
        let activityViewController = UIActivityViewController(activityItems: [String.localize("clipshare.message", variables: ["movie_name": "Man of Steel", "clip_link": self.shareContent.absoluteString])], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as? UIView
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
}

    

