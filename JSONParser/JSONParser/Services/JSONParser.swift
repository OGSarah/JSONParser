//
// JSONParser.swift
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

/// The concrete JSON parser, composing a ``Lexer`` and ``Parser``.
///
/// It holds no mutable state, so it is trivially `Sendable` and a fresh lexer and
/// parser are created for every call.
nonisolated struct JSONParser: JSONParsing {
    func parse(_ input: String) -> JSONParseOutcome {
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)

        do {
            let node = try parser.parseValue()
            if parser.currentToken != .eof {
                let position = lexer.currentPosition
                throw ParseError(
                    message: "Extra data after JSON at line \(position.line), column \(position.column)",
                    line: position.line,
                    column: position.column
                )
            }
            return JSONParseOutcome(result: .valid, node: node)
        } catch let error as ParseError {
            return JSONParseOutcome(result: .invalid(error), node: nil)
        } catch {
            return JSONParseOutcome(result: .invalid(ParseError(message: "Parsing failed: \(error)")), node: nil)
        }
    }
}
