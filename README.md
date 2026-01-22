# BikeBonk

A simple iOS app to help you remember when bikes are mounted on your car's roof rack. Never drive into the garage with bikes on top again!

## Features

- **Bold Visual States** - Full-screen gradient UI makes status impossible to miss
  - Green = Safe (no bikes mounted)
  - Red/Orange = Warning (bikes are mounted)
- **Interactive Home Screen Widgets** - Toggle status directly from your home screen
- **watchOS App** - Quick access from your Apple Watch
- **Watch Complications** - See and toggle status from any watch face
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
    ├── BikeState.swift        # State management via App Groups
    ├── Theme.swift            # Colors, gradients, icons
    ├── StatusIconView.swift   # Reusable icon component
    ├── ToggleBikesIntent.swift # AppIntent for interactive widgets
    ├── Color+Hex.swift        # Hex color extension
    └── [en|nb].lproj/         # Localization files
```

## Key Concepts

### Data Sharing with App Groups

All targets share state via `UserDefaults` with an App Group container:

```swift
struct BikeState {
    static let appGroupID = "group.no.follesoe.BikeBonk"

    static var bikesMounted: Bool {
        get { shared.bool(forKey: bikesMountedKey) }
        set {
            shared.set(newValue, forKey: bikesMountedKey)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
```

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
4. Update the App Group identifier if needed (`group.no.follesoe.BikeBonk`)
5. Build and run

### App Group Configuration

All targets must share the same App Group for data synchronization:

- `BikeBonk` (iOS app)
- `BikeBonkWidgetExtension` (iOS widget)
- `BikeBonkWatch` (watchOS app)
- `BikeBonkWatchWidgetExtension` (watchOS complications)

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

## License

MIT License - feel free to use this as a starting point for your own projects.

## Contributing

Contributions welcome! Please open an issue or submit a pull request.
