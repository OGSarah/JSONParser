//
//  AccessibilityIdentifiers.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
//

/// Stable accessibility identifiers shared by the app's views and the UI test suite.
///
/// The UI test target mirrors these exact string values; keep the two in sync so a
/// renamed identifier surfaces as a failing test rather than a silent regression.
enum AccessibilityID {
    static let jsonEditor = "json.editor"
    static let pasteButton = "json.button.paste"
    static let clearButton = "json.button.clear"
    static let parseButton = "json.button.parse"
    static let resultBanner = "json.result.banner"
    static let resultErrorMessage = "json.result.error"
    static let outputTree = "json.output.tree"
    static let outputEmptyState = "json.output.empty"

    /// Prefix for an individual node row in the output tree, suffixed with its key or index.
    static let treeRowPrefix = "json.tree.row."
}
