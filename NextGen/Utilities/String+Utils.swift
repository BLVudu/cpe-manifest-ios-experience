//
//  String+Utils.swift
//  NextGen
//
//  Created by Alec Ananian on 3/10/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import Foundation

extension String {
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
    }
    
}