//
//  VideoPlayerViewController.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

let kSceneDidChange = "kSceneDidChange"

class VideoPlayerViewController: WBVideoPlayerViewController {
    
    var video: Video?
    var currentScene: Scene?
    var didPlayInterstitial = false
    var showsTopToolbar = true
    
    @IBOutlet weak var commentaryBtn: UIButton!
    
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
        
        
        let ac = UIAlertController(title: "", message: "", preferredStyle: .ActionSheet)
        let director = UIAlertAction(title: "Director Commentary", style: .Default, handler: nil)
        let video = UIAlertAction(title: "Video Commentary", style: .Default, handler: nil)
        let actor = UIAlertAction(title: "Actor Commentary", style: .Default, handler: nil)
        let popover = ac.popoverPresentationController
        popover?.sourceView = view
        popover?.sourceRect = CGRect(x: self.commentaryBtn.frame.origin.x, y: self.commentaryBtn.frame.origin.y-30, width: 64, height: 64)
        popover?.backgroundColor = UIColor.darkGrayColor()
   
        ac.addAction(director)
        ac.addAction(video)
        ac.addAction(actor)
        presentViewController(ac, animated: true, completion: nil)
        
        
        
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


}
