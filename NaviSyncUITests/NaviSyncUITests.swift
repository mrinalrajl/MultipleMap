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

    func testAppLaunchAndMainNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify that the app launches and displays the primary view
        let multiMapTitle = app.navigationBars["Multi-Map Live"]
        let exists = multiMapTitle.waitForExistence(timeout: 5.0) || app.tabBars.firstMatch.waitForExistence(timeout: 5.0)
        XCTAssertTrue(exists)
    }

    func testTabBarInteraction() throws {
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 5.0) {
            let meetingsButton = tabBar.buttons["Meetings"]
            if meetingsButton.exists {
                if meetingsButton.isHittable {
                    meetingsButton.tap()
                } else {
                    meetingsButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                }
            }
        }
    }
}
