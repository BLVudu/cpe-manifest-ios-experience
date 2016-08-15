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
    
    @IBOutlet weak private var exitButton: UIButton!
    @IBOutlet weak private var backgroundImageView: UIImageView?
    @IBOutlet weak private var backgroundVideoView: UIView?
    
    private var didFinishPlayingObserver: NSObjectProtocol?
    
    private var backgroundVideoFadeInViews: [UIView]?
    private var backgroundVideoTimeObserver: AnyObject?
    private var backgroundVideoPlayer: AVPlayer?
    private var interfaceCreated = false
    
    deinit {
        unloadBackground()
        
        if let observer = didFinishPlayingObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            didFinishPlayingObserver = nil
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        didFinishPlayingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let appearance = NGDMManifest.sharedInstance.mainExperience?.appearance, videoPlayer = self?.backgroundVideoPlayer {
                videoPlayer.muted = true
                videoPlayer.seekToTime(CMTimeMakeWithSeconds(appearance.backgroundVideoLoopTime, Int32(NSEC_PER_SEC)))
                videoPlayer.play()
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !interfaceCreated {
            var homeScreenViews = [UIView]()
            var willFadeInViews = false
            
            let frameWidth = CGRectGetWidth(self.view.frame)
            let frameHeight = CGRectGetHeight(self.view.frame)
            
            exitButton.setTitle(String.localize("label.exit"), forState: .Normal)
            exitButton.titleLabel?.layer.shadowColor = UIColor.blackColor().CGColor
            exitButton.titleLabel?.layer.shadowOpacity = 0.75
            exitButton.titleLabel?.layer.shadowRadius = 2
            exitButton.titleLabel?.layer.shadowOffset = CGSizeMake(0, 1)
            exitButton.titleLabel?.layer.masksToBounds = false
            exitButton.titleLabel?.layer.shouldRasterize = true
            homeScreenViews.append(exitButton)
            
            if let appearance = NGDMManifest.sharedInstance.mainExperience?.appearance {
                willFadeInViews = appearance.backgroundVideoFadeTime > 0
                
                if let centerOffset = appearance.titleImageCenterOffset, sizeOffset = appearance.titleImageSizeOffset, titleImageURL = appearance.titleImageURL {
                    let imageView = UIImageView(frame: CGRectMake(0, 0, frameWidth * sizeOffset.width, frameHeight * sizeOffset.height))
                    imageView.center = CGPointMake(frameWidth * centerOffset.x, frameHeight * centerOffset.y)
                    imageView.setImageWithURL(titleImageURL, completion: nil)
                    imageView.hidden = true
                    self.view.addSubview(imageView)
                    
                    homeScreenViews.append(imageView)
                }
            }
            
            // Play button
            if let appearance = NGDMManifest.sharedInstance.inMovieExperience?.appearance, centerOffset = appearance.buttonCenterOffset, sizeOffset = appearance.buttonSizeOffset {
                let button = UIButton(frame: CGRectMake(0, 0, frameWidth * sizeOffset.width, frameHeight * sizeOffset.height))
                button.center = CGPointMake(frameWidth * centerOffset.x, frameHeight * centerOffset.y)
                
                if let imageURL = appearance.buttonImageURL {
                    button.setImageWithURL(imageURL)
                } else {
                    button.setTitle(String.localize("label.play_movie"), forState: .Normal)
                    button.backgroundColor = UIColor.redColor()
                }
                
                button.addTarget(self, action: #selector(self.onPlay), forControlEvents: UIControlEvents.TouchUpInside)
                button.hidden = true
                self.view.addSubview(button)
                
                homeScreenViews.append(button)
            }
            
            // Extras button
            if let appearance = NGDMManifest.sharedInstance.outOfMovieExperience?.appearance, centerOffset = appearance.buttonCenterOffset, sizeOffset = appearance.buttonSizeOffset {
                let button = UIButton(frame: CGRectMake(0, 0, frameWidth * sizeOffset.width, frameHeight * sizeOffset.height))
                button.center = CGPointMake(frameWidth * centerOffset.x, frameHeight * centerOffset.y)
                
                if let imageURL = appearance.buttonImageURL {
                    button.setImageWithURL(imageURL)
                } else {
                    button.setTitle(String.localize("label.extras"), forState: .Normal)
                    button.backgroundColor = UIColor.grayColor()
                }
                
                button.addTarget(self, action: #selector(self.onExtras), forControlEvents: UIControlEvents.TouchUpInside)
                button.hidden = true
                self.view.addSubview(button)
                
                homeScreenViews.append(button)
                
                let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPressExtrasButton(_:)))
                longPressGestureRecognizer.minimumPressDuration = 5
                button.addGestureRecognizer(longPressGestureRecognizer)
            }
            
            if !willFadeInViews {
                for view in homeScreenViews {
                    view.hidden = false
                }
            } else {
                backgroundVideoFadeInViews = homeScreenViews
            }
            
            loadBackground()
            interfaceCreated = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if interfaceCreated {
            loadBackground()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        unloadBackground()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return (DeviceType.IS_IPAD ? .Landscape : .All)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        if DeviceType.IS_IPAD {
            let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
            return UIInterfaceOrientationIsLandscape(interfaceOrientation) ? interfaceOrientation : .LandscapeLeft
        }
        
        return super.preferredInterfaceOrientationForPresentation()
    }
    
    func didLongPressExtrasButton(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            NextGenHook.delegate?.nextGenExperienceWillEnterDebugMode()
        }
    }
    
    // MARK: Video Player
    func loadBackground() {
        if let appearance = NGDMManifest.sharedInstance.mainExperience?.appearance {
            if let backgroundVideoURL = appearance.backgroundVideoURL {
                let playerItem = AVPlayerItem(cacheableURL: backgroundVideoURL)
                if let videoPlayer = backgroundVideoPlayer {
                    videoPlayer.replaceCurrentItemWithPlayerItem(playerItem)
                    videoPlayer.muted = true
                    videoPlayer.seekToTime(CMTimeMakeWithSeconds(appearance.backgroundVideoLoopTime, Int32(NSEC_PER_SEC)))
                    videoPlayer.play()
                } else {
                    let videoPlayer = AVPlayer(playerItem: playerItem)
                    let backgroundVideoLayer = AVPlayerLayer(player: videoPlayer)
                    backgroundVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    backgroundVideoLayer.frame = self.view.bounds
                    backgroundVideoView?.frame = self.view.bounds
                    backgroundVideoView?.layer.addSublayer(backgroundVideoLayer)
                    
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
                    backgroundImageView?.removeFromSuperview()
                }
            } else if let backgroundImageURL = appearance.backgroundImageURL {
                backgroundImageView?.setImageWithURL(backgroundImageURL, completion: nil)
                backgroundVideoView?.removeFromSuperview()
            }
        }
    }
    
    func unloadBackground() {
        if let observer = backgroundVideoTimeObserver {
            backgroundVideoPlayer?.removeTimeObserver(observer)
        }
        
        backgroundVideoPlayer?.pause()
        backgroundVideoPlayer?.replaceCurrentItemWithPlayerItem(nil)
        backgroundImageView?.image = nil
    }
    
    // MARK: Actions
    func onPlay() {
        self.performSegueWithIdentifier(SegueIdentifier.ShowInMovieExperience, sender: nil)
    }
    
    func onExtras() {
        self.performSegueWithIdentifier(SegueIdentifier.ShowOutOfMovieExperience, sender: NGDMManifest.sharedInstance.outOfMovieExperience)
    }
    
    @IBAction func onExit() {
        NextGenHook.experienceWillClose()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Storyboard
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? ExtrasExperienceViewController, experience = sender as? NGDMExperience {
            viewController.experience = experience
        }
    }
    
}

