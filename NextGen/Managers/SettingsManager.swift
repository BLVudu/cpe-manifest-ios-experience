//
//  SettingsManager.swift
//

import Foundation

class SettingsManager {
    
    private struct UserDefaults {
        static let DidWatchVideo = "kUserDefaultsDidWatchVideo"
    }
    
    static func didWatchVideo(videoURL: NSURL) -> Bool {
        if let allVideos = NSUserDefaults.standardUserDefaults().arrayForKey(UserDefaults.DidWatchVideo) as? [String] {
            return allVideos.contains(videoURL.absoluteString)
        }
        
        return false
    }
    
    static func setVideoAsWatched(videoURL: NSURL) {
        var allVideos = (NSUserDefaults.standardUserDefaults().arrayForKey(UserDefaults.DidWatchVideo) as? [String]) ?? [String]()
        if !allVideos.contains(videoURL.absoluteString) {
            allVideos.append(videoURL.absoluteString)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(allVideos, forKey: UserDefaults.DidWatchVideo)
    }
    
}