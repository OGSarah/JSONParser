//
//  JSONNodeView.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/5/25.
//

import SwiftUI

struct JSONNodeView: View {
    let node: JSONNode
    let depth: Int

    @State private var isExpanded = true

    var body: some View {
        switch node {
        case .object(let dict):
            collapsibleView {
                ForEach(dict.keys.sorted(), id: \.self) { key in
                    let value = dict[key]!
                    HStack(alignment: .top, spacing: 4) {
                        Text("\"\(key)\"")
                            .foregroundColor(.green)
                        Text(":")
                        JSONNodeView(node: value, depth: depth + 1)
                    }
                }
            } label: {
                Label(dict.isEmpty ? "{}" : "Object (\(dict.count) items)", systemImage: "folder")
            }

        case .array(let array):
            collapsibleView {
                ForEach(Array(array.enumerated()), id: \.offset) { index, value in
                    HStack(alignment: .top, spacing: 4) {
                        Text("[\(index)]")
                            .foregroundColor(.secondary)
                        JSONNodeView(node: value, depth: depth + 1)
                    }
                }
            } label: {
                Label(array.isEmpty ? "[]" : "Array (\(array.count) items)", systemImage: "list.bullet")
            }

        case .string(let str):
            Text("\"\(str)\"")
                .foregroundColor(.green)
        case .number(let num):
            Text(formattedNumber(num))
                .foregroundColor(.orange)
        case .bool(let bool):
            Text(bool ? "true" : "false")
                .foregroundColor(.blue)
        case .null:
            Text("null")
                .foregroundColor(.purple)
        }
    }

    // Formats numbers without trailing ".0" if integral, and avoids Int overflow.
    private func formattedNumber(_ value: Double) -> String {
        // If it's integral, format with zero fraction digits.
        if value.isFinite, value.rounded(.towardZero) == value {
            let numFormatter = NumberFormatter()
            numFormatter.locale = Locale(identifier: "en_US_POSIX")
            numFormatter.numberStyle = .decimal
            numFormatter.maximumFractionDigits = 0
            numFormatter.usesGroupingSeparator = false
            if let s = numFormatter.string(from: NSNumber(value: value)) {
                return s
            }
        }
        // Fallback: format with up to 15 fraction digits to preserve typical JSON precision
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "en_US_POSIX")
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 15
        nf.minimumFractionDigits = 0
        nf.usesGroupingSeparator = false
        return nf.string(from: NSNumber(value: value)) ?? String(value)
    }

    @ViewBuilder
    private func collapsibleView<Content: View, Label: View>(
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> Label
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                label()
            }
            .foregroundColor(.primary)
            .onTapGesture { isExpanded.toggle() }

            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    content()
                }
                .padding(.leading, 16)
            }
        }
        .padding(.leading, CGFloat(depth * 12))
    }

}
