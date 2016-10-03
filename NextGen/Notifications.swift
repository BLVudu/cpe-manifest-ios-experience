//
//  Notifications.swift
//

import Foundation

extension Notification.Name {
    // Out-of-Movie Experience
    static let outOfMovieExperienceShouldLaunch = Notification.Name("nextgen.notifications.outOfMovieExperienceShouldLaunch")
    
    // In-Movie Experience
    static let inMovieExperienceWillCloseDetails = Notification.Name("nextgen.notifications.inMovieExperienceWillCloseDetails")
    
    // Video Player
    static let videoPlayerWillPlayNextItem = Notification.Name("nextgen.notifications.videoPlayerWillPlayNextItem")
    static let videoPlayerDidChangeTime = Notification.Name("nextgen.notifications.videoPlayerDidChangeTime")
    static let videoPlayerDidToggleFullScreen = Notification.Name("nextgen.notifications.videoPlayerDidToggleFullScreen")
    static let videoPlayerDidPlayMainExperience = Notification.Name("nextgen.notifications.videoPlayerDidPlayMainExperience")
    static let videoPlayerDidPlayVideo = Notification.Name("nextgen.notifications.videoPlayerDidPlayVideo")
    static let videoPlayerDidEndVideo = Notification.Name("nextgen.notifications.videoPlayerDidEndVideo")
    static let videoPlayerDidEndLastVideo = Notification.Name("nextgen.notifications.videoPlayerDidEndLastVideo")
    
    // Image Gallery
    static let imageGalleryDidScrollToPage = Notification.Name("nextgen.notifications.imageGalleryDidScrollToPage")
    static let imageGalleryDidToggleFullScreen = Notification.Name("nextgen.notifications.imageGalleryDidToggleFullScreen")
    
    // Locations
    static let locationsMapTypeDidChange = Notification.Name("nextgen.notifications.locationsMapTypeDidChange")
    
    // Shopping
    static let shoppingDidSelectCategory = Notification.Name("nextgen.notifications.shoppingDidSelectCategory")
    static let shoppingShouldCloseDetails = Notification.Name("nextgen.notifications.shoppingShouldCloseDetails")
}

struct NotificationConstants {
    static let categoryId = "categoryId"
    static let duration = "duration"
    static let index = "index"
    static let isFullScreen = "isFullScreen"
    static let mapType = "mapType"
    static let page = "page"
    static let time = "time"
    static let videoUrl = "videoUrl"
}
