//
//  VideoPlayerViewController.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/13/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//

import UIKit

class VideoPlayerViewController: WBVideoPlayerViewController {
    
    var video: Video!
    
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

}
