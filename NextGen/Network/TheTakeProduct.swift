//
//  TheTakeProduct.swift
//

import Foundation
import CoreGraphics

class TheTakeProduct: NSObject {
    
    var id: String
    var name: String
    var brand: String?
    var price: String?
    var productImageURL: URL?
    var sceneImageURL: URL?
    var exactMatch = false
    var theTakeURLString: String?
    var theTakeURL: URL?
    var bullseyePoint = CGPoint.zero
    
    var shareText: String {
        get {
            return name + " - " + (theTakeURL?.absoluteString ?? "")
        }
    }
    
    init(data: NSDictionary) {
        id = data["productId"] as? String ?? NSUUID().uuidString
        name = data["productName"] as? String ?? "Unknown"
        brand = data["productBrand"] as? String
        price = data["productPrice"] as? String
        
        if let imagesData = (data["productImages"] ?? data["productImage"]) as? [String: String], let imageString = imagesData["500pxLink"] {
            productImageURL = URL(string: imageString)
        }
        
        if let imagesData = (data["cropImages"] ?? data["cropImage"]) as? [String: String], let imageString = imagesData["500pxCropLink"] {
            sceneImageURL = URL(string: imageString)
        }
        
        if let verified = data["verified"] as? Bool {
            exactMatch = verified
        }
        
        if let purchaseLink = data["purchaseLink"] as? String , purchaseLink.characters.count > 0 {
            theTakeURL = URL(string: purchaseLink)
        } else {
            theTakeURL = URL(string: "http://www.thetake.com/product/" + id)
        }
        
        if let x = data["keyCropProductX"] as? Double, let y = data["keyCropProductY"] as? Double {
            bullseyePoint = CGPoint(x: x, y: y)
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let otherProduct = object as? TheTakeProduct {
            return otherProduct.id == id
        }
        
        return false
    }
    
}
