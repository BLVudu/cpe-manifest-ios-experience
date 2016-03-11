//
//  Film.swift
//  NextGen
//
//  Created by Alec Ananian on 1/14/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class Film: NSObject {
    
    var title: String!
    var projectID: String!
    var posterImageURL: NSURL?
    var externalURL: NSURL?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    required init(info: NSDictionary) {
        super.init()
        
        title = info["PROJECT_NAME"] as! String
        projectID = String(info["PROJECT_ID"] as! NSNumber)
        
        getPosterImage(projectID)
        
        //if let posterImage = info["poster_image"] as? String {
            //posterImageURL = NSURL(string: posterImage)
        //}
        
        if let externalURLStr = info["external_url"] as? String {
            externalURL = NSURL(string: externalURLStr)
        }
    }
    
    func getPosterImage(id:String){
        
        let key = defaults.objectForKey("apiKey")
        
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let task = defaultSession.dataTaskWithURL(NSURL(string:"http://baselineapi.com/api/ProjectFilmPoster?id=\(id)&apikey=\(key!)")!){
            data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        
                        let rawJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        if rawJSON.count > 0 {
                            self.posterImageURL = NSURL(string: rawJSON[0]["FULL_URL"]as! String)
                            
                        } else {
                            self.posterImageURL = nil
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
