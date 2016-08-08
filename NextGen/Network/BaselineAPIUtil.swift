//
//  BaselineAPIUtil.swift
//

import Foundation
import NextGenDataManager

public class BaselineAPIUtil: APIUtil, TalentAPIUtil {
    
    public static var APIDomain = "http://baselineapi.com/api"
    
    private struct Endpoints {
        static let GetCredits = "/ProjectAllCredits"
        static let GetBio = "/ParticipantBioShort"
        static let GetImages = "/ParticipantProfileImages"
        static let GetSocialMedia = "/ParticipantSocialMedia"
        static let GetFilmography = "/ParticipantFilmCredit"
        static let GetFilmPoster = "/ProjectFilmPoster"
    }
    
    private struct Keys {
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
    
    private struct Constants {
        static let MaxCredits = 15
        static let MaxFilmography = 10
    }
    
    public var apiNamespace = Namespaces.Baseline
    public var apiId: String?
    
    public convenience init(apiKey: String) {
        self.init(apiDomain: BaselineAPIUtil.APIDomain)
        
        self.customHeaders["x-api-key"] = apiKey
    }
    
    public func prefetchCredits(successBlock: (talents: [String: NGDMTalent]?) -> Void) {
        if let apiId = apiId {
            getJSONWithPath(Endpoints.GetCredits, parameters: ["id": apiId], successBlock: { (result) -> Void in
                if let results = result["result"] as? NSArray {
                    var talents = [String: NGDMTalent]()
                    for talentInfo in results.subarrayWithRange(NSRange(location: 0, length: min(Constants.MaxCredits, results.count))) {
                        if let talentInfo = talentInfo as? NSDictionary, talentId = talentInfo[Keys.ParticipantID] as? NSNumber {
                            let baselineId = (talentInfo[BaselineAPIUtil.Keys.ParticipantID] as! NSNumber).stringValue
                            let name = talentInfo[BaselineAPIUtil.Keys.FullName] as? String
                            let role = talentInfo[BaselineAPIUtil.Keys.Credit] as? String
                            var type: TalentType?
                            if let creditGroup = talentInfo[BaselineAPIUtil.Keys.CreditGroup] as? String {
                                type = TalentType(rawValue: creditGroup)
                            }
                            
                            talents[talentId.stringValue] = NGDMTalent(apiId: baselineId, name: name, role: role, type: type ?? .Unknown)
                        }
                    }
                    
                    successBlock(talents: talents)
                }
            }, errorBlock: nil)
        } else {
            successBlock(talents: nil)
        }
    }
    
    public func getTalentBio(talentId: String, successBlock: (biography: String?) -> Void) {
        getJSONWithPath(Endpoints.GetBio, parameters: ["id": talentId], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray, response = results[0] as? NSDictionary, biography = response[Keys.ShortBio] as? String {
                successBlock(biography: biography.htmlDecodedString())
            } else {
                successBlock(biography: nil)
            }
        }, errorBlock: nil)
    }
    
    public func getTalentImages(talentId: String, successBlock: (talentImages: [TalentImage]?) -> Void) {
        getJSONWithPath(Endpoints.GetImages, parameters: ["id": talentId], successBlock: { (result) -> Void in
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
    
    public func getTalentSocialAccounts(talentId: String, successBlock: (socialAccounts: [TalentSocialAccount]?) -> Void) {
        getJSONWithPath(Endpoints.GetSocialMedia, parameters: ["id": talentId], successBlock: { (result) -> Void in
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
    
    public func getTalentFilmography(talentId: String, successBlock: (films: [TalentFilm]) -> Void) {
        getJSONWithPath(Endpoints.GetFilmography, parameters: ["id": talentId], successBlock: { (result) -> Void in
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
        return getJSONWithPath(Endpoints.GetFilmPoster, parameters: ["id": filmID], successBlock: { (result) -> Void in
            var imageURL: NSURL?
            if let results = result["result"] as? NSArray where results.count > 0 {
                if let response = results[0] as? NSDictionary, posterImageURL = response[Keys.LargeURL] as? String {
                    imageURL = NSURL(string: posterImageURL)
                }
            }
            
            successBlock(imageURL: imageURL)
        }, errorBlock: nil)
    }
    
}