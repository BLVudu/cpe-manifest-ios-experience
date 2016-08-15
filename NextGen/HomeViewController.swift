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
    private var backgroundVideoLayer: AVPlayerLayer?
    private var backgroundVideoPlayer: AVPlayer?
    private var backgroundBaseSize = CGSizeZero
    
    private var mainExperience: NGDMMainExperience!
    private var buttonOverlayView: UIView!
    private var playButton: UIButton!
    private var extrasButton: UIButton!
    
    private var didFinishPlayingObserver: NSObjectProtocol?
    
    private var backgroundVideoFadeInViews: [UIView]?
    private var backgroundVideoTimeObserver: AnyObject?
    private var interfaceCreated = false
    
    private var nodeStyle: NGDMNodeStyle? {
        return mainExperience.getNodeStyle(UIApplication.sharedApplication().statusBarOrientation)
    }
    
    private var playButtonImage: NGDMImage? {
        return nodeStyle?.getButtonImage("Play")
    }
    
    private var extrasButtonImage: NGDMImage? {
        return nodeStyle?.getButtonImage("Extras")
    }
    
    private var playButtonImageURL: NSURL? {
        return playButtonImage?.url
    }
    
    private var extrasButtonImageURL: NSURL? {
        return extrasButtonImage?.url
    }
    
    private var buttonOverlaySize: CGSize {
        return nodeStyle?.buttonOverlaySize ?? CGSizeMake(CGRectGetWidth(self.view.frame), 100)
    }
    
    private var buttonOverlayBottomLeft: CGPoint {
        return nodeStyle?.buttonOverlayBottomLeft ?? CGPointMake(0, 100)
    }
    
    private var playButtonSize: CGSize {
        return playButtonImage?.size ?? CGSizeMake(250, 50)
    }
    
    private var extrasButtonSize: CGSize {
        return extrasButtonImage?.size ?? CGSizeMake(175, 35)
    }
    
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
        
        mainExperience = NGDMManifest.sharedInstance.mainExperience!
        
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
            
            buttonOverlayView = UIView()
            buttonOverlayView.hidden = true
            buttonOverlayView.userInteractionEnabled = true
            homeScreenViews.append(buttonOverlayView)
            
            // Play button
            playButton = UIButton()
            playButton.addTarget(self, action: #selector(self.onPlay), forControlEvents: UIControlEvents.TouchUpInside)
            
            if let playButtonImageURL = playButtonImageURL {
                playButton.setImageWithURL(playButtonImageURL)
            } else {
                playButton.setTitle(String.localize("label.play_movie"), forState: .Normal)
                playButton.backgroundColor = UIColor.redColor()
            }
            
            // Extras button
            extrasButton = UIButton()
            extrasButton.addTarget(self, action: #selector(self.onExtras), forControlEvents: UIControlEvents.TouchUpInside)
            
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPressExtrasButton(_:)))
            longPressGestureRecognizer.minimumPressDuration = 5
            extrasButton.addGestureRecognizer(longPressGestureRecognizer)
            
            if let extrasButtonImageURL = extrasButtonImageURL {
                extrasButton.setImageWithURL(extrasButtonImageURL)
            } else {
                extrasButton.setTitle(String.localize("label.extras"), forState: .Normal)
                extrasButton.backgroundColor = UIColor.grayColor()
            }
            
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
            
            buttonOverlayView.addSubview(playButton)
            buttonOverlayView.addSubview(extrasButton)
            self.view.addSubview(buttonOverlayView)
            
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if interfaceCreated {
            var videoToScreenRatio: CGFloat = 0
            var leftOffset: CGFloat = 0
            var topOffset: CGFloat = 0
            
            if (backgroundBaseSize.width / backgroundBaseSize.height) > (CGRectGetWidth(self.view.frame) / CGRectGetHeight(self.view.frame)) {
                videoToScreenRatio = backgroundBaseSize.height / CGRectGetHeight(self.view.frame)
                leftOffset = ((backgroundBaseSize.width / videoToScreenRatio) - CGRectGetWidth(self.view.frame)) / 2
            } else {
                videoToScreenRatio = backgroundBaseSize.width / CGRectGetWidth(self.view.frame)
                topOffset = ((backgroundBaseSize.height / videoToScreenRatio) - CGRectGetHeight(self.view.frame)) / 2
            }
            
            if videoToScreenRatio > 0 {
                buttonOverlayView.frame = CGRectMake(
                    (buttonOverlayBottomLeft.x / videoToScreenRatio) - leftOffset,
                    CGRectGetHeight(self.view.frame) - (((buttonOverlayBottomLeft.y + buttonOverlaySize.height) / videoToScreenRatio) - topOffset),
                    buttonOverlaySize.width / videoToScreenRatio,
                    buttonOverlaySize.height / videoToScreenRatio
                )
                
                playButton.frame.size = CGSizeMake(playButtonSize.width / videoToScreenRatio, playButtonSize.height / videoToScreenRatio)
                extrasButton.frame.size = CGSizeMake(extrasButtonSize.width / videoToScreenRatio, extrasButtonSize.height / videoToScreenRatio)
                
                playButton.center = CGPointMake(CGRectGetWidth(buttonOverlayView.frame) / 2, (CGRectGetHeight(playButton.frame) / 2))
                extrasButton.center = CGPointMake(CGRectGetWidth(buttonOverlayView.frame) / 2, CGRectGetHeight(buttonOverlayView.frame) - (CGRectGetHeight(extrasButton.frame) / 2))
            }
        }
        
        if let backgroundVideoView = backgroundVideoView {
            backgroundVideoView.frame = self.view.bounds
            
            if let backgroundVideoLayer = backgroundVideoLayer {
                backgroundVideoLayer.frame = backgroundVideoView.bounds
            }
        }
        
        if let backgroundImageView = backgroundImageView {
            backgroundImageView.frame = self.view.bounds
        }
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
        if let appearance = NGDMManifest.sharedInstance.mainExperience?.appearance, nodeStyle = nodeStyle {
            if let backgroundVideoURL = nodeStyle.backgroundVideoURL {
                let playerItem = AVPlayerItem(cacheableURL: backgroundVideoURL)
                if let videoPlayer = backgroundVideoPlayer {
                    videoPlayer.replaceCurrentItemWithPlayerItem(playerItem)
                    videoPlayer.muted = true
                    videoPlayer.seekToTime(CMTimeMakeWithSeconds(appearance.backgroundVideoLoopTime, Int32(NSEC_PER_SEC)))
                    videoPlayer.play()
                } else {
                    let videoPlayer = AVPlayer(playerItem: playerItem)
                    backgroundVideoLayer = AVPlayerLayer(player: videoPlayer)
                    backgroundVideoLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                    backgroundVideoLayer!.frame = self.view.bounds
                    backgroundVideoView?.frame = self.view.bounds
                    backgroundVideoView?.layer.addSublayer(backgroundVideoLayer!)
                    
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
                    
                    if let backgroundVideoSize = playerItem.asset.tracks.first?.naturalSize {
                        backgroundBaseSize = backgroundVideoSize
                    } else {
                        backgroundBaseSize = self.view.frame.size
                    }
                    
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }
            }
        } else if let backgroundImageURL = NGDMManifest.sharedInstance.outOfMovieExperience?.imageURL { // FIXME: This appears to be the way Comcast defines background images
            backgroundImageView?.setImageWithURL(backgroundImageURL, completion: nil)
            backgroundBaseSize = self.view.frame.size
            backgroundVideoView?.removeFromSuperview()
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

