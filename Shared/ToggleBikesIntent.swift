//
//  ToggleBikesIntent.swift
//  BikeBonkWidget
//
//  Created by Jonas Follesø on 21/01/2026.
//

import AppIntents
import WidgetKit

/// App Intent for toggling the bike-mounted state from widgets.
struct ToggleBikesIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Bikes"
    static var description = IntentDescription("Toggle whether bikes are mounted on the roof")

    @MainActor
    func perform() async throws -> some IntentResult {
        BikeState.toggle()
        return .result()
    }
}
