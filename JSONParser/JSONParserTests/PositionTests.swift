//
// PositionTests.swift
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

@Suite("Position")
struct PositionTests {

    @Test("A new position starts at line 1, column 1")
    func startsAtOrigin() {
        let position = Position()
        #expect(position.line == 1)
        #expect(position.column == 1)
    }

    @Test("Advancing a non newline increments the column")
    func advancesColumn() {
        var position = Position()
        position.advance("a")
        position.advance("b")
        #expect(position.line == 1)
        #expect(position.column == 3)
    }

    @Test("A newline bumps the line and resets the column")
    func newlineResetsColumn() {
        var position = Position()
        position.advance("a")
        position.advance("\n")
        #expect(position.line == 2)
        #expect(position.column == 1)
    }

    @Test("Tracking holds across multiple lines")
    func multipleLines() {
        var position = Position()
        for character in "ab\ncd\ne" {
            position.advance(character)
        }
        #expect(position.line == 3)
        #expect(position.column == 2)
    }
}
