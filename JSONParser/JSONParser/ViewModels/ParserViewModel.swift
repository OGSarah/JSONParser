//
//  ParserViewModel.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
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
