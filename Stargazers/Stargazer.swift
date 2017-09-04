//
//  Stargazer.swift
//  Stargazers
//
//  Created by Pietro Santececca on 02/09/17.
//  Copyright © 2017 Tecnojam. All rights reserved.
//

import ObjectMapper

class Stargazer: Mappable {
    
    var identifier: Int!
    var name: String!
    var imageUrl: String!
    
    required init?(map: Map) {}
    
    public func mapping(map: Map) {
        identifier <- map["id"]
        name <- map["login"]
        imageUrl <- map["avatar_url"]
    }
}
