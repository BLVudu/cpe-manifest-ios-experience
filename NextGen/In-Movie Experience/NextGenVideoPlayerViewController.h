//
//  NextGenVideoPlayerViewController.m
//  Fork of Apple's AVPlayerDemoPlaybackViewController.m
//


@import UIKit;
@import AVFoundation;

@class NextGenVideoPlayerPlaybackView, NextGenVideoPlayerViewController;

//=========================================================
# pragma mark - enums
//=========================================================
typedef NS_ENUM(NSInteger, NextGenVideoPlayerState) {
    NextGenVideoPlayerStateUnknown,
    NextGenVideoPlayerStateReadyToPlay,
    NextGenVideoPlayerStateVideoLoading,
    NextGenVideoPlayerStateVideoSeeking,
    NextGenVideoPlayerStateVideoPlaying,
    NextGenVideoPlayerStateVideoPaused,
    NextGenVideoPlayerStateSuspend,
    NextGenVideoPlayerStateDismissed,
    NextGenVideoPlayerStateError
};

//=========================================================
# pragma mark - Constants
//=========================================================
static NSString * const kNextGenVideoPlayerItemDurationDidLoadNotification       = @"kNextGenVideoPlayerItemDurationDidLoadNotification";
static NSString * const kNextGenVideoPlayerItemReadyToPlayNotification           = @"kNextGenVideoPlayerItemReadyToPlayNotification";
static NSString * const kNextGenVideoPlayerPlaybackStateDidChangeNotification    = @"kNextGenVideoPlayerPlaybackStateDidChangeNotification";
static NSString * const kNextGenVideoPlayerPlaybackBufferEmptyNotification       = @"kNextGenVideoPlayerPlaybackBufferEmptyNotification";
static NSString * const kNextGenVideoPlayerPlaybackLikelyToKeepUpNotification    = @"kNextGenVideoPlayerPlaybackLikelyToKeepUpNotification";

//=========================================================
# pragma mark -
# pragma mark - NextGenVideoPlayerDelegate
//=========================================================
@protocol NextGenVideoPlayerDelegate <NSObject>
@optional

- (void)videoPlayer:(NextGenVideoPlayerViewController *)videoPlayer isBuffering:(BOOL)buffering;

@end

//=========================================================
# pragma mark - NextGenVideoPlayerViewController Interface
//=========================================================
@interface NextGenVideoPlayerViewController : UIViewController <AVAssetResourceLoaderDelegate> {
@protected
	float                                    mRestoreAfterScrubbingRate;
	id                                       mTimeObserver;
	BOOL                                     isSeeking;
    NSTimeInterval                           playbackSyncStartTime;
    BOOL                                     hasSeekedToPlaybackSyncStartTime;
}

@property (nonatomic, weak)             id<NextGenVideoPlayerDelegate>  delegate;
@property (nonatomic, assign)           NextGenVideoPlayerState         state;
@property (nonatomic, readonly)         NSURL                           *URL;
@property (readwrite, strong)           AVQueuePlayer                   *player;
@property (strong)                      AVPlayerItem                    *playerItem;
@property (nonatomic, weak)   IBOutlet  NextGenVideoPlayerPlaybackView  *playbackView;
@property (readwrite, nonatomic)        NSInteger                       playerControlsAutoHideTime;
@property (strong, nonatomic)           NSTimer                         *playerControlsAutoHideTimer;
@property (weak, nonatomic)   IBOutlet  UIView                          *topToolbar;
@property (weak, nonatomic)   IBOutlet  UIView                          *playbackToolbar;
@property (weak, nonatomic)   IBOutlet  UIButton                        *fullScreenButton;
@property (weak, nonatomic)   IBOutlet  UITapGestureRecognizer          *tapGestureRecognizer;
@property (nonatomic, assign)           BOOL                            isFullScreen;

/**
 * Toggles all player controls visibility.
 * NOTE: There is a difference between enabling/disableing and showing/hiding
 * player controls.
 * @see setPlayerControlsEnabled:
 * @see setPlayPauseVisible:
 */
@property (nonatomic, assign)           BOOL                             playerControlsVisible;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
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
- (void)initAutoHideTimer;

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;

@end
