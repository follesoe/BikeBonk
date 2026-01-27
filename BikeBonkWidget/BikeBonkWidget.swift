//
//  BikeBonkWidget.swift
//  BikeBonkWidget
//
//  Created by Jonas Follesø on 21/01/2026.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entry

struct BikeBonkEntry: TimelineEntry {
    let date: Date
    let bikesMounted: Bool
}

// MARK: - Timeline Provider

struct BikeBonkProvider: TimelineProvider {
    /// Refresh interval for checking iCloud updates (10 minutes)
    private let refreshInterval: TimeInterval = 10 * 60

    func placeholder(in context: Context) -> BikeBonkEntry {
        BikeBonkEntry(date: .now, bikesMounted: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (BikeBonkEntry) -> Void) {
        let entry = BikeBonkEntry(date: .now, bikesMounted: currentState())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BikeBonkEntry>) -> Void) {
        let entry = BikeBonkEntry(date: .now, bikesMounted: currentState())
        let nextRefresh = Date().addingTimeInterval(refreshInterval)
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    /// Gets current state, checking iCloud for cross-device updates.
    private func currentState() -> Bool {
        // If local was just updated (same-device), trust local
        // iCloud sync is async so it may have stale data
        if BikeState.wasRecentlyUpdatedLocally {
            return BikeState.bikesMounted
        }

        // For periodic refresh, check iCloud for cross-device updates
        let iCloud = NSUbiquitousKeyValueStore.default
        iCloud.synchronize()

        let iCloudValue = iCloud.bool(forKey: BikeState.bikesMountedKey)
        let localValue = BikeState.bikesMounted

        // If iCloud differs, it's a cross-device update - prefer iCloud
        if iCloudValue != localValue {
            BikeState.shared.set(iCloudValue, forKey: BikeState.bikesMountedKey)
            return iCloudValue
        }

        return localValue
    }
}

// MARK: - Widget Views

struct BikeBonkWidgetEntryView: View {
    var entry: BikeBonkEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.widgetContentMargins) var margins
    @Environment(\.showsWidgetContainerBackground) var showsBackground

    /// Whether widget is displayed in StandBy or CarPlay (larger, no background)
    private var isStandByOrCarPlay: Bool {
        !showsBackground
    }

    var body: some View {
        Button(intent: ToggleBikesIntent()) {
            switch family {
            case .systemSmall:
                smallWidgetContent
            case .systemMedium:
                mediumWidgetContent
            case .accessoryCircular:
                accessoryCircularContent
            case .accessoryRectangular:
                accessoryRectangularContent
            default:
                smallWidgetContent
            }
        }
        .buttonStyle(.plain)
    }

    private var smallWidgetContent: some View {
        VStack(spacing: isStandByOrCarPlay ? 12 : 8) {
            StatusIconView(
                bikesMounted: entry.bikesMounted,
                size: isStandByOrCarPlay ? .widgetMedium : .widget
            )

            StatusTextView(
                bikesMounted: entry.bikesMounted,
                fontSize: isStandByOrCarPlay ? 20 : 14
            )
            .fontWeight(.semibold)
            .lineLimit(2)
        }
        .padding()
    }

    private var mediumWidgetContent: some View {
        HStack(spacing: 20) {
            StatusIconView(bikesMounted: entry.bikesMounted, size: .widgetMedium)

            StatusTextView(bikesMounted: entry.bikesMounted, fontSize: 22)

            Spacer()
        }
        .padding()
    }

    private var accessoryCircularContent: some View {
        ZStack {
            AccessoryWidgetBackground()
            StatusIconView(bikesMounted: entry.bikesMounted, size: .accessoryCircular)
        }
    }

    private var accessoryRectangularContent: some View {
        HStack(spacing: 6) {
            StatusIconView(bikesMounted: entry.bikesMounted, size: .accessoryRectangular)

            VStack(alignment: .leading, spacing: 2) {
                Text("BikeBonk")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                StatusTextView(bikesMounted: entry.bikesMounted, fontSize: 13, alignment: .leading)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
    }
}

// MARK: - Widget Configuration

struct BikeBonkWidget: Widget {
    let kind: String = "BikeBonkWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BikeBonkProvider()) { entry in
            BikeBonkWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Theme.gradient(for: entry.bikesMounted)
                }
                .invalidatableContent()
        }
        .configurationDisplayName("BikeBonk")
        .description("Quick access to your bike rack status")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Previews

#Preview("Small - Safe", as: .systemSmall) {
    BikeBonkWidget()
} timeline: {
    BikeBonkEntry(date: .now, bikesMounted: false)
}

#Preview("Small - Warning", as: .systemSmall) {
    BikeBonkWidget()
} timeline: {
    BikeBonkEntry(date: .now, bikesMounted: true)
}

// MARK: - StandBy/CarPlay Preview Views
// These simulate StandBy appearance: no background, full-bleed content

struct StandByPreviewView: View {
    let bikesMounted: Bool

    var body: some View {
        // StandBy shows systemSmall without background, scaled up
        VStack(spacing: 12) {
            StatusIconView(bikesMounted: bikesMounted, size: .widgetMedium)

            StatusTextView(bikesMounted: bikesMounted, fontSize: 18)
                .fontWeight(.semibold)
                .lineLimit(2)
        }
        .frame(width: 170, height: 170)
        .background(Color.black)
    }
}

#Preview("StandBy - Safe") {
    StandByPreviewView(bikesMounted: false)
}

#Preview("StandBy - Warning") {
    StandByPreviewView(bikesMounted: true)
}

#Preview("Medium - Safe", as: .systemMedium) {
    BikeBonkWidget()
} timeline: {
    BikeBonkEntry(date: .now, bikesMounted: false)
}

#Preview("Medium - Warning", as: .systemMedium) {
    BikeBonkWidget()
} timeline: {
    BikeBonkEntry(date: .now, bikesMounted: true)
}

// MARK: - Accessory Widget Previews (Lock Screen, StandBy, CarPlay)

#Preview("Circular - Safe", as: .accessoryCircular) {
    BikeBonkWidget()
} timeline: {
    BikeBonkEntry(date: .now, bikesMounted: false)
}

#Preview("Circular - Warning", as: .accessoryCircular) {
    BikeBonkWidget()
} timeline: {
    BikeBonkEntry(date: .now, bikesMounted: true)
}

#Preview("Rectangular - Safe", as: .accessoryRectangular) {
    BikeBonkWidget()
} timeline: {
    BikeBonkEntry(date: .now, bikesMounted: false)
}

#Preview("Rectangular - Warning", as: .accessoryRectangular) {
    BikeBonkWidget()
} timeline: {
    BikeBonkEntry(date: .now, bikesMounted: true)
}
