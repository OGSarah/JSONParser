//
//  JSONParserTests.swift
//  JSONParserTests
//
//  Created by Sarah Clark on 11/3/25.
//

import Testing
@testable import JSONParser

/// End to end tests for the ``JSONParser`` facade, exercising the lexer and parser together.
@Suite("JSONParser Facade")
struct JSONParserFacadeTests {

    private let parser = JSONParser()

    // MARK: - Valid Documents

    @Test("Well formed documents validate and return a tree", arguments: [
        "{}",
        "[]",
        "\"a bare string\"",
        "123.456",
        "{\"nested\": {\"array\": [1, 2, 3], \"flag\": true, \"empty\": null}}",
        "[{\"a\": 1}, {\"b\": 2}]",
        "{\"escapes\": \"line\\nbreak \\u0041\", \"exp\": 1.5e10}"
    ])
    func validDocuments(json: String) {
        let outcome = parser.parse(json)
        #expect(outcome.result == .valid)
        #expect(outcome.node != nil)
    }

    @Test("A valid object produces the expected tree")
    func validTreeShape() {
        let outcome = parser.parse("{\"id\": 7, \"name\": \"test\"}")
        #expect(outcome.node == .object(["id": .number(7), "name": .string("test")]))
    }

    // MARK: - Invalid Documents

    @Test("Malformed documents fail validation", arguments: [
        "{",
        "[1, 2",
        "{\"a\": }",
        "{\"a\" 1}",
        "tru",
        "@invalid",
        ""
    ])
    func invalidDocuments(json: String) {
        let outcome = parser.parse(json)
        #expect(outcome.node == nil)
        guard case .invalid = outcome.result else {
            Issue.record("Expected .invalid for input \(json)")
            return
        }
    }

    @Test("Extra data after a complete value is rejected")
    func extraDataRejected() {
        let outcome = parser.parse("{} {}")
        guard case .invalid(let error) = outcome.result else {
            Issue.record("Expected trailing data to be invalid")
            return
        }
        #expect(error.message.contains("Extra data"))
        #expect(error.line != nil)
    }

    @Test("Trailing comma after a closing bracket is rejected")
    func trailingDataAfterArray() {
        let outcome = parser.parse("[1, 2],")
        #expect(outcome.result != .valid)
    }

    // MARK: - Outcome Equality

    @Test("Outcomes compare by result and node")
    func outcomeEquality() {
        let first = parser.parse("[1, 2, 3]")
        let second = parser.parse("[1, 2, 3]")
        #expect(first == second)
    }
}
