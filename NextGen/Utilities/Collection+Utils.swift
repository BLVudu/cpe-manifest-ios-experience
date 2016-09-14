//
//  Collection+Utils.swift
//

import Foundation

extension Collection {
    
    /*func indexOfFirstObjectPassingTest(_ test: ((Self._Element) -> Bool)) -> Self.Index? {
        var searchRange = startIndex ..< endIndex
        while searchRange.count > 0 {
            let testIndex: Index = self.index(searchRange.lowerBound, offsetBy: (searchRange.count - 1) / 2)
            let passesTest: Bool = test(self[testIndex])
            
            if (searchRange.count == 1) {
                return passesTest ? searchRange.lowerBound : nil
            }
            
            if (passesTest) {
                searchRange.upperBound = self.index(testIndex, offsetBy: 1)
            } else {
                searchRange.lowerBound = self.index(testIndex, offsetBy: 1)
            }
        }
        
        return nil
    }*/
    
}
