//
//  WBVideoPlayerExtensions.swift
//  Flixster
//
//  Created by Imran Saadi on 8/9/15.
//  Copyright (c) 2015 Flixster, Inc. All rights reserved.
//

import Foundation

extension NSString {
    public static func stringFromVideoPlayerState(videoPlayerState: WBVideoPlayerState) -> NSString {
        switch videoPlayerState {
            case .Unknown:
                return "WBVideoPlayerStateUnknown"
            case .ReadyToPlay:
                return "WBVideoPlayerStateReadyToPlay"
            case .VideoLoading:
                return "WBVideoPlayerStateVideoLoading"
            case .VideoSeeking:
                return "WBVideoPlayerStateVideoSeeking"
            case .VideoPlaying:
                return "WBVideoPlayerStateVideoPlaying"
            case .VideoPaused:
                return "WBVideoPlayerStateVideoPaused"
            case .Suspend:
                return "WBVideoPlayerStateSuspend"
            case .Dismissed:
                return "WBVideoPlayerStateDismissed"
            case .Error:
                return "WBVideoPlayerStateError"
        }
    }
}