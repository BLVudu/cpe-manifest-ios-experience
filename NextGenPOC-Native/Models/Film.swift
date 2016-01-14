//
//  Film.swift
//  NextGen
//
//  Created by Alec Ananian on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class Film: NSObject {
    
    var name: String!
    var imageURL: NSURL?
    var externalURL: NSURL?
    
    required init(info: [String: String]) {
        name = info["name"]
        if info["imageURL"] != nil {
            imageURL = NSURL(string: info["imageURL"]!)
        }
        
        if info["externalURL"] != nil {
            externalURL = NSURL(string: info["externalURL"]!)
        }
    }

}
