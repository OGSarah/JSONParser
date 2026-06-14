//
// ResultBanner.swift
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

/// A status banner summarizing the most recent validation result.
///
/// It reads as a single combined element to VoiceOver, announcing either success
/// or the specific failure message.
struct ResultBanner: View {
    let result: ValidationResult

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(tint)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(tint)

                if let detail {
                    Text(detail)
                        .font(.system(.callout, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .accessibilityIdentifier(AccessibilityID.resultErrorMessage)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.1), in: .rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(tint.opacity(0.25), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityID.resultBanner)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Presentation

    private var iconName: String {
        switch result {
        case .none: "info.circle"
        case .valid: "checkmark.circle.fill"
        case .invalid: "xmark.circle.fill"
        }
    }

    private var tint: Color {
        switch result {
        case .none: .secondary
        case .valid: .green
        case .invalid: .red
        }
    }

    private var title: String {
        switch result {
        case .none: "Ready to parse"
        case .valid: "Valid JSON. Parsed successfully."
        case .invalid: "Invalid JSON"
        }
    }

    private var detail: String? {
        switch result {
        case .none: "Enter JSON and choose Parse to validate and view the tree."
        case .valid: nil
        case .invalid(let error): error.message
        }
    }

    private var accessibilityLabel: String {
        switch result {
        case .none: "Ready to parse. Enter JSON and choose Parse."
        case .valid: "Valid JSON. Parsed successfully."
        case .invalid(let error): "Invalid JSON. \(error.message)"
        }
    }
}

#Preview("States") {
    VStack(spacing: 16) {
        ResultBanner(result: .none)
        ResultBanner(result: .valid)
        ResultBanner(result: .invalid(ParseError(message: "Unexpected token at line 2, column 7", line: 2, column: 7)))
    }
    .padding()
    .frame(width: 420)
}
