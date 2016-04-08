//
//  SharingViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/1/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit



class SharingViewController: UIViewController{
    
    
    @IBOutlet weak var player: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var clipDuration: UILabel!
    @IBOutlet weak var clipName: UILabel!
    @IBOutlet weak var clipThumbnailView: UIImageView!
    
    var clipURL: NSURL!
    var clipThumbnail: NSURL!
    var clipCaption: String!
    
    
    
    var shareContent: NSURL!
    var clip: Clip? = nil {
        didSet {
            clipURL = clip?.url
            clipThumbnail = clip?.thumbnailImage
            clipCaption = (clip?.text)
            
        }
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        

        
        NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.ShouldPause, object: nil)
        clipName.text = clip?.text
        clipThumbnailView.setImageWithURL(clipThumbnail)
        if let videoURL = self.clip?.url, videoPlayerViewController = videoPlayerViewController() {
            if let player = videoPlayerViewController.player {
                player.removeAllItems()
            }
            
            videoPlayerViewController.curIndex = 0
            videoPlayerViewController.indexMax = 1
            videoPlayerViewController.playerControlsVisible = false
            videoPlayerViewController.lockTopToolbar = true
            videoPlayerViewController.playVideoWithURL(videoURL)
            
            NSNotificationCenter.defaultCenter().addObserverForName(kWBVideoPlayerItemReadyToPlayNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
                
                videoPlayerViewController.pauseVideo()
                
                
            }
            
            NSNotificationCenter.defaultCenter().addObserverForName(kWBVideoPlayerItemDurationDidLoadNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
                
                if let userInfo = notification.userInfo{
                    let duration = userInfo["duration"] as! NSTimeInterval
                    
                    self.clipDuration.text = duration.timeString()
                }
            }
            
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

    

    @IBAction func playClip(sender: AnyObject) {
        
        self.clipThumbnailView.hidden = true
        self.playButton.hidden = true
        
        videoPlayerViewController()?.playVideo()
        
        
    }

    
    @IBAction func shareClip(sender: AnyObject) {
        
        /*
        let activityViewController = UIActivityViewController(activityItems: ["Check out this clip from Man of Steel \(self.shareContent)"], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as? UIView
        activityViewController.excludedActivityTypes = [UIActivityTypeCopyToPasteboard]
        self.presentViewController(activityViewController, animated: true, completion: nil)
        */
        
    }

    

    @IBAction func close(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(VideoPlayerNotification.ShouldResume, object: nil)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
}