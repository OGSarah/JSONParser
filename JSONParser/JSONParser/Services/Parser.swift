//
// Parser.swift
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

/// A recursive descent parser that turns a ``Lexer`` token stream into a ``JSONNode`` tree.
nonisolated final class Parser {
    private let lexer: Lexer
    var currentToken: Token

    init(lexer: Lexer) {
        self.lexer = lexer
        do {
            self.currentToken = try lexer.nextToken()
        } catch {
            self.currentToken = .eof
        }
    }

    func parseValue() throws -> JSONNode {
        switch currentToken {
        case .leftBrace: return try parseObject()
        case .leftBracket: return try parseArray()
        case .string(let str): advance(); return .string(str)
        case .number(let num): advance(); return .number(num)
        case .bool(let boolean): advance(); return .bool(boolean)
        case .null: advance(); return .null
        default:
            throw error("Unexpected token \(currentToken)")
        }
    }

    private func parseObject() throws -> JSONNode {
        try eat(.leftBrace)
        var dict: [String: JSONNode] = [:]

        if currentToken == .rightBrace {
            advance()
            return .object(dict)
        }

        try parsePair(into: &dict)
        while currentToken == .comma {
            try eat(.comma)
            try parsePair(into: &dict)
        }
        try eat(.rightBrace)
        return .object(dict)
    }

    private func parsePair(into dict: inout [String: JSONNode]) throws {
        guard case .string(let key) = currentToken else {
            throw error("Expected string key")
        }
        advance()
        try eat(.colon)
        let value = try parseValue()
        dict[key] = value
    }

    private func parseArray() throws -> JSONNode {
        try eat(.leftBracket)
        var array: [JSONNode] = []

        if currentToken == .rightBracket {
            advance()
            return .array(array)
        }

        array.append(try parseValue())
        while currentToken == .comma {
            try eat(.comma)
            array.append(try parseValue())
        }
        try eat(.rightBracket)
        return .array(array)
    }

    private func eat(_ expected: Token) throws {
        if currentToken == expected {
            advance()
        } else {
            throw error("Expected \(expected), got \(currentToken)")
        }
    }

    private func advance() {
        do {
            currentToken = try lexer.nextToken()
        } catch {
            currentToken = .eof
        }
    }

    /// Builds a ``ParseError`` annotated with the lexer's current position.
    private func error(_ message: String) -> ParseError {
        let position = lexer.currentPosition
        return ParseError(
            message: "\(message) at line \(position.line), column \(position.column)",
            line: position.line,
            column: position.column
        )
    }
}
