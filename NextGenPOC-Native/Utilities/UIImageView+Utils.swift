//
//  UIImageView+Utils.swift
//  NextGen
//
//  Created by Alec Ananian on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setImageWithURL(url: NSURL) {
        setImageWithURL(url, placeholderImage: nil)
    }
    
    func setImageWithURL(url: NSURL, placeholderImage: UIImage?) {
        self.image = placeholderImage
        let request = NSURLRequest(URL: url)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.image = UIImage(data: data!)
            })
        }.resume()
    }
    
}
