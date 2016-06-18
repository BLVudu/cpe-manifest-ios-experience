//
//  TheTakeProduct.swift
//

import Foundation
import CoreGraphics

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
    
    var productImageURL: NSURL? {
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
    
    var sceneImageURL: NSURL? {
        get {
            var images = _data["cropImages"]
            if images == nil {
                images = _data["cropImage"]
            }
            
            if images != nil {
                if let image = images?["500pxCropLink"] as? String {
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
            /*if let link = _data["purchaseLink"] as? String {
                return link
            }*/
            
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
    
    func getSceneBullseyePoint(parentRect: CGRect) -> CGPoint {
        return CGPointMake(CGRectGetWidth(parentRect) * CGFloat((dataValue("keyCropProductX") as NSString).doubleValue), CGRectGetHeight(parentRect) * CGFloat((dataValue("keyCropProductY") as NSString).doubleValue))
    }
    
}