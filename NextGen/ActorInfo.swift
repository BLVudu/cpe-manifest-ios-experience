//
//  ActorInfo.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/10/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class ActorInfo {
    
    static let sharedInstance = ActorInfo()
    var bio: String!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    //BioShort
    //FilmCredit
    //Headshot
    
    func getBio(url:String){
        
        
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let task = defaultSession.dataTaskWithURL(NSURL(string:url)!){
            data, response, error in

            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        
                        let rawJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                            self.bio = rawJSON[0]["SHORT_BIO"] as! String
                                                
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                
                }
            }
        }
        
        task.resume()
        
        

    }
    


    
    func getFilmography(url: NSURL){
    
    }
    
    func getHeadshot(url: NSURL){
        
    }
    
}
