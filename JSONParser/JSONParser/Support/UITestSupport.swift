//
//  UITestSupport.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
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
