//
//  NextGenCacheManager.swift
//

import Foundation

class NextGenCacheManager {
    
    private struct Constants {
        static let CacheParentDirectory = "NextGen"
    }
    
    private static var tempDirectoryURL: NSURL? {
        let directoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(Constants.CacheParentDirectory, isDirectory: true)
        
        var isDirectory: ObjCBool = false
        if let path = directoryURL.path where NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory) {
            if isDirectory {
                return directoryURL
            }
        }
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating temp directory: \(error)")
            return nil
        }
        
        return directoryURL
    }
    
    private static var applicationSupportDirectoryURL: NSURL? {
        let paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        if let path = paths.first {
            return NSURL(fileURLWithPath: path, isDirectory: true)
        }
        
        return nil
    }
    
    private static func fileNameForURL(remoteURL: NSURL) -> String? {
        if let fileName = remoteURL.path?.characters.split("/").last {
            return String(fileName)
        }
        
        return nil
    }
    
    static func tempFileURL(remoteURL: NSURL) -> NSURL? {
        if let fileName = fileNameForURL(remoteURL) {
            return tempDirectoryURL?.URLByAppendingPathComponent(fileName)
        }
        
        return nil
    }
    
    static func applicationSupportFileURL(remoteURL: NSURL) -> NSURL? {
        if let fileName = fileNameForURL(remoteURL) {
            return applicationSupportDirectoryURL?.URLByAppendingPathComponent(fileName)
        }
        
        return nil
    }
    
    static func fileExists(fileURL: NSURL) -> Bool {
        if let path = fileURL.path {
            return NSFileManager.defaultManager().fileExistsAtPath(path)
        }
        
        return false
    }
    
    static func storeTempFile(remoteURL: NSURL) {
        NSURLSession.sharedSession().downloadTaskWithURL(remoteURL, completionHandler: { (location, response, error) in
            if error != nil {
                print("Error downloading temp file: \(error)")
            } else if let sourceURL = location, destinationURL = NextGenCacheManager.tempFileURL(remoteURL) {
                do {
                    try NSFileManager.defaultManager().moveItemAtURL(sourceURL, toURL: destinationURL)
                } catch let error as NSError {
                    print("Error moving temp file: \(error)")
                }
            }
        }).resume()
    }
    
    static func storeApplicationSupportFile(remoteURL: NSURL, completionHandler: (localFileURL: NSURL?) -> Void) {
        NSURLSession.sharedSession().downloadTaskWithURL(remoteURL, completionHandler: { (location, response, error) in
            if error != nil {
                print("Error downloading application support file: \(error)")
                completionHandler(localFileURL: nil)
            } else if let sourceURL = location, destinationURL = NextGenCacheManager.applicationSupportFileURL(remoteURL) {
                do {
                    try NSFileManager.defaultManager().moveItemAtURL(sourceURL, toURL: destinationURL)
                    completionHandler(localFileURL: destinationURL)
                } catch let error as NSError {
                    if error.code == NSFileWriteFileExistsError {
                        do {
                            try NSFileManager.defaultManager().replaceItemAtURL(destinationURL, withItemAtURL: sourceURL, backupItemName: nil, options: .UsingNewMetadataOnly, resultingItemURL: nil)
                            completionHandler(localFileURL: destinationURL)
                        } catch {
                            print("Error replacing application support file: \(error)")
                            completionHandler(localFileURL: nil)
                        }
                    } else {
                        print("Error moving application support file: \(error)")
                        completionHandler(localFileURL: nil)
                    }
                }
            }
        }).resume()
    }
    
    static func clearTempDirectory() {
        if let tempDirectoryURL = tempDirectoryURL {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(tempDirectoryURL)
            } catch {
                print("Error deleting temp directory: \(error)")
            }
        }
    }
    
}