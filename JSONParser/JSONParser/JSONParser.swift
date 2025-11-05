//
//  JSONParser.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
//

import Foundation

final class JSONParser {
    func parse(_ input: String) -> (result: ValidationResult, node: JSONNode?) {
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)

        do {
            let node = try parser.parseValue()
            if parser.currentToken != .eof {
                throw ParseError(message: "Extra data after JSON")
            }
            return (.valid, node)
        } catch let error as ParseError {
            return (.invalid(error), nil)
        } catch {
            return (.invalid(ParseError(message: "Parsing failed: \(error)")), nil)
        }
    }

}
