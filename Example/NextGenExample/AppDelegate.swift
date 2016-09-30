//
//  AppDelegate.swift
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        application.isStatusBarHidden = true
        
        NextGenDataLoader.sharedInstance.loadConfig()
        
        return true
    }

}
