//
//  MockJSONParser.swift
//  JSONParserTests
//
//  Created by Sarah Clark on 11/3/25.
//

@testable import JSONParser

/// A test double for ``JSONParsing`` that returns a fixed outcome and records the
/// inputs it was asked to parse.
nonisolated final class MockJSONParser: JSONParsing, @unchecked Sendable {
    private let stub: JSONParseOutcome
    private(set) var receivedInputs: [String] = []

    init(stub: JSONParseOutcome) {
        self.stub = stub
    }

    func parse(_ input: String) -> JSONParseOutcome {
        receivedInputs.append(input)
        return stub
    }
}
