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
    
    private var backgroundVideoFadeInViews: [UIView]?
    private var backgroundVideoTimeObserver: AnyObject?
    private var backgroundVideoPlayer: AVPlayer?
    private var backgroundVideoLayer: AVPlayerLayer?
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var homeScreenViews = [UIView]()
        var willFadeInViews = false
        
        if let appearance = CurrentManifest.mainExperience.appearance {
            willFadeInViews = appearance.backgroundVideoFadeTime > 0
            
            if let origin = appearance.titleImageOrigin, size = appearance.titleImageSize {
                let imageView = UIImageView(frame: CGRectMake(origin.x, origin.y, size.width, size.height))
                imageView.image = appearance.titleImage
                imageView.hidden = true
                self.view.addSubview(imageView)
                
                homeScreenViews.append(imageView)
            }
        }
        
        // Play button
        if let appearance = CurrentManifest.inMovieExperience.appearance, image = appearance.buttonImage, origin = appearance.buttonOrigin, size = appearance.buttonSize {
            let button = UIButton(frame: CGRectMake(origin.x, origin.y, size.width, size.height))
            button.setImage(image, forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(self.onPlay), forControlEvents: UIControlEvents.TouchUpInside)
            button.hidden = true
            self.view.addSubview(button)
            
            homeScreenViews.append(button)
        }
        
        // Extras button
        if let appearance = CurrentManifest.outOfMovieExperience.appearance, image = appearance.buttonImage, origin = appearance.buttonOrigin, size = appearance.buttonSize {
            let button = UIButton(frame: CGRectMake(origin.x, origin.y, size.width, size.height))
            button.setImage(image, forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(self.onExtras), forControlEvents: UIControlEvents.TouchUpInside)
            button.hidden = true
            self.view.addSubview(button)
            
            homeScreenViews.append(button)
        }
        
        if !willFadeInViews {
            for view in homeScreenViews {
                view.hidden = false
            }
        } else {
            backgroundVideoFadeInViews = homeScreenViews
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadVideoPlayer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        unloadVideoPlayer()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    // MARK: Video Player
    func loadVideoPlayer() {
        if let appearance = CurrentManifest.mainExperience.appearance {
            if let backgroundVideoURL = appearance.backgroundVideoURL {
                let videoPlayer = AVPlayer(playerItem: AVPlayerItem(URL: backgroundVideoURL))
                backgroundVideoLayer = AVPlayerLayer(player: videoPlayer)
                backgroundVideoLayer!.frame = backgroundVideoView.frame
                backgroundVideoView.layer.addSublayer(backgroundVideoLayer!)
                
                didFinishPlayingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) in
                    videoPlayer.muted = true
                    videoPlayer.seekToTime(CMTimeMakeWithSeconds(appearance.backgroundVideoLoopTime, Int32(NSEC_PER_SEC)))
                    videoPlayer.play()
                })
                
                if backgroundVideoFadeInViews?.count > 0 {
                    backgroundVideoTimeObserver = videoPlayer.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(0.55, Int32(NSEC_PER_SEC)), queue: dispatch_get_main_queue(), usingBlock: { [weak self] (time) in
                        if let strongSelf = self where time.seconds > appearance.backgroundVideoFadeTime {
                            if let observer = strongSelf.backgroundVideoTimeObserver {
                                videoPlayer.removeTimeObserver(observer)
                                strongSelf.backgroundVideoTimeObserver = nil
                            }
                            
                            if let views = strongSelf.backgroundVideoFadeInViews {
                                for view in views {
                                    view.alpha = 0
                                    view.hidden = false
                                }
                                
                                UIView.animateWithDuration(0.5, animations: {
                                    for view in views {
                                        view.alpha = 1
                                    }
                                })
                            }
                            
                            strongSelf.backgroundVideoFadeInViews = nil
                        }
                    })
                    
                    videoPlayer.play()
                } else {
                    videoPlayer.muted = true
                    videoPlayer.seekToTime(CMTimeMakeWithSeconds(appearance.backgroundVideoLoopTime, Int32(NSEC_PER_SEC)))
                    videoPlayer.play()
                }
                
                backgroundVideoPlayer = videoPlayer
                backgroundImageView.removeFromSuperview()
            } else if let backgroundImage = appearance.backgroundImage {
                backgroundImageView.image = backgroundImage
                backgroundVideoView.removeFromSuperview()
            }
        }
    }
    
    func unloadVideoPlayer() {
        if let observer = didFinishPlayingObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            didFinishPlayingObserver = nil
        }
        
        if let observer = backgroundVideoTimeObserver {
            backgroundVideoPlayer?.removeTimeObserver(observer)
        }
        
        backgroundVideoLayer?.player?.pause()
        backgroundVideoLayer?.removeFromSuperlayer()
        backgroundVideoLayer = nil
        backgroundVideoPlayer = nil
    }
    
    // MARK: Actions
    func onPlay() {
        self.performSegueWithIdentifier(SegueIdentifier.ShowInMovieExperience, sender: nil)
    }
    
    func onExtras() {
        self.performSegueWithIdentifier(SegueIdentifier.ShowOutOfMovieExperience, sender: nil)
    }
    
}

