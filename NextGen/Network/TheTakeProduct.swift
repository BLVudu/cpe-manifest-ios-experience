//
//  TheTakeProduct.swift
//

import Foundation
import CoreGraphics

class TheTakeProduct: NSObject {
    
    private struct Constants {
        static let ProductURLPrefix = "http://www.thetake.com/product/"
        
        struct Keys {
            static let ProductId = "productId"
            static let ProductName = "productName"
            static let ProductBrand = "productBrand"
            static let ProductPrice = "productPrice"
            static let ProductImages = "productImages"
            static let ProductImage = "productImage"
            static let ProductImageThumbnail = "500pxLink"
            static let CropImages = "cropImages"
            static let CropImage = "cropImage"
            static let CropImageThumbnail = "500pxCropLink"
            static let ExactMatch = "verified"
            static let PurchaseLink = "purchaseLink"
            static let BullseyeX = "keyCropProductX"
            static let BullseyeY = "keyCropProductY"
        }
    }
    
    private var id: String
    var name: String
    var brand: String?
    var price: String?
    var productImageURL: URL?
    var sceneImageURL: URL?
    var exactMatch = false
    private var theTakeURLString: String?
    var theTakeURL: URL?
    var bullseyePoint = CGPoint.zero
    
    var shareText: String {
        get {
            return name + " - " + (theTakeURL?.absoluteString ?? "")
        }
    }
    
    init(data: NSDictionary) {
        id = data[Constants.Keys.ProductId] as? String ?? NSUUID().uuidString
        name = data[Constants.Keys.ProductName] as? String ?? ""
        brand = data[Constants.Keys.ProductBrand] as? String
        price = data[Constants.Keys.ProductPrice] as? String
        
        if let imagesData = (data[Constants.Keys.ProductImages] ?? data[Constants.Keys.ProductImage]) as? [String: String], let imageString = imagesData[Constants.Keys.ProductImageThumbnail] {
            productImageURL = URL(string: imageString)
        }
        
        if let imagesData = (data[Constants.Keys.CropImages] ?? data[Constants.Keys.CropImage]) as? [String: String], let imageString = imagesData[Constants.Keys.CropImageThumbnail] {
            sceneImageURL = URL(string: imageString)
        }
        
        if let verified = data[Constants.Keys.ExactMatch] as? Bool {
            exactMatch = verified
        }
        
        if let purchaseLink = data[Constants.Keys.PurchaseLink] as? String , purchaseLink.characters.count > 0 {
            theTakeURL = URL(string: purchaseLink)
        } else {
            theTakeURL = URL(string: Constants.ProductURLPrefix + id)
        }
        
        if let x = data[Constants.Keys.BullseyeX] as? Double, let y = data[Constants.Keys.BullseyeY] as? Double {
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
