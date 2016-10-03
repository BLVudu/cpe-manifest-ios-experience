//
//  NextGenHook.swift
//

import Foundation

public enum NextGenAnalyticsEvent: String {
    case homeAction = "home_action"
    case extrasAction = "extras_action"
    case extrasTalentAction = "extras_talent_action"
    case extrasTalentGalleryAction = "extras_talent_gallery_action"
    case extrasVideoGalleryAction = "extras_video_gallery_action"
    case extrasImageGalleryAction = "extras_image_gallery_action"
    case extrasSceneLocationsAction = "extras_scene_locations_action"
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
    case selectImageGalleries = "select_image_galleries"
    case selectSceneLocations = "select_scene_locations"
    case selectApp = "select_app"
    case selectShopping = "select_shopping"
    
    // Talent
    case selectGallery = "select_gallery"
    case selectSocial = "select_social"
    case selectFilm = "select_film"
    case selectImage = "select_image"
    
    // Galleries
    case selectVideo = "select_video"
    case setVideoFullScreen = "set_video_full_screen"
    case selectImageGallery = "select_image_gallery"
    case setImageGalleryFullScreen = "set_image_gallery_full_screen"
    case scrollImageGallery = "scroll_image_gallery"
    case shareImage = "share_image"
    
    // Locations
    case setMapType = "set_map_type"
    case selectLocationMarker = "select_location_marker"
    case selectLocationThumbnail = "select_location_thumbnail"
    
    // TODO: SHOPPING
    // TODO: FULL IME
}

struct NextGenAnalyticsLabel {
    // Locations
    static let road = "road"
    static let satellite = "satellite"
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
