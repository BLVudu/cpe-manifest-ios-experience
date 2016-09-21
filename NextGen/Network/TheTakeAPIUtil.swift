//
//  TheTakeAPIUtil.swift
//

import Foundation
import NextGenDataManager
private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public class TheTakeAPIUtil: APIUtil {
    
    public static let sharedInstance = TheTakeAPIUtil(apiDomain: "https://thetake.p.mashape.com")
    
    public var mediaId: String!
    var apiKey: String!
    
    private var frameTimes = [Double: NSDictionary]()
    private var _frameTimeKeys = [Double]()
    private var frameTimeKeys: [Double] {
        if _frameTimeKeys.count == 0 {
            _frameTimeKeys = frameTimes.keys.sorted()
        }
        
        return _frameTimeKeys
    }
    
    var productCategories = [TheTakeCategory]()
    
    override public func requestWithURLPath(_ urlPath: String) -> NSMutableURLRequest {
        let request = super.requestWithURLPath(urlPath)
        request.addValue(apiKey, forHTTPHeaderField: "X-Mashape-Key")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    func prefetchProductFrames(start: Int) {
        var limit = 100000
        if start == 0 {
            limit = 100
            frameTimes.removeAll()
        }
        
        _ = getJSONWithPath("/frames/listFrames", parameters: ["media": mediaId, "start": String(start), "limit": String(limit)], successBlock: { (result) -> Void in
            if let frames = result["result"] as? [NSDictionary] {
                for frameInfo in frames {
                    if let frameTime = frameInfo["frameTime"] as? Double {
                        self.frameTimes[frameTime] = frameInfo
                    }
                }
            }
            
            if start == 0 {
                self.prefetchProductFrames(start: limit + 1)
            }
        }, errorBlock: nil)
    }
    
    func prefetchProductCategories() {
        productCategories.removeAll()
        
        _ = getJSONWithPath("/categories/listProductCategories", parameters: ["media": mediaId], successBlock: { [weak self] (result) in
            if let strongSelf = self, let categories = result["result"] as? [NSDictionary] {
                for categoryInfo in categories {
                    strongSelf.productCategories.append(TheTakeCategory(info: categoryInfo))
                }
            }
        }, errorBlock: nil)
    }
    
    func closestFrameTime(_ timeInSeconds: Double) -> Double {
        let timeInMilliseconds = timeInSeconds * 1000
        var closestFrameTime = -1.0
        
        if frameTimes.count > 0 && frameTimes[timeInMilliseconds] == nil {
            if let frameIndex = frameTimeKeys.index(where: { $0 > timeInMilliseconds }) {
                closestFrameTime = frameTimeKeys[max(frameIndex - 1, 0)]
            }
        } else {
            closestFrameTime = timeInMilliseconds
        }
        
        return closestFrameTime
    }
    
    func getFrameProducts(_ frameTime: Double, successBlock: @escaping (_ products: [TheTakeProduct]) -> Void) -> URLSessionDataTask? {
        if frameTime >= 0 && frameTimes[frameTime] != nil {
            return getJSONWithPath("/frameProducts/listFrameProducts", parameters: ["media": mediaId, "time": String(frameTime)], successBlock: { (result) -> Void in
                if let productList = result["result"] as? NSArray {
                    var products = [TheTakeProduct]()
                    for productInfo in productList {
                        if let productData = productInfo as? NSDictionary {
                            products.append(TheTakeProduct(data: productData))
                        }
                    }
                    
                    successBlock(products)
                }
            }) { (error) -> Void in
                
            }
        }
        
        return nil
    }
    
    func getCategoryProducts(_ categoryId: String, successBlock: @escaping (_ products: [TheTakeProduct]) -> Void) -> URLSessionDataTask? {
        var parameters: [String: String] = ["media": mediaId, "limit": "100"]
        if Int(categoryId) > 0 {
            parameters["category"] = categoryId
        }
        
        return getJSONWithPath("/products/listProducts", parameters: parameters, successBlock: { (result) -> Void in
            if let productList = result["result"] as? NSArray {
                var products = [TheTakeProduct]()
                for productInfo in productList {
                    if let productData = productInfo as? NSDictionary {
                        products.append(TheTakeProduct(data: productData))
                    }
                }
                
                successBlock(products)
            }
        }) { (error) -> Void in
            
        }
    }
    
    func getProductDetails(_ productId: String, successBlock: @escaping (_ product: TheTakeProduct) -> Void) -> URLSessionDataTask {
        return getJSONWithPath("/products/productDetails", parameters: ["product": productId], successBlock: { (result) -> Void in
            successBlock(TheTakeProduct(data: result))
        }) { (error) -> Void in
                
        }
    }
    
}
