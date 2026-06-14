//
//  Pasteboard.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
//

import AppKit

/// A minimal abstraction over the system pasteboard so the view model's paste
/// behavior can be unit tested without touching `NSPasteboard`.
protocol PasteboardReading: Sendable {
    /// The current plain text contents of the pasteboard, if any.
    nonisolated func readString() -> String?
}

/// The live pasteboard backed by `NSPasteboard.general`.
nonisolated struct SystemPasteboard: PasteboardReading {
    func readString() -> String? {
        NSPasteboard.general.string(forType: .string)
    }
}
