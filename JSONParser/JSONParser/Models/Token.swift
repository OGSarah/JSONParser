//
//  Token.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
//

/// A single lexical token produced by the ``Lexer``.
nonisolated enum Token: Equatable {
    case leftBrace, rightBrace
    case leftBracket, rightBracket
    case colon, comma
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case eof
}
