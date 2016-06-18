//
//  UIButton+Utils.swift
//

import UIKit

extension UIButton {
    
    static func buttonWithImage(image: UIImage!) -> UIButton {
        let button = UIButton(type: .Custom)
        button.setImage(image, forState: .Normal)
        return button
    }
    
    func setImageWithURL(url: NSURL) -> NSURLSessionDataTask? {
        return setImageWithURL(url, placeholderImage: nil, completion: nil)
    }
    
    func setImageWithURL(url: NSURL, completion: ((image: UIImage?) -> Void)?) -> NSURLSessionDataTask? {
        return setImageWithURL(url, placeholderImage: nil, completion: completion)
    }
    
    func setImageWithURL(url: NSURL, placeholderImage: UIImage?) -> NSURLSessionDataTask? {
        return setImageWithURL(url, placeholderImage: placeholderImage, completion: nil)
    }
    
    func setImageWithURL(url: NSURL, placeholderImage: UIImage?, completion: ((image: UIImage?) -> Void)?) -> NSURLSessionDataTask? {
        if url.fileURL {
            if let path = url.path {
                self.setImage(UIImage(named: path), forState: .Normal)
            }
            
            return nil
        }
        
        self.setImage(placeholderImage, forState: .Normal)
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        sessionConfiguration.URLCache = NSURLCache(memoryCapacity: 0, diskCapacity: 1024 * 1024 * 256, diskPath: "com.wb.nextgen_image_cache") // 256Mb
        sessionConfiguration.timeoutIntervalForRequest = 20
        let task = NSURLSession(configuration: sessionConfiguration).dataTaskWithRequest(NSURLRequest(URL: url)) { (data, response, error) -> Void in
            if let data = data {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let image = UIImage(data: data)
                    self.setImage(image, forState: .Normal)
                    if let completion = completion {
                        completion(image: image)
                    }
                })
            } else if let completion = completion {
                completion(image: nil)
            }
        }
        
        task.resume()
        return task
    }
    
}