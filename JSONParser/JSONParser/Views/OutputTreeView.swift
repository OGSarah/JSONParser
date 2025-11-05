//
//  OutputTreeView.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/5/25.
//

import SwiftUI

struct OutputTreeView: View {
    let node: JSONNode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                JSONNodeView(node: node, depth: 0)
            }
            .padding()
        }
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
    }

}
