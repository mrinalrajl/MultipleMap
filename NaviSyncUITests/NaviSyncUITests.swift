//
//  NaviSyncUITests.swift
//  NaviSyncUITests
//
//  Created by Mrinal Raj on 7/29/26.
//

import XCTest

final class NaviSyncUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTabBarNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify Multi-Map tab
        XCTAssertTrue(app.tabBars.buttons["Multi-Map"].exists)
        
        // Navigate to Meetings tab
        app.tabBars.buttons["Meetings"].tap()
        XCTAssertTrue(app.navigationBars["Joint Meetings"].exists)
        
        // Navigate to CarPlay Drive tab
        app.tabBars.buttons["CarPlay Drive"].tap()
        XCTAssertTrue(app.navigationBars["CarPlay Drive View"].exists)
        
        // Navigate to Applet Info tab
        app.tabBars.buttons["Applet Info"].tap()
        XCTAssertTrue(app.navigationBars["Applet & System Policies"].exists)
    }
}
