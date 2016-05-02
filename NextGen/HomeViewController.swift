//
//  HomeViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/7/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import AVKit

class HomeViewController: UIViewController {
    
    private struct SegueIdentifier {
        static let ShowInMovieExperience = "ShowInMovieExperienceSegueIdentifier"
        static let ShowOutOfMovieExperience = "ShowOutOfMovieExperienceSegueIdentifier"
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundVideoView: UIView!
    
    private var didFinishPlayingObserver: NSObjectProtocol?
    private var didFadeInViews = false
    private var backgroundVideoPlayer: AVPlayer?
    
    deinit {
        if let observer = didFinishPlayingObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var fadeInViews = [UIView]()
        var willFadeInViews = false
        
        if let appearance = CurrentManifest.mainExperience.appearance {
            if let backgroundVideoURL = appearance.backgroundVideoURL {
                backgroundVideoPlayer = AVPlayer(playerItem: AVPlayerItem(URL: backgroundVideoURL))
                if let videoPlayer = backgroundVideoPlayer {
                    let videoLayer = AVPlayerLayer(player: videoPlayer)
                    videoLayer.frame = backgroundVideoView.frame
                    backgroundVideoView.layer.addSublayer(videoLayer)
                    
                    if appearance.backgroundVideoFadeTime > 0 {
                        willFadeInViews = true
                        
                        videoPlayer.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(1, Int32(NSEC_PER_SEC)), queue: dispatch_get_main_queue(), usingBlock: { [weak self] (time) in
                            if let strongSelf = self where !strongSelf.didFadeInViews && round(time.seconds) > appearance.backgroundVideoFadeTime {
                                strongSelf.didFadeInViews = true
                                
                                for view in fadeInViews {
                                    view.alpha = 0
                                    view.hidden = false
                                }
                                
                                UIView.animateWithDuration(0.5, animations: {
                                    for view in fadeInViews {
                                        view.alpha = 1
                                    }
                                })
                            }
                        })
                    }
                    
                    if appearance.backgroundVideoLoopTime > 0 {
                        didFinishPlayingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) in
                            videoPlayer.muted = true
                            videoPlayer.seekToTime(CMTimeMakeWithSeconds(appearance.backgroundVideoLoopTime, Int32(NSEC_PER_SEC)))
                            videoPlayer.play()
                        })
                    }
                }
            } else if let backgroundImage = appearance.backgroundImage {
                backgroundImageView.image = backgroundImage
            }
            
            if let origin = appearance.titleImageOrigin, size = appearance.titleImageSize {
                let imageView = UIImageView(frame: CGRectMake(origin.x, origin.y, size.width, size.height))
                imageView.image = appearance.titleImage
                imageView.hidden = true
                self.view.addSubview(imageView)
                
                fadeInViews.append(imageView)
            }
        }
        
        // Play button
        if let appearance = CurrentManifest.inMovieExperience.appearance, image = appearance.buttonImage, origin = appearance.buttonOrigin, size = appearance.buttonSize {
            let button = UIButton(frame: CGRectMake(origin.x, origin.y, size.width, size.height))
            button.setImage(image, forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(self.onPlay), forControlEvents: UIControlEvents.TouchUpInside)
            button.hidden = true
            self.view.addSubview(button)
            
            fadeInViews.append(button)
        }
        
        // Extras button
        if let appearance = CurrentManifest.outOfMovieExperience.appearance, image = appearance.buttonImage, origin = appearance.buttonOrigin, size = appearance.buttonSize {
            let button = UIButton(frame: CGRectMake(origin.x, origin.y, size.width, size.height))
            button.setImage(image, forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(self.onExtras), forControlEvents: UIControlEvents.TouchUpInside)
            button.hidden = true
            self.view.addSubview(button)
            
            fadeInViews.append(button)
        }
        
        if !willFadeInViews {
            for view in fadeInViews {
                view.hidden = false
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        backgroundVideoPlayer?.play()
    }
    
    override func viewWillDisappear(animated: Bool) {
        backgroundVideoPlayer?.pause()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    // MARK: Actions
    func onPlay() {
        self.performSegueWithIdentifier(SegueIdentifier.ShowInMovieExperience, sender: nil)
    }
    
    func onExtras() {
        self.performSegueWithIdentifier(SegueIdentifier.ShowOutOfMovieExperience, sender: nil)
    }
    
}

