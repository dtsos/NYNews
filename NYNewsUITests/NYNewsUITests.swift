//
//  NYNewsUITests.swift
//  NYNewsUITests
//
//  Created by David Trivian S on 5/5/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import XCTest

class NYNewsUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testHeadline(){
        
        
        let element = XCUIApplication().collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        element.swipeUp()
        element.swipeUp()
        
        
        
        
    }
    func testDown(){
        
        let element = XCUIApplication().collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        element.swipeDown()
        element.swipeDown()
        
        
    }
    
    func testSearch(){
        
        
        //        let app = XCUIApplication()
        //        app.navigationBars["NY Times"].buttons["Search"].tap()
        //        app.searchFields["Keyword"].typeText("ok")
        //        app.typeText("e\r")
        
        let app = XCUIApplication()
        app.navigationBars["NY Times"].buttons["Search"].tap()
        app.searchFields["Keyword"].typeText("Who ")
        app.typeText("are\r")
        
        
    }
    
    func testSearchButton(){
        
        
        
        
        let app = XCUIApplication()
        app.navigationBars["NY Times"].buttons["Search"].tap()
        app.searchFields["Keyword"].typeText("I ")
        app.typeText("You\r")
        app.buttons["Cancel"].tap()
        
        
    }
    
    
    func testDetail(){
        
        
        let collectionViewsQuery = XCUIApplication()
            .collectionViews
        collectionViewsQuery.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.tap()
        
        let element = collectionViewsQuery.webViews.children(matching: .other).element
        element.swipeUp()
        element.swipeLeft()
        element.swipeLeft()
        
        
    }
    
   
}
