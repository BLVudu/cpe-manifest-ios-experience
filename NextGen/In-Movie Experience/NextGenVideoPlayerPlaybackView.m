//
//  NextGenVideoPlayerPlaybackView.m
//  Fork of Apple's AVPlayerDemoPlaybackView.m
//

#import "NextGenVideoPlayerPlaybackView.h"

/* ---------------------------------------------------------
**  To play the visual component of an asset, you need a view 
**  containing an AVPlayerLayer layer to which the output of an 
**  AVPlayer object can be directed. You can create a simple 
**  subclass of UIView to accommodate this. Use the view’s Core 
**  Animation layer (see the 'layer' property) for rendering.  
**  This class, AVPlayerPlaybackView, is a subclass of UIView  
**  that is used for this purpose.
** ------------------------------------------------------- */

@implementation NextGenVideoPlayerPlaybackView

+ (Class)layerClass {
	return [AVPlayerLayer class];
}

- (AVPlayer *)player {
	return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
	[(AVPlayerLayer *)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds. 
	(AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode {
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    [CATransaction setDisableActions:YES];
    playerLayer.videoGravity = fillMode;
    [CATransaction commit];
}

@end
