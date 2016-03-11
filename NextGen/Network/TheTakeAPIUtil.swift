//
//  TheTakeAPIUtil.swift
//  NextGen
//
//  Created by Alec Ananian on 3/10/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import Foundation

let kTheTakeIdentifierNamespace = "thetake"

class TheTakeAPIUtil: APIUtil {
    
    static let sharedInstance = TheTakeAPIUtil(apiDomain: "https://thetake.p.mashape.com")
    
    var mediaId: String!
    var frameTimes = [Double: NSDictionary]()
    
    override func requestWithURLPath(urlPath: String) -> NSMutableURLRequest {
        let request = super.requestWithURLPath(urlPath)
        request.addValue("M1RnzsU2OTmshwzmN7w8Wnq7ZPCep1SFQFQjsnZYY4C9sXhsPy", forHTTPHeaderField: "X-Mashape-Key")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    func prefetchProductFrames() {
        frameTimes.removeAll()
        
        getJSONWithPath("/frames/listFrames", parameters: ["media": mediaId, "limit": "9999"], successBlock: { (result) -> Void in
            if let frames = result["result"] as? [NSDictionary] {
                for frameInfo in frames {
                    if let frameTime = frameInfo["frameTime"] as? Double {
                        self.frameTimes[frameTime] = frameInfo
                    }
                }
                
                /*if let frameTime = self.frameTimes.first {
                    TheTakeAPIUtil.sharedInstance.getFrameProducts(frameTime, successBlock: { (result) -> Void in
                        if let products = result["products"] as? [TheTakeProduct] {
                            for product in products {
                                print(product.brand)
                                print(product.name)
                            }
                        }
                    })
                }*/
            }
        }, errorBlock: nil)
    }
    
    func closestFrameTime(timeInSeconds: Double) -> Double {
        let timeInMilliseconds = timeInSeconds * 1000
        var closestFrameTime = -1.0
        
        if frameTimes[timeInMilliseconds] == nil {
            let frameTimeKeys = frameTimes.keys.sort()
            let frameIndex = frameTimeKeys.indexOfFirstObjectPassingTest({ $0 > timeInMilliseconds })
            closestFrameTime = frameTimeKeys[max(frameIndex - 1, 0)]
        } else {
            closestFrameTime = timeInMilliseconds
        }
        
        return closestFrameTime
    }
    
    func getFrameProducts(frameTime: Double, successBlock: (products: [TheTakeProduct]) -> Void) -> NSURLSessionDataTask? {
        if frameTime >= 0 && frameTimes[frameTime] != nil {
            return getJSONWithPath("/frameProducts/listFrameProducts", parameters: ["media": mediaId, "time": String(frameTime)], successBlock: { (result) -> Void in
                if let productList = result["result"] as? NSArray {
                    var products = [TheTakeProduct]()
                    for productInfo in productList {
                        if let productData = productInfo as? NSDictionary {
                            products.append(TheTakeProduct(data: productData))
                        }
                    }
                    
                    successBlock(products: products)
                }
            }) { (error) -> Void in
                
            }
        }
        
        return nil
    }
    
    func getProductDetails(productId: String, successBlock: (product: TheTakeProduct) -> Void) -> NSURLSessionDataTask {
        return getJSONWithPath("/products/productDetails", parameters: ["product": productId], successBlock: { (result) -> Void in
            successBlock(product: TheTakeProduct(data: result))
        }) { (error) -> Void in
                
        }
    }
    
}