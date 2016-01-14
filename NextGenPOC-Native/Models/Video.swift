//
//  Video.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

class Video: NSObject {
    
    var url: NSURL!
    var title: String!
    var deliveryFormat: String?
    
    required init(info: [String: String]) {
        url = NSURL(string: info["url"]!)
        title = info["title"]
        deliveryFormat = info["deliveryFormat"]
    }
    
}