//
//  GetCredits.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/9/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class GetCredits{
    
    static let sharedInstance = GetCredits()
    let defaults = NSUserDefaults.standardUserDefaults()
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var talent = [Talent]()

    
    func callAPI(url: NSURL){
            let task = defaultSession.dataTaskWithURL(url){
            data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        
                        let rawJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        
                        for index in 0...13{
                            let talentObj = Talent(info: rawJSON[index] as! NSDictionary)
                            self.talent.append(talentObj)

                        }
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }

                }
            }
        }
        
        task.resume()

        
        
        
    }
       
    
}