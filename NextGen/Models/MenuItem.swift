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
    }
    
    var title: String!
    var value: String?
    
    required init(info: NSDictionary) {
        title = info[Keys.Title] as! String
        value = info[Keys.Value] as? String
    }

}
