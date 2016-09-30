//
//  NextGenCacheManager.swift
//

import Foundation

class NextGenCacheManager {
    
    private struct Constants {
        static let CacheParentDirectory = "NextGen"
    }
    
    private static var tempDirectoryURL: URL? {
        let directoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(Constants.CacheParentDirectory, isDirectory: true)
        
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return directoryURL
            }
        }
        
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating temp directory: \(error)")
            return nil
        }
        
        return directoryURL
    }
    
    private static var applicationSupportDirectoryURL: URL? {
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        if let path = paths.first {
            if !FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error creating Application Support directory: \(error)")
                    return nil
                }
            }
            
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        
        return nil
    }
    
    private static func fileNameForURL(_ remoteURL: URL) -> String? {
        if let fileName = remoteURL.path.characters.split(separator: "/").last {
            return String(fileName)
        }
        
        return nil
    }
    
    static func tempFileURL(_ remoteURL: URL) -> URL? {
        if let fileName = fileNameForURL(remoteURL) {
            return tempDirectoryURL?.appendingPathComponent(fileName)
        }
        
        return nil
    }
    
    static func applicationSupportFileURL(_ remoteURL: URL) -> URL? {
        if let fileName = fileNameForURL(remoteURL) {
            return applicationSupportDirectoryURL?.appendingPathComponent(fileName)
        }
        
        return nil
    }
    
    static func fileExists(_ fileURL: URL) -> Bool {
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    static func storeTempFile(_ remoteURL: URL) {
        URLSession.shared.downloadTask(with: remoteURL, completionHandler: { (location, response, error) in
            if error != nil {
                print("Error downloading temp file: \(error)")
            } else if let sourceURL = location, let destinationURL = NextGenCacheManager.tempFileURL(remoteURL) {
                do {
                    try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
                } catch let error as NSError {
                    print("Error moving temp file: \(error)")
                }
            }
        }).resume()
    }
    
    static func storeApplicationSupportFile(_ remoteURL: URL, completionHandler: @escaping (_ localFileURL: URL?) -> Void) {
        URLSession.shared.downloadTask(with: remoteURL, completionHandler: { (location, response, error) in
            if error != nil {
                print("Error downloading Application Support file: \(error)")
                completionHandler(nil)
            } else if let sourceURL = location, let destinationURL = NextGenCacheManager.applicationSupportFileURL(remoteURL) {
                do {
                    try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
                    completionHandler(destinationURL)
                } catch let error as NSError {
                    if error.code == NSFileWriteFileExistsError {
                        do {
                            try FileManager.default.replaceItem(at: destinationURL, withItemAt: sourceURL, backupItemName: nil, options: .usingNewMetadataOnly, resultingItemURL: nil)
                            completionHandler(destinationURL)
                        } catch {
                            print("Error replacing Application Support file: \(error)")
                            completionHandler(nil)
                        }
                    } else {
                        print("Error moving Application Support file: \(error)")
                        completionHandler(nil)
                    }
                }
            }
        }).resume()
    }
    
    static func clearTempDirectory() {
        if let tempDirectoryURL = tempDirectoryURL {
            do {
                try FileManager.default.removeItem(at: tempDirectoryURL)
            } catch {
                print("Error deleting temp directory: \(error)")
            }
        }
    }
    
}
