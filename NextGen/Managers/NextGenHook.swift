//
//  NextGenHook.swift
//

import Foundation

public protocol NextGenHookDelegate {
    func nextGenExperienceWillClose()
    func nextGenExperienceWillEnterDebugMode()
    func videoPlayerWillClose(mode: VideoPlayerMode)
    func getProcessedVideoURL(url: NSURL, mode: VideoPlayerMode, completion: (url: NSURL?) -> Void)
    func getUrlForContent(title: String, completion: (url: NSURL?) -> Void)
}

class NextGenHook {
    
    static var delegate: NextGenHookDelegate?
    
    static func experienceWillClose() {
        delegate?.nextGenExperienceWillClose()
        NextGenCacheManager.clearTempDirectory()
    }
    
}