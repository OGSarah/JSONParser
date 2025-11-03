<div align="center">
  <img src="" width="300" style="border: 3px solid white; border-radius: 15px; vertical-align: middle; margin-right: 20px;">
  <h1 style="display: inline-block; vertical-align: middle;">ChatPrototype</h1>
</div>

# JSONParser - macOS App with SwiftUI
![Swift 6+](https://img.shields.io/badge/Swift-6%2B-orange.svg) ![macOS 26](https://img.shields.io/badge/platform-macOS_26-lightgrey.svg)

**A Swift macOS app built in SwiftUI that lets you paste, load, or drag-and-drop JSON to validate it using our hand-crafted JSON parser — no `JSONSerialization`, fully custom lexer + parser.**

***This project implements a complete, standards-compliant JSON parser in pure Swift, following the official RFC 8259 specification.
Built as a learning exercise in lexical analysis and recursive descent parsing, it supports all JSON data types and nested structures — including proper error reporting with line/column numbers.***

## Screenshots:
TODO: Add

## Features 
- Zero external dependencies
- Manual lexer (tokenizer) 
- Recursive descent parser 
- Full JSON Support (Objects `{}`, Arrays `[]`, Strings (with escapes, Unicode `\uXXXX`), Numbers (int, float, scientific notation), Booleans (`true`, `false`), `null`) 
- Precise error messages with line and column 
- Drag & drop JSON files 
- Paste JSON from clipboard 
- Load from file 
- Real-time validation  
- Rich error reporting with line/column 
- Syntax highlighting (valid/invalid) 
- Clean, modern SwiftUI interface 

## License
Proprietary Software

© 2025 SarahUniverse

This software and its source code are the exclusive property of SarahUniverse.
No part of this software may be reproduced, distributed, or transmitted in any form or by any means without prior written permission.
