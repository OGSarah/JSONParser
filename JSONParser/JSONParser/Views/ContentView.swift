//
// ContentView.swift
// JSONParser
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

import SwiftUI

/// The root screen: a two column split with the JSON editor on the leading side
/// and the parsed output tree on the trailing side, driven by ``ParserViewModel``.
struct ContentView: View {
    @State private var viewModel: ParserViewModel

    init(viewModel: ParserViewModel? = nil) {
        self.viewModel = viewModel ?? ParserViewModel()
    }

    var body: some View {
        NavigationSplitView {
            editorColumn
                .navigationSplitViewColumnWidth(min: 320, ideal: 460)
                .navigationTitle("Input")
        } detail: {
            outputColumn
                .navigationTitle("Output")
        }
        .toolbar { toolbarContent }
        .frame(minWidth: 900, minHeight: 600)
    }

    // MARK: - Editor Column

    private var editorColumn: some View {
        SyntaxTextView(text: $viewModel.jsonText)
            .accessibilityIdentifier(AccessibilityID.jsonEditor)
            .accessibilityLabel("JSON input editor")
            .accessibilityHint("Enter or paste the JSON you want to validate.")
    }

    // MARK: - Output Column

    private var outputColumn: some View {
        Group {
            if let node = viewModel.parsedNode {
                OutputTreeView(node: node)
            } else {
                emptyOutputState
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            ResultBanner(result: viewModel.validationResult)
                .padding([.horizontal, .bottom])
        }
    }

    private var emptyOutputState: some View {
        ContentUnavailableView(
            "No Parsed Output",
            systemImage: "curlybraces.square",
            description: Text("Parse a valid JSON document to explore its structure here.")
        )
        .accessibilityIdentifier(AccessibilityID.outputEmptyState)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button("Paste", systemImage: "doc.on.clipboard") {
                viewModel.paste()
            }
            .keyboardShortcut("v", modifiers: [.command])
            .accessibilityIdentifier(AccessibilityID.pasteButton)
            .accessibilityHint("Replaces the editor contents with the clipboard text.")

            Button("Clear", systemImage: "trash") {
                viewModel.clear()
            }
            .keyboardShortcut("k", modifiers: [.command])
            .disabled(viewModel.jsonText.isEmpty)
            .accessibilityIdentifier(AccessibilityID.clearButton)
            .accessibilityHint("Clears the editor and the parsed output.")

            Button("Parse", systemImage: "play.fill") {
                viewModel.parse()
            }
            .keyboardShortcut(.return, modifiers: [])
            .disabled(!viewModel.canParse)
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(AccessibilityID.parseButton)
            .accessibilityHint("Validates the JSON and shows its structure.")
        }
    }
}

#Preview {
    ContentView()
}
