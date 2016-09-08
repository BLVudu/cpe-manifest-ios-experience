//
//  HomeViewController.swift
//

import UIKit
import AVFoundation
import NextGenDataManager

class HomeViewController: UIViewController {
    
    private struct Constants {
        static let OverlayFadeInDuration = 0.5
    }
    
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
    private var titleOverlayView: UIView?
    private var titleImageView: UIImageView?
    private var homeScreenViews = [UIView]()
    private var interfaceCreated = false
    
    private var didFinishPlayingObserver: NSObjectProtocol?
    private var shouldLaunchExtrasObserver: NSObjectProtocol?
    
    private var backgroundVideoTimeObserver: AnyObject?
    private var backgroundVideoFadeTime: Double {
        if let loopTimecode = nodeStyle?.backgroundVideoLoopTimecode {
            return max(loopTimecode - Constants.OverlayFadeInDuration, 0)
        }
        
        return 0
    }
    
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
        return nodeStyle?.buttonOverlaySize ?? CGSizeMake(300, 100)
    }
    
    private var buttonOverlayBottomLeft: CGPoint {
        return nodeStyle?.buttonOverlayBottomLeft ?? CGPointMake(490, 25)
    }
    
    private var playButtonSize: CGSize {
        return playButtonImage?.size ?? CGSizeMake(300, 55)
    }
    
    private var extrasButtonSize: CGSize {
        return extrasButtonImage?.size ?? CGSizeMake(300, 60)
    }
    
    private var titleOverlaySize: CGSize {
        return CGSizeMake(300, 100)
    }
    
    private var titleOverlayBottomLeft: CGPoint {
        return CGPointMake(490, backgroundBaseSize.height - (titleOverlaySize.height + 15))
    }
    
    deinit {
        unloadBackground()
        
        if let observer = didFinishPlayingObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            didFinishPlayingObserver = nil
        }
        
        if let observer = shouldLaunchExtrasObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            shouldLaunchExtrasObserver = nil
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainExperience = NGDMManifest.sharedInstance.mainExperience!
        
        shouldLaunchExtrasObserver = NSNotificationCenter.defaultCenter().addObserverForName(Notifications.ShouldLaunchExtras, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (_) in
            self?.onExtras()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !interfaceCreated {
            homeScreenViews.removeAll()
            
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
            playButton.layer.shadowRadius = 5
            playButton.layer.shadowColor = UIColor.blackColor().CGColor
            playButton.layer.shadowOffset = CGSizeZero
            //playButton.layer.shadowOpacity = 0.5
            playButton.layer.masksToBounds = false
            
            if let playButtonImageURL = playButtonImageURL {
                playButton.af_setImageForState(.Normal, URL: playButtonImageURL)
                playButton.contentHorizontalAlignment = .Fill
                playButton.contentVerticalAlignment = .Fill
                playButton.imageView?.contentMode = .ScaleAspectFit
            } else {
                playButton.setTitle(String.localize("label.play_movie"), forState: .Normal)
                playButton.backgroundColor = UIColor.redColor()
            }
            
            // Extras button
            extrasButton = UIButton()
            extrasButton.addTarget(self, action: #selector(self.onExtras), forControlEvents: UIControlEvents.TouchUpInside)
            extrasButton.layer.shadowRadius = 5
            extrasButton.layer.shadowColor = UIColor.blackColor().CGColor
            extrasButton.layer.shadowOffset = CGSizeZero
            //extrasButton.layer.shadowOpacity = 0.5
            extrasButton.layer.masksToBounds = false
            
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPressExtrasButton(_:)))
            longPressGestureRecognizer.minimumPressDuration = 5
            extrasButton.addGestureRecognizer(longPressGestureRecognizer)
            
            if let extrasButtonImageURL = extrasButtonImageURL {
                extrasButton.af_setBackgroundImageForState(.Normal, URL: extrasButtonImageURL)
                extrasButton.contentHorizontalAlignment = .Fill
                extrasButton.contentVerticalAlignment = .Fill
                extrasButton.imageView?.contentMode = .ScaleAspectFit
            } else {
                extrasButton.setTitle(String.localize("label.extras"), forState: .Normal)
                extrasButton.backgroundColor = UIColor.grayColor()
            }
            
            buttonOverlayView.addSubview(playButton)
            buttonOverlayView.addSubview(extrasButton)
            self.view.addSubview(buttonOverlayView)
            
            // Title treatment
            if let imageURL = NGDMManifest.sharedInstance.inMovieExperience?.imageURL {
                titleOverlayView = UIView()
                titleOverlayView!.hidden = true
                titleOverlayView!.userInteractionEnabled = false
                homeScreenViews.append(titleOverlayView!)
                
                titleImageView = UIImageView()
                titleImageView!.contentMode = .ScaleAspectFit
                titleImageView!.af_setImageWithURL(imageURL)
                titleOverlayView!.addSubview(titleImageView!)
                
                self.view.addSubview(titleOverlayView!)
                homeScreenViews.append(titleOverlayView!)
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
        
        if interfaceCreated && backgroundBaseSize != CGSizeZero {
            let backgroundBaseAspectRatio = backgroundBaseSize.width / backgroundBaseSize.height
            var backgroundNewSize = CGSizeZero

            if (backgroundBaseAspectRatio > (CGRectGetWidth(self.view.frame) / CGRectGetHeight(self.view.frame))) {
                backgroundNewSize.height = CGRectGetHeight(self.view.frame)
                backgroundNewSize.width = backgroundNewSize.height * backgroundBaseAspectRatio
            } else {
                backgroundNewSize.width = CGRectGetWidth(self.view.frame)
                backgroundNewSize.height = backgroundNewSize.width / backgroundBaseAspectRatio
            }
            
            let backgroundNewScale = (backgroundNewSize.height / backgroundBaseSize.height)
            let buttonOverlayWidth = min(buttonOverlaySize.width * backgroundNewScale, CGRectGetWidth(self.view.frame) - 20)
            let buttonOverlayHeight = buttonOverlayWidth / (buttonOverlaySize.width / buttonOverlaySize.height)
            let buttonOverlayX = (buttonOverlayBottomLeft.x * backgroundNewScale) - ((backgroundNewSize.width - CGRectGetWidth(self.view.frame)) / 2)
            
            buttonOverlayView.frame = CGRectMake(
                buttonOverlayX < 0 || (buttonOverlayX + buttonOverlayWidth > CGRectGetWidth(self.view.frame)) ? 10 : buttonOverlayX,
                CGRectGetHeight(self.view.frame) - buttonOverlayBottomLeft.y * backgroundNewScale - buttonOverlayHeight,
                buttonOverlayWidth,
                buttonOverlayHeight
            )
            
            playButton.frame = CGRectMake(0, 0, CGRectGetWidth(buttonOverlayView.frame), CGRectGetWidth(buttonOverlayView.frame) / (playButtonSize.width / playButtonSize.height))
            
            let extrasButtonWidth = CGRectGetWidth(playButton.frame) * 0.6
            let extrasButtonHeight = extrasButtonWidth / (extrasButtonSize.width / extrasButtonSize.height)
            extrasButton.frame = CGRectMake((CGRectGetWidth(buttonOverlayView.frame) - extrasButtonWidth) / 2, buttonOverlayHeight - extrasButtonHeight, extrasButtonWidth, extrasButtonHeight)
            
            if let titleOverlayView = titleOverlayView {
                let titleOverlayWidth = min(titleOverlaySize.width * backgroundNewScale, CGRectGetWidth(self.view.frame) - 20)
                let titleOverlayHeight = titleOverlayWidth / (titleOverlaySize.width / titleOverlaySize.height)
                let titleOverlayX = (titleOverlayBottomLeft.x * backgroundNewScale) - ((backgroundNewSize.width - CGRectGetWidth(self.view.frame)) / 2)
                
                titleOverlayView.frame = CGRectMake(
                    titleOverlayX < 0 || (titleOverlayX + titleOverlayWidth > CGRectGetWidth(self.view.frame)) ? 10 : titleOverlayX,
                    CGRectGetHeight(self.view.frame) - titleOverlayBottomLeft.y * backgroundNewScale - titleOverlayHeight,
                    titleOverlayWidth,
                    titleOverlayHeight
                )
                
                titleImageView?.frame = titleOverlayView.bounds
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
        if let nodeStyle = nodeStyle, backgroundVideoURL = nodeStyle.backgroundVideoURL {
            if nodeStyle.backgroundVideoLoops {
                didFinishPlayingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (_) in
                    if let videoPlayer = self?.backgroundVideoPlayer {
                        videoPlayer.muted = true
                        videoPlayer.seekToTime(CMTimeMakeWithSeconds(nodeStyle.backgroundVideoLoopTimecode, Int32(NSEC_PER_SEC)))
                        videoPlayer.play()
                    }
                })
            }
            
            let playerItem = AVPlayerItem(cacheableURL: backgroundVideoURL)
            if let videoPlayer = backgroundVideoPlayer {
                videoPlayer.replaceCurrentItemWithPlayerItem(playerItem)
                videoPlayer.muted = true
                videoPlayer.seekToTime(CMTimeMakeWithSeconds(nodeStyle.backgroundVideoLoopTimecode, Int32(NSEC_PER_SEC)))
                videoPlayer.play()
            } else {
                let videoPlayer = AVPlayer(playerItem: playerItem)
                backgroundVideoLayer = AVPlayerLayer(player: videoPlayer)
                backgroundVideoLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                backgroundVideoLayer!.frame = self.view.bounds
                backgroundVideoView?.frame = self.view.bounds
                backgroundVideoView?.layer.addSublayer(backgroundVideoLayer!)
                
                if backgroundVideoFadeTime > 0 {
                    backgroundVideoTimeObserver = videoPlayer.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(0.55, Int32(NSEC_PER_SEC)), queue: dispatch_get_main_queue(), usingBlock: { [weak self] (time) in
                        if let strongSelf = self where time.seconds > strongSelf.backgroundVideoFadeTime {
                            if let observer = strongSelf.backgroundVideoTimeObserver {
                                videoPlayer.removeTimeObserver(observer)
                                strongSelf.backgroundVideoTimeObserver = nil
                            }
                            
                            for view in strongSelf.homeScreenViews {
                                view.alpha = 0
                                view.hidden = false
                            }
                            
                            UIView.animateWithDuration(Constants.OverlayFadeInDuration, animations: {
                                for view in strongSelf.homeScreenViews {
                                    view.alpha = 1
                                }
                            })
                            
                            strongSelf.homeScreenViews.removeAll()
                        }
                    })
                } else {
                    for view in homeScreenViews {
                        view.hidden = false
                    }
                    
                    homeScreenViews.removeAll()
                }
                
                if interfaceCreated {
                    videoPlayer.muted = true
                    videoPlayer.seekToTime(CMTimeMakeWithSeconds(nodeStyle.backgroundVideoLoopTimecode, Int32(NSEC_PER_SEC)))
                }
                
                videoPlayer.play()
                
                backgroundVideoPlayer = videoPlayer
                backgroundImageView?.removeFromSuperview()
                
                if let backgroundVideoSize = playerItem.asset.tracksWithMediaType(AVMediaTypeVideo).first?.naturalSize where backgroundVideoSize != CGSizeZero {
                    backgroundBaseSize = backgroundVideoSize
                } else {
                    backgroundBaseSize = self.view.frame.size
                }
                
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        } else {
            if let backgroundImageURL = nodeStyle?.backgroundImageURL ?? NGDMManifest.sharedInstance.outOfMovieExperience?.imageURL { // FIXME: This appears to be the way Comcast defines background images
                backgroundImageView?.af_setImageWithURL(backgroundImageURL, placeholderImage: nil, filter: nil, progress: nil, progressQueue: dispatch_get_main_queue(), imageTransition: .None, runImageTransitionIfCached: false, completion: { [weak self] (response) in
                    if let strongSelf = self, image = response.result.value {
                        strongSelf.backgroundBaseSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale)
                    }
                })
                
                backgroundVideoView?.removeFromSuperview()
            }
            
            for view in homeScreenViews {
                view.hidden = false
            }
            
            homeScreenViews.removeAll()
        }
    }
    
    func unloadBackground() {
        if let observer = backgroundVideoTimeObserver {
            backgroundVideoPlayer?.removeTimeObserver(observer)
            backgroundVideoTimeObserver = nil
        }
        
        if let observer = didFinishPlayingObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            didFinishPlayingObserver = nil
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

