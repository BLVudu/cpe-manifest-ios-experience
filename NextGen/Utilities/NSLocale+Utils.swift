//
//  NSLocale+Utils.swift
//

import Foundation

extension NSLocale {
    
    static func currentLanguage() -> String {
        if let language = NSLocale.preferredLanguages().first {
            return (language as NSString).substringToIndex(2)
        }
        
        return "en"
    }
    
}