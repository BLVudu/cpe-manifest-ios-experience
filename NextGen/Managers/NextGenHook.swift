//
//  NextGenHook.swift
//

import Foundation

public protocol NextGenHookDelegate {
    func nextGenExperienceWillClose()
    func videoPlayerWillClose(mode: VideoPlayerMode)
    func getProcessedVideoURL(url: NSURL, mode: VideoPlayerMode, completion: (url: NSURL?) -> Void)
}

class NextGenHook {
    
    static var delegate: NextGenHookDelegate?
    
}