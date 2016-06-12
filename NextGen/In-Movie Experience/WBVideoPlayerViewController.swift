//
//  WBVideoPlayerViewController.h
//  Flixster
//
//  Fork of Apple's AVPlayerDemoPlaybackViewController.h
//

import Foundation
import AVFoundation

enum WBVideoPlayerState: String {
    case Unknown = "WBVideoPlayerStateUnknown"
    case ReadyToPlay = "WBVideoPlayerStateReadyToPlay"
    case VideoLoading = "WBVideoPlayerStateVideoLoading"
    case VideoSeeking = "WBVideoPlayerStateVideoSeeking"
    case VideoPlaying = "WBVideoPlayerStateVideoPlaying"
    case VideoPaused = "WBVideoPlayerStateVideoPaused"
    case Suspend = "WBVideoPlayerStateSuspend"
    case Dismissed = "WBVideoPlayerStateDismissed"
    case Error = "WBVideoPlayerStateError"
}

struct WBVideoPlayerConstants {
    
    static let NibName = "WBVideoPlayerView"
    
    static let ControlsAutoHideTime: NSTimeInterval = 5
    
    struct Notification {
        static let ItemDurationDidLoad = "kWBVideoPlayerItemDurationDidLoadNotification"
        static let ItemReadyToPlay = "kWBVideoPlayerItemReadyToPlayNotification"
        static let PlaybackStateDidChange = "kWBVideoPlayerPlaybackStateDidChangeNotification"
        static let PlaybackBufferEmpty = "kWBVideoPlayerPlaybackBufferEmptyNotification"
        static let PlaybackLikelyToKeepUp = "kWBVideoPlayerPlaybackLikelyToKeepUpNotification"
        static let WillPlayNextItem = "kWBVideoPlayerWillPlayNextItem"
    }
    
    struct AVPlayerKVO {
        static let ItemStatus = "status"
        static let ItemDuration = "duration"
        static let ItemPlaybackBufferEmpty = "playbackBufferEmpty"
        static let ItemPlaybackLikelyToKeepUp = "playbackLikelyToKeepUp"
        static let CurrentItem = "currentItem"
        static let Rate = "rate"
        static let Tracks = "tracks"
        static let Playable = "playbacle"
    }
    
}

struct VideoPlayerObservationContext {
    static var Rate = 0
    static var Status = 0
    static var Duration = 0
    static var CurrentItem = 0
    static var BufferEmpty = 0
    static var PlaybackLikelyToKeepUp = 0
}

