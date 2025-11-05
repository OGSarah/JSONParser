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
            Text(num.truncatingRemainder(dividingBy: 1) == 0 ?
                 "\(Int(num))" : "\(num)")
                .foregroundColor(.orange)
        case .bool(let bool):
            Text(bool ? "true" : "false")
                .foregroundColor(.blue)
        case .null:
            Text("null")
                .foregroundColor(.purple)
        }
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
