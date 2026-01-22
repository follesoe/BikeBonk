//
//  BikeBonkComplication.swift
//  BikeBonkWatchWidget
//
//  Watch complications showing bike mount status with toggle support.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Widget Bundle

@main
struct BikeBonkWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        BikeBonkComplication()
    }
}

// MARK: - Timeline Entry

struct BikeBonkComplicationEntry: TimelineEntry {
    let date: Date
    let bikesMounted: Bool
}

// MARK: - Timeline Provider

struct BikeBonkComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> BikeBonkComplicationEntry {
        BikeBonkComplicationEntry(date: .now, bikesMounted: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (BikeBonkComplicationEntry) -> Void) {
        let entry = BikeBonkComplicationEntry(date: .now, bikesMounted: BikeState.bikesMounted)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BikeBonkComplicationEntry>) -> Void) {
        let entry = BikeBonkComplicationEntry(date: .now, bikesMounted: BikeState.bikesMounted)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// MARK: - Complication Views

struct BikeBonkComplicationEntryView: View {
    var entry: BikeBonkComplicationEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            accessoryCircularView
        case .accessoryRectangular:
            accessoryRectangularView
        case .accessoryInline:
            accessoryInlineView
        case .accessoryCorner:
            accessoryCornerView
        default:
            accessoryCircularView
        }
    }

    // MARK: - Circular Complication

    private var accessoryCircularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            Image(systemName: Theme.icon(for: entry.bikesMounted))
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(entry.bikesMounted ? .red : .green)
                .widgetAccentable()
        }
    }

    // MARK: - Rectangular Complication

    private var accessoryRectangularView: some View {
        HStack(spacing: 8) {
            Image(systemName: Theme.icon(for: entry.bikesMounted))
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(entry.bikesMounted ? .red : .green)
                .widgetAccentable()

            VStack(alignment: .leading, spacing: 2) {
                Text("app_title", tableName: nil, bundle: .main)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(entry.bikesMounted ? String(localized: "complication_status_mounted") : String(localized: "complication_status_clear"))
                    .font(.headline)
                    .foregroundStyle(entry.bikesMounted ? .red : .green)
                    .widgetAccentable()
            }

            Spacer()
        }
    }

    // MARK: - Inline Complication

    private var accessoryInlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: Theme.icon(for: entry.bikesMounted))
            Text(entry.bikesMounted ? String(localized: "complication_inline_mounted") : String(localized: "complication_inline_clear"))
        }
    }

    // MARK: - Corner Complication

    private var accessoryCornerView: some View {
        Image(systemName: Theme.icon(for: entry.bikesMounted))
            .font(.system(size: 21, weight: .medium))
            .foregroundStyle(entry.bikesMounted ? .red : .green)
            .widgetAccentable()
            .widgetLabel {
                Text(entry.bikesMounted ? String(localized: "complication_corner_mounted") : String(localized: "complication_corner_clear"))
            }
    }
}

// MARK: - Widget Configuration

struct BikeBonkComplication: Widget {
    let kind: String = "BikeBonkComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BikeBonkComplicationProvider()) { entry in
            Button(intent: ToggleBikesIntent()) {
                BikeBonkComplicationEntryView(entry: entry)
            }
            .buttonStyle(.plain)
            .containerBackground(.clear, for: .widget)
            .invalidatableContent()
        }
        .configurationDisplayName(String(localized: "app_title"))
        .description(String(localized: "complication_description"))
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner
        ])
    }
}

// MARK: - Previews

#Preview("Circular - Safe", as: .accessoryCircular) {
    BikeBonkComplication()
} timeline: {
    BikeBonkComplicationEntry(date: .now, bikesMounted: false)
}

#Preview("Circular - Warning", as: .accessoryCircular) {
    BikeBonkComplication()
} timeline: {
    BikeBonkComplicationEntry(date: .now, bikesMounted: true)
}

#Preview("Rectangular - Safe", as: .accessoryRectangular) {
    BikeBonkComplication()
} timeline: {
    BikeBonkComplicationEntry(date: .now, bikesMounted: false)
}

#Preview("Rectangular - Warning", as: .accessoryRectangular) {
    BikeBonkComplication()
} timeline: {
    BikeBonkComplicationEntry(date: .now, bikesMounted: true)
}

#Preview("Inline - Safe", as: .accessoryInline) {
    BikeBonkComplication()
} timeline: {
    BikeBonkComplicationEntry(date: .now, bikesMounted: false)
}

#Preview("Inline - Warning", as: .accessoryInline) {
    BikeBonkComplication()
} timeline: {
    BikeBonkComplicationEntry(date: .now, bikesMounted: true)
}

#Preview("Corner - Safe", as: .accessoryCorner) {
    BikeBonkComplication()
} timeline: {
    BikeBonkComplicationEntry(date: .now, bikesMounted: false)
}

#Preview("Corner - Warning", as: .accessoryCorner) {
    BikeBonkComplication()
} timeline: {
    BikeBonkComplicationEntry(date: .now, bikesMounted: true)
}
