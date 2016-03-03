//
//  Film.swift
//  NextGen
//
//  Created by Alec Ananian on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class Film: NSObject {
    
    var title: String!
    var posterImageURL: NSURL?
    var externalURL: NSURL?
    
    required init(info: NSDictionary) {
        super.init()
        
        title = info["title"] as! String
        
        if let posterImage = info["poster_image"] as? String {
            posterImageURL = NSURL(string: posterImage)
        }
        
        if let externalURLStr = info["external_url"] as? String {
            externalURL = NSURL(string: externalURLStr)
        }
    }

}
