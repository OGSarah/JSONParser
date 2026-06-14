//
//  ValidationResultTests.swift
//  JSONParserTests
//
//  Created by Sarah Clark on 11/3/25.
//

import Testing
@testable import JSONParser

@Suite("ValidationResult and ParseError")
struct ValidationResultTests {

    @Test("Like cases compare equal")
    func likeCasesAreEqual() {
        #expect(ValidationResult.none == .none)
        #expect(ValidationResult.valid == .valid)
    }

    @Test("Different cases compare unequal")
    func differentCasesAreUnequal() {
        #expect(ValidationResult.none != .valid)
        #expect(ValidationResult.valid != .invalid(ParseError(message: "x")))
    }

    @Test("Invalid cases compare by their error")
    func invalidComparesByError() {
        let error = ParseError(message: "boom", line: 2, column: 5)
        #expect(ValidationResult.invalid(error) == .invalid(error))
        #expect(ValidationResult.invalid(error) != .invalid(ParseError(message: "other")))
    }

    @Test("ParseError defaults to no position")
    func parseErrorDefaults() {
        let error = ParseError(message: "no position")
        #expect(error.line == nil)
        #expect(error.column == nil)
    }

    @Test("ParseError retains its position")
    func parseErrorPosition() {
        let error = ParseError(message: "at a spot", line: 3, column: 9)
        #expect(error.line == 3)
        #expect(error.column == 9)
    }

    @Test("ParseError equality includes position")
    func parseErrorEqualityIncludesPosition() {
        let base = ParseError(message: "m", line: 1, column: 1)
        #expect(base == ParseError(message: "m", line: 1, column: 1))
        #expect(base != ParseError(message: "m", line: 1, column: 2))
    }
}
