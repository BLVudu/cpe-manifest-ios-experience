//
//  NextGenHook.swift
//

import Foundation

public struct NextGenAnalytics {
    struct Param {
        static let Action = "action"
        static let TitleId = "title_id"
        static let ItemId = "item_id"
        static let ItemName = "item_name"
    }
}

public enum NextGenAnalyticsEvent: String {
    case homeAction = "home_action"
    case extrasAction = "extras_action"
}

public enum NextGenAnalyticsAction: String {
    // General
    case exit = "exit"
    
    // Home
    case launchInMovie = "launch_ime"
    case launchExtras = "launch_extras"
    
    // Extras
    case selectTalent = "select_talent"
    case selectVideoGallery = "select_video_gallery"
    case selectImageGallery = "select_image_gallery"
    case selectSceneLocations = "select_scene_locations"
    case selectApp = "select_app"
    case selectShopping = "select_shopping"
    
    // TODO: SHOPPING
    // TODO: FULL IME
}

public protocol NextGenHookDelegate {
    // NextGen Experience status
    func nextGenExperienceWillClose()
    func nextGenExperienceWillEnterDebugMode()
    
    // Video Player callbacks
    func videoPlayerWillClose(_ mode: VideoPlayerMode, playbackPosition: Double)
    func getProcessedVideoURL(_ url: URL, mode: VideoPlayerMode, completion: @escaping (_ url: URL?, _ startTime: Double) -> Void)
    
    // Talent callbacks
    func getUrlForContent(_ title: String, completion: @escaping (_ url: URL?) -> Void)
    
    // Analytics
    func log(event: String, parameters: [String: String]?)
}

class NextGenHook {
    
    static var delegate: NextGenHookDelegate?
    
    static func experienceWillClose() {
        delegate?.nextGenExperienceWillClose()
        NextGenCacheManager.clearTempDirectory()
    }
    
    static func log(event: NextGenAnalyticsEvent, action: NextGenAnalyticsAction, itemId: String) {
        log(event: event, action: action, parameters: [NextGenAnalytics.Param.ItemId: itemId])
    }
    
    static func log(event: NextGenAnalyticsEvent, action: NextGenAnalyticsAction, parameters: [String: String]? = nil) {
        var allParameters = parameters ?? [String: String]()
        allParameters[NextGenAnalytics.Param.Action] = action.rawValue
        log(event: event.rawValue, parameters: allParameters)
    }
    
    static func log(event: String, parameters: [String: String]? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            delegate?.log(event: event, parameters: parameters)
        }
    }
    
}
