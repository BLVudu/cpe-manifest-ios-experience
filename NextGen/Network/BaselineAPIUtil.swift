//
//  BaselineAPIUtil.swift
//  NextGen
//
//  Created by Alec Ananian on 3/18/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import Foundation
import NextGenDataManager

public class BaselineAPIUtil: APIUtil, TalentAPIUtil {
    
    struct Endpoints {
        static let GetCredits = "/ProjectAllCredits"
        static let GetBio = "/ParticipantBioShort"
        static let GetImages = "/ParticipantProfileImages"
        static let GetSocialMedia = "/ParticipantSocialMedia"
        static let GetFilmography = "/ParticipantFilmCredit"
        static let GetFilmPoster = "/ProjectFilmPoster"
    }
    
    struct Keys {
        static let ParticipantID = "PARTICIPANT_ID"
        static let FullName = "FULL_NAME"
        static let Credit = "CREDIT"
        static let CreditGroup = "CREDIT_GROUP"
        static let Role = "ROLE"
        static let ShortBio = "SHORT_BIO"
        static let MediumURL = "MEDIUM_URL"
        static let LargeURL = "LARGE_URL"
        static let FullURL = "FULL_URL"
        static let ProjectID = "PROJECT_ID"
        static let ProjectName = "PROJECT_NAME"
        static let Handle = "HANDLE"
        static let URL = "URL"
    }
    
    struct Constants {
        static let MaxCredits = 15
        static let MaxFilmography = 10
    }
    
    public static let sharedInstance = BaselineAPIUtil(apiDomain: "http://baselineapi.com/api")
    
    var projectId: String!
    var apiKey: String!
    
    public func prefetchCredits(successBlock: (talents: [String: Talent]) -> Void) {
        getJSONWithPath(Endpoints.GetCredits, parameters: ["id": projectId, "apikey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray {
                var talents = [String: Talent]()
                for talentInfo in results.subarrayWithRange(NSRange(location: 0, length: min(Constants.MaxCredits, results.count))) {
                    if let talentInfo = talentInfo as? NSDictionary, talentID = talentInfo[Keys.ParticipantID] as? NSNumber {
                        let baselineId = (talentInfo[BaselineAPIUtil.Keys.ParticipantID] as! NSNumber).stringValue
                        let name = talentInfo[BaselineAPIUtil.Keys.FullName] as? String
                        let role = talentInfo[BaselineAPIUtil.Keys.Credit] as? String
                        var type: TalentType?
                        if let creditGroup = talentInfo[BaselineAPIUtil.Keys.CreditGroup] as? String {
                            type = TalentType(rawValue: creditGroup)
                        }
                        
                        talents[talentID.stringValue] = Talent(apiID: baselineId, name: name, role: role, type: type ?? .Unknown)
                    }
                }
                
                successBlock(talents: talents)
            }
        }, errorBlock: nil)
    }
    
    public func getTalentBio(talentID: String, successBlock: (biography: String) -> Void) {
        getJSONWithPath(Endpoints.GetBio, parameters: ["id": talentID, "apikey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray, response = results[0] as? NSDictionary, biography = response[Keys.ShortBio] as? String {
                successBlock(biography: biography)
            }
        }, errorBlock: nil)
    }
    
    public func getTalentImages(talentID: String, successBlock: (talentImages: [TalentImage]?) -> Void) {
        getJSONWithPath(Endpoints.GetImages, parameters: ["id": talentID, "apiKey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray {
                if results.count > 0 {
                    var talentImages = [TalentImage]()
                    for talentImageInfo in results {
                        if let talentImageInfo = talentImageInfo as? NSDictionary {
                            var talentImage = TalentImage()
                            
                            if let thumbnailURLString = talentImageInfo[Keys.MediumURL] as? String {
                                talentImage.thumbnailImageURL = NSURL(string: thumbnailURLString)
                            }
                            
                            if let imageURLString = talentImageInfo[Keys.FullURL] as? String {
                                talentImage.imageURL = NSURL(string: imageURLString)
                            }
                            
                            talentImages.append(talentImage)
                        }
                    }
                    
                    successBlock(talentImages: talentImages)
                } else {
                    successBlock(talentImages: nil)
                }
            }
        }, errorBlock: nil)
    }
    
    public func getTalentSocialAccounts(talentID: String, successBlock: (socialAccounts: [TalentSocialAccount]?) -> Void) {
        getJSONWithPath(Endpoints.GetSocialMedia, parameters: ["id": talentID, "apiKey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray {
                if results.count > 0 {
                    var socialAccounts = [TalentSocialAccount]()
                    for socialAccountInfo in results {
                        if let socialAccountInfo = socialAccountInfo as? NSDictionary {
                            let handle = socialAccountInfo[BaselineAPIUtil.Keys.Handle] as! String
                            let urlString = socialAccountInfo[BaselineAPIUtil.Keys.URL] as! String
                            socialAccounts.append(TalentSocialAccount(handle: handle, urlString: urlString))
                        }
                    }
                    
                    successBlock(socialAccounts: socialAccounts)
                } else {
                    successBlock(socialAccounts: nil)
                }
            }
        }, errorBlock: nil)
    }
    
    public func getTalentFilmography(talentID: String, successBlock: (films: [TalentFilm]) -> Void) {
        getJSONWithPath(Endpoints.GetFilmography, parameters: ["id": talentID, "apiKey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray {
                var films = [TalentFilm]()
                
                for filmInfo in (results.reverse() as NSArray) {
                    if let filmInfo = filmInfo as? NSDictionary where filmInfo[Keys.Role] as? String == "Actor" && filmInfo[Keys.ProjectID] as? Int != 5423190 {
                        let id = (filmInfo[BaselineAPIUtil.Keys.ProjectID] as! NSNumber).stringValue
                        let title = filmInfo[BaselineAPIUtil.Keys.ProjectName] as! String
                        films.append(TalentFilm(id: id, title: title))
                    }
                    
                    if films.count >= Constants.MaxFilmography {
                        break
                    }
                }
                
                successBlock(films: films)
            }
        }, errorBlock: nil)
    }
    
    public func getFilmImageURL(filmID: String, successBlock: (imageURL: NSURL?) -> Void) -> NSURLSessionDataTask {
        return getJSONWithPath(Endpoints.GetFilmPoster, parameters: ["id": filmID, "apiKey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray {
                if results.count > 0 {
                    if let response = results[0] as? NSDictionary, imageURL = response[Keys.LargeURL] as? String {
                        successBlock(imageURL: NSURL(string: imageURL))
                    }
                } else {
                    successBlock(imageURL: nil)
                }
            }
        }, errorBlock: nil)
    }
    
}