//
// JSONParserTests.swift
// JSONParserTests
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
