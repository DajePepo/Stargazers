//
//  StartgazersViewModelController.swift
//  Stargazers
//
//  Created by Pietro Santececca on 02/09/17.
//  Copyright © 2017 Tecnojam. All rights reserved.
//

import ReactiveSwift
import Result

class StargazersViewModelController {
    
    // MARK: - Variables
    
    let dataManager = StargazerDataManager()
    var stargazersList = [StargazerViewModel]()
    var isLoading = MutableProperty<Bool>(false)
    var isRefrehsing = MutableProperty<Bool>(false)
    var isLoadingNextPage = MutableProperty<Bool>(false)
    var owner = MutableProperty<String>("")
    var repo = MutableProperty<String>("")
    var page = MutableProperty<Int>(1)
    var stargazersSearchAction: Action<(String, String), [StargazerViewModel], AnyError>?
    var stargazersRefreshAction: Action<(String, String), [StargazerViewModel], AnyError>?
    var areAllStargazersDownloaded: Bool = false
    
    // MARK: - Configuration
    
    func configure() {
        
        stargazersSearchAction = Action<(String, String), [StargazerViewModel], AnyError> {
            (input: (owner: String, repo: String)) -> SignalProducer<[StargazerViewModel], AnyError> in
            
            return self.retrieveStargazers(owner: input.owner, repo: input.repo).on(
                starting: { [unowned self] in
                    self.isLoading.value = true
                },
                terminated: { [unowned self] in
                    self.isLoading.value = false
                },
                value: { [unowned self] stargazers in
                    self.areAllStargazersDownloaded = false
                    self.stargazersList = stargazers
                }
            )
        }
        
        stargazersRefreshAction = Action<(String, String), [StargazerViewModel], AnyError> {
            (input: (owner: String, repo: String)) -> SignalProducer<[StargazerViewModel], AnyError> in
            
            return self.retrieveStargazers(owner: input.owner, repo: input.repo).on(
                starting: { [unowned self] in
                    self.isRefrehsing.value = true
                },
                terminated: { [unowned self] in
                    self.isRefrehsing.value = false
                },
                value: { [unowned self] stargazers in
                    self.areAllStargazersDownloaded = false
                    self.stargazersList = stargazers
                }
            )
        }
        
        page.signal.observeValues { [unowned self] _ in
            self.retrieveStargazers(owner: self.owner.value, repo: self.repo.value, page: self.page.value).on(
                starting: { [unowned self] in
                    self.isLoadingNextPage.value = true
                },
                terminated: { [unowned self] in
                    self.isLoadingNextPage.value = false
                },
                value: { [unowned self] (stargazers: [StargazerViewModel]) in
                    if(stargazers.isEmpty) { self.areAllStargazersDownloaded = true }
                    else { self.stargazersList.append(contentsOf: stargazers) }
                }
            ).start()
        }
    }
    
    // MARK: - Stargazers list methods
    
    // Return number of stargazers
    var stargazersCount: Int {
        return stargazersList.count
    }
    
    // Return a specific stargazer (View Model)
    func stargazerViewModel(at index: Int) -> StargazerViewModel {
        return stargazersList[index]
    }
    
    // Return a specific stargazer (View Model)
    func incrementPage() {
        if(!areAllStargazersDownloaded && !isLoadingNextPage.value && !isLoading.value) {
            page.value = page.value + 1
        }
    }
    
    func retrieveStargazers(owner: String, repo: String, page: Int = 1) -> SignalProducer<[StargazerViewModel], AnyError> {
        return self.dataManager.retrieveStargazers(owner: owner, repo: repo, page: page)
            .map { StargazerViewModel(stargazer: $0) }
            .collect()
    }
    
}
