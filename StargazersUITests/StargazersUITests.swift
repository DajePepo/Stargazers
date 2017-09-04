//
//  StargazersUITests.swift
//  StargazersUITests
//
//  Created by Pietro Santececca on 02/09/17.
//  Copyright © 2017 Tecnojam. All rights reserved.
//

import XCTest

class StargazersUITests: XCTestCase {
    
    let owner = "mdiep"
    let repo = "Tentacle"
    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDownloadStargazers() {
        
        XCTAssertEqual(app.tables["StargazersTableView"].cells.count, 0)
        
        let ownerTextField = self.app.textFields["OwnerTextField"]
        ownerTextField.tap()
        ownerTextField.typeText(owner)
        
        let repoTextField = self.app.textFields["RepoTextField"]
        repoTextField.tap()
        repoTextField.typeText(repo)
        
        app.buttons["SearchButton"].tap()

        let notEmpty = NSPredicate(format: "self.cells.count > 0")
        expectation(for: notEmpty, evaluatedWith: app.tables["StargazersTableView"], handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
    func testRefreshStargazers() {
        
    }

    func testDownloadNextStargazers() {
        
        let ownerTextField = self.app.textFields["OwnerTextField"]
        ownerTextField.tap()
        ownerTextField.typeText(owner)
        
        let repoTextField = self.app.textFields["RepoTextField"]
        repoTextField.tap()
        repoTextField.typeText(repo)
        
        app.buttons["SearchButton"].tap()
        
        let notEmpty = NSPredicate(format: "self.cells.count > 0")
        expectation(for: notEmpty, evaluatedWith: app.tables["StargazersTableView"], handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        let cellsCountBefore = app.tables["StargazersTableView"].cells.count
        
        while !app.activityIndicators["ActivityIndicator"].exists {
            app.tables["StargazersTableView"].swipeUp()
        }
        
        let moreItems = NSPredicate(format: "self.cells.count > %d", cellsCountBefore)
        expectation(for: moreItems, evaluatedWith: app.tables["StargazersTableView"], handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAppDoesNotCrashWithFakeValues() {
    
    }

    func testDoNotDownloadWithoutOwner() {
        
    }
    
    func testDoNotDownloadWithoutRepo() {
        
    }
    
}
