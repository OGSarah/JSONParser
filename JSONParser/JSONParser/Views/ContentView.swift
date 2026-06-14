//
//  ContentView.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
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
