//
//  PositionTests.swift
//  JSONParserTests
//
//  Created by Sarah Clark on 11/3/25.
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
