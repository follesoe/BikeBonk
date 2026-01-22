# BikeBonk

A simple iOS app to help you remember when bikes are mounted on your car's roof rack. Never drive into the garage with bikes on top again!

## Features

- **Bold Visual States** - Full-screen gradient UI makes status impossible to miss
  - Green = Safe (no bikes mounted)
  - Red/Orange = Warning (bikes are mounted)
- **iCloud Sync** - State syncs between iPhone and Apple Watch via iCloud
- **Instant Sync** - Watch Connectivity provides instant sync when both apps are open
- **Interactive Home Screen Widgets** - Toggle status directly from your home screen
- **watchOS App** - Quick access from your Apple Watch
- **Watch Complications** - See and toggle status from any watch face
- **Siri Voice Commands** - "Check bikes in BikeBonk" on iPhone or Apple Watch
- **Shortcuts Integration** - Build automations with HomeKit and other apps
- **Localization** - English and Norwegian support

## Screenshots

| iOS App | Widget | Watch App | Complication |
|---------|--------|-----------|--------------|
| Safe/Warning states | Small/Medium sizes | Toggle from wrist | Multiple styles |

## Architecture

```
BikeBonk/
├── BikeBonk/                  # iOS app
│   ├── BikeBonkApp.swift      # App entry point
│   └── ContentView.swift      # Main UI
├── BikeBonkWidget/            # iOS home screen widget
│   ├── BikeBonkWidget.swift   # Widget configuration & views
│   └── BikeBonkWidgetBundle.swift
├── BikeBonkWatch/             # watchOS app
│   ├── BikeBonkWatchApp.swift # Watch app entry point
│   └── ContentView.swift      # Watch UI
├── BikeBonkWatchWidget/       # watchOS complications
│   └── BikeBonkComplication.swift
└── Shared/                    # Shared code across all targets
    ├── BikeState.swift        # State management via App Groups + iCloud
    ├── SyncManager.swift      # Hybrid sync (Watch Connectivity + iCloud)
    ├── Theme.swift            # Colors, gradients, icons
    ├── StatusIconView.swift   # Reusable icon component
    ├── ToggleBikesIntent.swift # AppIntent for interactive widgets
    ├── SetBikesMountedIntent.swift  # AppIntent for setting state
    ├── GetBikesMountedIntent.swift  # AppIntent for checking state
    ├── AppShortcuts.swift     # Siri phrase definitions
    ├── Color+Hex.swift        # Hex color extension
    └── [en|nb].lproj/         # Localization files
        ├── Localizable.strings    # UI strings
        └── AppShortcuts.strings   # Siri phrases
```

## Key Concepts

### Data Sharing with App Groups

All targets share state via `UserDefaults` with an App Group container for local caching:

```swift
struct BikeState {
    static let appGroupID = "group.no.follesoe.BikeBonk.shared"

    static var bikesMounted: Bool {
        get { shared.bool(forKey: bikesMountedKey) }
        set {
            shared.set(newValue, forKey: bikesMountedKey)  // Local cache
            iCloud.set(newValue, forKey: bikesMountedKey)  // iCloud sync
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
```

### Cross-Device Sync with iCloud

The app uses a hybrid sync strategy for iOS ↔ watchOS synchronization:

| Method | Speed | Use Case |
|--------|-------|----------|
| Watch Connectivity | Instant (~0.1s) | Both apps in foreground |
| iCloud Key-Value Store | ~seconds | Background sync, widget changes |

```swift
final class SyncManager: NSObject, ObservableObject {
    @Published private(set) var bikesMounted: Bool

    func setBikesMounted(_ newValue: Bool) {
        bikesMounted = newValue
        BikeState.bikesMounted = newValue      // Writes to local + iCloud
        sendViaWatchConnectivity(newValue)     // Instant sync when reachable
    }
}
```

**Sync Flow:**
1. User toggles state on iPhone
2. `BikeState` writes to App Group (local) and iCloud KV Store
3. `SyncManager` sends via Watch Connectivity if watch is reachable
4. Watch receives instant update via Watch Connectivity
5. If watch app is closed, iCloud delivers update when it opens

**Widget/Complication Sync:**
- Widgets check iCloud every 10 minutes for cross-device updates
- Same-device updates are instant via `WidgetCenter.shared.reloadAllTimelines()`

