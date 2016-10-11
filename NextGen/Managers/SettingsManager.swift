//
//  SettingsManager.swift
//

import Foundation

class SettingsManager {
    
    private struct NextGenUserDefaults {
        static let DidWatchVideo = "kUserDefaultsDidWatchVideo"
        static let DidWatchInterstitial = "kUserDefaultsDidWatchInterstitial"
    }
    
    static var didWatchInterstitial: Bool {
        get {
            return UserDefaults.standard.bool(forKey: NextGenUserDefaults.DidWatchInterstitial)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: NextGenUserDefaults.DidWatchInterstitial)
        }
    }
    
    static func didWatchVideo(_ videoURL: URL) -> Bool {
        if let allVideos = UserDefaults.standard.array(forKey: NextGenUserDefaults.DidWatchVideo) as? [String] {
            return allVideos.contains(videoURL.absoluteString)
        }
        
        return false
    }
    
    static func setVideoAsWatched(_ videoURL: URL) {
        var allVideos = (UserDefaults.standard.array(forKey: NextGenUserDefaults.DidWatchVideo) as? [String]) ?? [String]()
        if !allVideos.contains(videoURL.absoluteString) {
            allVideos.append(videoURL.absoluteString)
        }
        
        UserDefaults.standard.set(allVideos, forKey: NextGenUserDefaults.DidWatchVideo)
    }
    
}
