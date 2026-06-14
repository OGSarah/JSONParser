//
//  JSONNodeView.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/5/25.
//

import SwiftUI

/// Recursively renders a ``JSONNode`` as an indented, collapsible tree.
struct JSONNodeView: View {
    let node: JSONNode
    let depth: Int

    @State private var isExpanded = true

    var body: some View {
        switch node {
        case .object(let dict):
            collapsibleView {
                ForEach(dict.keys.sorted(), id: \.self) { key in
                    if let value = dict[key] {
                        keyedRow(key: key, value: value)
                    }
                }
            } label: {
                Label(dict.isEmpty ? "{}" : "Object, \(dict.count) items", systemImage: "folder")
            }

        case .array(let array):
            collapsibleView {
                ForEach(Array(array.enumerated()), id: \.offset) { index, value in
                    indexedRow(index: index, value: value)
                }
            } label: {
                Label(array.isEmpty ? "[]" : "Array, \(array.count) items", systemImage: "list.bullet")
            }

        case .string(let str):
            Text("\"\(str)\"")
                .foregroundStyle(.green)
                .accessibilityLabel("string, \(str)")
        case .number(let num):
            Text(formattedNumber(num))
                .foregroundStyle(.orange)
                .accessibilityLabel("number, \(formattedNumber(num))")
        case .bool(let bool):
            Text(bool ? "true" : "false")
                .foregroundStyle(.blue)
                .accessibilityLabel("boolean, \(bool ? "true" : "false")")
        case .null:
            Text("null")
                .foregroundStyle(.purple)
                .accessibilityLabel("null")
        }
    }

    // MARK: - Rows

    @ViewBuilder
    private func keyedRow(key: String, value: JSONNode) -> some View {
        let row = HStack(alignment: .top, spacing: 4) {
            Text("\"\(key)\"")
                .foregroundStyle(.green)
            Text(":")
                .accessibilityHidden(true)
            JSONNodeView(node: value, depth: depth + 1)
        }
        .accessibilityIdentifier(AccessibilityID.treeRowPrefix + key)

        // Collapse leaf rows into one spoken element ("key, value"); keep container
        // rows navigable so VoiceOver can still drill into nested structure.
        if value.isLeaf {
            row.accessibilityElement(children: .combine)
        } else {
            row
        }
    }

    @ViewBuilder
    private func indexedRow(index: Int, value: JSONNode) -> some View {
        let row = HStack(alignment: .top, spacing: 4) {
            Text("[\(index)]")
                .foregroundStyle(.secondary)
            JSONNodeView(node: value, depth: depth + 1)
        }
        .accessibilityIdentifier(AccessibilityID.treeRowPrefix + "\(index)")

        if value.isLeaf {
            row.accessibilityElement(children: .combine)
        } else {
            row
        }
    }

    // MARK: - Collapsible Container

    @ViewBuilder
    private func collapsibleView<Content: View, Label: View>(
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> Label
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .accessibilityHidden(true)
                label()
            }
            .foregroundStyle(.primary)
            .contentShape(.rect)
            .onTapGesture { isExpanded.toggle() }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits([.isButton, .isHeader])
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
            .accessibilityHint("Double tap to expand or collapse.")
            .accessibilityAction { isExpanded.toggle() }

            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    content()
                }
                .padding(.leading, 16)
            }
        }
        .padding(.leading, CGFloat(depth * 12))
    }

    // MARK: - Number Formatting

    /// Formats numbers without a trailing ".0" when integral, preserving precision otherwise.
    private func formattedNumber(_ value: Double) -> String {
        if value.isFinite, value.rounded(.towardZero) == value {
            let integerFormatter = NumberFormatter()
            integerFormatter.locale = Locale(identifier: "en_US_POSIX")
            integerFormatter.numberStyle = .decimal
            integerFormatter.maximumFractionDigits = 0
            integerFormatter.usesGroupingSeparator = false
            if let formatted = integerFormatter.string(from: NSNumber(value: value)) {
                return formatted
            }
        }

        let decimalFormatter = NumberFormatter()
        decimalFormatter.locale = Locale(identifier: "en_US_POSIX")
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.maximumFractionDigits = 15
        decimalFormatter.minimumFractionDigits = 0
        decimalFormatter.usesGroupingSeparator = false
        return decimalFormatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}

#Preview {
    JSONNodeView(
        node: .object([
            "name": .string("JSON Parser"),
            "count": .number(3),
            "nested": .array([.bool(true), .null])
        ]),
        depth: 0
    )
    .padding()
}
