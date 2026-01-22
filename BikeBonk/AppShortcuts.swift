//
//  AppShortcuts.swift
//  BikeBonk
//
//  Defines Siri phrases and App Shortcuts for the app.
//  Phrases are localized via AppShortcuts.strings files.
//

import AppIntents

/// Provides App Shortcuts for Siri integration.
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // Check bike status
        AppShortcut(
            intent: GetBikesMountedIntent(),
            phrases: [
                "Check bikes in \(.applicationName)",
                "Are bikes mounted in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("shortcut_check_title"),
            systemImageName: "bicycle"
        )

        // Mark bikes as mounted
        AppShortcut(
            intent: MarkBikesMountedIntent(),
            phrases: [
                "Bikes mounted in \(.applicationName)",
                "Mark bikes mounted in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("shortcut_mounted_title"),
            systemImageName: "bicycle"
        )

        // Mark bikes as removed
        AppShortcut(
            intent: MarkBikesRemovedIntent(),
            phrases: [
                "Bikes removed in \(.applicationName)",
                "Mark bikes removed in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("shortcut_removed_title"),
            systemImageName: "car"
        )

        // Toggle bikes
        AppShortcut(
            intent: ToggleBikesIntent(),
            phrases: [
                "Toggle bikes in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("shortcut_toggle_title"),
            systemImageName: "arrow.triangle.2.circlepath"
        )
    }
}
