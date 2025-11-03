//
//  SyntaxTextView.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
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
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false

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
            guard let layoutManager = textView.layoutManager,
                  let textStorage = textView.textStorage else { return }

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
                        textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: nsRange)
                        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 14, weight: .medium), range: nsRange)
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
