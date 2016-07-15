//
//  UIImageRemoteLoader.swift
//

import UIKit

struct UIImageRemoteLoader {
    
    static func loadImage(url: NSURL, completion: ((image: UIImage?) -> Void)?) -> NSURLSessionDataTask? {
        let request = NSURLRequest(URL: url)
        let urlCache = NSURLCache(memoryCapacity: 0, diskCapacity: 1024 * 1024 * 512, diskPath: "com.wb.nextgen_image_cache") // 512Mb
        if let cachedResponse = urlCache.cachedResponseForRequest(request) where cachedResponse.data.length > 0 {
            if let completion = completion {
                completion(image: UIImage(data: cachedResponse.data))
            }
            
            return nil
        }
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        sessionConfiguration.URLCache = urlCache
        sessionConfiguration.timeoutIntervalForRequest = 10
        let task = NSURLSession(configuration: sessionConfiguration).dataTaskWithRequest(NSURLRequest(URL: url)) { (data, response, error) -> Void in
            if let completion = completion {
                completion(image: (data != nil ? UIImage(data: data!) : nil))
            }
        }
        
        task.resume()
        return task
    }
    
}