//
//  HomeViewController.swift
//

import UIKit
import AVFoundation
import NextGenDataManager

class HomeViewController: UIViewController {
    
    fileprivate struct Constants {
        static let OverlayFadeInDuration = 0.5
    }
    
    fileprivate struct SegueIdentifier {
        static let ShowInMovieExperience = "ShowInMovieExperienceSegueIdentifier"
        static let ShowOutOfMovieExperience = "ShowOutOfMovieExperienceSegueIdentifier"
    }
    
    @IBOutlet weak fileprivate var exitButton: UIButton!
    @IBOutlet weak fileprivate var backgroundImageView: UIImageView!
    @IBOutlet weak fileprivate var backgroundVideoView: UIView!
    fileprivate var backgroundVideoLayer: AVPlayerLayer?
    fileprivate var backgroundVideoPlayer: AVPlayer?
    fileprivate var backgroundVideoSize = CGSize.zero
    fileprivate var backgroundImageSize = CGSize.zero
    
    fileprivate var mainExperience: NGDMMainExperience!
    fileprivate var buttonOverlayView: UIView!
    fileprivate var playButton: UIButton!
    fileprivate var extrasButton: UIButton!
    fileprivate var titleOverlayView: UIView?
    fileprivate var titleImageView: UIImageView?
    fileprivate var homeScreenViews = [UIView]()
    fileprivate var interfaceCreated = false
    fileprivate var currentlyDismissing = false
    
    fileprivate var didFinishPlayingObserver: NSObjectProtocol?
    fileprivate var shouldLaunchExtrasObserver: NSObjectProtocol?
    
    fileprivate var backgroundVideoTimeObserver: Any?
    fileprivate var backgroundVideoFadeTime: Double {
        if let loopTimecode = nodeStyle?.backgroundVideoLoopTimecode {
            return max(loopTimecode - Constants.OverlayFadeInDuration, 0)
        }
        
        return 0
    }
    
    fileprivate var nodeStyle: NGDMNodeStyle? {
        return mainExperience.getNodeStyle(UIApplication.shared.statusBarOrientation)
    }
    
    fileprivate var playButtonImage: NGDMImage? {
        return nodeStyle?.getButtonImage("Play")
    }
    
    fileprivate var extrasButtonImage: NGDMImage? {
        return nodeStyle?.getButtonImage("Extras")
    }
    
    fileprivate var playButtonImageURL: URL? {
        return playButtonImage?.url
    }
    
    fileprivate var extrasButtonImageURL: URL? {
        return extrasButtonImage?.url
    }
    
    fileprivate var buttonOverlaySize: CGSize {
        return nodeStyle?.buttonOverlaySize ?? CGSize(width: 300, height: 100)
    }
    
    fileprivate var buttonOverlayBottomLeft: CGPoint {
        return nodeStyle?.buttonOverlayBottomLeft ?? CGPoint(x: 490, y: 25)
    }
    
    fileprivate var playButtonSize: CGSize {
        return playButtonImage?.size ?? CGSize(width: 300, height: 55)
    }
    
    fileprivate var extrasButtonSize: CGSize {
        return extrasButtonImage?.size ?? CGSize(width: 300, height: 60)
    }
    
    fileprivate var titleOverlaySize: CGSize {
        return CGSize(width: 300, height: 100)
    }
    
    fileprivate var titleOverlayBottomLeft: CGPoint {
        return CGPoint.zero
        //return CGPointMake(490, backgroundBaseSize.height - (titleOverlaySize.height + 15))
    }
    
