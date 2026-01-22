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
    static var title: LocalizedStringResource = "intent_toggle_title"
    static var description = IntentDescription("intent_toggle_description")

    @MainActor
    func perform() async throws -> some IntentResult {
        BikeState.toggle()
        return .result()
    }
}
