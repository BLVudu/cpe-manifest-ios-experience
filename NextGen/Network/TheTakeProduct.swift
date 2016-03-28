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
    
    var price: String {
        get {
            return dataValue("productPrice")
        }
    }
    
    var imageURL: NSURL? {
        get {
            var images = _data["productImages"]
            if images == nil {
                images = _data["productImage"]
            }
            
            if images != nil {
                if let image = images?["500pxLink"] as? String {
                    return NSURL(string: image)
                }
            }
            
            return nil
        }
    }
    
    var exactMatch: Bool {
        get {
            if let verified = _data["verified"] {
                return verified.boolValue
            }
            
            return false
        }
    }
    
    var theTakeURLString: String {
        get {
            return "http://www.thetake.com/product/" + id
        }
    }
    
    var theTakeURL: NSURL {
        get {
            return NSURL(string: theTakeURLString)!
        }
    }
    
    var shareText: String {
        get {
            return name + " - " + theTakeURLString
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