class WBVideoPlayerViewController : UIViewController, AVAssetResourceLoaderDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var playbackToolbar: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var scrubber: UISlider!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var subtitlesButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    private var mRestoreAfterScrubbingRate: Float = 0
    private var seekToZeroBeforePlay = false
    private var playerControlsVisible = true
    
    private var videoURLs: [NSURL]?
    private var url: NSURL?
    private var playbackSyncStartTime: NSTimeInterval = 0
    internal var playerControlsAutoHideTimer: NSTimer?
    private var mTimeObserver: AnyObject?
    private var isSeeking = false
    private var hasSeekedToPlaybackSyncStartTime = true
    
    internal var player: AVQueuePlayer?
    private var playerItem: AVPlayerItem?
    
    private var state = WBVideoPlayerState.Unknown {
        didSet {
            //DDLogInfo(@"%@", [NSString stringFromVideoPlayerState:newState]);
            
            switch (state) {
            case .Unknown:
                removePlayerTimeObserver()
                syncScrubber()
                //self.playerControlsEnabled = NO;
                break
                
            case .ReadyToPlay:
                // Play from playbackSyncStartTime
                if playbackSyncStartTime > 1 && !hasSeekedToPlaybackSyncStartTime {
                    // hasSeekedToStartTime
                    hasSeekedToPlaybackSyncStartTime = true
                    
                    // Seek
                    seekPlayerToTime(CMTimeMakeWithSeconds(playbackSyncStartTime, Int32(NSEC_PER_SEC)))
                } else {
                    // Start from either beginning or from wherever left off
                    playVideo()
                }
                
                // Scrubber timer
                initScrubberTimer()
                
                // Hide activity indicator
                setActivityIndicatorVisible(false)
                
                // Enable (not show) controls
                setPlayerControlsEnabled(true)
                break
                
            case .VideoPlaying:
                // Hide activity indicator
                setActivityIndicatorVisible(false)
                
                // Enable (not show) controls
                setPlayerControlsEnabled(true)
                
                // Auto Hide Timer
                initAutoHideTimer()
                break
                
            case .VideoPaused:
                // Hide activity indicator
                setActivityIndicatorVisible(false)
                
                // Enable (not show) controls
                setPlayerControlsEnabled(true)
                break
                
            case .VideoSeeking, .VideoLoading:
                // Show activity indicator
                setActivityIndicatorVisible(true)
                break
                
            default:
                // Disable controls
                /*if !isSeeking {
                    setPlayerControlsEnabled(false)
                }*/
                break
            }
            
            // Post notification
            NSNotificationCenter.defaultCenter().postNotificationName(WBVideoPlayerConstants.Notification.PlaybackStateDidChange, object: self)
        }
    }
    
    // MARK: Playback
    func loadItems(urls: [NSURL]) {
        videoURLs = urls
        if let url = videoURLs!.first {
            playVideoWithURL(url)
        }
    }
    
    // Play from beginning
    func playVideoWithURL(url: NSURL) {
        playVideoWithURL(url, startTime: 0)
    }
    
    // Play from start time
    func playVideoWithURL(url: NSURL, startTime: NSTimeInterval) {
        if url != self.url {
            // Set URL
            self.url = url
            
            // Set start time
            playbackSyncStartTime = startTime
            
            if let url = self.url {
                /*
                 Create an asset for inspection of a resource referenced by a given URL.
                 Load the values for the asset key "playable".
                 */
                let asset = AVURLAsset(URL: url)
                
                // Set AVAssetResourceLoaderDelegate
                asset.resourceLoader.setDelegate(self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
                
                let requestedKeys = [WBVideoPlayerConstants.AVPlayerKVO.Tracks, WBVideoPlayerConstants.AVPlayerKVO.Playable]
                
                /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
                asset.loadValuesAsynchronouslyForKeys(requestedKeys, completionHandler: {
                    dispatch_async(dispatch_get_main_queue(), {
                        /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                        self.prepareToPlayAsset(asset, requestedKeys: requestedKeys)
                    })
                })
            }
        }
    }
    
    // MARK: Actions
    @IBAction func play() {
        // Play media
        initScrubberTimer()
        playVideo()
    }
    
    @IBAction func pause() {
        // Pause media
        pauseVideo()
    }
    
    @IBAction func share(sender: AnyObject!) {
        // Override
    }
    
    @IBAction func toggleFullScreen() {
        // Toggle full screen
        toggleFullScreen()
    }
    
    // Exits player
    @IBAction func done() {
        // Pause playback
        pause()
    }
    
    // MARK: Controls
    /* Show the pause button in the movie player controller. */
    func showPauseButton() {
        if state != .VideoLoading {
            // Disable + Hide Play Button
            playButton.enabled = false
            playButton.hidden = true
        } else {
            // Enable + Show Pause Button
            pauseButton.enabled = true
            pauseButton.hidden = false
        }
    }
    
    /* Show the play button in the movie player controller. */
    func showPlayButton() {
        if state == .VideoPaused || state == .ReadyToPlay {
            // Disable + Hide Pause Button
            pauseButton.enabled = false
            pauseButton.hidden = true
            
            // Enable + Show Play Button
            playButton.enabled = true
            playButton.hidden = false
        }
    }
    
    /* If the media is playing, show the stop button; otherwise, show the play button. */
    func syncPlayPauseButtons() {
        if isPlaying() {
            showPauseButton()
        } else {
            showPlayButton()
        }
    }
    
    func enablePlayerButtons() {
        playButton.enabled = true
        pauseButton.enabled = true
        subtitlesButton.enabled = true
        fullScreenButton.enabled = true
    }
    
    func disablePlayerButtons() {
        playButton.enabled = false
        pauseButton.enabled = false
        subtitlesButton.enabled = false
        fullScreenButton.enabled = false
    }
    
    internal func setPlayerControlsEnabled(enabled: Bool) {
        if enabled {
            enableScrubber()
            enablePlayerButtons()
        } else {
            disableScrubber()
            disablePlayerButtons()
        }
    }
    
    internal func setPlayerControlsVisible(visible: Bool) {
        playerControlsVisible = visible
        
        // Show controls
        if visible {
            // Top toolbar
            topToolbar.hidden = false
            UIView.animateWithDuration(0.2, animations: {
                self.topToolbar.transform = CGAffineTransformIdentity
            })
            
            // Controls toolbar
            playbackToolbar.hidden = false
            UIView.animateWithDuration(0.2, animations: {
                self.playbackToolbar.transform = CGAffineTransformIdentity
            })
        }
        // Hide controls
        else {
            // Top toolbar
            UIView.animateWithDuration(0.2, animations: {
                self.topToolbar.transform = CGAffineTransformMakeTranslation(0, -(CGRectGetHeight(self.topToolbar.bounds)))
            }, completion: { (finished) in
                self.topToolbar.hidden = true
            })
            
            // Controls toolbar
            UIView.animateWithDuration(0.2, animations: {
                self.playbackToolbar.transform = CGAffineTransformMakeTranslation(0, -(CGRectGetHeight(self.playbackToolbar.bounds)))
            }, completion: { (finished) in
                self.playbackToolbar.hidden = true
            })
        }
    }
    
    func setActivityIndicatorVisible(visible: Bool) {
        if visible {
            // Show activity indicator
            UIView.animateWithDuration(0.2, animations: { 
                self.activityIndicator.startAnimating()
                self.activityIndicator.hidden = false
                self.activityIndicator.alpha = 1
            })
        } else {
            // Hide activity indicator
            UIView.animateWithDuration(0.2, animations: { 
                self.activityIndicator.alpha = 0
            }, completion: { (finished) in
                if let activityIndicator = self.activityIndicator {
                    activityIndicator.hidden = true
                    activityIndicator.stopAnimating()
                }
                
                // Show play/pause button if player controls are visible
                // Calling setPlayerControlsVisible will now toggle the play/pause
                // button once the player's state is NOT WBVideoPlayerStateVideoLoading
                self.setPlayerControlsVisible(self.playerControlsVisible)
            })
        }
    }
    
    func initAutoHideTimer() {
        // Invalidate existing timer
        if let timer = playerControlsAutoHideTimer {
            timer.invalidate()
            playerControlsAutoHideTimer = nil
        }
        
        if playerControlsVisible {
            // Start timer
            playerControlsAutoHideTimer = NSTimer.scheduledTimerWithTimeInterval(WBVideoPlayerConstants.ControlsAutoHideTime, target: self, selector: #selector(self.autoHideControls), userInfo: nil, repeats: false)
        }
    }
    
    func autoHideControls() {
        // Auto-hide controls if player is playing
        if playerControlsVisible && state == .VideoPlaying {
            setPlayerControlsVisible(false)
        }
    }
    
    // MARK: Movie Scrubber Control
    /* Requests invocation of a given block during media playback to update the movie scrubber control. */
    func initScrubberTimer() {
        let playerDuration = playerItemDuration()
        if CMTIME_IS_VALID(playerDuration) {
            /* Update the scrubber during normal playback. */
            mTimeObserver = player?.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(1, 1), queue: nil, usingBlock: { [weak self] (time) in
                if let strongSelf = self {
                    strongSelf.syncScrubber()
                }
            })
        }
    }
    
    func syncScrubber() {
        let playerDuration = playerItemDuration()
        if CMTIME_IS_VALID(playerDuration), let player = player {
            let duration = CMTimeGetSeconds(playerDuration)
            if isfinite(duration) {
                let time = Float(CMTimeGetSeconds(player.currentTime()))
                scrubber.value = (scrubber.maximumValue - scrubber.minimumValue) * time / Float(duration) + scrubber.minimumValue
                
                // Update time labels
                updateTimeLabelsWithTime(time)
            }
        } else {
            scrubber.minimumValue = 0
        }
    }
    
    func timeValueForSlider(slider: UISlider) -> Float {
        let playerDuration = playerItemDuration()
        if CMTIME_IS_VALID(playerDuration) {
            let duration = CMTimeGetSeconds(playerDuration)
            if isfinite(duration) {
                return Float(duration) * (slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue)
            }
        }
        
        return 0
    }
    
    /* The user is dragging the movie controller thumb to scrub through the movie. */
    @IBAction func beginScrubbing(sender: AnyObject) {
        if let player = player {
            mRestoreAfterScrubbingRate = player.rate
        }
        
        pauseVideo()
        
        // Remove previous timer
        removePlayerTimeObserver()
    }
    
    /* Set the player current time to match the scrubber position. */
    @IBAction func scrub(sender: AnyObject) {
        if let slider = sender as? UISlider {
            // Update time labels
            updateTimeLabelsWithTime(timeValueForSlider(slider))
        }
    }
    
    func seekPlayerToTime(seekTime: CMTime) {
        // Set instance vars
        isSeeking = true
        
        // Set State
        state = .VideoSeeking
        
        // Seek
        player?.seekToTime(seekTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (finished) in
            if finished {
                dispatch_async(dispatch_get_main_queue(), {
                    // Seeking complete
                    self.isSeeking = false
                    
                    // Play
                    self.playVideo()
                })
            }
        })
    }
    
    /* The user has released the movie thumb control to stop scrubbing through the movie. */
    @IBAction func endScrubbing(sender: AnyObject) {
        if mTimeObserver == nil {
            initScrubberTimer()
        }
        
        if let slider = sender as? UISlider {
            let time = timeValueForSlider(slider)
            
            // Update time labels
            updateTimeLabelsWithTime(time)
            
            // Seek
            seekPlayerToTime(CMTimeMakeWithSeconds(Float64(time), Int32(NSEC_PER_SEC)))
        }
        
        if mRestoreAfterScrubbingRate != 0 {
            player?.setRate(mRestoreAfterScrubbingRate, time: kCMTimeZero, atHostTime: kCMTimeZero)
            mRestoreAfterScrubbingRate = 0
        }
    }
    
    func isScrubbing() -> Bool {
        return mRestoreAfterScrubbingRate != 0
    }
    
    func enableScrubber() {
        scrubber.enabled = true
    }
    
    func disableScrubber() {
        scrubber.enabled = false
    }
    
    func updateTimeLabelsWithTime(time: Float) {
        // Update time labels
        timeElapsedLabel.text = timeStringFromSecondsValue(time)
    }
    
    // MARK: Timecode labels
    func timeStringFromSecondsValue(seconds: Float) -> String {
        let hours = seconds / 3600
        let minutes = (seconds / 60) % 60
        let secs = seconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    // MARK: Initialization
    override init(nibName: String?, bundle: NSBundle?) {
        super.init(nibName: nibName, bundle: bundle)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    func setup() {
        player = nil
        self.edgesForExtendedLayout = UIRectEdge.All
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        // Disable OS Idle timer
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        player = nil
        
        // Setup audio to be heard even if device is on silent
        var error: NSError?
        //AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: error)
        
        if error != nil {
            //DDLogError(@"%@", error);
        }
        
        isSeeking = false
        initScrubberTimer()
        syncPlayPauseButtons()
        syncScrubber()
        
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(animated: Bool) {
        player?.pause()
        
        super.viewWillDisappear(animated)
    }
    
    private func setViewDisplayName() {
        /* Set the view title to the last component of the asset URL. */
        self.title = url?.lastPathComponent
        
        /* Or if the item has a AVMetadataCommonKeyTitle metadata, use that instead. */
        if let playerItem = player?.currentItem {
            for item in playerItem.asset.commonMetadata {
                if item.commonKey == AVMetadataCommonKeyTitle {
                    self.title = item.stringValue
                }
            }
        }
    }
    
    @IBAction func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        setPlayerControlsVisible(!playerControlsVisible)
        initAutoHideTimer()
    }
    
    // MARK: Player
    func playVideo() {
        /* If we are at the end of the movie, we must seek to the beginning first
         before starting playback. */
        if seekToZeroBeforePlay {
            // Pause
            pauseVideo()
            
            // Seek
            player?.seekToTime(kCMTimeZero)
            
            seekToZeroBeforePlay = false
        }
        
        // Play
        player?.play()
        
        // Immediately show pause button. NOTE: syncPlayPauseButtons will actually update this
        // to reflect the playback "rate", e.g. 0.0 will automatically show the pause button.
        showPauseButton()
    }
    
    func pauseVideo() {
        // Pause media
        player?.pause()
        
        // Immediately show play button. NOTE: syncPlayPauseButtons will actually update this
        // to reflect the playback "rate", e.g. 0.0 will automatically show the pause button.
        showPlayButton()
    }
    
    // MARK: Player Item
    func isPlaying() -> Bool {
        return mRestoreAfterScrubbingRate != 0 || player?.rate != 0;
    }
    
    /* Called when the player item has played to its end time. */
    internal func playerItemDidReachEnd(notification: NSNotification) {
        /* After the movie has played to its end time, seek back to time zero
            to play it again. */
        seekToZeroBeforePlay = true
    }
    
    func playerItemDuration() -> CMTime {
        if let playerItem = player?.currentItem where playerItem.status == .ReadyToPlay {
            return playerItem.duration
        }
        
        return kCMTimeInvalid
    }
    
    /* Cancels the previously registered time observer. */
    func removePlayerTimeObserver() {
        // Player timer
        if let observer = mTimeObserver {
            player?.removeTimeObserver(observer)
        }
        
        // Player Controls Auto-Hide Timer
        if let timer = playerControlsAutoHideTimer {
            timer.invalidate()
        }
        
        mTimeObserver = nil
        playerControlsAutoHideTimer = nil
    }
    
    // MARK: AVAssetResourceLoaderDelegate
    func resourceLoader(resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        return false
    }
    
    // MARK: Error Handling - Preparing Assets for Playback Failed
    /* --------------------------------------------------------------
     **  Called when an asset fails to prepare for playback for any of
     **  the following reasons:
     **
     **  1) values of asset keys did not load successfully,
     **  2) the asset keys did load successfully, but the asset is not
     **     playable
     **  3) the item did not become ready to play.
     ** ----------------------------------------------------------- */
    func assetFailedToPrepareForPlayback(error: NSError?) {
        // Set player state
        state = .Error
        
        removePlayerTimeObserver()
        syncScrubber()
        setPlayerControlsEnabled(false)
        
        // Log error
        //DDLogError(@"%@ %@", error, error.description);
        
        // Display error
        displayError(error)
    }
    
    // MARK: Prepare to play asset
    func prepareToPlayAsset(asset: AVURLAsset, requestedKeys: [String]) {
        // Set player state
        state = .VideoLoading
        
        /* Make sure that the value of each key has loaded successfully. */
        for key in requestedKeys {
            var error: NSError?
            let keyStatus = asset.statusOfValueForKey(key, error: &error)
            if keyStatus == .Failed {
                assetFailedToPrepareForPlayback(error)
                return
            }
            
            /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
        }
        
        /* Use the AVAsset playable property to detect whether the asset can be played. */
        if !asset.playable {
            /* Generate an error describing the failure. */
            let error = NSError(domain: "WBVideoPlayer", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Item cannot be played",
                NSLocalizedFailureReasonErrorKey: "Item cannot be played"
            ])
            
            /* Display the error to the user. */
            assetFailedToPrepareForPlayback(error)
            return
        }
        
        // At this point we're ready to set up for playback of the asset.
        
        // Stop observing our prior AVPlayerItem, if we have one.
        if let playerItem = playerItem {
            playerItem.removeObserver(self, forKeyPath: WBVideoPlayerConstants.AVPlayerKVO.ItemStatus)
            playerItem.removeObserver(self, forKeyPath: WBVideoPlayerConstants.AVPlayerKVO.ItemDuration)
            playerItem.removeObserver(self, forKeyPath: WBVideoPlayerConstants.AVPlayerKVO.ItemPlaybackBufferEmpty)
            playerItem.removeObserver(self, forKeyPath: WBVideoPlayerConstants.AVPlayerKVO.ItemPlaybackLikelyToKeepUp)
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: player?.currentItem)
        }
        
        // Create a new instance of AVPlayerItem from the now successfully loaded AVAsset.
        playerItem = AVPlayerItem(asset: asset)
        
        // Observe the player item "status" key to determine when it is ready to play.
        playerItem!.addObserver(self, forKeyPath: WBVideoPlayerConstants.AVPlayerKVO.ItemStatus, options: [.Initial, .New], context: &VideoPlayerObservationContext.Status)
        
        // Observe the player item "duration" key to determine when it is ready to play.
        playerItem!.addObserver(self, forKeyPath: WBVideoPlayerConstants.AVPlayerKVO.ItemDuration, options: [.Initial, .New], context: &VideoPlayerObservationContext.Duration)
        
        // Observe playback buffer
        playerItem!.addObserver(self, forKeyPath: WBVideoPlayerConstants.AVPlayerKVO.ItemPlaybackBufferEmpty, options: .New, context: &VideoPlayerObservationContext.BufferEmpty)
        
        // Observe playback buffer status
        playerItem!.addObserver(self, forKeyPath: WBVideoPlayerConstants.AVPlayerKVO.ItemPlaybackLikelyToKeepUp, options: .New, context: &VideoPlayerObservationContext.PlaybackLikelyToKeepUp)
        
        seekToZeroBeforePlay = false
        
        /* Create new player, if we don't already have one. */
        if player == nil {
            /* Get a new AVPlayer initialized to play the specified player item. */
            player = AVQueuePlayer(playerItem: playerItem!)
            
            /* Observe the AVPlayer "currentItem" property to find out when any
             AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
             occur.*/
            player!.addObserver(self, forKeyPath: WBVideoPlayerConstants.AVPlayerKVO.CurrentItem, options: [.Initial, .New], context: &VideoPlayerObservationContext.CurrentItem)
            
            /* Observe the AVPlayer "rate" property to update the scrubber control. */
            player!.addObserver(self, forKeyPath: WBVideoPlayerConstants.AVPlayerKVO.Rate, options: [.Initial, .New], context: &VideoPlayerObservationContext.Rate)
        } else {
            //insert new items to the queue
            player!.insertItem(playerItem!, afterItem: nil)
        }
        
        /* Make our new AVPlayerItem the AVPlayer's current item. */
        if player!.currentItem != playerItem! {
            /* Replace the player item with a new player item. The item replacement occurs
             asynchronously; observe the currentItem property to find out when the
             replacement will/did occur
             
             If needed, configure player item here (example: adding outputs, setting text style rules,
             selecting media options) before associating it with a player
             */
            
            //[self.player replaceCurrentItemWithPlayerItem:self.playerItem];
            syncPlayPauseButtons()
        }
        
        scrubber.value = 0
    }
    
    // MARK: User Feedback
    func displayError(error: NSError?) {
        /* Display the error. */
        UIAlertView(title: error?.localizedDescription, message: error?.localizedFailureReason, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
}