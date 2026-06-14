//
//  JSONParserUITests.swift
//  JSONParserUITests
//
//  Created by Sarah Clark on 11/3/25.
//
//  Note: UI automation uses XCTest / XCUIAutomation; Swift Testing cannot drive
//  the UI. These flows are made hermetic with launch arguments that inject a
//  stubbed parser and pasteboard, so they never depend on the real parser.

import XCTest

final class JSONParserUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Helpers

    private func launch(_ arguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTest"] + arguments
        app.launch()
        return app
    }

    /// Finds an element with the given identifier regardless of its element type.
    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    // MARK: - Tests

    @MainActor
    func testLaunchShowsEditorWithParseDisabled() {
        let app = launch(["-uiTestStub", "valid"])

        XCTAssertTrue(app.textViews[AccessibilityID.jsonEditor].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons[AccessibilityID.parseButton].exists)
        XCTAssertFalse(
            app.buttons[AccessibilityID.parseButton].isEnabled,
            "Parse should be disabled when the editor is empty."
        )
    }

    @MainActor
    func testParseValidShowsOutputTree() {
        let app = launch(["-uiTestStub", "valid", "-uiTestSeedText", "{\"a\": 1}"])

        let parseButton = app.buttons[AccessibilityID.parseButton]
        XCTAssertTrue(parseButton.waitForExistence(timeout: 5))
        XCTAssertTrue(parseButton.isEnabled)
        parseButton.click()

        // A valid parse renders the tree and shows no error message.
        XCTAssertTrue(element(AccessibilityID.outputTree, in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element(AccessibilityID.resultBanner, in: app).exists)
        XCTAssertFalse(element(AccessibilityID.resultErrorMessage, in: app).exists)
    }

    @MainActor
    func testParseInvalidShowsError() {
        let app = launch(["-uiTestStub", "invalid", "-uiTestSeedText", "{"])

        app.buttons[AccessibilityID.parseButton].click()

        // An invalid parse shows the empty output state and the result banner,
        // and never renders a parsed tree.
        XCTAssertTrue(element(AccessibilityID.outputEmptyState, in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element(AccessibilityID.resultBanner, in: app).exists)
        XCTAssertFalse(element(AccessibilityID.outputTree, in: app).exists)
    }

    @MainActor
    func testClearResetsEditor() {
        let app = launch(["-uiTestStub", "valid", "-uiTestSeedText", "{\"a\": 1}"])

        let editor = app.textViews[AccessibilityID.jsonEditor]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))

        app.buttons[AccessibilityID.clearButton].click()

        XCTAssertEqual(editor.value as? String, "")
        XCTAssertFalse(app.buttons[AccessibilityID.parseButton].isEnabled)
    }

    @MainActor
    func testPastePopulatesEditor() {
        let app = launch([
            "-uiTestStub", "valid",
            "-uiTestSeedPasteboard", "{\"pasted\": true}"
        ])

        let editor = app.textViews[AccessibilityID.jsonEditor]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))

        app.buttons[AccessibilityID.pasteButton].click()

        XCTAssertEqual(editor.value as? String, "{\"pasted\": true}")
    }

    @MainActor
    func testKeyAccessibilityIdentifiersArePresent() {
        let app = launch(["-uiTestStub", "valid"])

        XCTAssertTrue(app.textViews[AccessibilityID.jsonEditor].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons[AccessibilityID.pasteButton].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.clearButton].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.parseButton].exists)
    }
}
