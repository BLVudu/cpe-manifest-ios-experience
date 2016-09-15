//
//  SettingsManager.swift
//

import Foundation

class SettingsManager {
    
    fileprivate struct UserDefaults {
        static let DidWatchVideo = "kUserDefaultsDidWatchVideo"
        static let DidWatchInterstitial = "kUserDefaultsDidWatchInterstitial"
    }
    
    static var didWatchInterstitial: Bool {
        get {
            return Foundation.UserDefaults.standard.bool(forKey: UserDefaults.DidWatchInterstitial)
        }
        
        set {
            Foundation.UserDefaults.standard.set(newValue, forKey: UserDefaults.DidWatchInterstitial)
        }
    }
    
    static func didWatchVideo(_ videoURL: URL) -> Bool {
        if let allVideos = Foundation.UserDefaults.standard.array(forKey: UserDefaults.DidWatchVideo) as? [String] {
            return allVideos.contains(videoURL.absoluteString)
        }
        
        return false
    }
    
    static func setVideoAsWatched(_ videoURL: URL) {
        var allVideos = (Foundation.UserDefaults.standard.array(forKey: UserDefaults.DidWatchVideo) as? [String]) ?? [String]()
        if !allVideos.contains(videoURL.absoluteString) {
            allVideos.append(videoURL.absoluteString)
        }
        
        Foundation.UserDefaults.standard.set(allVideos, forKey: UserDefaults.DidWatchVideo)
    }
    
}
