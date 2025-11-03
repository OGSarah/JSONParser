//
//  Lexer.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
//

class Lexer {
    let input: String
    private var position = Position()
    private var readPosition = 0
    private var char: Character?

    init(input: String) {
        self.input = input
        readChar()
    }

    // MARK: Private functions
    private func readChar() {
        if readPosition >= input.count {
            char = nil
        } else {
            let idx = input.index(input.startIndex, offsetBy: readPosition)
            char = input[idx]
            position.advance(char!)
        }
        readPosition += 1
    }

    private func peekChar() -> Character? {
        if readPosition >= input.count { return nil }
        let idx = input.index(input.startIndex, offsetBy: readPosition)
        return input[idx]
    }

    private func skipWhitespace() {
        while let cha = char, cha.isWhitespace {
            readChar()
        }
    }

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
            throw ParseError(message: "Unexpected character '\(cha)' at line \(position.line), column \(position.column)")
        }
    }

    private func readString() throws -> Token {
        let startPos = position
        readChar() // consume "
        var result = ""

        while let cha = char, cha != "\"" {
            if cha == "\\" {
                readChar()
                guard let next = char else {
                    throw ParseError(message: "Unterminated string starting at line \(startPos.line), column \(startPos.column)")
                }
                switch next {
                case "\"": result += "\""
                case "\\": result += "\\"
                case "/": result += "/"
                case "b": result += "\u{08}"
                case "f": result += "\u{0C}"
                case "n": result += "\n"
                case "r": result += "\r"
                case "t": result += "\t"
                case "u":
                    readChar()
                    let hex = try readHex4()
                    if let scalar = UnicodeScalar(Int(hex, radix: 16)!) {
                        result += String(scalar)
                    } else {
                        throw ParseError(message: "Invalid Unicode escape at line \(position.line), column \(position.column)")
                    }
                default:
                    throw ParseError(message: "Invalid escape sequence at line \(position.line), column \(position.column)")
                }
            } else if cha < " " {
                throw ParseError(message: "Control character in string at line \(position.line), column \(position.column)")
            } else {
                result += String(cha)
            }
            readChar()
        }

        if char != "\"" {
            throw ParseError(message: "Unterminated string starting at line \(startPos.line), column \(startPos.column)")
        }
        readChar()
        return .string(result)
    }

    private func readHex4() throws -> String {
        var hex = ""
        for _ in 0..<4 {
            guard let cha = char, cha.isHexDigit else {
                throw ParseError(message: "Invalid hex digit in Unicode escape at line \(position.line), column \(position.column)")
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
            throw ParseError(message: "Invalid number at line \(startPos.line), column \(startPos.column)")
        }

        if let cha = char, cha == "." {
            numStr += "."
            readChar()
            guard let cha = char, cha.isNumber else {
                throw ParseError(message: "Expected digit after decimal point at line \(position.line), column \(position.column)")
            }
            while let cha = char, cha.isNumber {
                numStr += String(cha)
                readChar()
            }
        }

        if let cha = char, cha == "e" || cha == "E" {
            numStr += String(cha)
            readChar()
            if let cha = char, cha == "+" || cha == "-" {
                numStr += String(cha)
                readChar()
            }
            guard let cha = char, cha.isNumber else {
                throw ParseError(message: "Expected exponent digits at line \(position.line), column \(position.column)")
            }
            while let cha = char, cha.isNumber {
                numStr += String(cha)
                readChar()
            }
        }

        guard let value = Double(numStr) else {
            throw ParseError(message: "Invalid number format '\(numStr)' at line \(startPos.line), column \(startPos.column)")
        }
        return .number(value)
    }

    private func readBool() throws -> Token {
        if take("true") { return .bool(true) }
        if take("false") { return .bool(false) }
        throw ParseError(message: "Invalid boolean at line \(position.line), column \(position.column)")
    }

    private func readNull() throws -> Token {
        if take("null") { return .null }
        throw ParseError(message: "Invalid null at line \(position.line), column \(position.column)")
    }

    private func take(_ str: String) -> Bool {
        let start = readPosition - 1
        guard start + str.count <= input.count else { return false }
        let end = input.index(input.startIndex, offsetBy: start + str.count)
        let substr = String(input[input.index(input.startIndex, offsetBy: start)..<end])

        if substr == str {
            for _ in 0..<str.count { readChar() }
            return true
        }
        return false
    }

}

// MARK: - Lexer Extension for Range
extension Lexer {
    func tokenRange(from start: Int) -> Range<String.Index> {
        let startIdx = input.index(input.startIndex, offsetBy: start)
        let endIdx = input.index(input.startIndex, offsetBy: readPosition - 1)
        return startIdx..<endIdx
    }
}
