//
//  TheTakeProduct.swift
//  NextGen
//
//  Created by Alec Ananian on 3/10/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import Foundation

class TheTakeProduct: NSObject {
    
    private var _data: NSDictionary!
    
    var id: String {
        get {
            return dataValue("productId")
        }
    }
    
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
    
    var imageURL: NSURL? {
        get {
            if let images = _data["productImages"] as? NSDictionary, image = images["500pxLink"] as? String {
                return NSURL(string: image)!
            }
            
            return nil
        }
    }
    
    init(data: NSDictionary) {
        _data = data
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let otherProduct = object as? TheTakeProduct {
            return otherProduct.id == id
        }
        
        return false
    }
    
    func dataValue(key: String) -> String {
        if let value = _data[key] {
            return String(value)
        }
        
        return ""
    }
    
}