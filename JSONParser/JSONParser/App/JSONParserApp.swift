//
//  JSONParserApp.swift
//  JSONParser
//
//  Created by Sarah Clark on 11/3/25.
//

import SwiftUI

@main
struct JSONParserApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: Self.makeViewModel())
        }
        .defaultSize(width: 1100, height: 720)
    }

    /// Builds the root view model, substituting a hermetic stub when launched by
    /// the UI test suite.
    private static func makeViewModel() -> ParserViewModel {
        #if DEBUG
        if UITestSupport.isRunningUITests {
            return UITestSupport.makeViewModel()
        }
        #endif
        return ParserViewModel()
    }
}
