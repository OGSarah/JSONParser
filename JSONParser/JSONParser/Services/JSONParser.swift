//
//  JSONParser.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
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
