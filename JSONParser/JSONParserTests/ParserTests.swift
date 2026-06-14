//
// ParserTests.swift
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

@Suite("Parser")
struct ParserTests {

    private func parse(_ input: String) throws -> JSONNode {
        let parser = Parser(lexer: Lexer(input: input))
        return try parser.parseValue()
    }

    // MARK: - Scalars

    @Test("Scalar values parse to their node")
    func scalars() throws {
        #expect(try parse("\"hi\"") == .string("hi"))
        #expect(try parse("42") == .number(42))
        #expect(try parse("true") == .bool(true))
        #expect(try parse("false") == .bool(false))
        #expect(try parse("null") == .null)
    }

    // MARK: - Objects

    @Test("Empty object parses")
    func emptyObject() throws {
        #expect(try parse("{}") == .object([:]))
    }

    @Test("Object with multiple members parses")
    func multiMemberObject() throws {
        let expected = JSONNode.object([
            "name": .string("Sarah"),
            "active": .bool(true),
            "count": .number(3)
        ])
        #expect(try parse("{\"name\": \"Sarah\", \"active\": true, \"count\": 3}") == expected)
    }

    @Test("Nested objects parse recursively")
    func nestedObject() throws {
        let expected = JSONNode.object(["outer": .object(["inner": .number(1)])])
        #expect(try parse("{\"outer\": {\"inner\": 1}}") == expected)
    }

    // MARK: - Arrays

    @Test("Empty array parses")
    func emptyArray() throws {
        #expect(try parse("[]") == .array([]))
    }

    @Test("Mixed type array parses")
    func mixedArray() throws {
        let expected = JSONNode.array([.number(1), .string("two"), .bool(false), .null])
        #expect(try parse("[1, \"two\", false, null]") == expected)
    }

    @Test("Nested arrays parse recursively")
    func nestedArray() throws {
        let expected = JSONNode.array([.array([.number(1), .number(2)]), .array([])])
        #expect(try parse("[[1, 2], []]") == expected)
    }

    // MARK: - Errors

    @Test("A non string object key throws")
    func nonStringKeyThrows() throws {
        #expect(throws: ParseError.self) {
            try parse("{1: 2}")
        }
    }

    @Test("A missing colon throws")
    func missingColonThrows() throws {
        #expect(throws: ParseError.self) {
            try parse("{\"a\" 1}")
        }
    }

    @Test("A trailing comma in an object throws")
    func trailingCommaObjectThrows() throws {
        #expect(throws: ParseError.self) {
            try parse("{\"a\": 1,}")
        }
    }

    @Test("A trailing comma in an array throws")
    func trailingCommaArrayThrows() throws {
        #expect(throws: ParseError.self) {
            try parse("[1, 2,]")
        }
    }

    @Test("An unclosed object throws")
    func unclosedObjectThrows() throws {
        #expect(throws: ParseError.self) {
            try parse("{\"a\": 1")
        }
    }

    @Test("Parser errors carry a position")
    func errorsCarryPosition() throws {
        #expect { try parse("[1 2]") } throws: { error in
            guard let parseError = error as? ParseError else { return false }
            return parseError.line != nil && parseError.column != nil
        }
    }
}
