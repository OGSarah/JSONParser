//
//  JSONNode.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/5/25.
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
