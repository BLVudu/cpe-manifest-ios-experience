//
//  Scene.swift
//  NextGen
//
//  Created by Alec Ananian on 1/15/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class Scene: NSObject {
    
    var startTime = -1
    var endTime = -1
    var gallery = 0
    var canShare = false
    var talent = [Talent]()
    var longitude = 0.0
    var latitude = 0.0
    var locationName = ""
    var locationImage = ""
    var locationImages = []
    var triviaImage = ""
    var triviaFact = ""
    
    required init(info: NSDictionary) {
        super.init()
        
        startTime = info["startTime"] as! Int
        endTime = info["endTime"] as! Int
        gallery = info["gallery"] as! Int
        canShare = info["share"] as! Bool
            }
    
}