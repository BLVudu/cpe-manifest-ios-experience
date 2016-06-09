//
//  WBVideoPlayerViewController.h
//  Flixster
//
//  Fork of Apple's AVPlayerDemoPlaybackViewController.h
//

import Foundation
import AVFoundation

struct WBVideoPlayerConstants {
    
    static let NibName = "WBVideoPlayerView"
    
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
    
    struct ObservationContext {
        static let Rate = &VideoPlayerRateObservationContext
        static let Status = &VideoPlayerStatusObservationContext
        static let Duration = &VideoPlayerDurationObservationContext
        static let CurrentItem = &VideoPlayerCurrentItemObservationContext
        static let BufferEmpty = &VideoPlayerBufferEmptyObservationContext
        static let PlaybackLikelyToKeepUp = &VideoPlayerPlaybackLikelyToKeepUpObservationContext
    }
    
}

enum WBVideoPlayerState {
    case Unknown
    case ReadyToPlay
    case VideoLoading
    case VideoPaused
}

class WBVideoPlayerViewController {
    
    @IBOutlet weak var playbackToolbar: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var scrubber: UISlider!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var subtitlesButton: UIButton!
    
    private var state = WBVideoPlayerState.Unknown
    
    private var videoURLs: [NSURL]?
    private var url: NSURL?
    private var playbackSyncStartTime: NSTimeInterval = 0
    
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
            
            /*
             Create an asset for inspection of a resource referenced by a given URL.
             Load the values for the asset key "playable".
             */
            let asset = AVURLAsset(URL: self.url)
            
            // Set AVAssetResourceLoaderDelegate
            asset.resourceLoader.setDelegate(self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
            
            let requestedKeys = [WBVideoPlayerConstants.AVPlayerKVO.Tracks, WBVideoPlayerConstants.AVPlayerKVO.Playable]
            
            /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
            asset.loadValuesAsynchronouslyForKeys(requestedKeys, completionHandler: ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                    self.prepareToPlayAsset(asset, withKeys: requestedKeys)
                });
            })
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
    
    @IBAction func share() {
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
        if state == .VideoPause || state == .ReadyToPlay {
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
        if isPlaying {
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
    
    func setPlayerControlsEnabled(enabled: Bool) {
        if enabled {
            enableScrubber()
            enablePlayerButtons()
        } else {
            disableScrubber()
            disablePlayerButtons()
        }
    }
    
    func setPlayerControlsVisible(visible: Bool) {
        // Show controls
        if visible {
            // Top toolbar
            topToolbar.hidden = false
            UIView.animateWithDuration(0.2, animations: ^{
                self.topToolbar.transform = CGAffineTransformIdentity
            })
            
            // Controls toolbar
            playbackToolbar.hidden = false
            UIView.animateWithDuration(0.2, animations: ^{
                self.playbackToolbar.transform = CGAffineTransformIdentity
            })
        }
        // Hide controls
        else {
            // Top toolbar
            UIView.animateWithDuration(0.2, animations: ^{
                self.topToolbar.transform = CGAffineTransformMakeTranslation(0, -(CGRectGetHeight(self.topToolbar.bounds)))
            }, completion: ^(finished: Bool) {
                self.topToolbar.hidden = true
            })
            
            // Controls toolbar
            UIView.animateWithDuration(0.2, animations: ^{
                self.playbackToolbar.transform = CGAffineTransformMakeTranslation(0, -(CGRectGetHeight(self.playbackToolbar.bounds)))
            }, completion: ^(finished: Bool) {
                self.playbackToolbar.hidden = true
            })
        }
    }
    
    func setActivityIndicatorVisible(visible: Bool) {
        if visible {
            
        } else {
            
        }
    }
    
    func initAutoHideTimer() {
        
    }
    
    func autoHideControls() {
        
    }
    
    // MARK: Movie Scrubber Control
    func initScrubberTimer() {
        
    }
    
    func syncScrubber() {
        
    }
    
    func timeValueForSlider(slider: UISlider) -> Double {
        return 0
    }
    
    /* The user is dragging the movie controller thumb to scrub through the movie. */
    @IBAction func beginScrubbing(sender: AnyObject) {
    
    }
    
    /* Set the player current time to match the scrubber position. */
    @IBAction func scrub(sender: AnyObject) {
        
    }
    
    func seekPlayerToTime(seekTime: CMTime) {
        
    }
    
    /* The user has released the movie thumb control to stop scrubbing through the movie. */
    @IBAction func endScrubbing(sender: AnyObject) {
        
    }
    
    func isScrubbing() -> Bool {
        return false
    }
    
    func enableScrubber() {
        scrubber.enabled = true
    }
    
    func disableScrubber() {
        scrubber.enabled = false
    }
    
    func updateTimeLabelsWithTime(time: CGFloat) {
        
    }
    
    // MARK: Timecode labels
    func timeStringFromSecondsValue(seconds: Int) -> String {
        
    }
    
    // MARK: Initialization
    override init(nibName: String?, bundle: NSBundle?) {
        super.init(nibName, bundle: bundle)
        setup()
    }
    
    override init(coder: NSCoder) {
        super.init(coder)
        setup()
    }
    
    func setup() {
        player = nil
        self.edgesForExtendedLayout = UIRectEdge.All
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
}