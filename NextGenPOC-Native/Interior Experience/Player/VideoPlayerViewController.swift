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
    
    var video: Video!
    var currentScene: Scene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTitleText(video.title)
        self.setDeliveryFormatText(video.deliveryFormat)
        self.playVideoWithURL(video.url)
    }
    
    override func done(sender: AnyObject?) {
        super.done(sender)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func syncScrubber() {
        super.syncScrubber()
        
        if player != nil {
            let newScene = DataManager.sharedInstance.content?.sceneAtTime(Int(CMTimeGetSeconds(player.currentTime())))
            if newScene != self.currentScene {
                currentScene = newScene
                NSNotificationCenter.defaultCenter().postNotificationName(kSceneDidChange, object: nil, userInfo: ["scene": currentScene!])
            }
        }
    }

}
