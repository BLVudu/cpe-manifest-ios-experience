//
//  BaselineAPIUtil.swift
//

import Foundation
import NextGenDataManager

public class BaselineAPIUtil: APIUtil, TalentAPIUtil {
    
    public static var APIDomain = "https://vic57ayytg.execute-api.us-west-2.amazonaws.com/prod"
    
    private struct Endpoints {
        static let GetCredits = "/film/credits"
        static let GetTalentImages = "/talent/images"
        static let GetTalentDetails = "/talent"
    }
    
    private struct Keys {
        static let ParticipantID = "PARTICIPANT_ID"
        static let FullName = "FULL_NAME"
        static let Credit = "CREDIT"
        static let CreditGroup = "CREDIT_GROUP"
        static let Role = "ROLE"
        static let Filmography = "FILMOGRAPHY"
        static let SocialAccounts = "SOCIAL_ACCOUNTS"
        static let Posters = "POSTERS"
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
                    
                    var i = 0
                    for talentInfo in results.subarrayWithRange(NSRange(location: 0, length: min(Constants.MaxCredits, results.count))) {
                        if let talentInfo = talentInfo as? NSDictionary, talentId = talentInfo[Keys.ParticipantID] as? NSNumber {
                            let baselineId = (talentInfo[Keys.ParticipantID] as! NSNumber).stringValue
                            let name = talentInfo[Keys.FullName] as? String
                            let role = talentInfo[Keys.Credit] as? String
                            var type: TalentType?
                            if let creditGroup = talentInfo[Keys.CreditGroup] as? String {
                                type = TalentType(rawValue: creditGroup)
                            }
                            
                            talents[talentId.stringValue] = NGDMTalent(apiId: baselineId, name: name, role: role, billingBlockOrder: i, type: type ?? .Unknown)
                        }
                        
                        i += 1
                    }
                    
                    successBlock(talents: talents)
                }
            }, errorBlock: nil)
        } else {
            successBlock(talents: nil)
        }
    }
    
    public func getTalentImages(talentId: String, successBlock: (talentImages: [TalentImage]?) -> Void) {
        getJSONWithPath(Endpoints.GetTalentImages, parameters: ["id": talentId], successBlock: { (result) -> Void in
            if let results = result["result"] as? NSArray where results.count > 0 {
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
        }, errorBlock: nil)
    }
    
    public func getTalentDetails(talentId: String, successBlock: (biography: String?, socialAccounts: [TalentSocialAccount]?, films: [TalentFilm]) -> Void) {
        getJSONWithPath(Endpoints.GetTalentDetails, parameters: ["id": talentId], successBlock: { (result) in
            var socialAccounts = [TalentSocialAccount]()
            if let socialAccountInfoList = result[Keys.SocialAccounts] as? NSArray {
                for socialAccountInfo in socialAccountInfoList {
                    if let socialAccountInfo = socialAccountInfo as? NSDictionary {
                        let handle = socialAccountInfo[Keys.Handle] as! String
                        let urlString = socialAccountInfo[Keys.URL] as! String
                        socialAccounts.append(TalentSocialAccount(handle: handle, urlString: urlString))
                    }
                }
            }
            
            var films = [TalentFilm]()
            if let filmInfoList = result[Keys.Filmography] as? NSArray {
                for filmInfo in filmInfoList {
                    if let filmInfo = filmInfo as? NSDictionary {
                        let id = (filmInfo[Keys.ProjectID] as! NSNumber).stringValue
                        let title = filmInfo[Keys.ProjectName] as! String
                        
                        var imageURL: NSURL?
                        if let posterImageURLString = ((filmInfo[Keys.Posters] as? NSArray)?.firstObject as? NSDictionary)?[Keys.LargeURL] as? String {
                            imageURL = NSURL(string: posterImageURLString)
                        }
                        
                        films.append(TalentFilm(id: id, title: title, imageURL: imageURL))
                    }
                }
            }
            
            successBlock(biography: result[Keys.ShortBio] as? String, socialAccounts: socialAccounts, films: films)
        }, errorBlock: nil)
    }
    
}