//
//  NextGenDataLoader.swift
//

import Foundation
import UIKit
import GoogleMaps
import NextGenDataManager
import PromiseKit

@objc class NextGenDataLoader: NSObject, NextGenHookDelegate {
    
    private enum DataLoaderError: ErrorType {
        case TitleNotFound
        case FileMissing
    }
    
    private struct Constants {
        static let XMLBaseURI = "https://your-domain.com"
        
        struct ConfigKey {
            static let TheTakeAPI = "thetake_api_key"
            static let BaselineAPI = "baseline_api_key"
            static let GoogleMapsAPI = "google_maps_api_key"
        }
    }
    
    static let ManifestData = [
        "urn:dece:cid:eidr-s:DAFF-8AB8-3AF0-FD3A-29EF-Q": [
            "title": "Man of Steel",
            "image": "MOS-Onesheet",
            "manifest": "mos_hls_manifest_r60-v2.0.xml",
            "appdata": "mos_appdata_locations_r60-v2.0.xml",
            "cpestyle": "mos_cpestyle-v0.1.xml"
        ],
        "urn:dece:cid:eidr-s:B257-8696-871C-A12B-B8C1-S": [
            "title": "Batman v Superman",
            "image": "BvS-Onesheet",
            "manifest": "bvs_manifest_r60-v2.0.xml",
            "appdata": "bvs_appdata_locations_r60-v2.0.xml",
            "cpestyle": "bvs_cpestyle-v0.1.xml"
        ],
        "urn:dece:cid:eidr-s:D2E8-4520-9446-BFAD-B106-4": [
            "title": "Sisters (Unrated)",
            "image": "SistersUnrated-Onesheet",
            "manifest": "sisters_extended_hls_manifest_v3-generated-spec1.5.xml"
        ],
        "urn:dece:cid:eidr-s:F1F8-3CDA-0844-0D78-E520-Q": [
            "title": "Minions",
            "image": "Minions-Onesheet",
            "manifest": "minions_hls_manifest_v6-R60-generated-spec1.5.xml"
        ]
    ]
    
    static func supportsContent(cid: String) -> Bool {
        return ManifestData[cid] != nil
    }
    
    static let sharedInstance = NextGenDataLoader()
    private var currentCid: String?
    
    override init() {
        super.init()
        
        NextGenHook.delegate = self
    }
    
