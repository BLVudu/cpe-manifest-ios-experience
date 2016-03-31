//
//  Clip.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/22/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class Clip: NSObject{
    
    var inTime: Double? = -1
    var outTime: Double? = -1
    var url: NSURL?
    var thumbnailImage: NSURL?
    var text: String?
    
    required init(info: NSDictionary) {
        super.init()
   
        inTime = info["in_time"] as? Double
        outTime = info["out_time"] as? Double
        url = NSURL(string:"http://cdn.theplatform.services/u/ContentServer/WarnerBros/Static/mos/NextGEN/\(info["url"] as! String)")
        if let thumbnails = info["thumbnails"] as? NSArray{
            for thumbnail  in thumbnails{
                thumbnailImage = NSURL(string:"http://cdn.theplatform.services/u/ContentServer/WarnerBros/Static/mos/NextGEN/\(thumbnail["url"] as! String)")
            }
        }


        text = info["text"] as? String
        }
    
}
