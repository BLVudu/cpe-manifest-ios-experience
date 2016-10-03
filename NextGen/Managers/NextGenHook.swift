//
//  NextGenHook.swift
//

import Foundation

public enum NextGenAnalyticsEvent: String {
    case homeAction = "home_action"
    case extrasAction = "extras_action"
    case extrasTalentAction = "extras_talent_action"
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
    
    // Talent
    case selectGallery = "select_gallery"
    case selectSocial = "select_social"
    case selectFilm = "select_film"
    
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
    func logAnalyticsEvent(_ event: NextGenAnalyticsEvent, action: NextGenAnalyticsAction, itemId: String?, itemName: String?)
}

class NextGenHook {
    
    static var delegate: NextGenHookDelegate?
    
    static func experienceWillClose() {
        delegate?.nextGenExperienceWillClose()
        NextGenCacheManager.clearTempDirectory()
    }
    
    static func logAnalyticsEvent(_ event: NextGenAnalyticsEvent, action: NextGenAnalyticsAction, itemId: String? = nil, itemName: String? = nil) {
        delegate?.logAnalyticsEvent(event, action: action, itemId: itemId, itemName: itemName)
    }
    
}
