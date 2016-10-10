//
//  VideoPlayerViewController.swift
//

import Foundation
import UIKit
import MessageUI
import CoreMedia
import NextGenDataManager
import UAProgressView

public enum VideoPlayerMode {
    case mainFeature
    case supplemental
    case supplementalInMovie
    case basicPlayer
}

typealias Task = (_ cancel : Bool) -> ()

class VideoPlayerViewController: NextGenVideoPlayerViewController {
    
    public struct Constants {
        static let CountdownTimeInterval: CGFloat = 1
        static let CountdownTotalTime: CGFloat = 5
    }
    
    var mode = VideoPlayerMode.supplemental
    var shouldMute = false
    var shouldTrackOutput = false
    
    private var playerItemVideoOutput: AVPlayerItemVideoOutput?
    
    private var _didPlayInterstitial = false
    private var _lastNotifiedTime = -1.0
    private var _controlsAreLocked = false
    private var manuallyPaused = false
    @IBOutlet weak private var _commentaryView: UIView!
    @IBOutlet weak private var _commentaryButton: UIButton!
    @IBOutlet weak private var _homeButton: UIButton!
    @IBOutlet weak private var cropToActivePictureButton: UIButton?
    var commentaryIndex = 0
    
    override var isFullScreen: Bool {
        didSet {
            NotificationCenter.default.post(name: .videoPlayerDidToggleFullScreen, object: nil, userInfo: [NotificationConstants.isFullScreen: isFullScreen])
        }
    }
    
    // Countdown/Queue
    var queueTotalCount = 0
    var queueCurrentIndex = 0
    private var countdownSeconds: CGFloat = 0 {
        didSet {
            countdownLabel.text = String.localize("label.time.seconds", variables: ["count": String(Int(Constants.CountdownTotalTime - countdownSeconds))])
            countdownProgressView?.setProgress(((countdownSeconds + 1) / Constants.CountdownTotalTime), animated: true)
        }
    }
    
    private var countdownTimer: Timer?
    private var countdownProgressView: UAProgressView?
    @IBOutlet weak private var countdownLabel: UILabel!
    
    // Skip interstitial
    @IBOutlet weak private var skipContainerView: UIView!
    @IBOutlet weak private var skipCountdownContainerView: UIView!
    @IBOutlet private var skipContainerLandscapeHeightConstraint: NSLayoutConstraint?
    @IBOutlet private var skipContainerPortraitHeightConstraint: NSLayoutConstraint?
    
    // Notifications
    private var playerItemDurationDidLoadObserver: NSObjectProtocol?
    private var videoPlayerDidPlayVideoObserver: NSObjectProtocol?
    private var updateCommentaryButtonObserver: NSObjectProtocol?
    private var sceneDetailWillCloseObserver: NSObjectProtocol?
    private var videoPlayerShouldPauseObserver: NSObjectProtocol?
    
