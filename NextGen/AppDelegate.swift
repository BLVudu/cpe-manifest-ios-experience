//
//  AppDelegate.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/7/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit
import CoreData
import HockeySDK


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    let charSet = NSCharacterSet.URLQueryAllowedCharacterSet()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Load current film's data file
        if let metadataPath = NSBundle.mainBundle().pathForResource("Data/mos_timeline_v2", ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: metadataPath), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                DataManager.sharedInstance.loadData(data)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }

        if let xmlPath = NSBundle.mainBundle().pathForResource("Data/mos_hls_manifest_v3", ofType: "xml") {
            NextGenDataManager.sharedInstance.loadXMLFile(xmlPath)
            
            TheTakeAPIUtil.sharedInstance.mediaId = NextGenDataManager.sharedInstance.mainExperience.customIdentifier(kTheTakeIdentifierNamespace)
            BaselineAPIUtil.sharedInstance.projectId = NextGenDataManager.sharedInstance.mainExperience.customIdentifier(kBaselineIdentifierNamespace)
            
            if let configDataPath = NSBundle.mainBundle().pathForResource("Data/config", ofType: "json") {
                do {
                    let configData = try NSData(contentsOfURL: NSURL(fileURLWithPath: configDataPath), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if let configJSON = try NSJSONSerialization.JSONObjectWithData(configData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        if let theTakeAPIKey = configJSON["thetake_api_key"] as? String {
                            TheTakeAPIUtil.sharedInstance.apiKey = theTakeAPIKey
                            TheTakeAPIUtil.sharedInstance.prefetchProductFrames(start: 0)
                            TheTakeAPIUtil.sharedInstance.prefetchProductCategories()
                        }
                        
                        if let baselineAPIKey = configJSON["baseline_api_key"] as? String {
                            BaselineAPIUtil.sharedInstance.apiKey = baselineAPIKey
                        }
                    }
                } catch let error as NSError {
                    print("Error parsing config data \(error.localizedDescription)")
                }
            }
            
            NextGenDataManager.sharedInstance.mainExperience.loadTalent()
        }
 
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier("d95d0b2a68ba4bb2b066c854a5c18c60")
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        
        application.statusBarHidden = true
        
        return true
    }

}

