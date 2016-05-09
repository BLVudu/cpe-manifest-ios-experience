//
//  MenuItem.swift
//  NextGen
//
//  Created by Alec Ananian on 3/25/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class MenuItem: NSObject {
    
    struct Keys {
        static let Title = "title"
        static let Value = "value"
        static let Latitude   = "latitude"
        static let Longitude   = "longitude"
    }
    
    var title: String!
    var value: String?
    var latitude: String?
    var longitude: String?
    
    
    required init(info: NSDictionary) {
        title = info[Keys.Title] as! String
        value = info[Keys.Value] as? String
        latitude = info[Keys.Latitude] as? String
        longitude = info[Keys.Longitude] as? String
    }

}
