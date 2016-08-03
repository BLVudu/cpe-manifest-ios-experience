//
//  AppDelegate.swift
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.statusBarHidden = true
        
        return true
    }

}
