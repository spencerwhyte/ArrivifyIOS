//
//  ArrivifyUITests.swift
//  ArrivifyUITests
//
//  Created by Spencer Whyte on 2016-01-01.
//  Copyright © 2016 Spencer Whyte. All rights reserved.
//

import XCTest

class ArrivifyUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        setupSnapshot(XCUIApplication())
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let app = XCUIApplication()
        
        helper("440 Turk St, San Francisco, CA 94102, USA", people: ["Kate Bell", "John Appleseed"])
        //
        helper("476 Turk St, San Francisco, CA 94102, United States", people: ["Anna Haro", "David Taylor"],  screenshot:true)
        
        helper("510 Larkin St, San Francisco, CA 94102, United States", people: ["Kate Bell", "John Appleseed"])
        //
        helper("560 Larkin St, San Francisco, CA 94102, United States", people: ["Anna Haro", "David Taylor"])
        
        
        sleep(3)
        XCUIApplication().switches.elementMatchingPredicate(NSPredicate(format:"label == 'Saigon Sandwich'")).tap()
        
        snapshot("01AllDestinations")

    }
    
    
    func helper(locationName: String, people:[String], screenshot:Bool = false){
        let app = XCUIApplication()
        let plus72Button = app.buttons["Plus72"]
        plus72Button.tap()
        
        
        sleep(3)
        
        if(screenshot){
            snapshot("03Summary")
        }
        
        let tablesQuery2 = app.tables
        let tapToSelectLocationStaticText = tablesQuery2.staticTexts["Tap to select location"]
        tapToSelectLocationStaticText.tap()
        
        sleep(5)
        
        
        if(screenshot){
            snapshot("04Location")
        }
        sleep(5)
        
        let tablesQuery = tablesQuery2
        tablesQuery.staticTexts["\(locationName)"].tap()
        
        
        let tapToSelectRecipientsStaticText = tablesQuery.staticTexts["Tap to select recipients"]
        
        var limit = 30
        
        while(!tapToSelectRecipientsStaticText.exists || !tapToSelectRecipientsStaticText.hittable){
            
            XCUIApplication().swipeUp()
            sleep(3)
            limit--
            if(limit == 0){
                break
            }
        }
        
        tapToSelectRecipientsStaticText.tap()
        
        
        for person in people{
            XCUIApplication().staticTexts.elementMatchingPredicate(NSPredicate(format:"label == '\(person)'")).tap()
        }
        
        if(screenshot){
            snapshot("02PeoplePicker")
        }
        
        let doneButton = app.navigationBars["Add Members (\(people.count))"].buttons["Done"]
        doneButton.tap()
        
        let doneButton2 = app.navigationBars["New Notification"].buttons["Done"]
        doneButton2.tap()
        
    }
    
    
    
}

