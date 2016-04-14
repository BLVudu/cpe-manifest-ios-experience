//
//  NSLocale+Utils.swift
//  NextGen
//
//  Created by Alec Ananian on 4/12/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

extension NSLocale {
    
    static func currentLanguage() -> String {
        if let language = NSLocale.preferredLanguages().first {
            return (language as NSString).substringToIndex(2)
        }
        
        return "en"
    }
    
}