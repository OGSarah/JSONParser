//
//  ValidationResult.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
//

// MARK: Error handling related code
enum ValidationResult: Equatable {
    case none
    case valid
    case invalid(ParseError)
}

struct ParseError: Error, Equatable {
    let message: String
}
