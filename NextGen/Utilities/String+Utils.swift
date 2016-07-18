//
//  String+Utils.swift
//

import Foundation

extension String {
    
    func removeAll(characters: [Character]) -> String {
        return String(self.characters.filter({ !characters.contains($0) }))
    }
    
    static func localize(key: String) -> String {
        return NSLocalizedString(key, tableName: "NextGen", bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
    static func localize(key: String, variables: [String: String]) -> String {
        var localizedString = String.localize(key)
        for (variableName, variableValue) in variables {
            localizedString = localizedString.stringByReplacingOccurrencesOfString("%{" + variableName + "}", withString: variableValue)
        }
        
        return localizedString
    }
    
    static func localizePlural(singularKey: String, pluralKey: String, count: Int) -> String {
        return localize(count == 1 ? singularKey : pluralKey, variables: ["count": String(count)])
    }
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[start ..< end]
    }
    
}