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
    @State private var isDragging = false
    @State private var isParsing = false

    private let parser = JSONParser()

    var body: some View {
        VStack(spacing: 0) {
            headerView
            editorView
            controlsView
            resultView
        }
        .frame(minWidth: 700, minHeight: 500)
        .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
            handleDrop(providers)
        }
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
                    validate()
                }
            }
            .keyboardShortcut("v", modifiers: [.command])

            Button("Clear") {
                jsonText = ""
                validationResult = .none
            }
            .keyboardShortcut("k", modifiers: [.command])
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(Divider(), alignment: .bottom)
    }

 private var editorView: some View {
        SyntaxTextView(text: $jsonText)
            .padding()
    }

     private var controlsView: some View {
        HStack {
            Spacer()
            
            Button("Parse") {
                isParsing = true
                validationResult = parser.validate(jsonText)
                isParsing = false
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
                Text("Paste or drop JSON to validate")
                    .foregroundColor(.secondary)
                    .italic()
            case .valid:
                Label("Valid JSON", systemImage: "checkmark.circle.fill")
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
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var editorBackground: Color {
        switch validationResult {
        case .valid: return Color.green.opacity(0.08)
        case .invalid: return Color.red.opacity(0.08)
        default: return Color.clear
        }
    }

    private var borderColor: Color {
        switch validationResult {
        case .valid: return .green
        case .invalid: return .red
        default: return Color(NSColor.separatorColor)
        }
    }

    private func validate() {
        validationResult = parser.validate(jsonText)
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: "public.file-url") { data, _ in
            guard let urlData = data as? Data,
                  let url = URL(dataRepresentation: urlData, relativeTo: nil),
                  let content = try? String(contentsOf: url, encoding: .utf8) else { return }

            DispatchQueue.main.async {
                jsonText = content
                validate()
            }
        }
        return true
    }
}

#Preview {
    ContentView()
}
