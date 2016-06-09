//
//  BaselineAPIUtil.swift
//  NextGen
//
//  Created by Alec Ananian on 3/18/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import Foundation
import NextGenDataManager

class BaselineAPIUtil: APIUtil, TalentAPIUtil {
    
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
    
    static let sharedInstance = BaselineAPIUtil(apiDomain: "http://baselineapi.com/api")
    
    var projectId: String!
    var apiKey: String!
    
    func prefetchCredits(successBlock: (talents: [String: Talent]) -> Void) {
        getJSONWithPath(Endpoints.GetCredits, parameters: ["id": projectId, "apikey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray {
                var talents = [String: Talent]()
                for talentInfo in results.subarrayWithRange(NSRange(location: 0, length: min(Constants.MaxCredits, results.count))) {
                    if let talentInfo = talentInfo as? NSDictionary, talentID = talentInfo[Keys.ParticipantID] as? NSNumber {
                        talents[talentID.stringValue] = Talent(baselineInfo: talentInfo)
                    }
                }
                
                successBlock(talents: talents)
            }
        }, errorBlock: nil)
    }
    
    func getTalentBio(talentID: String, successBlock: (biography: String) -> Void) {
        getJSONWithPath(Endpoints.GetBio, parameters: ["id": talentID, "apikey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray, response = results[0] as? NSDictionary, biography = response[Keys.ShortBio] as? String {
                successBlock(biography: biography)
            }
        }, errorBlock: nil)
    }
    
    func getTalentImages(talentID: String, successBlock: (talentImages: [TalentImage]?) -> Void) {
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
    
    func getTalentSocialAccounts(talentID: String, successBlock: (socialAccounts: [TalentSocialAccount]?) -> Void) {
        getJSONWithPath(Endpoints.GetSocialMedia, parameters: ["id": talentID, "apiKey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray {
                if results.count > 0 {
                    var socialAccounts = [TalentSocialAccount]()
                    for socialAccountInfo in results {
                        if let socialAccountInfo = socialAccountInfo as? NSDictionary {
                            socialAccounts.append(TalentSocialAccount(baselineInfo: socialAccountInfo))
                        }
                    }
                    
                    successBlock(socialAccounts: socialAccounts)
                } else {
                    successBlock(socialAccounts: nil)
                }
            }
        }, errorBlock: nil)
    }
    
    func getTalentFilmography(talentID: String, successBlock: (films: [TalentFilm]) -> Void) {
        getJSONWithPath(Endpoints.GetFilmography, parameters: ["id": talentID, "apiKey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray {
                var films = [TalentFilm]()
                
                for filmInfo in (results.reverse() as NSArray) {
                    if let filmInfo = filmInfo as? NSDictionary where filmInfo[Keys.Role] as? String == "Actor" && filmInfo[Keys.ProjectID] as? Int != 5423190 {
                        films.append(TalentFilm(baselineInfo: filmInfo))
                    }
                    
                    if films.count >= Constants.MaxFilmography {
                        break
                    }
                }
                
                successBlock(films: films)
            }
        }, errorBlock: nil)
    }
    
    func getFilmImageURL(filmID: String, successBlock: (imageURL: NSURL?) -> Void) -> NSURLSessionDataTask {
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