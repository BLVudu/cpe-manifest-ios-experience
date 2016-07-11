//
//  UIImageView+Utils.swift
//

import UIKit

extension UIImageView {
    
    func setImageWithURL(url: NSURL, completion: ((image: UIImage?) -> Void)?) -> NSURLSessionDataTask? {
        if url.fileURL {
            if let path = url.path {
                self.image = UIImage(named: path)
            }
            
            if let completion = completion {
                completion(image: self.image)
            }
            
            return nil
        }
        
        return UIImageRemoteLoader.loadImage(url, completion: { (image) in
            self.image = image
            
            if let completion = completion {
                completion(image: self.image)
            }
        })
    }
    
}
