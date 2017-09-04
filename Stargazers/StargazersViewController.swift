//
//  StragazersViewController.swift
//  Stargazers
//
//  Created by Pietro Santececca on 02/09/17.
//  Copyright © 2017 Tecnojam. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import MBProgressHUD


class StargazersViewController: UIViewController {

    // MARK: - Variables
    
    var nextLoaderHeight: CGFloat = 40
    var viewModel = StargazersViewModelController()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(StargazersViewController.refreshStargazersList), for: UIControlEvents.valueChanged)
        return refreshControl
    }()

    // MARK: - IBOutlets
 
    @IBOutlet weak var stargazersTableView: UITableView! {
        didSet {
            stargazersTableView.accessibilityIdentifier = "StargazersTableView"
        }
    }
    @IBOutlet weak var nextLoader: UIActivityIndicatorView! {
        didSet {
            nextLoader.accessibilityIdentifier = "ActivityIndicator"
        }
    }
    @IBOutlet weak var nextLoaderView: UIView! {
        didSet {
            nextLoaderView.isHidden = true
        }
    }
    @IBOutlet weak var nextLoaderHeightConstraint: NSLayoutConstraint! {
        didSet {
            nextLoaderHeightConstraint.constant = 0
        }
    }
    @IBOutlet weak var ownerTextField: UITextField! {
        didSet {
            ownerTextField.autocorrectionType = .no
            ownerTextField.accessibilityIdentifier = "OwnerTextField"
            ownerTextField.leftViewMode = UITextFieldViewMode.always
            ownerTextField.leftView = UIImageView(image: UIImage(named: "owner"))
            ownerTextField.layer.borderWidth = 1.0
            ownerTextField.layer.borderColor = UIColor(colorLiteralRed: 151/255, green: 151/255, blue: 151/255, alpha: 1.0).cgColor
        }
    }
    @IBOutlet weak var repoTextField: UITextField!{
        didSet {
            repoTextField.autocorrectionType = .no
            repoTextField.accessibilityIdentifier = "RepoTextField"
            repoTextField.leftViewMode = UITextFieldViewMode.always
            repoTextField.leftView = UIImageView(image: UIImage(named: "repo"))
            repoTextField.layer.borderWidth = 1.0
            repoTextField.layer.borderColor = UIColor(colorLiteralRed: 151/255, green: 151/255, blue: 151/255, alpha: 1.0).cgColor
        }
    }
    @IBOutlet weak var searchButton: UIButton! {
        didSet {
            searchButton.accessibilityIdentifier = "SearchButton"
            searchButton.isEnabled = false
        }
    }
    
    // MARK: - Life cylce methods
  
    override func viewDidLoad() {
        super.viewDidLoad()
        //stargazersTableView.addSubview(refreshControl)
        viewModel.configure()
        bind()
        searchButton.isEnabled = false
        nextLoaderHeightConstraint.constant = 0
    }
    
    func bind() {
        
        viewModel.isLoading.producer
            .observe(on: UIScheduler())
            .startWithValues { [weak self] isLoading in
                if isLoading {
                    if self != nil { MBProgressHUD.showAdded(to: self!.view, animated: true) }
                }
                else {
                    self?.stargazersTableView.reloadData()
                    if self != nil { MBProgressHUD.hide(for: self!.view, animated: true) }
                }
        }
        
        viewModel.isRefrehsing.producer
            .observe(on: UIScheduler())
            .startWithValues { [weak self] isRefreshing in
                if !isRefreshing {
                    self?.stargazersTableView.reloadData()
                    self?.refreshControl.endRefreshing()
                }
        }
        
        viewModel.isLoadingNextPage.producer
            .observe(on: UIScheduler())
            .startWithValues { [weak self] isLoading in
                if isLoading {
                    if self != nil { self!.nextLoaderHeightConstraint.constant = self!.nextLoaderHeight }
                    self?.nextLoaderView.isHidden = false
                }
                else {
                    
                    // Wait one sec more to give the ui test the opportunity to check 
                    // if the activity loader exists (it would mean that I'm loading new items)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        self?.stargazersTableView.reloadData()
                        self?.nextLoaderView.isHidden = true
                        self?.nextLoaderHeightConstraint.constant = 0
                    })
                }
        }
        
        ownerTextField.reactive.text <~ viewModel.owner
        repoTextField.reactive.text <~ viewModel.repo
        
        viewModel.owner <~ ownerTextField.reactive.continuousTextValues
            .map { $0!.trimmingCharacters(in: .whitespacesAndNewlines) }
        viewModel.repo <~ repoTextField.reactive.continuousTextValues
            .map { $0!.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        searchButton.reactive.isEnabled <~ Property.combineLatest(viewModel.owner, viewModel.repo)
            .map { !$0.isEmpty && !$1.isEmpty }.signal.observe(on: UIScheduler())
        
        if let action = viewModel.stargazersSearchAction {
            searchButton.reactive.pressed = CocoaAction(action) { _ in
                (self.ownerTextField.text!, self.repoTextField.text!)
            }
        }
    }
    
    func refreshStargazersList() {
        _ = viewModel.stargazersRefreshAction?.apply((self.ownerTextField.text!, self.repoTextField.text!)).start()
    }
}

// MARK: - TableView data source

extension StargazersViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.stargazersCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StargazerTableViewCell", for: indexPath) as? StargazerTableViewCell
        guard let stargazersCell = cell else { return UITableViewCell() }
        stargazersCell.configure(viewModel: viewModel.stargazerViewModel(at: (indexPath as NSIndexPath).row))
        return stargazersCell
    }
}

// MARK: - ScrollView delegate

extension StargazersViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        // If it's the table view bottom
        if offsetY >= contentHeight - scrollView.frame.size.height {
            viewModel.incrementPage()
        }
    }
    
}



