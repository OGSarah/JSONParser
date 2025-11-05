//
//  JSONNode.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/5/25.
//

enum JSONNode: Equatable {
    case object([String: JSONNode])
    case array([JSONNode])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
}
