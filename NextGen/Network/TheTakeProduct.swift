//
//  TheTakeProduct.swift
//

import Foundation
import CoreGraphics

class TheTakeProduct: NSObject {
    
    fileprivate var _data: NSDictionary!
    
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
    
    var productImageURL: URL? {
        get {
            var images = _data["productImages"]
            if images == nil {
                images = _data["productImage"]
            }
            
            if let image = (images as? NSDictionary)?["500pxLink"] as? String {
                return URL(string: image)
            }
            
            return nil
        }
    }
    
    var sceneImageURL: URL? {
        get {
            var images = _data["cropImages"]
            if images == nil {
                images = _data["cropImage"]
            }
            
            if let image = (images as? NSDictionary)?["500pxCropLink"] as? String {
                return URL(string: image)
            }
            
            return nil
        }
    }
    
    var exactMatch: Bool {
        get {
            if let verified = _data["verified"] {
                return (verified as AnyObject).boolValue
            }
            
            return false
        }
    }
    
    var theTakeURLString: String {
        get {
            if let link = _data["purchaseLink"] as? String , link.characters.count > 0 {
                return link
            }
            
            return "http://www.thetake.com/product/" + id
        }
    }
    
    var theTakeURL: URL {
        get {
            return URL(string: theTakeURLString)!
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
    
    override func isEqual(_ object: Any?) -> Bool {
        if let otherProduct = object as? TheTakeProduct {
            return otherProduct.id == id
        }
        
        return false
    }
    
    func dataValue(_ key: String) -> String {
        return (_data[key] as? String) ?? ""
    }
    
    func getSceneBullseyePoint(_ parentRect: CGRect) -> CGPoint {
        return CGPoint(x: parentRect.width * CGFloat((dataValue("keyCropProductX") as NSString).doubleValue), y: parentRect.height * CGFloat((dataValue("keyCropProductY") as NSString).doubleValue))
    }
    
}