    deinit {
        let center = NotificationCenter.default
        
        if let observer = playerItemDurationDidLoadObserver {
            center.removeObserver(observer)
            playerItemDurationDidLoadObserver = nil
        }
        
        if let observer = videoPlayerDidPlayVideoObserver {
            center.removeObserver(observer)
            videoPlayerDidPlayVideoObserver = nil
        }
        
        if let observer = updateCommentaryButtonObserver {
            center.removeObserver(observer)
            updateCommentaryButtonObserver = nil
        }
        
        if let observer = sceneDetailWillCloseObserver {
            center.removeObserver(observer)
            sceneDetailWillCloseObserver = nil
        }
        
        if let observer = videoPlayerShouldPauseObserver {
            center.removeObserver(observer)
            videoPlayerShouldPauseObserver = nil
        }
        
        cancelCountdown()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skipContainerView.isHidden = true
        skipContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapSkip)))
        
        // Localizations
        _homeButton.setTitle(String.localize("label.home"), for: UIControlState())
        _commentaryButton.setTitle(String.localize("label.commentary"), for: UIControlState())
        _commentaryView.isHidden = true
        
        // Notifications
        playerItemDurationDidLoadObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kNextGenVideoPlayerItemDurationDidLoadNotification), object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            if let strongSelf = self, let duration = notification.userInfo?[NotificationConstants.duration] as? Double , strongSelf.countdownProgressView == nil {
                let progressView = UAProgressView(frame: strongSelf.skipCountdownContainerView.frame)
                progressView.borderWidth = 0
                progressView.lineWidth = 2
                progressView.fillOnTouch = false
                progressView.tintColor = UIColor.white
                progressView.animationDuration = duration
                strongSelf.skipContainerView.addSubview(progressView)
                strongSelf.countdownProgressView = progressView
                strongSelf.countdownProgressView?.setProgress(1, animated: true)
            }
        })
        
        videoPlayerDidPlayVideoObserver = NotificationCenter.default.addObserver(forName: .videoPlayerDidPlayVideo, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            if let strongSelf = self, strongSelf._didPlayInterstitial {
                if let videoURL = notification.userInfo?[NotificationConstants.videoUrl] as? URL, videoURL != strongSelf.url {
                    strongSelf.pauseVideo()
                }
            }
        })
        
        videoPlayerShouldPauseObserver = NotificationCenter.default.addObserver(forName: .videoPlayerShouldPause, object: nil, queue: OperationQueue.main, using: { [weak self] (_) in
            self?.pauseVideo()
        })
        
        /*updateCommentaryButtonObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kDidSelectCommetaryOption), object: nil, queue: OperationQueue.main, using: { [weak self]
            (notification) in
            if let strongSelf = self {
                if let index = notification.userInfo.userInfo?["option"] as? Int {
                    strongSelf.commentaryIndex = index
                    strongSelf._commentaryButton.setTitle(index > 0 ? String.localize("label.commentary.on") : String.localize("label.commentary"), for: UIControlState())
                }
            }
        })*/
        
        sceneDetailWillCloseObserver = NotificationCenter.default.addObserver(forName: .inMovieExperienceWillCloseDetails, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            if let strongSelf = self , strongSelf.mode == .mainFeature && !strongSelf.manuallyPaused {
                strongSelf.playVideo()
            }
        })
        
        if !DeviceType.IS_IPAD {
            self.cropToActivePictureButton?.removeFromSuperview()
        }

        if mode == .mainFeature {
            self.fullScreenButton.removeFromSuperview()
            playMainExperience()
        } else {
            _didPlayInterstitial = true
            self.playerControlsVisible = false
            self.topToolbar.removeFromSuperview()
            self.cropToActivePictureButton?.removeFromSuperview()
            
            if mode == .supplementalInMovie {
                self.fullScreenButton.removeFromSuperview()
            } else if mode == .basicPlayer {
                self.playbackToolbar.removeFromSuperview()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if _didPlayInterstitial {
            self.playerControlsVisible = true
            self.initAutoHideTimer()
        } else {
            countdownProgressView?.frame = skipCountdownContainerView.frame
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if !_didPlayInterstitial {
            let currentOrientation = UIApplication.shared.statusBarOrientation
            skipContainerLandscapeHeightConstraint?.isActive = UIInterfaceOrientationIsLandscape(currentOrientation)
            skipContainerPortraitHeightConstraint?.isActive = UIInterfaceOrientationIsPortrait(currentOrientation)
            countdownProgressView?.frame = skipCountdownContainerView.frame
        }
    }
    
    // MARK: Video Playback
    override func playVideo(with url: URL?) {
        cancelCountdown()
        
        if _didPlayInterstitial, let url = url {
            DispatchQueue.global(qos: .userInteractive).async {
                SettingsManager.setVideoAsWatched(url)
                NextGenHook.delegate?.urlForProcessedVideo(url, mode: self.mode, completion: { (url, startTime) in
                    if let url = url {
                        DispatchQueue.main.async {
                            super.playVideo(with: url, startTime: startTime)
                        }
                    }
                })
            }
        } else {
            super.playVideo(with: url)
        }
    }
    
    func playMainExperience() {
        self.playerControlsVisible = false
        countdownProgressView?.removeFromSuperview()
        countdownProgressView = nil
        
        if !_didPlayInterstitial {
            if let videoURL = NGDMManifest.sharedInstance.mainExperience?.interstitialVideoURL {
                self.playVideo(with: videoURL)
                
                skipContainerView.isHidden = !SettingsManager.didWatchInterstitial
                SettingsManager.didWatchInterstitial = true
                return
            }
            
            _didPlayInterstitial = true
        }
        
        skipContainerView.isHidden = true
        if let videoURL = NGDMManifest.sharedInstance.mainExperience?.videoURL {
            NotificationCenter.default.post(name: .videoPlayerDidPlayMainExperience, object: nil)
            self.playVideo(with: videoURL)
        }
    }
    
    func skipInterstitial() {
        self.pauseVideo()
        self.player?.removeAllItems()
        self._didPlayInterstitial = true
        self.playMainExperience()
        NextGenHook.logAnalyticsEvent(.imeAction, action: .skipInterstitial)
    }
    
    override func playVideo() {
        super.playVideo()
        
        manuallyPaused = false
        NotificationCenter.default.post(name: .videoPlayerDidPlayVideo, object: nil, userInfo: [NotificationConstants.videoUrl: self.url])
    }
    
    override func observeValue(forKeyPath path: String!, of object: Any!, change: [AnyHashable : Any]!, context: UnsafeMutableRawPointer!) {
        super.observeValue(forKeyPath: path, of: object, change: change, context: context)
        
        self.playbackView.setVideoFillMode(_didPlayInterstitial && mode != .basicPlayer ? AVLayerVideoGravityResizeAspect : AVLayerVideoGravityResizeAspectFill)
        
        if mode == .basicPlayer {
            self.player?.actionAtItemEnd = .none
        }
    }
    
    override func syncScrubber() {
        super.syncScrubber()
        
        if player != nil && (mode == .mainFeature || mode == .basicPlayer) {
            var currentTime = _didPlayInterstitial ? CMTimeGetSeconds(self.player?.currentTime() ?? kCMTimeZero) : 0
            if currentTime.isNaN {
                currentTime = 0.0
            }
            
            if _lastNotifiedTime != currentTime {
                _lastNotifiedTime = currentTime
                NotificationCenter.default.post(name: .videoPlayerDidChangeTime, object: nil, userInfo: [NotificationConstants.time: Double(currentTime)])
            }
            
            if currentTime >= 1 && mode == .basicPlayer {
                self.activityIndicator?.removeFromSuperview()
            }
            
            self.player.isMuted = shouldMute
            if shouldTrackOutput && self.playerItem.outputs.count == 0 {
                self.playerItem.add(AVPlayerItemVideoOutput())
            }
        }
    }
    
    override func playerItemDidReachEnd(_ notification: Notification!) {
        if let playerItem = notification.object as? AVPlayerItem, playerItem == self.player.currentItem {
            if !_didPlayInterstitial {
                _didPlayInterstitial = true
                playMainExperience()
                return
            }
            
            queueCurrentIndex += 1
            if queueCurrentIndex < queueTotalCount {
                self.pauseVideo()
                
                countdownLabel.isHidden = false
                
                let progressView = UAProgressView(frame: countdownLabel.frame)
                progressView.centralView = countdownLabel
                progressView.borderWidth = 0
                progressView.lineWidth = 2
                progressView.fillOnTouch = false
                progressView.tintColor = UIColor.themePrimary
                progressView.animationDuration = Double(Constants.CountdownTimeInterval)
                self.view.addSubview(progressView)
                countdownProgressView = progressView
                
                countdownSeconds = 0
                countdownTimer = Timer.scheduledTimer(timeInterval: Double(Constants.CountdownTimeInterval), target: self, selector: #selector(self.onCountdownTimerFired), userInfo: nil, repeats: true)
            } else {
                NotificationCenter.default.post(name: .videoPlayerDidEndLastVideo, object: nil)
            }
            
            NotificationCenter.default.post(name: .videoPlayerDidEndVideo, object: nil)
            
            //super.playerItemDidReachEnd(notification)
            
            if mode == .mainFeature {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                    NextGenHook.delegate?.videoPlayerWillClose(self.mode, playbackPosition: 0)
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: .outOfMovieExperienceShouldLaunch, object: nil)
                    })
                }
            }
        }
    }
    
    func onCountdownTimerFired() {
        countdownSeconds += Constants.CountdownTimeInterval
        
        if countdownSeconds >= Constants.CountdownTotalTime {
            if let timer = countdownTimer {
                timer.invalidate()
                countdownTimer = nil
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(Constants.CountdownTimeInterval) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                self.cancelCountdown()
                NotificationCenter.default.post(name: .videoPlayerWillPlayNextItem, object: nil, userInfo: [NotificationConstants.index: self.queueCurrentIndex])
            }
        }
    }
    
    func cancelCountdown() {
        if let timer = countdownTimer {
            timer.invalidate()
            countdownTimer = nil
        }
        
        countdownLabel.isHidden = true
        countdownProgressView?.removeFromSuperview()
        countdownProgressView = nil
    }
    
    func getScreenGrab() -> UIImage? {
        if let playerItemVideoOutput = self.playerItem?.outputs.first as? AVPlayerItemVideoOutput {
            if let cvPixelBuffer = playerItemVideoOutput.copyPixelBuffer(forItemTime: self.playerItem.currentTime(), itemTimeForDisplay: nil) {
                return UIImage(ciImage: CIImage(cvPixelBuffer: cvPixelBuffer))
            }
        }
        
        return nil
    }
    
    // MARK: Actions
    override func pause(_ sender: Any?) {
        super.pause(sender)
        
        manuallyPaused = true
    }
    
    override func done(_ sender: Any?) {
        super.done(sender)
        
        NextGenHook.delegate?.videoPlayerWillClose(mode, playbackPosition: self.playerItem != nil ? CMTimeGetSeconds(self.playerItem.currentTime()) : 0)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCropToActivePicture() {
        self.playbackView.setVideoFillMode(self.playbackView.videoFillMode() == AVLayerVideoGravityResizeAspectFill ? AVLayerVideoGravityResizeAspect : AVLayerVideoGravityResizeAspectFill)
    }
    
    @IBAction func commentary(_ sender: UIButton) {
        
        sender.imageView!.image? = (sender.imageView!.image?.withRenderingMode(.alwaysTemplate))!
        _commentaryView.isHidden = !_commentaryView.isHidden
        
        if !_commentaryView.isHidden {
            
            sender.tintColor = UIColor.themePrimary
            
            if let timer = self.playerControlsAutoHideTimer {
                timer.invalidate()
            }
        } else {
            if commentaryIndex == 0 {
                sender.tintColor = UIColor.white
            }
            
            self.initAutoHideTimer()
        }
    }
    
    override func handleTap(_ gestureRecognizer: UITapGestureRecognizer!) {
        if !_controlsAreLocked && _didPlayInterstitial {
            if _commentaryView.isHidden {
                super.handleTap(gestureRecognizer)
            } else {
                commentary(_commentaryButton)
            }
        }
    }
    
    func onTapSkip() {
        if !_controlsAreLocked && !_didPlayInterstitial {
            skipInterstitial()
        }
    }
    
}
