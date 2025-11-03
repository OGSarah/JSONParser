# JSONParser - macOS App with SwiftUI
![Swift 6+](https://img.shields.io/badge/Swift-6%2B-orange.svg) ![macOS 26](https://img.shields.io/badge/platform-macOS_26-lightgrey.svg)

**A Swift JSON parser built from scratch. No frameworks, no `JSONSerialization`.** 

***This project implements a complete, standards-compliant JSON parser in pure Swift, following the official RFC 8259 specification.
Built as a learning exercise in lexical analysis and recursive descent parsing, it supports all JSON data types and nested structures — including proper error reporting with line/column numbers.***


| Features |
|-------|
| Zero external dependencies|
| Manual lexer (tokenizer) |
| Recursive descent parser |
| Full JSON Support (Objects `{}`, Arrays `[]`, Strings (with escapes, Unicode `\uXXXX`), Numbers (int, float, scientific notation), Booleans (`true`, `false`), `null`) |
| Precise error messages with line and column |