    func loadConfig() {
        // Load configuration file
        if let configDataPath = NSBundle.mainBundle().pathForResource("Data/config", ofType: "json") {
            do {
                let configData = try NSData(contentsOfURL: NSURL(fileURLWithPath: configDataPath), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                if let configJSON = try NSJSONSerialization.JSONObjectWithData(configData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    if let key = configJSON[Constants.ConfigKey.TheTakeAPI] as? String {
                        TheTakeAPIUtil.sharedInstance.apiKey = key
                    }
                    
                    if let key = configJSON[Constants.ConfigKey.BaselineAPI] as? String {
                        NGDMConfiguration.talentAPIUtil = BaselineAPIUtil(apiKey: key)
                    }
                    
                    if let key = configJSON[Constants.ConfigKey.GoogleMapsAPI] as? String {
                        GMSServices.provideAPIKey(key)
                        NGDMConfiguration.mapService = .GoogleMaps
                    }
                }
            } catch let error as NSError {
                print("Error parsing config data \(error.localizedDescription)")
            }
        } else {
            print("Configuration file not found")
        }
    }
    
    func loadTitle(cid: String, completionHandler: (success: Bool) -> Void) throws {
        guard let titleData = NextGenDataLoader.ManifestData[cid] else { throw DataLoaderError.TitleNotFound }
        
        guard let manifestFileName = titleData["manifest"] else { throw NGDMError.ManifestMissing }
        loadXMLFile(manifestFileName).then { localFilePath -> Void in
            do {
                NGDMManifest.createInstance()
                
                try NGDMManifest.sharedInstance.loadManifestXMLFile(localFilePath)
                NGDMManifest.sharedInstance.mainExperience?.appearance = NGDMAppearance(type: .Main)
                
                NGDMManifest.sharedInstance.inMovieExperience?.appearance = NGDMAppearance(type: .InMovie)
                NGDMManifest.sharedInstance.outOfMovieExperience?.appearance = NGDMAppearance(type: .OutOfMovie)
                
                if TheTakeAPIUtil.sharedInstance.apiKey != nil, let mediaId = NGDMManifest.sharedInstance.mainExperience?.customIdentifier(Namespaces.TheTake) {
                    TheTakeAPIUtil.sharedInstance.mediaId = mediaId
                    TheTakeAPIUtil.sharedInstance.prefetchProductFrames(start: 0)
                    TheTakeAPIUtil.sharedInstance.prefetchProductCategories()
                }
                
                if var talentAPIUtil = NGDMConfiguration.talentAPIUtil {
                    talentAPIUtil.apiId = NGDMManifest.sharedInstance.mainExperience?.customIdentifier(Namespaces.Baseline)
                }
                
                NGDMManifest.sharedInstance.mainExperience?.loadTalent()
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
            
            var promises = [Promise<String>]()
            var hasAppData = false
            
            if let appDataFileName = titleData["appdata"] {
                promises.append(self.loadXMLFile(appDataFileName))
                hasAppData = true
            }
            
            if let cpeStyleFileName = titleData["cpestyle"] {
                promises.append(self.loadXMLFile(cpeStyleFileName))
            }
            
            if promises.count > 0 {
                join(promises).then { results -> Void in
                    if var localFilePath = results.first {
                        if hasAppData {
                            do {
                                NGDMManifest.sharedInstance.appData = try NGDMManifest.sharedInstance.loadAppDataXMLFile(localFilePath)
                            } catch {
                                print("Error loading AppData file")
                            }
                            
                            if results.count > 1 {
                                localFilePath = results.last!
                            }
                        }
                        
                        do {
                            try NGDMManifest.sharedInstance.loadCPEStyleXMLFile(localFilePath)
                        } catch {
                            print ("Error loading CPE-Style file")
                        }
                    }
                    
                    self.currentCid = cid
                    completionHandler(success: true)
                }
            } else {
                self.currentCid = cid
                completionHandler(success: true)
            }
            }.error { error -> Void in
                completionHandler(success: false)
        }
    }
    
    private func loadXMLFile(fileName: String) -> Promise<String> {
        return Promise { fulfill, reject in
            if let remoteURL = NSURL(string: Constants.XMLBaseURI + "/" + fileName), applicationSupportFileURL = NextGenCacheManager.applicationSupportFileURL(remoteURL) {
                if NextGenCacheManager.fileExists(applicationSupportFileURL), let filePath = applicationSupportFileURL.path {
                    fulfill(filePath)
                    NextGenCacheManager.storeApplicationSupportFile(remoteURL, completionHandler: { (localFileURL) in
                        
                    })
                } else {
                    NextGenCacheManager.storeApplicationSupportFile(remoteURL, completionHandler: { (localFileURL) in
                        if let filePath = localFileURL?.path {
                            fulfill(filePath)
                        } else {
                            reject(DataLoaderError.FileMissing)
                        }
                    })
                }
            } else {
                reject(DataLoaderError.FileMissing)
            }
        }
    }
    
    // MARK: NextGenHookDelegate
    func nextGenExperienceWillClose() {
        NGDMManifest.destroyInstance()
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
    }
    
    func nextGenExperienceWillEnterDebugMode() {
        // Perform any debug tasks or unlock any debug sections of the app
        // Debug mode is activated by tapping and holding the "Extras" button on the home screen for five seconds
    }
    
    func videoPlayerWillClose(mode: VideoPlayerMode) {
        // Handle end of playback
    }
    
    func getProcessedVideoURL(url: NSURL, mode: VideoPlayerMode, completion: (url: NSURL?) -> Void) {
        // Handle DRM
        completion(url: url)
    }
    
    func getUrlForContent(title: String, completion: (url: NSURL?) -> Void) {
        if let encodedTitleName = title.stringByReplacingOccurrencesOfString(":", withString: "").stringByReplacingOccurrencesOfString("-", withString: "").stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
            completion(url: NSURL(string: "http://www.vudu.com/movies/#search/" + encodedTitleName))
        } else {
            completion(url: nil)
        }
    }
    
}