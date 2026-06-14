//
// SyntaxTextView.swift
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

import AppKit
import SwiftUI

struct SyntaxTextView: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }

        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.textContainer?.lineFragmentPadding = 8
        let unbounded = CGFloat.greatestFiniteMagnitude
        textView.textContainer?.containerSize = NSSize(width: unbounded, height: unbounded)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false

        // Expose the editor to assistive technologies and the UI test suite. The
        // SwiftUI accessibility modifiers do not reach the underlying NSTextView,
        // so the identifier and label are set directly here.
        textView.setAccessibilityIdentifier(AccessibilityID.jsonEditor)
        textView.setAccessibilityLabel("JSON input editor")

        context.coordinator.textView = textView
        textView.delegate = context.coordinator

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
            context.coordinator.highlightSyntax(in: textView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        weak var textView: NSTextView?

        init(_ text: Binding<String>) {
            self._text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.text = textView.string
            highlightSyntax(in: textView)
        }

        func highlightSyntax(in textView: NSTextView) {
            guard let textStorage = textView.textStorage else { return }

            let input = textView.string
            let range = NSRange(input.startIndex..., in: input)

            // Reset
            textStorage.beginEditing()
            textStorage.removeAttribute(.foregroundColor, range: range)
            textStorage.removeAttribute(.backgroundColor, range: range)
            textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular), range: range)
            textStorage.endEditing()

            let lexer = Lexer(input: input)
            var position = 0

            while true {
                do {
                    let token = try lexer.nextToken()
                    if token == .eof { break }

                    let tokenRange = lexer.tokenRange(from: position)
                    let nsRange = NSRange(tokenRange, in: input)

                    switch token {
                    case .string:
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: nsRange)
                    case .number:
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemOrange, range: nsRange)
                    case .bool:
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: nsRange)
                    case .null:
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: nsRange)
                    case .leftBrace, .rightBrace, .leftBracket, .rightBracket, .colon, .comma:
                        let mediumFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .medium)
                        textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: nsRange)
                        textStorage.addAttribute(.font, value: mediumFont, range: nsRange)
                    default:
                        break
                    }

                    // Advance integer offset to the end of this token's range
                    position = input.distance(from: input.startIndex, to: tokenRange.upperBound)
                } catch {
                    break
                }
            }
        }
    }

}

// MARK: Previews
#Preview("Light") {
    SyntaxTextView(text: .constant("Hello, World!"))
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SyntaxTextView(text: .constant("Hello, World!"))
        .preferredColorScheme(.dark)
}
