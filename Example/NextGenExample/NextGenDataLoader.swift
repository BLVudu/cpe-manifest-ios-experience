//
//  NextGenDataLoader.swift
//

import Foundation
import UIKit
import GoogleMaps
import NextGenDataManager
import PromiseKit

@objc class NextGenDataLoader: NSObject, NextGenHookDelegate {
    
    private enum DataLoaderError: Error {
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
            "manifest": "urn:dece:cid:eidr-s:DAFF-8AB8-3AF0-FD3A-29EF-Q/mos_manifest-2.2.xml",
            "appdata": "urn:dece:cid:eidr-s:DAFF-8AB8-3AF0-FD3A-29EF-Q/mos_appdata_locations-2.2.xml",
            "cpestyle": "urn:dece:cid:eidr-s:DAFF-8AB8-3AF0-FD3A-29EF-Q/mos_cpestyle-2.2.xml"
        ],
        "urn:dece:cid:eidr-s:B257-8696-871C-A12B-B8C1-S": [
            "title": "Batman v Superman",
            "image": "BvS-Onesheet",
            "manifest": "urn:dece:cid:eidr-s:B257-8696-871C-A12B-B8C1-S/bvs_manifest-2.2.xml",
            "appdata": "urn:dece:cid:eidr-s:B257-8696-871C-A12B-B8C1-S/bvs_appdata_locations-2.2.xml",
            "cpestyle": "urn:dece:cid:eidr-s:B257-8696-871C-A12B-B8C1-S/bvs_cpestyle-2.2.xml"
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
        if let configDataPath = Bundle.main.path(forResource: "Data/config", ofType: "json") {
            do {
                let configData = try NSData(contentsOf: URL(fileURLWithPath: configDataPath), options: NSData.ReadingOptions.mappedIfSafe)
                if let configJSON = try JSONSerialization.jsonObject(with: configData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    if let key = configJSON[Constants.ConfigKey.TheTakeAPI] as? String {
                        TheTakeAPIUtil.sharedInstance.apiKey = key
                    }
                    
                    if let key = configJSON[Constants.ConfigKey.BaselineAPI] as? String {
                        NGDMConfiguration.talentAPIUtil = BaselineAPIUtil(apiKey: key)
                    }
                    
                    if let key = configJSON[Constants.ConfigKey.GoogleMapsAPI] as? String {
                        GMSServices.provideAPIKey(key)
                        NGDMConfiguration.mapService = .googleMaps
                    }
                }
            } catch let error as NSError {
                print("Error parsing config data \(error.localizedDescription)")
            }
        } else {
            print("Configuration file not found")
        }
    }
    
    func loadTitle(cid: String, completionHandler: @escaping (_ success: Bool) -> Void) throws {
        guard let titleData = NextGenDataLoader.ManifestData[cid] else { throw DataLoaderError.TitleNotFound }
        
        guard let manifestFileName = titleData["manifest"] else { throw NGDMError.manifestMissing }
        loadXMLFile(fileName: manifestFileName).then { localFilePath -> Void in
            do {
                NGDMManifest.createInstance()
                
                try NGDMManifest.sharedInstance.loadManifestXMLFile(localFilePath)
                
                if TheTakeAPIUtil.sharedInstance.apiKey != nil, let mediaId = NGDMManifest.sharedInstance.mainExperience?.customIdentifier(Namespaces.TheTake) {
                    TheTakeAPIUtil.sharedInstance.mediaId = mediaId
                    TheTakeAPIUtil.sharedInstance.prefetchProductFrames(start: 0)
                    TheTakeAPIUtil.sharedInstance.prefetchProductCategories()
                }
                
                if var talentAPIUtil = NGDMConfiguration.talentAPIUtil {
                    talentAPIUtil.apiId = NGDMManifest.sharedInstance.mainExperience?.customIdentifier(Namespaces.Baseline)
                }
                
                NGDMManifest.sharedInstance.mainExperience?.loadTalent()
            } catch NGDMError.mainExperienceMissing {
                print("Error loading Manifest file: no main Experience found")
                abort()
            } catch NGDMError.inMovieExperienceMissing {
                print("Error loading Manifest file: no in-movie Experience found")
                abort()
            } catch NGDMError.outOfMovieExperienceMissing {
                print("Error loading Manifest file: no out-of-movie Experience found")
                abort()
            } catch {
                print("Error loading Manifest file: unknown error")
                abort()
            }
            
            var promises = [Promise<String>]()
            var hasAppData = false
            
            if let appDataFileName = titleData["appdata"] {
                promises.append(self.loadXMLFile(fileName: appDataFileName))
                hasAppData = true
            }
            
            if let cpeStyleFileName = titleData["cpestyle"] {
                promises.append(self.loadXMLFile(fileName: cpeStyleFileName))
            }
            
            if promises.count > 0 {
                _ = when(fulfilled: promises).then(on: DispatchQueue.global(qos: .userInitiated), execute: { results -> Void in
                    var appDataFilePath: String?
                    var cpeStyleFilePath: String?
                    if hasAppData {
                        appDataFilePath = results.first
                        if results.count > 1 {
                            cpeStyleFilePath = results.last
                        }
                    } else {
                        cpeStyleFilePath = results.first
                    }
                    
                    if let localFilePath = appDataFilePath {
                        do {
                            NGDMManifest.sharedInstance.appData = try NGDMManifest.sharedInstance.loadAppDataXMLFile(localFilePath)
                        } catch {
                            print("Error loading AppData file")
                        }
                    }
                    
                    if let localFilePath = cpeStyleFilePath {
                        do {
                            try NGDMManifest.sharedInstance.loadCPEStyleXMLFile(localFilePath)
                        } catch {
                            print ("Error loading CPE-Style file")
                        }
                    }
                    
                    self.currentCid = cid
                    completionHandler(true)
                })
            } else {
                self.currentCid = cid
                completionHandler(true)
            }
        }.catch { error in
            completionHandler(false)
        }
    }
    
    private func loadXMLFile(fileName: String) -> Promise<String> {
        return Promise { fulfill, reject in
            if let remoteURL = URL(string: Constants.XMLBaseURI + "/" + fileName), let applicationSupportFileURL = NextGenCacheManager.applicationSupportFileURL(remoteURL) {
                if NextGenCacheManager.fileExists(applicationSupportFileURL) {
                    fulfill(applicationSupportFileURL.path)
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
        
        UIApplication.shared.setStatusBarHidden(false, with: .slide)
    }
    
    func nextGenExperienceWillEnterDebugMode() {
        // Perform any debug tasks or unlock any debug sections of the app
        // Debug mode is activated by tapping and holding the "Extras" button on the home screen for five seconds
    }
    
    func videoPlayerWillClose(_ mode: VideoPlayerMode, playbackPosition: Double) {
        // Handle end of playback
    }
    
    func getProcessedVideoURL(_ url: URL, mode: VideoPlayerMode, completion: @escaping (URL?, Double) -> Void) {
        // Handle DRM
        completion(url, 0)
    }
    
    func getUrlForContent(_ title: String, completion: @escaping (_ url: URL?) -> Void) {
        if let encodedTitleName = title.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "-", with: "").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            completion(URL(string: "http://www.vudu.com/movies/#search/" + encodedTitleName))
        } else {
            completion(nil)
        }
    }
    
    func logAnalyticsEvent(_ event: NextGenAnalyticsEvent, action: NextGenAnalyticsAction, itemId: String?, itemName: String?) {
        // Adjust values as needed for your analytics implementation
    }
    
}
