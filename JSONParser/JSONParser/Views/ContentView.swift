//
//  ContentView.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct ContentView: View {
    @State private var jsonText: String = ""
    @State private var validationResult: ValidationResult = .none
    @State private var parsedNode: JSONNode? = nil
    @State private var isParsing = false
    @State private var selectedTab: Tab = .editor

    private let parser = JSONParser()

    enum Tab { case editor, output }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            tabView
            editorView
            controlsView
            resultView
        }
        .frame(minWidth: 800, minHeight: 600)
    }

    private var headerView: some View {
        HStack {
            Label("JSON Parser", systemImage: "curlybraces")
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Button("Paste") {
                if let clipboard = NSPasteboard.general.string(forType: .string) {
                    jsonText = clipboard
                }
            }
            .keyboardShortcut("v", modifiers: [.command])

            Button("Clear") {
                jsonText = ""
                validationResult = .none
                parsedNode = nil
                selectedTab = .editor
            }
            .keyboardShortcut("k", modifiers: [.command])
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(Divider(), alignment: .bottom)
    }

    private var tabView: some View {
        HStack {
            TabButton(title: "Input", systemImage: "doc.text", isSelected: selectedTab == .editor) {
                selectedTab = .editor
            }
            TabButton(title: "Output", systemImage: "rectangle.expand.vertical", isSelected: selectedTab == .output) {
                selectedTab = .output
            }
            .disabled(parsedNode == nil)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var editorView: some View {
        Group {
            if selectedTab == .editor {
                SyntaxTextView(text: $jsonText)
                    .padding()
            } else if let node = parsedNode {
                OutputTreeView(node: node)
                    .padding()
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var controlsView: some View {
        HStack {
            Spacer()

            Button("Parse") {
                parseJSON()
            }
            .keyboardShortcut(.return)
            .disabled(isParsing || jsonText.isEmpty)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(Divider(), alignment: .top)
    }

    private var resultView: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch validationResult {
            case .none:
                Text("Click **Parse** to validate and view JSON")
                    .foregroundColor(.secondary)
                    .italic()
            case .valid:
                Label("Valid JSON – Parsed successfully", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                    .fontWeight(.medium)
            case .invalid(let error):
                VStack(alignment: .leading, spacing: 6) {
                    Label("Invalid JSON", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                        .fontWeight(.medium)

                    Text(error.message)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                        .textSelection(.enabled)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(resultBackground)
    }

    private var resultBackground: Color {
        switch validationResult {
        case .valid: return Color.green.opacity(0.08)
        case .invalid: return Color.red.opacity(0.08)
        default: return Color(NSColor.controlBackgroundColor)
        }
    }

    private func parseJSON() {
        isParsing = true
        let result = parser.parse(jsonText)
        validationResult = result.result
        parsedNode = result.node
        if case .valid = result.result {
            selectedTab = .output
        }
        isParsing = false
    }
}

#Preview {
    ContentView()
}
