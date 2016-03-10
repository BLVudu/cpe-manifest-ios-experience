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
import DropDown


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaults = NSUserDefaults.standardUserDefaults()
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    let charSet = NSCharacterSet.URLQueryAllowedCharacterSet()
    var movieTitle: String!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Load current film's data file
        
       
        if let path = NSBundle.mainBundle().pathForResource("Data/man_of_steel", ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                //DataManager.sharedInstance.loadData(data)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        if let xmlPath = NSBundle.mainBundle().pathForResource("Data/mos_hls_manifest_v3", ofType: "xml") {
            NextGenDataManager.sharedInstance.loadXMLFile(xmlPath)
        }
        
        if let baselineData = NSBundle.mainBundle().pathForResource("Data/config", ofType: "json"){
            do {

            let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: baselineData), options: NSDataReadingOptions.DataReadingMappedIfSafe)

                
            let rawJSON = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                
                defaults.setObject(rawJSON!["data"]?.objectForKey("apiKey"), forKey: "apiKey")
                defaults.setObject(rawJSON!["data"]?.objectForKey("title"), forKey: "title")
                movieTitle = (defaults.objectForKey("title") as! String).stringByAddingPercentEncodingWithAllowedCharacters(charSet)!
                

            } catch let error as NSError {
                print(error.localizedDescription)
            }
    
            
        }
        
        let key = defaults.objectForKey("apiKey")
        let url = NSURL(string: "http://baselineapi.com/api/ProjectSearch?id=\(movieTitle)&apikey=\(key!)")
        let task = defaultSession.dataTaskWithURL(url!){
        data, response, error in

            if let error = error {
            print(error.localizedDescription)
        } else if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                self.parseResults(data!)
            }
        }
    }
 
        task.resume()
        GetCredits.sharedInstance.callAPI(NSURL(string:"http://baselineapi.com/api/ProjectAllCredits?id=4667130&apikey=\(key!)")!)
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier("d95d0b2a68ba4bb2b066c854a5c18c60")
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        
        application.statusBarHidden = true
        
        DropDown.startListeningToKeyboard()
        
        return true
    }
    
    func parseResults(data: NSData){
        
      
        
        
        
        do {
        
        let rawJSON = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            
            for movieData in rawJSON as! [AnyObject]{
                
                if movieData["PROJECT_NAME"] as! String == defaults.objectForKey("title") as! String{
                    defaults.setObject(movieData["PROJECT_ID"],forKey: "projectID")
                }
            }
            
        } catch let error as NSError {
        print(error.localizedDescription)
        }
    


    
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }


    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.SG.NextGen" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("NextGen", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

