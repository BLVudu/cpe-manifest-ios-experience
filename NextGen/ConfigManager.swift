//
//  ConfigManager.swift
//  NextGen
//
//  Created by Alec Ananian on 4/11/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import GoogleMaps

class ConfigManager {
    
    static let sharedInstance = ConfigManager()
    
    var hasTheTakeAPI = false
    var hasBaselineAPI = false
    var hasGoogleMaps = false
    
    func loadConfigs() {
        TheTakeAPIUtil.sharedInstance.mediaId = NextGenDataManager.sharedInstance.mainExperience.customIdentifier(kTheTakeIdentifierNamespace)
        BaselineAPIUtil.sharedInstance.projectId = NextGenDataManager.sharedInstance.mainExperience.customIdentifier(kBaselineIdentifierNamespace)
        
        if let configDataPath = NSBundle.mainBundle().pathForResource("Data/config", ofType: "json") {
            do {
                let configData = try NSData(contentsOfURL: NSURL(fileURLWithPath: configDataPath), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                if let configJSON = try NSJSONSerialization.JSONObjectWithData(configData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    if TheTakeAPIUtil.sharedInstance.mediaId != nil {
                        if let theTakeAPIKey = configJSON["thetake_api_key"] as? String {
                            TheTakeAPIUtil.sharedInstance.apiKey = theTakeAPIKey
                            TheTakeAPIUtil.sharedInstance.prefetchProductFrames(start: 0)
                            TheTakeAPIUtil.sharedInstance.prefetchProductCategories()
                            self.hasTheTakeAPI = true
                        }
                    }
                    
                    if BaselineAPIUtil.sharedInstance.projectId != nil {
                        if let baselineAPIKey = configJSON["baseline_api_key"] as? String {
                            BaselineAPIUtil.sharedInstance.apiKey = baselineAPIKey
                            self.hasBaselineAPI = true
                        }
                    }
                    
                    if let googleMapsAPIKey = configJSON["google_maps_api_key"] as? String {
                        GMSServices.provideAPIKey(googleMapsAPIKey)
                        self.hasGoogleMaps = true
                    }
                }
            } catch let error as NSError {
                print("Error parsing config data \(error.localizedDescription)")
            }
        }
    }
    
}