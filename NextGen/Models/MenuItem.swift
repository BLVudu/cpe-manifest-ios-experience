//
//  MenuItem.swift
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
