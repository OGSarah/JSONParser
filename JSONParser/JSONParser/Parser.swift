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

    init(lexer: Lexer) throws {
        self.lexer = lexer
        self.currentToken = try lexer.nextToken()
    }

    func parseValue() throws {
        switch currentToken {
        case .leftBrace: try parseObject()
        case .leftBracket: try parseArray()
        case .string, .number, .bool, .null:
            advance()
        default:
            throw ParseError(message: "Unexpected token \(currentToken) at line ?, column ?")
        }
    }

    // MARK: Private functions
    private func parseObject() throws {
        try eat(.leftBrace)
        if currentToken == .rightBrace {
            advance()
            return
        }

        try parsePair()
        while currentToken == .comma {
            try eat(.comma)
            try parsePair()
        }
        try eat(.rightBrace)
    }

    private func parsePair() throws {
        guard case .string = currentToken else {
            throw ParseError(message: "Expected string key, got \(currentToken)")
        }
        advance()
        try eat(.colon)
        try parseValue()
    }

    private func parseArray() throws {
        try eat(.leftBracket)
        if currentToken == .rightBracket {
            advance()
            return
        }

        try parseValue()
        while currentToken == .comma {
            try eat(.comma)
            try parseValue()
        }
        try eat(.rightBracket)
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
