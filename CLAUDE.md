# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build iOS app
xcodebuild -scheme BikeBonk -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Build for release (all platforms)
xcodebuild -scheme BikeBonk -configuration Release -destination 'generic/platform=iOS' build

# Run tests
xcodebuild -scheme BikeBonk -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```

## Fastlane Commands

```bash
# Upload App Store metadata (descriptions, keywords, etc.)
fastlane metadata

# Upload screenshots only
fastlane screenshots

# Upload both metadata and screenshots
fastlane upload_all
```

## Architecture Overview

BikeBonk is a multi-target iOS/watchOS app with 6 targets sharing code through a `Shared/` folder:

| Target | Purpose |
|--------|---------|
| BikeBonk | iOS main app |
| BikeBonkWidgetExtension | iOS home screen widget |
| BikeBonkWatch | watchOS app |
| BikeBonkWatchWidgetExtension | watchOS complications |
| BikeBonkTests | Unit tests |
| BikeBonkUITests | UI tests |

### State Management

All state flows through `BikeState.swift`:
- Writes to **App Group UserDefaults** (local cache) and **iCloud Key-Value Store** (cross-device sync)
- Calls `WidgetCenter.shared.reloadAllTimelines()` on every state change

### Sync Strategy

`SyncManager.swift` implements hybrid sync:
1. **Watch Connectivity** - instant sync when both iOS and watchOS apps are active
2. **iCloud KVS** - background sync fallback, widget/complication updates

### AppIntents

Four intents in `Shared/` enable Siri, widgets, and Shortcuts:
- `ToggleBikesIntent` - toggles state (used by widgets)
- `MarkBikesMountedIntent` / `MarkBikesRemovedIntent` - explicit state setting
- `GetBikesMountedIntent` - returns bool for Shortcuts automations

### Localization

Two languages: English (en) and Norwegian (nb). Files in `Shared/[lang].lproj/`:
- `Localizable.strings` - UI strings
- `AppShortcuts.strings` - Siri phrase translations

## Key Configuration

- **App Group**: `group.no.follesoe.BikeBonk.shared` (all targets)
- **Bundle IDs**: `no.follesoe.BikeBonkApp`, `.BikeBonkWidget`, `.watchkitapp`, `.watchkitapp.widget`
- **iCloud KVS**: All targets share same identifier for cross-device sync

## App Store Submission Notes

- App icons must NOT have alpha channel (use JPEG conversion to strip)
- Export compliance: `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` is set in build settings
- Xcode Cloud is configured for CI/CD with TestFlight distribution
