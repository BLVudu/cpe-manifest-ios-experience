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
    var talent = [Talent]()
    
    required init(info: NSDictionary) {
        super.init()
        
        startTime = info["startTime"] as! Int
        endTime = info["endTime"] as! Int
    }
    
}