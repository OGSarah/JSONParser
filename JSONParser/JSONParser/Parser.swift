//
//  Parser.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
//

import Foundation

class Parser {
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
            throw ParseError(message: "Unexpected token \(currentToken)")
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
            throw ParseError(message: "Expected string key")
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
            throw ParseError(message: "Expected \(expected), got \(currentToken)")
        }
    }

    private func advance() {
        do {
            currentToken = try lexer.nextToken()
        } catch {
            currentToken = .eof
        }
    }

}
