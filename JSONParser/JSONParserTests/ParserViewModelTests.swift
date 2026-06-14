//
//  ParserViewModelTests.swift
//  JSONParserTests
//
//  Created by Sarah Clark on 11/3/25.
//

import Testing
@testable import JSONParser

@MainActor
@Suite("ParserViewModel")
struct ParserViewModelTests {

    private func makeViewModel(
        outcome: JSONParseOutcome,
        pasteboard: String? = nil
    ) -> (ParserViewModel, MockJSONParser) {
        let parser = MockJSONParser(stub: outcome)
        let viewModel = ParserViewModel(parser: parser, pasteboard: MockPasteboard(contents: pasteboard))
        return (viewModel, parser)
    }

    // MARK: - Parsing

    @Test("A valid parse publishes the tree and switches to the output pane")
    func validParse() {
        let outcome = JSONParseOutcome(result: .valid, node: .object(["a": .number(1)]))
        let (viewModel, parser) = makeViewModel(outcome: outcome)
        viewModel.jsonText = "{\"a\": 1}"

        viewModel.parse()

        #expect(viewModel.validationResult == .valid)
        #expect(viewModel.parsedNode == .object(["a": .number(1)]))
        #expect(viewModel.selectedPane == .output)
        #expect(!viewModel.isParsing)
        #expect(parser.receivedInputs == ["{\"a\": 1}"])
    }

    @Test("An invalid parse keeps the editor pane and clears the tree")
    func invalidParse() {
        let error = ParseError(message: "bad", line: 1, column: 1)
        let outcome = JSONParseOutcome(result: .invalid(error), node: nil)
        let (viewModel, _) = makeViewModel(outcome: outcome)
        viewModel.jsonText = "{"

        viewModel.parse()

        #expect(viewModel.validationResult == .invalid(error))
        #expect(viewModel.parsedNode == nil)
        #expect(viewModel.selectedPane == .editor)
    }

    // MARK: - Derived State

    @Test("canParse requires non empty text")
    func canParseRequiresText() {
        let (viewModel, _) = makeViewModel(outcome: JSONParseOutcome(result: .valid, node: .null))
        #expect(!viewModel.canParse)
        viewModel.jsonText = "{}"
        #expect(viewModel.canParse)
    }

    @Test("hasOutput reflects the presence of a parsed tree")
    func hasOutputReflectsTree() {
        let (viewModel, _) = makeViewModel(outcome: JSONParseOutcome(result: .valid, node: .array([])))
        #expect(!viewModel.hasOutput)
        viewModel.jsonText = "[]"
        viewModel.parse()
        #expect(viewModel.hasOutput)
    }

    // MARK: - Paste and Clear

    @Test("Paste copies pasteboard contents into the editor")
    func pastePopulatesEditor() {
        let (viewModel, _) = makeViewModel(
            outcome: JSONParseOutcome(result: .valid, node: .null),
            pasteboard: "{\"pasted\": true}"
        )

        viewModel.paste()

        #expect(viewModel.jsonText == "{\"pasted\": true}")
    }

    @Test("Paste with an empty pasteboard leaves the editor unchanged")
    func pasteWithoutContentsIsNoOp() {
        let (viewModel, _) = makeViewModel(outcome: JSONParseOutcome(result: .valid, node: .null))
        viewModel.jsonText = "existing"

        viewModel.paste()

        #expect(viewModel.jsonText == "existing")
    }

    @Test("Clear resets text, result, tree, and pane")
    func clearResetsState() {
        let outcome = JSONParseOutcome(result: .valid, node: .object(["a": .number(1)]))
        let (viewModel, _) = makeViewModel(outcome: outcome)
        viewModel.jsonText = "{\"a\": 1}"
        viewModel.parse()

        viewModel.clear()

        #expect(viewModel.jsonText.isEmpty)
        #expect(viewModel.validationResult == .none)
        #expect(viewModel.parsedNode == nil)
        #expect(viewModel.selectedPane == .editor)
    }
}
