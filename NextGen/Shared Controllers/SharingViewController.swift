//
//  SharingViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/1/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class SharingViewController: SceneDetailViewController {
    
    @IBOutlet weak var player: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var clipDuration: UILabel!
    @IBOutlet weak var clipName: UILabel!
    @IBOutlet weak var clipThumbnailView: UIImageView!
    
    private var _durationDidLoadObserver: NSObjectProtocol!
    
    var clipURL: NSURL!
    var clipThumbnail: NSURL!
    var clipCaption: String!
    
    private var _shareableURL: NSURL?
    
    var clip: Clip? = nil {
        didSet {
            clipURL = clip?.url
            clipThumbnail = clip?.thumbnailImage
            clipCaption = (clip?.text)
            
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(_durationDidLoadObserver)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clipName.text = clip?.text
        clipThumbnailView.setImageWithURL(clipThumbnail)
        
        _durationDidLoadObserver = NSNotificationCenter.defaultCenter().addObserverForName(kWBVideoPlayerItemDurationDidLoadNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            if let strongSelf = self, userInfo = notification.userInfo, duration = userInfo["duration"] as? NSTimeInterval {
                strongSelf.clipDuration.text = duration.timeString()
            }
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
    
    // MARK: Actions
    @IBAction func playClip(sender: AnyObject) {
        self.clipThumbnailView.hidden = true
        self.playButton.hidden = true
        
        if let videoURL = clip?.url, videoPlayerViewController = videoPlayerViewController() {
            videoPlayerViewController.curIndex = 0
            videoPlayerViewController.indexMax = 1
            videoPlayerViewController.mode = VideoPlayerMode.SupplementalInMovie
            videoPlayerViewController.playVideoWithURL(videoURL)
            _shareableURL = videoURL
        }
    }
    
    @IBAction func shareClip(sender: AnyObject) {
        if let url = _shareableURL {
            let activityViewController = UIActivityViewController(activityItems: [String.localize("clipshare.message", variables: ["movie_name": "Man of Steel", "clip_link": url.absoluteString])], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = sender as? UIView
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
}