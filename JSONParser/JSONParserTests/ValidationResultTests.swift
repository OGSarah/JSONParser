//
// ValidationResultTests.swift
// JSONParserTests
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
