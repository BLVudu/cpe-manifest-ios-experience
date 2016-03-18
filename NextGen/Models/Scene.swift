//
//  Scene.swift
//  NextGen
//
//  Created by Alec Ananian on 1/15/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class Scene: NSObject {
    
    var startTime: Double = -1
    var endTime: Double = -1
    var gallery = 0
    var canShare = false
    var talent = [Talent]()
    var longitude = 0.0
    var latitude = 0.0
    var locationName = ""
    var locationImage = ""
    var locationImages = []
    var triviaImage = ""
    var shopping = [Shopping]()
    
    required init(info: NSDictionary) {
        super.init()
        
        startTime = info["startTime"] as! Double
        endTime = info["endTime"] as! Double
        gallery = info["gallery"] as! Int
        canShare = info["share"] as! Bool
            }
    
    func triviaText() -> String? {
        /*if let triviaExperience = NextGenDataManager.sharedInstance.triviaExperience(), timedEvent = triviaExperience.timedEvent(startTime) {
            return timedEvent.textItem()
        }
        
        return nil*/
        return ""
    }
    
}