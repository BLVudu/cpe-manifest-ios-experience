//
//  AppDelegate.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/7/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    let charSet = NSCharacterSet.URLQueryAllowedCharacterSet()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Load current film's data file
        if let xmlPath = NSBundle.mainBundle().pathForResource("Data/mos_hls_manifest_v3", ofType: "xml") {
            NextGenDataManager.sharedInstance.loadXMLFile(xmlPath)
            ConfigManager.sharedInstance.loadConfigs()
            NextGenDataManager.sharedInstance.mainExperience.loadTalent()
        }
        
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier("d95d0b2a68ba4bb2b066c854a5c18c60")
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        
        application.statusBarHidden = true
        
        return true
    }

}