    deinit {
        unloadBackground()
        
        if let observer = didFinishPlayingObserver {
            NotificationCenter.default.removeObserver(observer)
            didFinishPlayingObserver = nil
        }
        
        if let observer = shouldLaunchExtrasObserver {
            NotificationCenter.default.removeObserver(observer)
            shouldLaunchExtrasObserver = nil
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainExperience = NGDMManifest.sharedInstance.mainExperience!
        
        shouldLaunchExtrasObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Notifications.ShouldLaunchExtras), object: nil, queue: OperationQueue.main, using: { [weak self] (_) in
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
            
            if let playButtonImageURL = playButtonImageURL {
                playButton.af_setImage(for: .normal, url: playButtonImageURL)
                playButton.contentHorizontalAlignment = .fill
                playButton.contentVerticalAlignment = .fill
                playButton.imageView?.contentMode = .scaleAspectFit
            } else {
                playButton.setTitle(String.localize("label.play_movie"), for: UIControlState())
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
            
            if let extrasButtonImageURL = extrasButtonImageURL {
                extrasButton.af_setBackgroundImage(for: .normal, url: extrasButtonImageURL)
                extrasButton.contentHorizontalAlignment = .fill
                extrasButton.contentVerticalAlignment = .fill
                extrasButton.imageView?.contentMode = .scaleAspectFit
            } else {
                extrasButton.setTitle(String.localize("label.extras"), for: UIControlState())
                extrasButton.backgroundColor = UIColor.gray
            }
            
            buttonOverlayView.addSubview(playButton)
            buttonOverlayView.addSubview(extrasButton)
            self.view.addSubview(buttonOverlayView)
            
            // Title treatment
            if let imageURL = NGDMManifest.sharedInstance.inMovieExperience?.imageURL {
                titleOverlayView = UIView()
                titleOverlayView!.isHidden = true
                titleOverlayView!.isUserInteractionEnabled = false
                homeScreenViews.append(titleOverlayView!)
                
                titleImageView = UIImageView()
                titleImageView!.contentMode = .scaleAspectFit
                titleImageView!.af_setImage(withURL: imageURL)
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
        
        if interfaceCreated {
            loadBackground()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentlyDismissing = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unloadBackground()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (_) in
            if self.interfaceCreated {
                self.unloadBackground()
                self.loadBackground()
            }
        }, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if interfaceCreated && !currentlyDismissing {
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
                
                if let backgroundVideoLayer = backgroundVideoLayer {
                    backgroundVideoLayer.frame = backgroundVideoView.frame
                }
            }
            
            if backgroundImageSize != CGSize.zero {
                var backgroundPoint = CGPoint.zero
                var backgroundSize = CGSize.zero
                let backgroundImageAspectRatio = backgroundImageSize.width / backgroundImageSize.height
                
                if nodeStyle?.backgroundScaleMethod == .Full && backgroundVideoSize == CGSize.zero {
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
                    
                    if nodeStyle?.backgroundPositionMethod == .Centered || backgroundVideoSize != CGSize.zero {
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
                    y: viewHeight - (buttonOverlayBottomLeft.y * backgroundNewScale) - buttonOverlayHeight - backgroundPoint.y,
                    width: buttonOverlayWidth,
                    height: buttonOverlayHeight
                )
                
                playButton.frame = CGRect(x: 0, y: 0, width: buttonOverlayView.frame.width, height: buttonOverlayView.frame.width / (playButtonSize.width / playButtonSize.height))
                
                let extrasButtonWidth = playButton.frame.width * 0.6
                let extrasButtonHeight = extrasButtonWidth / (extrasButtonSize.width / extrasButtonSize.height)
                extrasButton.frame = CGRect(x: (buttonOverlayView.frame.width - extrasButtonWidth) / 2, y: buttonOverlayHeight - extrasButtonHeight, width: extrasButtonWidth, height: extrasButtonHeight)
                
                if let titleOverlayView = titleOverlayView {
                    let titleOverlayWidth = min(titleOverlaySize.width * backgroundNewScale, viewWidth - 20)
                    let titleOverlayHeight = titleOverlayWidth / (titleOverlaySize.width / titleOverlaySize.height)
                    let titleOverlayX = (titleOverlayBottomLeft.x * backgroundNewScale) - ((backgroundNewSize.width - viewWidth) / 2)
                    
                    titleOverlayView.frame = CGRect(
                        x: titleOverlayX < 0 || (titleOverlayX + titleOverlayWidth > viewWidth) ? 10 : titleOverlayX,
                        y: viewHeight - titleOverlayBottomLeft.y * backgroundNewScale - titleOverlayHeight,
                        width: titleOverlayWidth,
                        height: titleOverlayHeight
                    )
                    
                    titleImageView?.frame = titleOverlayView.bounds
                }
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
            NextGenHook.delegate?.nextGenExperienceWillEnterDebugMode()
        }
    }
    
    // MARK: Video Player
    func loadBackground() {
        if let nodeStyle = nodeStyle, let backgroundVideoURL = nodeStyle.backgroundVideoURL {
            if nodeStyle.backgroundVideoLoops {
                didFinishPlayingObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: OperationQueue.main, using: { [weak self] (_) in
                    if let videoPlayer = self?.backgroundVideoPlayer {
                        videoPlayer.isMuted = true
                        videoPlayer.seek(to: CMTimeMakeWithSeconds(nodeStyle.backgroundVideoLoopTimecode, Int32(NSEC_PER_SEC)))
                        videoPlayer.play()
                    }
                })
            }
            
            let playerItem = AVPlayerItem(cacheableURL: backgroundVideoURL)
            if let videoPlayer = backgroundVideoPlayer {
                videoPlayer.replaceCurrentItem(with: playerItem)
                videoPlayer.isMuted = true
                videoPlayer.seek(to: CMTimeMakeWithSeconds(nodeStyle.backgroundVideoLoopTimecode, Int32(NSEC_PER_SEC)))
                videoPlayer.play()

                for view in homeScreenViews {
                    view.isHidden = false
                }
                
                homeScreenViews.removeAll()
            } else {
                let videoPlayer = AVPlayer(playerItem: playerItem)
                backgroundVideoLayer = AVPlayerLayer(player: videoPlayer)
                backgroundVideoLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                backgroundVideoLayer!.frame = self.view.bounds
                backgroundVideoView?.frame = self.view.bounds
                backgroundVideoView?.layer.addSublayer(backgroundVideoLayer!)
                
                if backgroundVideoFadeTime > 0 {
                    backgroundVideoTimeObserver = videoPlayer.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.55, Int32(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [weak self] (time) in
                        if let strongSelf = self , time.seconds > strongSelf.backgroundVideoFadeTime {
                            if let observer = strongSelf.backgroundVideoTimeObserver {
                                videoPlayer.removeTimeObserver(observer)
                                strongSelf.backgroundVideoTimeObserver = nil
                            }
                            
                            for view in strongSelf.homeScreenViews {
                                view.alpha = 0
                                view.isHidden = false
                            }
                            
                            UIView.animate(withDuration: Constants.OverlayFadeInDuration, animations: {
                                for view in strongSelf.homeScreenViews {
                                    view.alpha = 1
                                }
                            })
                            
                            strongSelf.homeScreenViews.removeAll()
                        }
                    })
                } else {
                    for view in homeScreenViews {
                        view.isHidden = false
                    }
                    
                    homeScreenViews.removeAll()
                }
                
                if interfaceCreated {
                    videoPlayer.isMuted = true
                    videoPlayer.seek(to: CMTimeMakeWithSeconds(nodeStyle.backgroundVideoLoopTimecode, Int32(NSEC_PER_SEC)))
                }
                
                videoPlayer.play()
                
                backgroundVideoPlayer = videoPlayer
            }
            
            if let backgroundVideoSize = playerItem.asset.tracks(withMediaType: AVMediaTypeVideo).first?.naturalSize , backgroundVideoSize != CGSize.zero {
                self.backgroundVideoSize = backgroundVideoSize
            } else {
                backgroundVideoSize = self.view.frame.size
            }
        } else {
            for view in homeScreenViews {
                view.isHidden = false
            }
            
            homeScreenViews.removeAll()
        }

        if let backgroundImageURL = nodeStyle?.backgroundImageURL {
            backgroundImageView.af_setImage(withURL: backgroundImageURL, completion: { [weak self] (response) in
                if let strongSelf = self, let image = response.result.value {
                    strongSelf.backgroundImageSize = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
                }
            })
        }
    }
    
    func unloadBackground() {
        if let observer = backgroundVideoTimeObserver {
            backgroundVideoPlayer?.removeTimeObserver(observer)
            backgroundVideoTimeObserver = nil
        }
        
        if let observer = didFinishPlayingObserver {
            NotificationCenter.default.removeObserver(observer)
            didFinishPlayingObserver = nil
        }
        
        backgroundVideoPlayer?.pause()
        backgroundVideoPlayer?.replaceCurrentItem(with: nil)
        backgroundImageView.image = nil
        backgroundVideoSize = CGSize.zero
        backgroundImageSize = CGSize.zero
    }
    
    // MARK: Actions
    func onPlay() {
        self.performSegue(withIdentifier: SegueIdentifier.ShowInMovieExperience, sender: nil)
    }
    
    func onExtras() {
        self.performSegue(withIdentifier: SegueIdentifier.ShowOutOfMovieExperience, sender: NGDMManifest.sharedInstance.outOfMovieExperience)
    }
    
    @IBAction func onExit() {
        NextGenHook.experienceWillClose()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ExtrasExperienceViewController, let experience = sender as? NGDMExperience {
            viewController.experience = experience
        }
    }
    
}

