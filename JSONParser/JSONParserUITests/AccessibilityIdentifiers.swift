//
//  AccessibilityIdentifiers.swift
//  JSONParserUITests
//
//  Created by Sarah Clark on 11/3/25.
//

/// Mirror of the app target's `AccessibilityID`.
///
/// The UI test target cannot import the app's internal types, so these string
/// values are duplicated here. Keep them identical to the app's definitions; a
/// mismatch surfaces as a failing UI test rather than a silent regression.
enum AccessibilityID {
    static let jsonEditor = "json.editor"
    static let pasteButton = "json.button.paste"
    static let clearButton = "json.button.clear"
    static let parseButton = "json.button.parse"
    static let resultBanner = "json.result.banner"
    static let resultErrorMessage = "json.result.error"
    static let outputTree = "json.output.tree"
    static let outputEmptyState = "json.output.empty"
    static let treeRowPrefix = "json.tree.row."
}
