//
//  Content.swift
//  NextGen
//
//  Created by Alec Ananian on 1/15/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class Content: NSObject {
    
    var title: String!
    var video: Video!
    var talent = [String: Talent]()
    var scenes = [Int: Scene]()
    
    required init(info: NSDictionary) {
        super.init()
        
        video = Video(info: info["video"] as! NSDictionary)
        video.content = self
        
        let metadata = info["metadata"] as! NSDictionary
        title = metadata["title"] as! String
        if let people = metadata["people"] as? NSArray {
            for person in people {
                let talentObj = Talent(info: person as! NSDictionary)
                talent[talentObj.id] = talentObj
            }
        }
        
        let sceneData = info["scenes"] as! NSArray
        for scene in sceneData {
            let sceneObj = Scene(info: scene as! NSDictionary)
            scenes[sceneObj.startTime] = sceneObj
            
            if let people = scene["people"] as? NSArray {
                for talentId in people {
                    if talent[talentId as! String] != nil {
                        sceneObj.talent.append(talent[talentId as! String]!)
                    }
                }
            }
        }
    }
    
    func allActors() -> [Talent] {
        return allTalentWithType(TalentType.Actor)
    }
    
    func allTalentWithType(type: TalentType) -> [Talent] {
        var allTalent = [Talent]()
        for (_, talentObj) in talent {
            if talentObj.type == TalentType.Actor {
                allTalent.append(talentObj)
            }
        }
        
        return allTalent.sort({ (talent1, talent2) -> Bool in
            return talent1.billingOrder < talent2.billingOrder
        })
    }
    
    func talentAtSceneTime(time: Int) -> [Talent] {
        var scene: Scene?
        for (startTime, sceneObj) in scenes {
            if startTime > time {
                break
            }
            
            scene = sceneObj
        }
        
        return (scene != nil ? scene!.talent : [Talent]())
    }
    
}
