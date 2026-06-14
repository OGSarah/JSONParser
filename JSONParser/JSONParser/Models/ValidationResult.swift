//
//  ValidationResult.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
//

// MARK: - Validation Outcome

/// The result of validating a JSON document.
nonisolated enum ValidationResult: Equatable {
    /// No validation has been performed yet.
    case none
    /// The document is well formed JSON.
    case valid
    /// The document is malformed, carrying the error that explains why.
    case invalid(ParseError)
}

// MARK: - Parse Error

/// A typed error describing why a JSON document failed to parse.
///
/// The optional ``line`` and ``column`` pinpoint the offending character so the
/// UI and tests can surface the exact location of the problem.
nonisolated struct ParseError: Error, Equatable {
    /// A human readable description of the failure.
    let message: String
    /// The 1 based line where the error occurred, when known.
    let line: Int?
    /// The 1 based column where the error occurred, when known.
    let column: Int?

    init(message: String, line: Int? = nil, column: Int? = nil) {
        self.message = message
        self.line = line
        self.column = column
    }
}
