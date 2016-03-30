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
    var scenes = [Double: Scene]()
    var sceneKeys: [Double]?
    var allClips = [Clip]()
    
    required init(info: NSDictionary) {
        super.init()
        
        if let share = info["share"] as? NSDictionary{
            if let clips = share["clips"] as? NSArray{
                for aClip in clips{
                    allClips.append(Clip(info: aClip as! NSDictionary))
                }
            }
        }

        
    }
        /*
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
            
            if let location = scene["location"] as? NSDictionary{
                sceneObj.longitude = (location["longitude"] as? Double)!
                sceneObj.latitude = (location["latitude"] as? Double)!
                sceneObj.locationName = (location["name"] as? String)!
                sceneObj.locationImage = (location["image"] as? String)!
                sceneObj.locationImages = (location["images"] as? NSArray)!
            }
            
            if let trivia = scene["trivia"] as? NSDictionary{
                
                sceneObj.triviaImage = (trivia["image"] as? String)!
            }
            
            if let shopping = scene["shopping"] as? NSArray{
                for item in shopping{
                    let shoppingObj = Shopping(info: item as! NSDictionary)
                    sceneObj.shopping.append(shoppingObj)
                    
                }
                
            }
        }
        
        sceneKeys = scenes.keys.sort { $0 < $1 }
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
        
        return allTalent.sort { $0.billingOrder < $1.billingOrder }
    }
    
    func sceneAtTime(time: Double) -> Scene? {
        var closestSceneTime: Double = -1
        if sceneKeys != nil {
            for sceneTime in sceneKeys! {
                if sceneTime > time {
                    break
                }
                
                closestSceneTime = sceneTime
            }
        }
        
        return (closestSceneTime >= 0 ? scenes[closestSceneTime] : nil)
    }
    */
}
