//
//  BikeBonkWatchApp.swift
//  BikeBonkWatch
//
//  Created by Jonas Follesø on 21/01/2026.
//

import SwiftUI

@main
struct BikeBonkWatchApp: App {
    init() {
        // Support launch arguments for screenshot automation
        #if DEBUG
        if CommandLine.arguments.contains("-SCREENSHOT_MODE") {
            if let index = CommandLine.arguments.firstIndex(of: "-BIKES_MOUNTED"),
               index + 1 < CommandLine.arguments.count {
                let value = CommandLine.arguments[index + 1]
                BikeState.bikesMounted = (value == "YES" || value == "1" || value == "true")
            }
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
