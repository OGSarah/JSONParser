//
// ParserViewModel.swift
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

import Observation

/// Drives the JSON editor screen: it owns the input text, runs validation through
/// a ``JSONParsing`` abstraction, and publishes the parsed tree and result for the
/// views to render.
///
/// All UI state lives here rather than in the view, which keeps `ContentView` thin
/// and makes the screen's behavior unit testable with a stubbed parser and
/// pasteboard.
@MainActor
@Observable
final class ParserViewModel {

    /// Which pane of the split view is currently emphasized.
    enum Pane: Hashable {
        case editor
        case output
    }

    // MARK: - Inputs

    /// The raw JSON text the user is editing.
    var jsonText: String = ""

    /// The pane the UI should bring forward.
    var selectedPane: Pane = .editor

    // MARK: - Outputs

    /// The most recent validation result.
    private(set) var validationResult: ValidationResult = .none

    /// The parsed tree for the last successful parse, if any.
    private(set) var parsedNode: JSONNode?

    /// Whether a parse is currently in flight.
    private(set) var isParsing = false

    // MARK: - Dependencies

    private let parser: JSONParsing
    private let pasteboard: PasteboardReading

    init(parser: JSONParsing = JSONParser(), pasteboard: PasteboardReading = SystemPasteboard()) {
        self.parser = parser
        self.pasteboard = pasteboard
    }

    // MARK: - Derived State

    /// Whether the parse action should be enabled.
    var canParse: Bool {
        !jsonText.isEmpty && !isParsing
    }

    /// Whether there is a parsed tree available to show.
    var hasOutput: Bool {
        parsedNode != nil
    }

    // MARK: - Actions

    /// Validates and parses the current ``jsonText``, surfacing the result and tree.
    func parse() {
        isParsing = true
        defer { isParsing = false }

        let outcome = parser.parse(jsonText)
        validationResult = outcome.result
        parsedNode = outcome.node
        if case .valid = outcome.result {
            selectedPane = .output
        }
    }

    /// Replaces the editor contents with the current pasteboard text, if present.
    func paste() {
        guard let contents = pasteboard.readString() else { return }
        jsonText = contents
    }

    /// Clears the editor and resets all derived state back to the empty document.
    func clear() {
        jsonText = ""
        validationResult = .none
        parsedNode = nil
        selectedPane = .editor
    }
}
