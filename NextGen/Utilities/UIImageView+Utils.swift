//
//  UIImageView+Utils.swift
//

import UIKit

extension UIImageView {
    
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
                self.image = UIImage(named: path)
            }
            
            if let completion = completion {
                completion(image: self.image)
            }
            
            return nil
        }
        
        self.image = placeholderImage
        
        return UIImageRemoteLoader.loadImage(url, completion: { (image) in
            self.image = image
            
            if let completion = completion {
                completion(image: self.image)
            }
        })
    }
    
}
