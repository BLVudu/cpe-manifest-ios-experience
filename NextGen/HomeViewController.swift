//
//  HomeViewController.swift
//  Created by Sedinam Gadzekpo on 1/7/16.
//

import UIKit
import AVFoundation
import NextGenDataManager

class HomeViewController: UIViewController {
    
    private struct SegueIdentifier {
        static let ShowInMovieExperience = "ShowInMovieExperienceSegueIdentifier"
        static let ShowOutOfMovieExperience = "ShowOutOfMovieExperienceSegueIdentifier"
    }
    
    @IBOutlet weak private var backButton: UIButton!
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak private var backgroundVideoView: UIView!
    
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
        
        let frameWidth = CGRectGetWidth(self.view.frame)
        let frameHeight = CGRectGetHeight(self.view.frame)
        
        backButton.setTitle(String.localize("label.back"), forState: .Normal)
        homeScreenViews.append(backButton)
        
        if let appearance = CurrentManifest.mainExperience.appearance {
            willFadeInViews = appearance.backgroundVideoFadeTime > 0
            
            if let centerOffset = appearance.titleImageCenterOffset, sizeOffset = appearance.titleImageSizeOffset, titleImageURL = appearance.titleImageURL {
                let imageView = UIImageView(frame: CGRectMake(0, 0, frameWidth * sizeOffset.width, frameHeight * sizeOffset.height))
                imageView.center = CGPointMake(frameWidth * centerOffset.x, frameHeight * centerOffset.y)
                imageView.setImageWithURL(titleImageURL)
                imageView.hidden = true
                self.view.addSubview(imageView)
                
                homeScreenViews.append(imageView)
            }
        }
        
        // Play button
        if let appearance = CurrentManifest.inMovieExperience.appearance, centerOffset = appearance.buttonCenterOffset, sizeOffset = appearance.buttonSizeOffset {
            let button = UIButton(frame: CGRectMake(0, 0, frameWidth * sizeOffset.width, frameHeight * sizeOffset.height))
            button.center = CGPointMake(frameWidth * centerOffset.x, frameHeight * centerOffset.y)
            
            if let imageURL = appearance.buttonImageURL {
                button.setImageWithURL(imageURL)
            } else {
                button.setTitle("Play Movie", forState: .Normal)
                button.backgroundColor = UIColor.redColor()
            }
            
            button.addTarget(self, action: #selector(self.onPlay), forControlEvents: UIControlEvents.TouchUpInside)
            button.hidden = true
            self.view.addSubview(button)
            
            homeScreenViews.append(button)
        }
        
        // Extras button
        if let appearance = CurrentManifest.outOfMovieExperience.appearance, centerOffset = appearance.buttonCenterOffset, sizeOffset = appearance.buttonSizeOffset {
            let button = UIButton(frame: CGRectMake(0, 0, frameWidth * sizeOffset.width, frameHeight * sizeOffset.height))
            button.center = CGPointMake(frameWidth * centerOffset.x, frameHeight * centerOffset.y)
            
            if let imageURL = appearance.buttonImageURL {
                button.setImageWithURL(imageURL)
            } else {
                button.setTitle("Extras", forState: .Normal)
                button.backgroundColor = UIColor.grayColor()
            }
            
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
                backgroundVideoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                backgroundVideoLayer?.frame = self.view.bounds
                backgroundVideoView?.frame = self.view.bounds
                backgroundVideoView?.layer.addSublayer(backgroundVideoLayer!)
                
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
                if backgroundImageView != nil {
                    backgroundImageView.removeFromSuperview()
                }
            } else if let backgroundImageURL = appearance.backgroundImageURL {
                backgroundImageView.setImageWithURL(backgroundImageURL)
                if backgroundVideoView != nil {
                    backgroundVideoView.removeFromSuperview()
                }
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
        self.performSegueWithIdentifier(SegueIdentifier.ShowOutOfMovieExperience, sender: CurrentManifest.outOfMovieExperience)
    }
    
    @IBAction func onBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Storyboard
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? ExtrasExperienceViewController, experience = sender as? NGDMExperience {
            viewController.experience = experience
        }
    }
    
}

