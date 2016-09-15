//
//  UIImageView+Utils.swift
//

import UIKit
import NextGenDataManager

extension UIImageView {
    
    func setImageWithURL(_ url: URL, completion: ((_ image: UIImage?) -> Void)?) -> URLSessionDataTask? {
        if url.isFileURL {
            DispatchQueue.main.async {
                self.image = UIImage(named: url.path)
                
                if let completion = completion {
                    completion(self.image)
                }
            }
        
            return nil
        }
        
        return UIImageRemoteLoader.loadImage(url, completion: { (image) in
            DispatchQueue.main.async {
                self.image = image
                
                if let completion = completion {
                    completion(self.image)
                }
            }
        })
    }
    
}
