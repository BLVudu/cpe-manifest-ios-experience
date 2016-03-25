//
//  BaselineAPIUtil.swift
//  NextGen
//
//  Created by Alec Ananian on 3/18/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import Foundation

let kBaselineIdentifierNamespace = "baseline"

class BaselineAPIUtil: APIUtil {
    
    struct Endpoints {
        static let GetCredits = "/ProjectAllCredits"
        static let GetBio = "/ParticipantBioShort"
        static let GetHeadshot = "/ParticipantHeadshot"
        static let GetFilmography = "/ParticipantFilmCredit"
        static let GetFilmPoster = "/ProjectFilmPoster"
    }
    
    struct Keys {
        static let ParticipantID = "PARTICIPANT_ID"
        static let FullName = "FULL_NAME"
        static let Credit = "CREDIT"
        static let CreditGroup = "CREDIT_GROUP"
        static let ShortBio = "SHORT_BIO"
        static let LargeThumbnailURL = "LARGE_THUMBNAIL_URL"
        static let LargeURL = "LARGE_URL"
        static let FullURL = "FULL_URL"
        static let ProjectID = "PROJECT_ID"
        static let ProjectName = "PROJECT_NAME"
    }
    
    static let sharedInstance = BaselineAPIUtil(apiDomain: "http://baselineapi.com/api")
    
    var projectId: String!
    var apiKey: String!
    
    private var _talent = [Int64: Talent]()
    var orderedTalent: [Talent] {
        get {
            return Array(_talent.values)
        }
    }
    
    func prefetchCredits() {
        getJSONWithPath(Endpoints.GetCredits, parameters: ["id": projectId, "apikey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray {
                for talentInfo in results {
                    if let talentInfo = talentInfo as? NSDictionary, talentID = talentInfo[Keys.ParticipantID] as? NSNumber {
                        self._talent[talentID.longLongValue] = Talent(info: talentInfo)
                    }
                }
            }
        }, errorBlock: nil)
    }
    
    func getTalentBio(talent: Talent) {
        getJSONWithPath(Endpoints.GetBio, parameters: ["id": String(talent.id), "apikey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray, response = results[0] as? NSDictionary, biography = response[Keys.ShortBio] as? String {
                talent.biography = biography
            }
        }, errorBlock: nil)
    }
    
    func getTalentImages(talent: Talent) {
        getJSONWithPath(Endpoints.GetHeadshot, parameters: ["id": String(talent.id), "apiKey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray, response = results[0] as? NSDictionary {
                let talentImage = TalentImage()
                if let thumbnailURL = response[Keys.LargeThumbnailURL] as? String {
                    talentImage.thumbnailImageURL = NSURL(string: thumbnailURL)
                }
                
                if let imageURL = response[Keys.LargeURL] as? String {
                    talentImage.imageURL = NSURL(string: imageURL)
                }
                
                talent.images.append(talentImage)
            }
        }, errorBlock: nil)
    }
    
    func getTalentFilmography(talent: Talent) {
        getJSONWithPath(Endpoints.GetFilmography, parameters: ["id": String(talent.id), "apiKey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray {
                for filmInfo in results {
                    if let filmInfo = filmInfo as? NSDictionary {
                        talent.films.append(TalentFilm(info: filmInfo))
                    }
                }
            }
        }, errorBlock: nil)
    }
    
    func getFilmPoster(film: TalentFilm) {
        getJSONWithPath(Endpoints.GetFilmPoster, parameters: ["id": String(film.id), "apiKey": apiKey], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray, response = results[0] as? NSDictionary, imageURL = response[Keys.FullURL] as? String {
                film.imageURL = NSURL(string: imageURL)
            }
        }, errorBlock: nil)
    }
    
}