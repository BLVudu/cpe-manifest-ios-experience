//
//  NextGenVideoPlayerPlaybackView.h
//  Fork of Apple's AVPlayerDemoPlaybackView.h
//

@import UIKit;
@import AVFoundation;

@interface NextGenVideoPlayerPlaybackView : UIView

@property (nonatomic, strong) AVPlayer *player;

- (void)setPlayer:(AVPlayer *)player;
- (void)setVideoFillMode:(NSString *)fillMode;
- (NSString *)videoFillMode;

@end
