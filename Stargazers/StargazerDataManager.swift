//
//  StargazerDataManager.swift
//  Stargazers
//
//  Created by Pietro Santececca on 02/09/17.
//  Copyright © 2017 Tecnojam. All rights reserved.
//

import ReactiveCocoa
import ReactiveSwift
import Result
import Alamofire
import ObjectMapper

let baseURL = "https://api.github.com/"

class StargazerDataManager {
    
    // Downloads a list of generic T elements from the server
    func retrieveStargazers(owner: String, repo: String, page: Int = 1) -> SignalProducer<Stargazer, AnyError> {
        
        let action = "repos/\(owner)/\(repo)/stargazers"
        let parameters = ["page" : page]
        
        return SignalProducer<Stargazer, AnyError> { observer, disposable in
            
            Alamofire.request(baseURL + action, parameters: parameters).responseJSON { response in
                print(response)
                if response.error == nil, let data = response.data {
                    do {
                        let dataDictionary = try JSONSerialization.jsonObject(with: data, options:[])
                        if let jsonStargazers = dataDictionary as? [[String: Any]] {
                            for jsonStargazer in jsonStargazers {
                                observer.send(value: Stargazer(JSON: jsonStargazer)!)
                            }
                        }
                        observer.sendCompleted()
                    }
                    catch let jsonError {
                        print("Error during json serialization: \(jsonError)")
                        observer.send(error: jsonError as! AnyError)
                    }
                }
                else {
                    print("Error during data retrieving: \(String(describing: response.error))")
                    observer.send(error: response.error as! AnyError)
                }
                
            }
        }
    }
    
}
