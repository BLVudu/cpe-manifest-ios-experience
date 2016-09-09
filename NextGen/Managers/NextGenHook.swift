//
//  NextGenHook.swift
//

import Foundation

public protocol NextGenHookDelegate {
    func nextGenExperienceWillClose()
    func nextGenExperienceWillEnterDebugMode()
    func videoPlayerWillClose(mode: VideoPlayerMode, playbackPosition: Double)
    func getProcessedVideoURL(url: NSURL, mode: VideoPlayerMode, completion: (url: NSURL?, startTime: Double) -> Void)
    func getUrlForContent(title: String, completion: (url: NSURL?) -> Void)
}

class NextGenHook {
    
    static var delegate: NextGenHookDelegate?
    
    static func experienceWillClose() {
        delegate?.nextGenExperienceWillClose()
        NextGenCacheManager.clearTempDirectory()
    }
    
}