//
//  AppDelegate.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/7/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import HockeySDK

struct CurrentManifest {
    static var mainExperience: NGDMMainExperience!
    static var inMovieExperience: NGDMExperience!
    static var outOfMovieExperience: NGDMExperience!
    static var allAppData: [String: NGDMAppData]?
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier("d95d0b2a68ba4bb2b066c854a5c18c60")
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        
        application.statusBarHidden = true
        
        return true
    }

}
