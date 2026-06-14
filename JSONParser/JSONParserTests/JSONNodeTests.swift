//
// JSONNodeTests.swift
// JSONParserTests
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

import Testing
@testable import JSONParser

@Suite("JSONNode")
struct JSONNodeTests {

    @Test("Equal trees compare equal regardless of key order")
    func equalityIgnoresKeyOrder() {
        let first = JSONNode.object(["a": .number(1), "b": .number(2)])
        let second = JSONNode.object(["b": .number(2), "a": .number(1)])
        #expect(first == second)
    }

    @Test("Differing values compare unequal")
    func inequality() {
        #expect(JSONNode.number(1) != JSONNode.number(2))
        #expect(JSONNode.string("a") != JSONNode.string("b"))
        #expect(JSONNode.bool(true) != JSONNode.bool(false))
        #expect(JSONNode.null != JSONNode.string("null"))
    }

    @Test("Nested structures compare deeply")
    func deepEquality() {
        let first = JSONNode.array([.object(["k": .array([.null, .bool(true)])])])
        let second = JSONNode.array([.object(["k": .array([.null, .bool(true)])])])
        #expect(first == second)
    }

    @Test("Scalar nodes are leaves")
    func scalarsAreLeaves() {
        #expect(JSONNode.string("x").isLeaf)
        #expect(JSONNode.number(1).isLeaf)
        #expect(JSONNode.bool(false).isLeaf)
        #expect(JSONNode.null.isLeaf)
    }

    @Test("Containers are not leaves")
    func containersAreNotLeaves() {
        #expect(!JSONNode.object([:]).isLeaf)
        #expect(!JSONNode.array([]).isLeaf)
    }
}
