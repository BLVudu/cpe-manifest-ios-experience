//
//  MenuSection.swift
//  NextGen
//
//  Created by Alec Ananian on 3/25/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class MenuSection: NSObject {
    
    struct Keys {
        static let Title = "title"
        static let Rows = "rows"
    }
    
    var title: String!
    var items = [MenuItem]()
    var expanded = false
    var selectedItem: MenuItem?
    
    var numRows: Int {
        get {
            if expanded {
                return items.count + 1
            }
            
            return 1
        }
    }
    
    var value: String? {
        get {
            return selectedItem?.value
        }
    }
    
    var expandable: Bool {
        get {
            return items.count > 0
        }
    }
    
    required init(info: NSDictionary) {
        title = info[Keys.Title] as! String
        if let rows = info[Keys.Rows] as? [NSDictionary] {
            for itemInfo in rows {
                items.append(MenuItem(info: itemInfo))
            }
        }
    }
    
    func toggle() {
        expanded = !expanded
    }

}
