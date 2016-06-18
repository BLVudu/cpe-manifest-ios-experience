//
//  Indexable+Utils.swift
//

import Foundation

extension Indexable {
    
    func indexOfFirstObjectPassingTest(test: (Self._Element -> Bool)) -> Self.Index? {
        var searchRange = startIndex..<endIndex
        
        while searchRange.count > 0 {
            let testIndex: Index = searchRange.startIndex.advancedBy((searchRange.count-1) / 2)
            let passesTest: Bool = test(self[testIndex])
            
            if (searchRange.count == 1) {
                return passesTest ? searchRange.startIndex : nil
            }
            
            if (passesTest) {
                searchRange.endIndex = testIndex.advancedBy(1)
            } else {
                searchRange.startIndex = testIndex.advancedBy(1)
            }
        }
        
        return nil
    }
    
}