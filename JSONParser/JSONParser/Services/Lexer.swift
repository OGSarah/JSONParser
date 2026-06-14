//
// Lexer.swift
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

/// Converts a raw JSON string into a stream of ``Token`` values.
///
/// The lexer is backed by a character array for constant time lookahead and
/// tracks a ``Position`` so every error can report its precise line and column.
nonisolated final class Lexer {
    let input: String
    private let chars: [Character]
    private var position = Position()
    private var readPosition = 0
    private var char: Character?

    init(input: String) {
        self.input = input
        self.chars = Array(input)
        readChar()
    }

    // MARK: - Character Navigation

    private func readChar() {
        if readPosition >= chars.count {
            char = nil
        } else {
            char = chars[readPosition]
            position.advance(chars[readPosition])
        }
        readPosition += 1
    }

    private func peekChar() -> Character? {
        readPosition < chars.count ? chars[readPosition] : nil
    }

    /// The lexer's current position, used by the parser to annotate token level errors.
    var currentPosition: Position { position }

    private func skipWhitespace() {
        while let cha = char, cha.isWhitespace {
            readChar()
        }
    }

    // MARK: - Tokenizing

    func nextToken() throws -> Token {
        skipWhitespace()

        guard let cha = char else { return .eof }

        switch cha {
        case "{": readChar(); return .leftBrace
        case "}": readChar(); return .rightBrace
        case "[": readChar(); return .leftBracket
        case "]": readChar(); return .rightBracket
        case ":": readChar(); return .colon
        case ",": readChar(); return .comma
        case "\"": return try readString()
        case "t", "f": return try readBool()
        case "n": return try readNull()
        case "-", "0"..."9": return try readNumber()
        default:
            throw error("Unexpected character '\(cha)'")
        }
    }

    private func readString() throws -> Token {
        let startPos = position
        readChar() // consume the opening quote
        var result = ""

        while let cha = char, cha != "\"" {
            if cha == "\\" {
                result += try decodeEscape(startingAt: startPos)
            } else if cha < " " {
                throw error("Control character in string")
            } else {
                result += String(cha)
                readChar()
            }
        }

        if char != "\"" {
            throw error("Unterminated string starting", at: startPos)
        }
        readChar()
        return .string(result)
    }

    /// Maps a single character escape (the character after the backslash) to its value.
    private static let simpleEscapes: [Character: Character] = [
        "\"": "\"", "\\": "\\", "/": "/",
        "b": "\u{08}", "f": "\u{0C}", "n": "\n", "r": "\r", "t": "\t"
    ]

    /// Decodes the escape sequence at the cursor, leaving the cursor on the next character.
    private func decodeEscape(startingAt startPos: Position) throws -> String {
        readChar() // consume the backslash
        guard let next = char else {
            throw error("Unterminated string starting", at: startPos)
        }

        if let mapped = Self.simpleEscapes[next] {
            readChar()
            return String(mapped)
        }

        if next == "u" {
            readChar()
            let hex = try readHex4()
            guard let code = Int(hex, radix: 16), let scalar = UnicodeScalar(code) else {
                throw error("Invalid Unicode escape")
            }
            return String(scalar)
        }

        throw error("Invalid escape sequence")
    }

    private func readHex4() throws -> String {
        var hex = ""
        for _ in 0..<4 {
            guard let cha = char, cha.isHexDigit else {
                throw error("Invalid hex digit in Unicode escape")
            }
            hex += String(cha)
            readChar()
        }
        return hex
    }

    private func readNumber() throws -> Token {
        let startPos = position
        var numStr = ""

        if char == "-" { numStr += "-"; readChar() }

        if char == "0" {
            numStr += "0"
            readChar()
        } else if let dec = char, dec.isNumber, dec != "0" {
            while let cha = char, cha.isNumber {
                numStr += String(cha)
                readChar()
            }
        } else {
            throw error("Invalid number", at: startPos)
        }

        if char == "." {
            numStr += "."
            readChar()
            guard let cha = char, cha.isNumber else {
                throw error("Expected digit after decimal point")
            }
            while let cha = char, cha.isNumber {
                numStr += String(cha)
                readChar()
            }
        }

        if let cha = char, cha == "e" || cha == "E" {
            numStr += String(cha)
            readChar()
            if let sign = char, sign == "+" || sign == "-" {
                numStr += String(sign)
                readChar()
            }
            guard let cha = char, cha.isNumber else {
                throw error("Expected exponent digits")
            }
            while let cha = char, cha.isNumber {
                numStr += String(cha)
                readChar()
            }
        }

        guard let value = Double(numStr) else {
            throw error("Invalid number format '\(numStr)'", at: startPos)
        }
        return .number(value)
    }

    private func readBool() throws -> Token {
        if take("true") { return .bool(true) }
        if take("false") { return .bool(false) }
        throw error("Invalid boolean")
    }

    private func readNull() throws -> Token {
        if take("null") { return .null }
        throw error("Invalid null")
    }

    private func take(_ str: String) -> Bool {
        let start = readPosition - 1
        let candidate = Array(str)
        guard start + candidate.count <= chars.count else { return false }
        guard Array(chars[start..<(start + candidate.count)]) == candidate else { return false }
        for _ in 0..<candidate.count { readChar() }
        return true
    }

    // MARK: - Error Helpers

    /// Builds a ``ParseError`` annotated with the lexer's current position.
    private func error(_ message: String) -> ParseError {
        error(message, at: position)
    }

    /// Builds a ``ParseError`` annotated with a specific position.
    private func error(_ message: String, at position: Position) -> ParseError {
        ParseError(
            message: "\(message) at line \(position.line), column \(position.column)",
            line: position.line,
            column: position.column
        )
    }
}

// MARK: - Syntax Highlighting Support

extension Lexer {
    /// Maps the most recently scanned token back to a range in the source string,
    /// used by the editor's syntax highlighter.
    func tokenRange(from start: Int) -> Range<String.Index> {
        let startIdx = input.index(input.startIndex, offsetBy: start)
        let endIdx = input.index(input.startIndex, offsetBy: readPosition - 1)
        return startIdx..<endIdx
    }
}
