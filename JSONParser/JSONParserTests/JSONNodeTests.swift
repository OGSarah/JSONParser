//
//  JSONNodeTests.swift
//  JSONParserTests
//
//  Created by Sarah Clark on 11/5/25.
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
