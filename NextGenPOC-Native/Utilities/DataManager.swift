//
//  DataManager.swift
//  NextGen
//
//  Created by Alec Ananian on 1/15/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class DataManager {
    static let sharedInstance = DataManager()
    
    private var rawJSON: NSDictionary?
    var content: Content?
    
    func loadData(data: NSData) {
        do {
            rawJSON = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            if rawJSON != nil {
                content = Content(info: rawJSON!)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}