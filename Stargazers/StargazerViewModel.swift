//
//  StargazerViewModel.swift
//  Stargazers
//
//  Created by Pietro Santececca on 02/09/17.
//  Copyright © 2017 Tecnojam. All rights reserved.
//

class StargazerViewModel {
    
    // Variables
    var identifier: Int!
    var name: String!
    var imageUrl: String!
    
    // Initialize the view model through the model
    init(stargazer: Stargazer) {
        self.identifier = stargazer.identifier
        self.name = stargazer.name
        self.imageUrl = stargazer.imageUrl
    }
}
