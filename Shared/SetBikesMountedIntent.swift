//
//  SetBikesMountedIntent.swift
//  BikeBonk
//
//  App Intent for setting bike-mounted state via Siri and Shortcuts.
//

import AppIntents
import WidgetKit

/// App Intent for setting the bike-mounted state.
struct SetBikesMountedIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_set_title"
    static var description = IntentDescription("intent_set_description")

    @Parameter(title: "intent_param_mounted", description: "intent_param_mounted_description")
    var mounted: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("intent_set_summary \(\.$mounted)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        BikeState.bikesMounted = mounted

        let message: String
        if mounted {
            message = String(localized: "bikes_status_mounted")
        } else {
            message = String(localized: "bikes_status_not_mounted")
        }

        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

/// Convenience intent for quickly marking bikes as mounted.
struct MarkBikesMountedIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_mark_mounted_title"
    static var description = IntentDescription("intent_mark_mounted_description")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        BikeState.bikesMounted = true
        let message = String(localized: "bikes_status_mounted")
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

/// Convenience intent for quickly marking bikes as removed.
struct MarkBikesRemovedIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_mark_removed_title"
    static var description = IntentDescription("intent_mark_removed_description")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        BikeState.bikesMounted = false
        let message = String(localized: "bikes_status_not_mounted")
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}
