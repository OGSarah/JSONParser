//
// AccessibilityIdentifiers.swift
// JSONParser
//
// MIT License
//
// Copyright (c) 2026 SarahUniverse
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
