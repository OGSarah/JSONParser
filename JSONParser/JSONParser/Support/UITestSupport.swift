//
// UITestSupport.swift
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

#if DEBUG
import Foundation

/// A ``JSONParsing`` implementation that returns a fixed outcome, used to make
/// UI tests deterministic and independent of the real parser.
struct StubJSONParser: JSONParsing {
    let outcome: JSONParseOutcome

    func parse(_ input: String) -> JSONParseOutcome {
        outcome
    }
}

/// A ``PasteboardReading`` implementation with canned contents for UI tests.
struct StubPasteboard: PasteboardReading {
    let contents: String?

    func readString() -> String? {
        contents
    }
}

/// Wires up a hermetic ``ParserViewModel`` from launch arguments when the app is
/// launched by the UI test suite.
///
/// Supported launch arguments:
/// - `-uiTest` enables UI test mode.
/// - `-uiTestStub valid` / `-uiTestStub invalid` controls the stubbed parse outcome.
/// - `-uiTestSeedText <text>` pre-populates the editor.
/// - `-uiTestSeedPasteboard <text>` pre-populates the stub pasteboard.
enum UITestSupport {
    static var isRunningUITests: Bool {
        ProcessInfo.processInfo.arguments.contains("-uiTest")
    }

    static func makeViewModel() -> ParserViewModel {
        let arguments = ProcessInfo.processInfo.arguments

        let outcome: JSONParseOutcome
        switch value(for: "-uiTestStub", in: arguments) {
        case "invalid":
            outcome = JSONParseOutcome(
                result: .invalid(ParseError(message: "Unexpected token at line 1, column 1", line: 1, column: 1)),
                node: nil
            )
        default:
            outcome = JSONParseOutcome(result: .valid, node: sampleNode)
        }

        let pasteboard = StubPasteboard(contents: value(for: "-uiTestSeedPasteboard", in: arguments))
        let viewModel = ParserViewModel(parser: StubJSONParser(outcome: outcome), pasteboard: pasteboard)

        if let seedText = value(for: "-uiTestSeedText", in: arguments) {
            viewModel.jsonText = seedText
        }
        return viewModel
    }

    /// Returns the argument value immediately following `flag`, if present.
    private static func value(for flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else {
            return nil
        }
        return arguments[index + 1]
    }

    private static var sampleNode: JSONNode {
        .object([
            "name": .string("JSON Parser"),
            "valid": .bool(true),
            "count": .number(3)
        ])
    }
}
#endif
