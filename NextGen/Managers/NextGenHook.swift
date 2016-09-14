//
//  NextGenHook.swift
//

import Foundation

public protocol NextGenHookDelegate {
    func nextGenExperienceWillClose()
    func nextGenExperienceWillEnterDebugMode()
    func videoPlayerWillClose(_ mode: VideoPlayerMode, playbackPosition: Double)
    func getProcessedVideoURL(_ url: URL, mode: VideoPlayerMode, completion: (_ url: URL?, _ startTime: Double) -> Void)
    func getUrlForContent(_ title: String, completion: (_ url: URL?) -> Void)
}

class NextGenHook {
    
    static var delegate: NextGenHookDelegate?
    
    static func experienceWillClose() {
        delegate?.nextGenExperienceWillClose()
        NextGenCacheManager.clearTempDirectory()
    }
    
}
