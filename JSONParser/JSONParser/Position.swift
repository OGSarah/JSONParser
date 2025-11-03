//
//  Position.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
//

struct Position {
    var line = 1
    var column = 1

    mutating func advance(_ char: Character) {
        if char == "\n" {
            line += 1
            column = 1
        } else {
            column += 1
        }
    }

}
