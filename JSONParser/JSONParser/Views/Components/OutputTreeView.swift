//
//  OutputTreeView.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/5/25.
//

import SwiftUI

/// A scrollable container that renders a parsed ``JSONNode`` tree.
struct OutputTreeView: View {
    let node: JSONNode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                JSONNodeView(node: node, depth: 0)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(NSColor.textBackgroundColor), in: .rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color(NSColor.separatorColor), lineWidth: 1)
        )
        .accessibilityIdentifier(AccessibilityID.outputTree)
        .accessibilityLabel("Parsed JSON tree")
    }
}

#Preview {
    OutputTreeView(
        node: .object([
            "name": .string("JSON Parser"),
            "valid": .bool(true),
            "tags": .array([.string("swift"), .string("macOS")])
        ])
    )
    .padding()
    .frame(width: 420, height: 320)
}
