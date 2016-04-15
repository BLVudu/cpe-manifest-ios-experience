//
//  APIUtil.swift
//  NextGen
//
//  Created by Alec Ananian on 3/10/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import Foundation

typealias APIUtilSuccessBlock = (result: NSDictionary) -> Void
typealias APIUtilErrorBlock = (error: NSError?) -> Void

class APIUtil: NSObject, NSURLSessionDataDelegate {
    
    var apiDomain: String!
    
    init(apiDomain: String) {
        super.init()
        self.apiDomain = apiDomain
    }
    
    func requestWithURLPath(urlPath: String) -> NSMutableURLRequest {
        return NSMutableURLRequest(URL: NSURL(string: apiDomain + urlPath)!)
    }
    
    func getJSONWithPath(urlPath: String, parameters: [String: String], successBlock: APIUtilSuccessBlock?, errorBlock: APIUtilErrorBlock?) -> NSURLSessionDataTask {
        return getJSONWithPath(urlPath + "?" + parameters.stringFromHTTPParameters(), successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func getJSONWithPath(urlPath: String, successBlock: APIUtilSuccessBlock?, errorBlock: APIUtilErrorBlock?) -> NSURLSessionDataTask {
        return getJSONWithRequest(requestWithURLPath(urlPath), successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func getJSONWithRequest(request: NSURLRequest, successBlock: APIUtilSuccessBlock?, errorBlock: APIUtilErrorBlock?) -> NSURLSessionDataTask {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        sessionConfiguration.URLCache = NSURLCache(memoryCapacity: 0, diskCapacity: 1024 * 1024 * 64, diskPath: "com.wb.nextgen_api_cache") // 64Mb
        sessionConfiguration.timeoutIntervalForRequest = 60
        let task = NSURLSession(configuration: sessionConfiguration).dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error == nil {
                if let data = data {
                    do {
                        if let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                            successBlock?(result: jsonDictionary)
                        } else if let jsonArray = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSArray {
                            successBlock?(result: ["result": jsonArray])
                        }
                    } catch {
                        errorBlock?(error: nil)
                    }
                }
            } else {
                errorBlock?(error: error)
            }
        }
        
        task.resume()
        return task
    }
    
}