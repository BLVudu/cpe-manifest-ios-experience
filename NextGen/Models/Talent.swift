//
//  Talent.swift
//  NextGen
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

enum TalentType {
    case Unknown
    case Actor
    case Director
    case Producer
    case Writer
}

class TalentImage: NSObject {
    
    var thumbnailImageURL: NSURL?
    var imageURL: NSURL?
    
}

class TalentFilm: NSObject {
    
    var id: Int64!
    var title: String!
    var imageURL: NSURL?
    
    required init(info: NSDictionary) {
        super.init()
        
        id = (info[BaselineAPIUtil.Keys.ProjectID] as! NSNumber).longLongValue
        title = info[BaselineAPIUtil.Keys.ProjectName] as! String
    }
    
}

class Talent: NSObject {
    
    var id: Int64!
    var name: String!
    var role: String?
    var type = TalentType.Unknown
    var biography: String?
    var images = [TalentImage]()
    var films = [TalentFilm]()
    
    var thumbnailImageURL: NSURL? {
        get {
            if images.count > 0 {
                return images[0].thumbnailImageURL
            }
            
            return nil
        }
    }
    
    var fullImageURL: NSURL? {
        get {
            if images.count > 0 {
                return images[0].imageURL
            }
            
            return nil
        }
    }
    
    var facebook: String?
    var facebookID: String?
    var twitter: String?
    var gallery = [String]()
    
    required init(info: NSDictionary) {
        super.init()
        
        id = (info[BaselineAPIUtil.Keys.ParticipantID] as! NSNumber).longLongValue
        name = info[BaselineAPIUtil.Keys.FullName] as! String
        role = info[BaselineAPIUtil.Keys.Credit] as? String
        type = talentTypeFromString(info[BaselineAPIUtil.Keys.CreditGroup] as? String)
    }
    
    private func talentTypeFromString(typeString: String?) -> TalentType! {
        if let type = typeString {
            switch type {
            case "Actor":
                return TalentType.Actor
                
            case "Director":
                return TalentType.Director
                
            case "Producer":
                return TalentType.Producer
                
            case "Writer":
                return TalentType.Writer
                
            default:
                break
            }
        }
        
        return TalentType.Unknown
    }

}

