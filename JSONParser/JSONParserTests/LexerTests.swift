//
//  LexerTests.swift
//  JSONParserTests
//
//  Created by Sarah Clark on 11/3/25.
//

import Testing
@testable import JSONParser

@Suite("Lexer")
struct LexerTests {

    /// Collects every token from the input up to, but not including, end of file.
    private func tokens(_ input: String) throws -> [Token] {
        let lexer = Lexer(input: input)
        var result: [Token] = []
        while true {
            let token = try lexer.nextToken()
            if token == .eof { break }
            result.append(token)
        }
        return result
    }

    // MARK: - Structural Tokens

    @Test("Structural punctuation tokenizes individually")
    func structuralTokens() throws {
        #expect(try tokens("{}[]:,") == [
            .leftBrace, .rightBrace, .leftBracket, .rightBracket, .colon, .comma
        ])
    }

    @Test("Whitespace between tokens is skipped")
    func skipsWhitespace() throws {
        #expect(try tokens("  {\n\t}  ") == [.leftBrace, .rightBrace])
    }

    @Test("Empty input yields end of file immediately")
    func emptyInput() throws {
        let lexer = Lexer(input: "   ")
        #expect(try lexer.nextToken() == .eof)
    }

    // MARK: - Literals

    @Test("Keyword literals tokenize")
    func keywordLiterals() throws {
        #expect(try tokens("true false null") == [.bool(true), .bool(false), .null])
    }

    // MARK: - Strings

    @Test("Plain string tokenizes without quotes")
    func plainString() throws {
        #expect(try tokens("\"hello\"") == [.string("hello")])
    }

    @Test("Escape sequences are decoded", arguments: [
        ("\"a\\\"b\"", "a\"b"),
        ("\"a\\\\b\"", "a\\b"),
        ("\"a\\/b\"", "a/b"),
        ("\"a\\nb\"", "a\nb"),
        ("\"a\\tb\"", "a\tb"),
        ("\"a\\rb\"", "a\rb")
    ])
    func escapeSequences(input: String, expected: String) throws {
        #expect(try tokens(input) == [.string(expected)])
    }

    @Test("Unicode escapes decode to scalars")
    func unicodeEscape() throws {
        #expect(try tokens("\"\\u0041\\u00e9\"") == [.string("Aé")])
    }

    @Test("Unterminated string throws with a position")
    func unterminatedString() throws {
        #expect { try tokens("\"oops") } throws: { error in
            guard let parseError = error as? ParseError else { return false }
            return parseError.message.contains("Unterminated") && parseError.line == 1
        }
    }

    @Test("Control character inside a string throws")
    func controlCharacterInString() throws {
        #expect(throws: ParseError.self) {
            try tokens("\"a\u{01}b\"")
        }
    }

    @Test("Invalid escape sequence throws")
    func invalidEscape() throws {
        #expect(throws: ParseError.self) {
            try tokens("\"a\\xb\"")
        }
    }

    // MARK: - Numbers

    @Test("Number forms tokenize to their double value", arguments: [
        ("0", 0.0),
        ("-42", -42.0),
        ("3.14", 3.14),
        ("-9876.5432", -9876.5432),
        ("1e3", 1000.0),
        ("2E-2", 0.02),
        ("1.5e+2", 150.0)
    ])
    func numberForms(input: String, expected: Double) throws {
        #expect(try tokens(input) == [.number(expected)])
    }

    @Test("Leading plus is not a valid number start")
    func leadingPlusRejected() throws {
        #expect(throws: ParseError.self) {
            try tokens("+1")
        }
    }

    @Test("A decimal point with no following digit throws")
    func danglingDecimalThrows() throws {
        #expect(throws: ParseError.self) {
            try tokens("1.")
        }
    }

    @Test("An exponent with no digits throws")
    func danglingExponentThrows() throws {
        #expect(throws: ParseError.self) {
            try tokens("1e")
        }
    }

    @Test("A lone minus sign throws")
    func loneMinusThrows() throws {
        #expect(throws: ParseError.self) {
            try tokens("-")
        }
    }

    // MARK: - Errors

    @Test("Unexpected characters throw with a line and column")
    func unexpectedCharacter() throws {
        #expect { try tokens("@") } throws: { error in
            guard let parseError = error as? ParseError else { return false }
            // The lexer reports the cursor position, which sits just past the
            // offending character on the same line.
            return parseError.line == 1 && parseError.column != nil
        }
    }

    @Test("A misspelled keyword throws")
    func misspelledKeyword() throws {
        #expect(throws: ParseError.self) {
            try tokens("tru")
        }
    }

    @Test("Position tracks across newlines for error reporting")
    func positionAcrossNewlines() throws {
        #expect { try tokens("{\n  @") } throws: { error in
            guard let parseError = error as? ParseError else { return false }
            return parseError.line == 2
        }
    }
}
