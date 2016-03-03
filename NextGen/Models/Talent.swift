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

class Talent: NSObject {
    
    var id: String!
    var name: String!
    var role: String?
    var type = TalentType.Unknown
    var billingOrder = -1
    var thumbnailImage: String?
    var fullImage: String?
    var biography: String?
    var facebook: String?
    var facebookID: String?
    var twitter: String?
    var films = [Film]()
    
    required init(info: NSDictionary) {
        super.init()
        
        id = info["id"] as! String
        name = info["name"] as! String
        role = info["character"] as? String
        type = talentTypeFromString(info["job_function"] as? String)
        billingOrder = info["billing_block_order"] as! Int
        thumbnailImage = info["thumbnail_image"] as? String
        fullImage = info["full_image"] as? String
        biography = info["biography"] as? String
        facebook = info["facebook"] as? String
        facebookID = info["facebookID"] as? String
        twitter = info["twitter"] as? String

        
        if let filmography = info["filmography"] as? NSArray {
            for film in filmography {
                films.append(Film(info: film as! NSDictionary))
            }
        }
    }
    
    private func talentTypeFromString(typeString: String?) -> TalentType! {
        if typeString != nil {
            let str = typeString!
            switch str {
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
