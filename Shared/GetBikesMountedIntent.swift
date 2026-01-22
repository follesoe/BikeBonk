//
//  GetBikesMountedIntent.swift
//  BikeBonk
//
//  App Intent for checking bike-mounted state via Siri and Shortcuts.
//

import AppIntents

/// App Intent for checking the bike-mounted state.
/// Also exposes the state value for use in Shortcuts automations.
struct GetBikesMountedIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_check_title"
    static var description = IntentDescription("intent_check_description")

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> & ProvidesDialog {
        let mounted = BikeState.bikesMounted

        let message: String
        if mounted {
            message = String(localized: "siri_response_mounted")
        } else {
            message = String(localized: "siri_response_not_mounted")
        }

        return .result(value: mounted, dialog: IntentDialog(stringLiteral: message))
    }
}