### Interactive Widgets with AppIntents

Widgets use `AppIntents` to toggle state directly without opening the app:

```swift
struct ToggleBikesIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Bikes"

    @MainActor
    func perform() async throws -> some IntentResult {
        BikeState.toggle()
        return .result()
    }
}
```

### Siri & Shortcuts Integration

The app provides App Intents for Siri voice commands and Shortcuts automations:

**Voice Commands (English):**
| Command | Phrase |
|---------|--------|
| Check status | "Check bikes in BikeBonk" |
| Mark mounted | "Bikes mounted in BikeBonk" |
| Mark removed | "Bikes removed in BikeBonk" |
| Toggle | "Toggle bikes in BikeBonk" |

**Voice Commands (Norwegian):**
| Command | Phrase |
|---------|--------|
| Check status | "Sjekk sykler i BikeBonk" |
| Mark mounted | "Sykler montert i BikeBonk" |
| Mark removed | "Sykler fjernet i BikeBonk" |

**Shortcuts Automation Example:**

Use `GetBikesMountedIntent` in Shortcuts to build automations:
- "When I open my garage with HomeKit, check if bikes are mounted, and send a notification if true"

```swift
struct GetBikesMountedIntent: AppIntent {
    static var title: LocalizedStringResource = "intent_check_title"

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> & ProvidesDialog {
        let mounted = BikeState.bikesMounted
        return .result(value: mounted, dialog: ...)
    }
}
```

The `ReturnsValue<Bool>` protocol exposes the state to Shortcuts for use in conditional automations.

### Theming System

A centralized `Theme` enum provides consistent styling across all targets:

```swift
enum Theme {
    enum Warning {
        static let gradient = LinearGradient(...)
        static let icon = "bicycle"
        static let badgeIcon = "exclamationmark.triangle.fill"
    }

    enum Safe {
        static let gradient = LinearGradient(...)
        static let icon = "car.fill"
        static let badgeIcon = "checkmark.circle.fill"
    }
}
```

## Requirements

- iOS 18.0+
- watchOS 11.0+
- Xcode 16.0+
- Swift 5.9+

## Setup

1. Clone the repository
2. Open `BikeBonk.xcodeproj` in Xcode
3. Select your development team in Signing & Capabilities
4. Update the App Group identifier if needed (`group.no.follesoe.BikeBonk.shared`)
5. Enable iCloud capability with Key-Value Store for all targets
6. Build and run

### App Group Configuration

All targets must share the same App Group for local data synchronization:

- `BikeBonk` (iOS app)
- `BikeBonkWidgetExtension` (iOS widget)
- `BikeBonkWatch` (watchOS app)
- `BikeBonkWatchWidgetExtension` (watchOS complications)

### iCloud Configuration

All targets must have iCloud Key-Value Store enabled with the same identifier for cross-device sync:

1. Select target → Signing & Capabilities → + Capability → iCloud
2. Check "Key-value storage"
3. Ensure all targets use the same KV Store identifier (e.g., `$(TeamIdentifierPrefix)no.follesoe.BikeBonkApp`)

## Widget Families

### iOS Widgets
- **Small** - Icon with status text
- **Medium** - Larger icon with full status message

### watchOS Complications
- **Circular** - Icon only
- **Rectangular** - Icon with app name and status
- **Inline** - Icon with short status text
- **Corner** - Icon with label

## Localization

The app supports:
- English (en)
- Norwegian Bokmål (nb)

Localization files are in `Shared/[lang].lproj/Localizable.strings` and shared across all targets.

## Privacy Policy

BikeBonk respects your privacy:

- **No data collection** - The app does not collect or transmit any personal data to third parties
- **No analytics** - No tracking or analytics of any kind
- **iCloud sync only** - State syncs between your devices via your personal iCloud account
- **No account required** - Uses your existing Apple ID for iCloud sync

Your bike mount status is only stored locally on your devices and in your personal iCloud account.

## License

MIT License - feel free to use this as a starting point for your own projects.

## Contributing

Contributions welcome! Please open an issue or submit a pull request.

## Support

- **Issues & Bugs**: [GitHub Issues](https://github.com/follesoe/BikeBonk/issues)
- **Source Code**: [GitHub Repository](https://github.com/follesoe/BikeBonk)
