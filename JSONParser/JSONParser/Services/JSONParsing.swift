//
//  JSONParsing.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
//

/// The outcome of parsing a JSON document: a validation result paired with the
/// parsed tree when the document is well formed.
nonisolated struct JSONParseOutcome: Equatable {
    let result: ValidationResult
    let node: JSONNode?
}

/// An abstraction over JSON parsing.
///
/// View models depend on this protocol rather than the concrete ``JSONParser`` so
/// they can be unit tested with a stub and so the parsing implementation stays
/// swappable.
protocol JSONParsing: Sendable {
    /// Parses the given string, returning whether it is valid JSON and, if so, its tree.
    nonisolated func parse(_ input: String) -> JSONParseOutcome
}
