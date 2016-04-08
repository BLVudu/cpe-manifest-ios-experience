//
//  WBVideoPlayerViewController.m
//  Flixster
//
//  Fork of Apple's AVPlayerDemoPlaybackViewController.m
//


@import UIKit;
@import AVFoundation;

@class WBVideoPlayerPlaybackView, WBVideoPlayerViewController;

//=========================================================
# pragma mark - enums
//=========================================================
typedef NS_ENUM(NSInteger, WBVideoPlayerState) {
    WBVideoPlayerStateUnknown,
    WBVideoPlayerStateReadyToPlay,
    WBVideoPlayerStateVideoLoading,
    WBVideoPlayerStateVideoSeeking,
    WBVideoPlayerStateVideoPlaying,
    WBVideoPlayerStateVideoPaused,
    WBVideoPlayerStateSuspend,
    WBVideoPlayerStateDismissed,
    WBVideoPlayerStateError
};

//=========================================================
# pragma mark - Constants
//=========================================================
static NSString * const kWBVideoPlayerItemDurationDidLoadNotification       = @"kWBVideoPlayerItemDurationDidLoadNotification";
static NSString * const kWBVideoPlayerItemReadyToPlayNotification           = @"kWBVideoPlayerItemReadyToPlayNotification";
static NSString * const kWBVideoPlayerPlaybackStateDidChangeNotification    = @"kWBVideoPlayerPlaybackStateDidChangeNotification";
//static NSString * const kWBVideoPlayerScrubberValueUpdatedNotification    = @"kWBVideoPlayerScrubberValueUpdatedNotification";
//static NSString * const kWBVideoPlayerShowVideoInfoNotification           = @"kWBVideoPlayerShowVideoInfoNotification";
//static NSString * const kWBVideoPlayerOrientationDidChangeNotification    = @"kWBVideoPlayerOrientationDidChangeNotification";
//static NSString * const kWBVideoPlayerUpdateVideoTrackNotification        = @"kWBVideoPlayerUpdateVideoTrackNotification";

static NSString * const kWBVideoPlayerPlaybackBufferEmptyNotification       = @"kWBVideoPlayerPlaybackBufferEmptyNotification";
static NSString * const kWBVideoPlayerPlaybackLikelyToKeepUpNotification    = @"kWBVideoPlayerPlaybackLikelyToKeepUpNotification";
static NSString * const kWBVideoPlayerWillPlayNextItem                      = @"kWBVideoPlayerWillPlayNextItem";

//static NSString * const kWBVideoPlayerStateChangedNotification            = @"kWBVideoPlayerStateChangedNotification";
//static NSString * const kWBVideoPlayerDismissNotification                 = @"kWBVideoPlayerDismissNotification";

//=========================================================
# pragma mark -
# pragma mark - WBVideoPlayerDelegate
//=========================================================
@protocol WBVideoPlayerDelegate <NSObject>
@optional
//- (BOOL)shouldVideoPlayer:(WBVideoPlayer*)videoPlayer changeStateTo:(WBVideoPlayerState)toState;
//- (void)videoPlayer:(WBVideoPlayer*)videoPlayer willChangeStateTo:(WBVideoPlayerState)toState;
//- (void)videoPlayer:(WBVideoPlayer*)videoPlayer didChangeStateFrom:(WBVideoPlayerState)fromState;
//- (BOOL)shouldVideoPlayer:(WBVideoPlayer*)videoPlayer startVideo:(id<WBVideoPlayerTrackProtocol>)track;
//- (void)videoPlayer:(WBVideoPlayer*)videoPlayer willStartVideo:(id<WBVideoPlayerTrackProtocol>)track;
//- (void)videoPlayer:(WBVideoPlayer*)videoPlayer didStartVideo:(id<WBVideoPlayerTrackProtocol>)track;

- (void)videoPlayer:(WBVideoPlayerViewController *)videoPlayer isBuffering:(BOOL)buffering;

//- (void)videoPlayer:(WBVideoPlayer*)videoPlayer didPlayFrame:(id<WBVideoPlayerTrackProtocol>)track time:(NSTimeInterval)time lastTime:(NSTimeInterval)lastTime;
//- (void)videoPlayer:(WBVideoPlayer*)videoPlayer didPlayToEnd:(id<WBVideoPlayerTrackProtocol>)track;
//- (void)videoPlayer:(WBVideoPlayer*)videoPlayer didControlByEvent:(WBVideoPlayerControlEvent)event;
//- (void)videoPlayer:(WBVideoPlayer*)videoPlayer didChangeSubtitleFrom:(NSString*)fronLang to:(NSString*)toLang;
//- (void)videoPlayer:(WBVideoPlayer*)videoPlayer willChangeOrientationTo:(UIInterfaceOrientation)orientation;
//- (void)videoPlayer:(WBVideoPlayer*)videoPlayer didChangeOrientationFrom:(UIInterfaceOrientation)orientation;
//
//- (void)handleErrorCode:(WBVideoPlayerErrorCode)errorCode track:(id<WBVideoPlayerTrackProtocol>)track customMessage:(NSString*)customMessage;
@end

//=========================================================
# pragma mark - WBVideoPlayerViewController Interface
//=========================================================
@interface WBVideoPlayerViewController : UIViewController <AVAssetResourceLoaderDelegate> {
@protected
	float                                    mRestoreAfterScrubbingRate;
	BOOL                                     seekToZeroBeforePlay;
	id                                       mTimeObserver;
	BOOL                                     isSeeking;
    NSTimeInterval                           playbackSyncStartTime;
    BOOL                                     hasSeekedToPlaybackSyncStartTime;
}

@property (nonatomic, weak)             id<WBVideoPlayerDelegate>        delegate;
@property (nonatomic, assign)           WBVideoPlayerState               state;
@property (nonatomic, readonly)         NSURL                           *URL;
@property (readwrite, strong)           AVQueuePlayer                   *player;
@property (strong)                      AVPlayerItem                    *playerItem;
@property (nonatomic, weak)   IBOutlet  WBVideoPlayerPlaybackView       *playbackView;
@property (readwrite, nonatomic)        NSInteger                        playerControlsAutoHideTime;

@property (weak, nonatomic)   IBOutlet  UIButton                        *shareButton;
@property (weak, nonatomic)   IBOutlet  UIButton                        *fullScreenButton;

/**
 * Toggles all player controls visibility.
 * NOTE: There is a difference between enabling/disableing and showing/hiding
 * player controls.
 * @see setPlayerControlsEnabled:
 * @see setPlayPauseVisible:
 */
@property (nonatomic, assign)           BOOL                             playerControlsVisible;

/**
 * Locks the top toolbar visibility so showing/hiding is not effective
 */
@property (nonatomic, assign)           BOOL                            lockTopToolbar;

@property (nonatomic, assign)           int                             indexMax;
@property (nonatomic, assign)           int                             curIndex;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)toggleFullScreen:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)handleTap:(UITapGestureRecognizer *)gestureRecognizer;
- (BOOL)isPlaying;
- (void)displayError:(NSError *)error;
- (CMTime)playerItemDuration;
- (void)playVideoWithURL:(NSURL *)url;
- (void)playVideoWithURL:(NSURL *)url startTime:(NSTimeInterval)time;
- (void)playVideo;
- (void)pauseVideo;
- (void)seekPlayerToTime:(CMTime)seekTime;
- (void)syncScrubber;
- (void)playerItemDidReachEnd:(NSNotification *)notification;

@end
