//
//  TheTakeProduct.swift
//  NextGen
//
//  Created by Alec Ananian on 3/10/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import Foundation

class TheTakeProduct {
    
    private var _data: NSDictionary!
    
    var name: String {
        get {
            return dataValue("productName")
        }
    }
    
    var brand: String {
        get {
            return dataValue("productBrand")
        }
    }
    
    init(data: NSDictionary) {
        _data = data
    }
    
    func dataValue(key: String) -> String {
        if let value = _data[key] as? String {
            return value
        }
        
        return ""
    }
    
}