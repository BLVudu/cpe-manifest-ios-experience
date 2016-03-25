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
        static let value = "value"
    }
    
    var value: String!
    
    required init(info: NSDictionary) {
        value = info[Keys.value] as! String
    }

}
