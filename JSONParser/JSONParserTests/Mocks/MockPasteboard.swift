//
//  MockPasteboard.swift
//  JSONParserTests
//
//  Created by Sarah Clark on 11/3/25.
//

@testable import JSONParser

/// A test double for ``PasteboardReading`` with canned contents.
nonisolated struct MockPasteboard: PasteboardReading {
    let contents: String?

    func readString() -> String? {
        contents
    }
}
