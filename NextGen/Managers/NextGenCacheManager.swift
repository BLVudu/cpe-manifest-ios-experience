//
//  NextGenCacheManager.swift
//

import Foundation

class NextGenCacheManager {
    
    private struct Constants {
        static let CacheParentDirectory = "NextGen"
    }
    
    static var tempDirectoryURL: NSURL? {
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
    
    static func tempFileURL(remoteURL: NSURL) -> NSURL? {
        if let fileName = remoteURL.path?.characters.split("/").last {
            return tempDirectoryURL?.URLByAppendingPathComponent(String(fileName))
        }
        
        return nil
    }
    
    static func tempFileExists(fileURL: NSURL) -> Bool {
        if let path = fileURL.path {
            return NSFileManager.defaultManager().fileExistsAtPath(path)
        }
        
        return false
    }
    
    static func storeTempFile(remoteURL: NSURL) {
        if !tempFileExists(remoteURL) {
            NSURLSession.sharedSession().downloadTaskWithURL(remoteURL, completionHandler: { (location, response, error) in
                if let sourceURL = location, destinationURL = NextGenCacheManager.tempFileURL(remoteURL) {
                    do {
                        try NSFileManager.defaultManager().moveItemAtURL(sourceURL, toURL: destinationURL)
                    } catch {
                        print("Error moving temp file: \(error)")
                    }
                }
            }).resume()
        }
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