//
//  Content.swift
//  NextGen
//
//  Created by Alec Ananian on 1/15/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class Content: NSObject {
    
    var clipKeys: [Double]?
    var inTimes = [Double: Clip]()
    var outTimes = [Double: Clip]()
    var outKeys: [Double]?
    
    required init(info: NSDictionary) {
        super.init()
        
        if let share = info["share"] as? NSDictionary{
            if let clips = share["clips"] as? NSArray{
                for aClip in clips{
                    let clipData = Clip(info: aClip as! NSDictionary)
                    inTimes[clipData.inTime!] = clipData
                    outTimes[clipData.outTime!] = clipData
                }
            }
        }
        
        clipKeys = inTimes.keys.sort { $0 < $1 }
        outKeys = outTimes.keys.sort { $0 < $1 }
    }
    
        
        func clipToShareAtTime(time: Double)->Clip?{
            
            var closestSceneTime: Double = -1
            if clipKeys != nil {
                for sceneTime in clipKeys! {
                        if sceneTime > time{
                            break
                        }

                    closestSceneTime = sceneTime
                }
            
                           }
            return (closestSceneTime >= 0 ? inTimes[closestSceneTime] : nil)

            
        }
}
