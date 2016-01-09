//
//  Talent.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//

import UIKit

class Talent: NSObject {
    
    var thumbnailImage: String?
    var fullImage: String?
    var name: String!
    var role: String!
    
    required init(info: [String: String]) {
        thumbnailImage = info["thumbnailImage"]
        fullImage = info["fullImage"]
        name = info["name"]
        role = info["role"]
    }

}
