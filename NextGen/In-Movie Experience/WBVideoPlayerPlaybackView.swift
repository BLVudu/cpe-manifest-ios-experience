//
//  WBVideoPlayerPlaybackView.m
//  Flixster
//
//  Fork of Apple's AVPlayerDemoPlaybackView.m
//

import Foundation

/* ---------------------------------------------------------
 **  To play the visual component of an asset, you need a view
 **  containing an AVPlayerLayer layer to which the output of an
 **  AVPlayer object can be directed. You can create a simple
 **  subclass of UIView to accommodate this. Use the view’s Core
 **  Animation layer (see the 'layer' property) for rendering.
 **  This class, AVPlayerPlaybackView, is a subclass of UIView
 **  that is used for this purpose.
 ** ------------------------------------------------------- */

class WBVideoPlayerPlaybackView {
    
    var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer? {
        if let layer = self.layer as? AVPlayerLayer {
            return layer
        }
        
        return nil
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer?.player
        }
        
        set {
            playerLayer?.player = newValue
        }
    }
    
    /* Specifies how the video is displayed within a player layer’s bounds.
     (AVLayerVideoGravityResizeAspect is default) */
    var videoFillMode: String? {
        get {
            return playerLayer?.videoGravity
        }
        
        set {
            playerLayer?.videoGravity = fillMode
        }
    }
}