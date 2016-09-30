//
//  TheTakeCategory.swift
//

import Foundation

class TheTakeCategory: NSObject {
    
    struct Keys {
        static let CategoryID = "categoryId"
        static let CategoryName = "categoryName"
        static let ChildCategories = "childCategories"
    }
    
    var id: Int!
    var name: String!
    var children: [TheTakeCategory]?
    
    convenience init(info: NSDictionary) {
        self.init()
        
        id = (info[Keys.CategoryID] as! NSNumber).intValue
        name = info[Keys.CategoryName] as! String
        
        if let childCategories = info[Keys.ChildCategories] as? [NSDictionary] {
            children = [TheTakeCategory]()
            for childCategory in childCategories {
                children!.append(TheTakeCategory(info: childCategory))
            }
        }
    }
    
}
