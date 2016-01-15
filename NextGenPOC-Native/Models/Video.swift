//
//  Video.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

class Video {
    
    var content: Content!
    var url: NSURL!
    var deliveryFormat: String?
    
    var title: String {
        get {
            return content.title
        }
    }
    
    required init(info: NSDictionary) {
        url = NSURL(string: info["file_url"] as! String)
        deliveryFormat = info["delivery_format"] as? String
    }
    
}