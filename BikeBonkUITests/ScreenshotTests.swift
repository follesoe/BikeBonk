//
//  ScreenshotTests.swift
//  BikeBonkUITests
//
//  Automated screenshot capture for App Store and README.
//  Run with: xcodebuild test -scheme BikeBonk -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:BikeBonkUITests/ScreenshotTests
//

import XCTest

final class ScreenshotTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testScreenshotSafeState() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-SCREENSHOT_MODE", "-BIKES_MOUNTED", "NO"]
        app.launch()

        // Wait for UI to settle
        Thread.sleep(forTimeInterval: 1.0)

        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "safe-state"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testScreenshotWarningState() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-SCREENSHOT_MODE", "-BIKES_MOUNTED", "YES"]
        app.launch()

        // Wait for UI to settle
        Thread.sleep(forTimeInterval: 1.0)

        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "warning-state"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
