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
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak private var backgroundVideoView: UIView!
    private var backgroundVideoPlayerViewController: VideoPlayerViewController?
    
    private var mainExperience: NGDMMainExperience!
    private var buttonOverlayView: UIView!
    private var playButton: UIButton!
    private var extrasButton: UIButton!
    private var titleOverlayView: UIView?
    private var titleImageView: UIImageView?
    private var homeScreenViews = [UIView]()
    private var interfaceCreated = false
    private var currentlyDismissing = false
    
    private var shouldLaunchExtrasObserver: NSObjectProtocol?
    
    private var backgroundAudioPlayer: AVPlayer?
    
    private var backgroundVideoLastTimecode = 0.0
    private var backgroundVideoPreviewImageView: UIImageView?
    private var backgroundVideoDidFinishPlayingObserver: NSObjectProtocol?
    private var backgroundVideoTimeObserver: NSObjectProtocol?
    private var backgroundVideoFadeTime: Double {
        if let loopTimecode = nodeStyle?.backgroundVideoLoopTimecode {
            return max(loopTimecode - Constants.OverlayFadeInDuration, 0)
        }
        
        return 0
    }
    
    private var nodeStyle: NGDMNodeStyle? {
        return mainExperience.getNodeStyle(UIApplication.shared.statusBarOrientation)
    }
    
    private var backgroundImage: NGDMImage? {
        return nodeStyle?.backgroundImage
    }
    
    private var observedBackgroundImageSize: CGSize?
    private var backgroundImageSize: CGSize {
        return backgroundImage?.size ?? observedBackgroundImageSize ?? CGSize.zero
    }
    
    private var backgroundVideo: NGDMVideo? {
        return nodeStyle?.backgroundVideo
    }
    
    private var backgroundVideoSize: CGSize {
        return backgroundVideo?.size ?? CGSize.zero
    }
    
    private var playButtonImage: NGDMImage? {
        return nodeStyle?.getButtonImage("Play")
    }
    
    private var extrasButtonImage: NGDMImage? {
        return nodeStyle?.getButtonImage("Extras")
    }
    
    private var buttonOverlaySize: CGSize {
        return nodeStyle?.buttonOverlaySize ?? CGSize(width: 300, height: 100)
    }
    
    private var buttonOverlayBottomLeft: CGPoint {
        return nodeStyle?.buttonOverlayBottomLeft ?? CGPoint(x: 490, y: 25)
    }
    
    private var playButtonSize: CGSize {
        return playButtonImage?.size ?? CGSize(width: 300, height: 55)
    }
    
    private var extrasButtonSize: CGSize {
        return extrasButtonImage?.size ?? CGSize(width: 300, height: 60)
    }
    
    private var titleOverlaySize: CGSize {
        return CGSize(width: 400, height: 133)
    }
    
    private var titleOverlayBottomLeft: CGPoint {
        return CGPoint(x: 440, y: backgroundImageSize.height - (titleOverlaySize.height + 15))
    }
    
    deinit {
        unloadBackground()
        
        if let observer = shouldLaunchExtrasObserver {
            NotificationCenter.default.removeObserver(observer)
            shouldLaunchExtrasObserver = nil
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainExperience = NGDMManifest.sharedInstance.mainExperience!
        
        shouldLaunchExtrasObserver = NotificationCenter.default.addObserver(forName: .outOfMovieExperienceShouldLaunch, object: nil, queue: OperationQueue.main, using: { [weak self] (_) in
            self?.onExtras()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !interfaceCreated {
            homeScreenViews.removeAll()
            
            exitButton.setTitle(String.localize("label.exit"), for: UIControlState())
            exitButton.titleLabel?.layer.shadowColor = UIColor.black.cgColor
            exitButton.titleLabel?.layer.shadowOpacity = 0.75
            exitButton.titleLabel?.layer.shadowRadius = 2
            exitButton.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 1)
            exitButton.titleLabel?.layer.masksToBounds = false
            exitButton.titleLabel?.layer.shouldRasterize = true
            homeScreenViews.append(exitButton)
            
            buttonOverlayView = UIView()
            buttonOverlayView.isHidden = true
            buttonOverlayView.isUserInteractionEnabled = true
            homeScreenViews.append(buttonOverlayView)
            
            // Play button
            playButton = UIButton()
            playButton.addTarget(self, action: #selector(self.onPlay), for: UIControlEvents.touchUpInside)
            playButton.layer.shadowRadius = 5
            playButton.layer.shadowColor = UIColor.black.cgColor
            playButton.layer.shadowOffset = CGSize.zero
            playButton.layer.masksToBounds = false
            
            if let playButtonImageURL = playButtonImage?.url {
                playButton.sd_setImage(with: playButtonImageURL, for: .normal)
                playButton.contentHorizontalAlignment = .fill
                playButton.contentVerticalAlignment = .fill
                playButton.imageView?.contentMode = .scaleAspectFit
            } else {
                playButton.setTitle(String.localize("label.play_movie"), for: UIControlState())
                playButton.titleLabel?.font = UIFont.themeCondensedBoldFont(15)
                playButton.backgroundColor = UIColor.red
            }
            
            // Extras button
            extrasButton = UIButton()
            extrasButton.addTarget(self, action: #selector(self.onExtras), for: UIControlEvents.touchUpInside)
            extrasButton.layer.shadowRadius = 5
            extrasButton.layer.shadowColor = UIColor.black.cgColor
            extrasButton.layer.shadowOffset = CGSize.zero
            extrasButton.layer.masksToBounds = false
            
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPressExtrasButton(_:)))
            longPressGestureRecognizer.minimumPressDuration = 5
            extrasButton.addGestureRecognizer(longPressGestureRecognizer)
            
            if let extrasButtonImageURL = extrasButtonImage?.url {
                extrasButton.sd_setImage(with: extrasButtonImageURL, for: .normal)
                extrasButton.contentHorizontalAlignment = .fill
                extrasButton.contentVerticalAlignment = .fill
                extrasButton.imageView?.contentMode = .scaleAspectFit
            } else {
                extrasButton.setTitle(String.localize("label.extras"), for: UIControlState())
                extrasButton.titleLabel?.font = UIFont.themeCondensedBoldFont(15)
                extrasButton.backgroundColor = UIColor.gray
            }
            
            buttonOverlayView.addSubview(playButton)
            buttonOverlayView.addSubview(extrasButton)
            self.view.addSubview(buttonOverlayView)
            
            // Title treatment
            if nodeStyle == nil, let imageURL = NGDMManifest.sharedInstance.inMovieExperience?.imageURL {
                titleOverlayView = UIView()
                titleOverlayView!.isHidden = true
                titleOverlayView!.isUserInteractionEnabled = false
                homeScreenViews.append(titleOverlayView!)
                
                titleImageView = UIImageView()
                titleImageView!.contentMode = .scaleAspectFit
                titleImageView!.sd_setImage(with: imageURL)
                titleOverlayView!.addSubview(titleImageView!)
                
                self.view.addSubview(titleOverlayView!)
                homeScreenViews.append(titleOverlayView!)
            }
            
            loadBackground()
            interfaceCreated = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentlyDismissing = false
        
        if interfaceCreated {
            loadBackground()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        currentlyDismissing = true
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        backgroundVideoPreviewImageView?.removeFromSuperview()
        backgroundVideoPreviewImageView = nil
        backgroundVideoLastTimecode = 0
        
        if let image = backgroundVideoPlayerViewController?.getScreenGrab() {
            backgroundVideoLastTimecode = backgroundVideoPlayerViewController!.playerItem.currentTime().seconds
            backgroundVideoPreviewImageView = UIImageView(frame: backgroundVideoView.frame)
            backgroundVideoPreviewImageView!.contentMode = .scaleAspectFill
            backgroundVideoPreviewImageView!.image = image
            self.view.addSubview(backgroundVideoPreviewImageView!)
            self.view.bringSubview(toFront: exitButton)
            self.view.bringSubview(toFront: buttonOverlayView)
            if let titleOverlayView = titleOverlayView {
                self.view.bringSubview(toFront: titleOverlayView)
            }
        }
    
        unloadBackground()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if self.view.window != nil && !currentlyDismissing {
            coordinator.animate(alongsideTransition: { [weak self] (_) in
                if let strongSelf = self, strongSelf.interfaceCreated {
                    if let currentUrl = strongSelf.backgroundVideoPlayerViewController?.url, let newUrl = strongSelf.backgroundVideo?.url, currentUrl != newUrl {
                        strongSelf.unloadBackground()
                        strongSelf.loadBackground()
                    } else {
                        strongSelf.seekBackgroundVideoToLoopTimecode()
                    }
                }
            }, completion: nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if interfaceCreated && !currentlyDismissing && (backgroundVideoSize != CGSize.zero || backgroundImageSize != CGSize.zero) {
            let viewWidth = self.view.frame.width
            let viewHeight = self.view.frame.height
            let viewAspectRatio = viewWidth / viewHeight
            
            if backgroundVideoSize != CGSize.zero {
                var backgroundPoint = CGPoint.zero
                var backgroundSize = CGSize.zero
                let backgroundVideoAspectRatio = backgroundVideoSize.width / backgroundVideoSize.height
                
                if nodeStyle?.backgroundScaleMethod == .Full {
                    if (backgroundVideoAspectRatio > viewAspectRatio) {
                        backgroundSize.width = viewWidth
                        backgroundSize.height = backgroundSize.width / backgroundVideoAspectRatio
                        
                        if nodeStyle?.backgroundPositionMethod == .Centered {
                            backgroundPoint.y = (viewHeight - backgroundSize.height) / 2
                        }
                    } else {
                        backgroundSize.height = viewHeight
                        backgroundSize.width = backgroundSize.height * backgroundVideoAspectRatio
                        
                        if nodeStyle?.backgroundPositionMethod == .Centered {
                            backgroundPoint.x = (viewWidth - backgroundSize.width) / 2
                        }
                    }
                } else {
                    if (backgroundVideoAspectRatio > viewAspectRatio) {
                        backgroundSize.height = viewHeight
                        backgroundSize.width = backgroundSize.height * backgroundVideoAspectRatio
                    } else {
                        backgroundSize.width = viewWidth
                        backgroundSize.height = backgroundSize.width / backgroundVideoAspectRatio
                    }
                    
                    if nodeStyle?.backgroundPositionMethod == .Centered {
                        backgroundPoint.x = (backgroundSize.width - viewWidth) / -2
                        backgroundPoint.y = (backgroundSize.height - viewHeight) / -2
                    }
                }
                
                backgroundVideoView.frame = CGRect(x: backgroundPoint.x, y: backgroundPoint.y, width: backgroundSize.width, height: backgroundSize.height)
            }
            
            if backgroundImageSize != CGSize.zero {
                var backgroundPoint = CGPoint.zero
                var backgroundSize = CGSize.zero
                let backgroundImageAspectRatio = backgroundImageSize.width / backgroundImageSize.height
                
                if nodeStyle?.backgroundScaleMethod == .Full && backgroundVideo == nil {
                    if (backgroundImageAspectRatio > viewAspectRatio) {
                        backgroundSize.width = viewWidth
                        backgroundSize.height = backgroundSize.width / backgroundImageAspectRatio
                        
                        if nodeStyle?.backgroundPositionMethod == .Centered {
                            backgroundPoint.y = (viewHeight - backgroundSize.height) / 2
                        }
                    } else {
                        backgroundSize.height = viewHeight
                        backgroundSize.width = backgroundSize.height * backgroundImageAspectRatio
                        
                        if nodeStyle?.backgroundPositionMethod == .Centered {
                            backgroundPoint.x = (viewWidth - backgroundSize.width) / 2
                        }
                    }
                } else {
                    if (backgroundImageAspectRatio > viewAspectRatio) {
                        backgroundSize.height = viewHeight
                        backgroundSize.width = backgroundSize.height * backgroundImageAspectRatio
                    } else {
                        backgroundSize.width = viewWidth
                        backgroundSize.height = backgroundSize.width / backgroundImageAspectRatio
                    }
                    
                    if nodeStyle == nil || backgroundVideo != nil || nodeStyle?.backgroundPositionMethod == .Centered {
                        backgroundPoint.x = (backgroundSize.width - viewWidth) / -2
                        backgroundPoint.y = (backgroundSize.height - viewHeight) / -2
                    }
                }
                
                backgroundImageView.frame = CGRect(x: backgroundPoint.x, y: backgroundPoint.y, width: backgroundSize.width, height: backgroundSize.height)
            }
            
            var backgroundBaseSize = CGSize.zero
            var backgroundNewSize = CGSize.zero
            var backgroundPoint = CGPoint.zero
            
            if backgroundImageSize != CGSize.zero {
                backgroundBaseSize = backgroundImageSize
                backgroundNewSize = backgroundImageView.frame.size
                backgroundPoint = backgroundImageView.frame.origin
            } else if backgroundVideoSize != CGSize.zero {
                backgroundBaseSize = backgroundVideoSize
                backgroundNewSize = backgroundVideoView.frame.size
                backgroundPoint = backgroundVideoView.frame.origin
            }
            
            if backgroundBaseSize != CGSize.zero {
                let backgroundNewScale = (backgroundNewSize.height / backgroundBaseSize.height)
                let buttonOverlayWidth = min(buttonOverlaySize.width * backgroundNewScale, viewWidth - 20)
                let buttonOverlayHeight = buttonOverlayWidth / (buttonOverlaySize.width / buttonOverlaySize.height)
                let buttonOverlayX = (buttonOverlayBottomLeft.x * backgroundNewScale) - ((backgroundNewSize.width - viewWidth) / 2)
                
                buttonOverlayView.frame = CGRect(
                    x: buttonOverlayX < 0 || (buttonOverlayX + buttonOverlayWidth > viewWidth) ? 10 : buttonOverlayX,
                    y: backgroundNewSize.height - (buttonOverlayBottomLeft.y * backgroundNewScale) - buttonOverlayHeight + backgroundPoint.y,
                    width: buttonOverlayWidth,
                    height: buttonOverlayHeight
                )
                
                playButton.frame = CGRect(x: 0, y: 0, width: buttonOverlayView.frame.width, height: buttonOverlayView.frame.width / (playButtonSize.width / playButtonSize.height))
                
                let extrasButtonWidth = playButton.frame.width * 0.675
                let extrasButtonHeight = extrasButtonWidth / (extrasButtonSize.width / extrasButtonSize.height)
                extrasButton.frame = CGRect(x: (buttonOverlayView.frame.width - extrasButtonWidth) / 2, y: buttonOverlayHeight - extrasButtonHeight, width: extrasButtonWidth, height: extrasButtonHeight)
                
                if let titleOverlayView = titleOverlayView {
                    let titleOverlayWidth = min(titleOverlaySize.width * backgroundNewScale, viewWidth * 0.9)
                    let titleOverlayHeight = titleOverlayWidth / (titleOverlaySize.width / titleOverlaySize.height)
                    let titleOverlayX = (titleOverlayBottomLeft.x * backgroundNewScale) - ((backgroundNewSize.width - viewWidth) / 2)
                    
                    titleOverlayView.frame = CGRect(
                        x: titleOverlayX < 0 || (titleOverlayX + titleOverlaySize.width > viewWidth) ? (viewWidth - titleOverlayWidth) / 2 : titleOverlayX,
                        y: viewHeight - titleOverlayBottomLeft.y * backgroundNewScale - titleOverlayHeight,
                        width: titleOverlayWidth,
                        height: titleOverlayHeight
                    )
                    
                    titleImageView?.frame = titleOverlayView.bounds
                }
            }
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return (DeviceType.IS_IPAD ? .landscape : .all)
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        if DeviceType.IS_IPAD {
            let interfaceOrientation = UIApplication.shared.statusBarOrientation
            return UIInterfaceOrientationIsLandscape(interfaceOrientation) ? interfaceOrientation : .landscapeLeft
        }
        
        return super.preferredInterfaceOrientationForPresentation
    }
    
    func didLongPressExtrasButton(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            NextGenHook.delegate?.experienceWillEnterDebugMode()
        }
    }
    
    // MARK: Helpers
    private func showHomeScreenViews(animated: Bool) {
        if animated {
            homeScreenViews.forEach {
                $0.alpha = 0
                $0.isHidden = false
            }
            
            UIView.animate(withDuration: Constants.OverlayFadeInDuration, animations: {
                self.homeScreenViews.forEach { $0.alpha = 1 }
            }, completion: { (_) in
                self.homeScreenViews.removeAll()
            })
        } else {
            homeScreenViews.forEach { $0.isHidden = false }
            homeScreenViews.removeAll()
        }
    }
    
    private func seekBackgroundVideoToLoopTimecode() {
        if let nodeStyle = nodeStyle, nodeStyle.backgroundVideoLoops, let videoPlayerViewController = backgroundVideoPlayerViewController {
            videoPlayerViewController.seekPlayer(to: CMTimeMakeWithSeconds(nodeStyle.backgroundVideoLoopTimecode, Int32(NSEC_PER_SEC)))
            videoPlayerViewController.player?.isMuted = true
        }
    }
    
    // MARK: Video Player
    func loadBackground() {
        if let nodeStyle = nodeStyle, let backgroundVideoURL = backgroundVideo?.url, let videoPlayerViewController = UIStoryboard.getNextGenViewController(VideoPlayerViewController.self) as? VideoPlayerViewController {
            videoPlayerViewController.mode = .basicPlayer
            
            videoPlayerViewController.view.frame = backgroundVideoView.bounds
            backgroundVideoView.addSubview(videoPlayerViewController.view)
            self.addChildViewController(videoPlayerViewController)
            videoPlayerViewController.didMove(toParentViewController: self)
            
            backgroundVideoTimeObserver = NotificationCenter.default.addObserver(forName: .videoPlayerDidChangeTime, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
                if let strongSelf = self, let time = notification.userInfo?[NotificationConstants.time] as? Double {
                    if time > strongSelf.backgroundVideoLastTimecode {
                        strongSelf.backgroundVideoPreviewImageView?.removeFromSuperview()
                        strongSelf.backgroundVideoPreviewImageView = nil
                        strongSelf.backgroundVideoLastTimecode = 0
                    }
                    
                    if strongSelf.backgroundVideoFadeTime > 0 {
                        if strongSelf.homeScreenViews.count > 0 && time > strongSelf.backgroundVideoFadeTime {
                            strongSelf.showHomeScreenViews(animated: true)
                        }
                    } else {
                        strongSelf.showHomeScreenViews(animated: false)
                    }
                }
            })
            
            if nodeStyle.backgroundVideoLoops {
                backgroundVideoDidFinishPlayingObserver = NotificationCenter.default.addObserver(forName: .videoPlayerDidEndVideo, object: nil, queue: OperationQueue.main, using: { [weak self] (_) in
                    self?.seekBackgroundVideoToLoopTimecode()
                })
            }
            
            videoPlayerViewController.shouldMute = interfaceCreated
            videoPlayerViewController.shouldTrackOutput = true
            videoPlayerViewController.playVideo(with: backgroundVideoURL, startTime: backgroundVideoLastTimecode)
            backgroundVideoPlayerViewController = videoPlayerViewController
        } else {
            showHomeScreenViews(animated: false)
        }
        
        if let backgroundImageURL = backgroundImage?.url {
            backgroundImageView.sd_setImage(with: backgroundImageURL)
        } else if backgroundVideo == nil {
            if let backgroundImageURL = NGDMManifest.sharedInstance.outOfMovieExperience?.imageURL {
                backgroundImageView.sd_setImage(with: backgroundImageURL, completed: { [weak self] (image, _, _, _) in
                    if let image = image {
                        self?.observedBackgroundImageSize = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
                        self?.view.setNeedsLayout()
                    }
                })
            } else {
                observedBackgroundImageSize = CGSize(width: 1280, height: 720)
            }
        }
        
        if !interfaceCreated, let backgroundAudioUrl = nodeStyle?.backgroundAudio?.url {
            let audioPlayerItem = AVPlayerItem(asset: AVAsset(url: backgroundAudioUrl))
            backgroundAudioPlayer = AVPlayer(playerItem: audioPlayerItem)
            backgroundAudioPlayer?.play()
        }
    }
    
    func unloadBackground() {
        if let observer = backgroundVideoTimeObserver {
            NotificationCenter.default.removeObserver(observer)
            backgroundVideoTimeObserver = nil
        }
        
        if let observer = backgroundVideoDidFinishPlayingObserver {
            NotificationCenter.default.removeObserver(observer)
            backgroundVideoDidFinishPlayingObserver = nil
        }
        
        backgroundVideoPlayerViewController?.willMove(toParentViewController: nil)
        backgroundVideoPlayerViewController?.view.removeFromSuperview()
        backgroundVideoPlayerViewController?.removeFromParentViewController()
        backgroundVideoPlayerViewController = nil
        backgroundImageView.image = nil
        backgroundAudioPlayer = nil
    }
    
    // MARK: Actions
    func onPlay() {
        self.performSegue(withIdentifier: SegueIdentifier.ShowInMovieExperience, sender: nil)
        NextGenHook.logAnalyticsEvent(.homeAction, action: .launchInMovie)
    }
    
    func onExtras() {
        self.performSegue(withIdentifier: SegueIdentifier.ShowOutOfMovieExperience, sender: NGDMManifest.sharedInstance.outOfMovieExperience)
        NextGenHook.logAnalyticsEvent(.homeAction, action: .launchExtras)
    }
    
    @IBAction func onExit() {
        NextGenHook.logAnalyticsEvent(.homeAction, action: .exit)
        NextGenLauncher.sharedInstance?.closeExperience()
    }
    
    // MARK: Storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ExtrasExperienceViewController, let experience = sender as? NGDMExperience {
            viewController.experience = experience
        }
    }
    
}
