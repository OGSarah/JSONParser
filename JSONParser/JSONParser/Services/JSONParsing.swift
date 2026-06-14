//
// JSONParsing.swift
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

/// The outcome of parsing a JSON document: a validation result paired with the
/// parsed tree when the document is well formed.
nonisolated struct JSONParseOutcome: Equatable {
    let result: ValidationResult
    let node: JSONNode?
}

/// An abstraction over JSON parsing.
///
/// View models depend on this protocol rather than the concrete ``JSONParser`` so
/// they can be unit tested with a stub and so the parsing implementation stays
/// swappable.
protocol JSONParsing: Sendable {
    /// Parses the given string, returning whether it is valid JSON and, if so, its tree.
    nonisolated func parse(_ input: String) -> JSONParseOutcome
}
