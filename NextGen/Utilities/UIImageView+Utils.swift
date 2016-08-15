//
//  UIImageView+Utils.swift
//

import UIKit
import NextGenDataManager

extension UIImageView {
    
    func setImageWithURL(url: NSURL, completion: ((image: UIImage?) -> Void)?) -> NSURLSessionDataTask? {
        if url.fileURL {
            dispatch_async(dispatch_get_main_queue()) {
                if let path = url.path {
                    self.image = UIImage(named: path)
                }
                
                if let completion = completion {
                    completion(image: self.image)
                }
            }
        
            return nil
        }
        
        return UIImageRemoteLoader.loadImage(url, completion: { (image) in
            dispatch_async(dispatch_get_main_queue()) {
                self.image = image
                
                if let completion = completion {
                    completion(image: self.image)
                }
            }
        })
    }
    
}