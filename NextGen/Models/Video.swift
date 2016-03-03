//
//  Video.swift
//  NextGen
//
//  Created by Alec Ananian on 1/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

class Video {
    
    var content: Content!
    var url: NSURL!
    var interstitialUrl: NSURL?
    var deliveryFormat: String?
    
    var title: String {
        get {
            return content.title
        }
    }
    
    required init(info: NSDictionary) {
        url = NSURL(string: info["file_url"] as! String)
        interstitialUrl = info["interstitial_file_url"] != nil ? NSURL(string: info["interstitial_file_url"] as! String) : nil
        deliveryFormat = info["delivery_format"] as? String
    }
    
}