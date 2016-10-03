//
//  NSTimeInterval+Utils.swift
//

import Foundation

extension TimeInterval {
    
    func formattedTime() -> String {
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        let minutes = Int((self / 60).truncatingRemainder(dividingBy: 60))
        let hours = Int(self / 3600)
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        }
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func timeString() -> String {
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        let minutes = Int((self / 60).truncatingRemainder(dividingBy: 60))
        let hours = Int(self / 3600)
        
        var timeStrings = [String]()
        if hours > 0 {
            timeStrings.append(String.localize("label.time.hours", variables: ["count": String(hours)]))
        }
        
        if minutes > 0 {
            timeStrings.append(String.localize("label.time.minutes", variables: ["count": String(minutes)]))
        }
        
        if seconds > 0 {
            timeStrings.append(String.localize("label.time.seconds", variables: ["count": String(seconds)]))
        }
        
        return timeStrings.joined(separator: " ")
    }
    
}
