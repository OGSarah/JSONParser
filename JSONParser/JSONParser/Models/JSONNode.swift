//
// JSONNode.swift
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

/// A parsed JSON value. The recursive `object` and `array` cases let the tree
/// represent any well formed document.
nonisolated enum JSONNode: Equatable {
    case object([String: JSONNode])
    case array([JSONNode])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null

    /// Whether this node is a scalar value rather than a container.
    ///
    /// Used by the tree view to decide when a row can be collapsed into a single
    /// accessibility element without hiding nested structure.
    var isLeaf: Bool {
        switch self {
        case .object, .array: false
        case .string, .number, .bool, .null: true
        }
    }
}
