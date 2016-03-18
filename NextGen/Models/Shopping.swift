//
//  Shopping.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/3/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class Shopping: NSObject{
    
    var itemBrand: String!
    var itemName: String!
    var itemPrice: String!
    var itemimage: String!
    var itemLink: String!
    
    
    required init(info: NSDictionary) {
        super.init()
        
        itemBrand = info["brand"] as! String
        itemName = info["name"] as! String
        itemPrice = info["price"] as? String
        itemLink = info["link"] as! String
        itemimage = info["image"]as! String
        
        print(itemName)
        
    }

}
