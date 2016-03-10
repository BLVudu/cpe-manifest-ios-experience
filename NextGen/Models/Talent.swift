//
//  Talent.swift
//  NextGen
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

enum TalentType {
    case Unknown
    case Actor
    case Director
    case Producer
    case Writer
}

class Talent: NSObject {
    
    var id: String!
    var participantID: String!
    var name: String!
    var role: String?
    var type = TalentType.Unknown
    var billingOrder = -1
    var thumbnailImage: String?
    var fullImage: String?
    var biography: String!
    var facebook: String?
    var facebookID: String?
    var twitter: String?
    var films = [Film]()
    var gallery = [String]()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    required init(info: NSDictionary) {
        super.init()
        participantID = String(info["PARTICIPANT_ID"] as! NSNumber)
        name = info["FULL_NAME"] as! String
        role = info["CREDIT"] as? String
        type = talentTypeFromString(info["CREDIT_GROUP"] as? String)
        getBio(participantID)
        //getFilmography("http://www.baselineapi.com/api/ParticipantFilmCredit?id=\(participantID)&apikey=\(key!)")
        getHeadshot(participantID)
       
       
        
        

    }
    

    
    func getBio(id:String){
        let key = defaults.objectForKey("apiKey")
        
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let task = defaultSession.dataTaskWithURL(NSURL(string:"http://baselineapi.com/api/ParticipantBioShort?id=\(id)&apikey=\(key!)")!){
            data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        
                        let rawJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        if rawJSON.count == 0 {
                            self.biography = "No biography information avaliable"
                        } else {
                        self.biography = rawJSON[0]["SHORT_BIO"] as! String
                        }
                        
                        
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                }
            }
        }
        
        task.resume()
        
        
        
    }
    
    func getFilmography(url: String){
        let key = defaults.objectForKey("apiKey")
        
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let task = defaultSession.dataTaskWithURL(NSURL(string:"http://www.baselineapi.com/api/ParticipantFilmCredit?id=\(id)&apikey=\(key!)")!){
            data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        
                        let rawJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        /*
                        if rawJSON.count == 0 {
                            self.biography = "No biography information avaliable"
                        } else {
                            self.biography = rawJSON[0]["SHORT_BIO"] as! String
                        }
                        
                        */
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                }
            }
        }
        
        task.resume()
        

        
    }
    
    func getHeadshot(id: String){
        let key = defaults.objectForKey("apiKey")
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let task = defaultSession.dataTaskWithURL(NSURL(string:"http://www.baselineapi.com/api/ParticipantHeadshot?id=\(id)&apikey=\(key!)")!){
            data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        
                        let rawJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        if rawJSON.count == 0 {
                            self.thumbnailImage = nil
                            self.fullImage = nil

                            
                        } else {
                            self.thumbnailImage = rawJSON[0]["LARGE_THUMBNAIL_URL"] as? String
                            self.fullImage = rawJSON[0]["LARGE_URL"] as? String
                            
                            
                        }
                        
                       
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                }
            }
        }
        
        task.resume()
        

        
    }


 
    
        

/*
        id = info["id"] as! String
        name = info["name"] as! String
        role = info["character"] as? String
        type = talentTypeFromString(info["job_function"] as? String)
        billingOrder = info["billing_block_order"] as! Int
        thumbnailImage = info["thumbnail_image"] as? String
        fullImage = info["full_image"] as? String
        biography = info["biography"] as? String
        facebook = info["facebook"] as? String
        facebookID = info["facebookID"] as? String
        twitter = info["twitter"] as? String

        
        if let filmography = info["filmography"] as? NSArray {
            for film in filmography {
                films.append(Film(info: film as! NSDictionary))
            }
        }
        
        if let images = info["gallery"] as? NSArray{
            for image in images{
            gallery.append(image as! String)
            }
        }
    }
    */
    private func talentTypeFromString(typeString: String?) -> TalentType! {
        if typeString != nil {
            let str = typeString!
            switch str {
            case "Actor":
                return TalentType.Actor
                
            case "Director":
                return TalentType.Director
                
            case "Producer":
                return TalentType.Producer
                
            case "Writer":
                return TalentType.Writer
                
            default:
                break
            }
        }
        
        return TalentType.Unknown
    }

}

