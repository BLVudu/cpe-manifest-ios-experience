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
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Load current film's data file
        if let xmlPath = NSBundle.mainBundle().pathForResource("Data/mos_hls_manifest_v3", ofType: "xml") {
            NextGenDataManager.sharedInstance.loadXMLFile(xmlPath)
            
            do {
                CurrentManifest.mainExperience = try NextGenDataManager.sharedInstance.getMainExperience()
                CurrentManifest.mainExperience.appearance = NGDMAppearance(type: .Main)
                CurrentManifest.inMovieExperience = try CurrentManifest.mainExperience.getInMovieExperience()
                CurrentManifest.inMovieExperience.appearance = NGDMAppearance(type: .InMovie)
                CurrentManifest.outOfMovieExperience = try CurrentManifest.mainExperience.getOutOfMovieExperience()
                CurrentManifest.outOfMovieExperience.appearance = NGDMAppearance(type: .OutOfMovie)
                
                TheTakeAPIUtil.sharedInstance.mediaId = CurrentManifest.mainExperience.customIdentifier(kTheTakeIdentifierNamespace)
                BaselineAPIUtil.sharedInstance.projectId = CurrentManifest.mainExperience.customIdentifier(kBaselineIdentifierNamespace)
                ConfigManager.sharedInstance.loadConfigs()
                CurrentManifest.mainExperience.loadTalent()
            } catch NGDMError.MainExperienceMissing {
                print("Error loading Manifest file: no main Experience found")
                abort()
            } catch NGDMError.InMovieExperienceMissing {
                print("Error loading Manifest file: no in-movie Experience found")
                abort()
            } catch NGDMError.OutOfMovieExperienceMissing {
                print("Error loading Manifest file: no out-of-movie Experience found")
                abort()
            } catch {
                print("Error loading Manifest file: unknown error")
                abort()
            }
        }
        
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier("d95d0b2a68ba4bb2b066c854a5c18c60")
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        
        application.statusBarHidden = true
        
        return true
    }

}
