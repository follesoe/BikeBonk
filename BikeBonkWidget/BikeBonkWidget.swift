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
    func placeholder(in context: Context) -> BikeBonkEntry {
        BikeBonkEntry(date: .now, bikesMounted: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (BikeBonkEntry) -> Void) {
        let entry = BikeBonkEntry(date: .now, bikesMounted: BikeState.bikesMounted)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BikeBonkEntry>) -> Void) {
        let entry = BikeBonkEntry(date: .now, bikesMounted: BikeState.bikesMounted)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// MARK: - Widget Views

struct BikeBonkWidgetEntryView: View {
    var entry: BikeBonkEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Button(intent: ToggleBikesIntent()) {
            switch family {
            case .systemSmall:
                smallWidgetContent
            case .systemMedium:
                mediumWidgetContent
            default:
                smallWidgetContent
            }
        }
        .buttonStyle(.plain)
    }

    private var smallWidgetContent: some View {
        VStack(spacing: 8) {
            StatusIconView(bikesMounted: entry.bikesMounted, size: .widget)

            StatusTextView(bikesMounted: entry.bikesMounted, fontSize: 12)
                .fontWeight(.semibold)
                .lineLimit(2)
        }
        .padding()
    }

    private var mediumWidgetContent: some View {
        HStack(spacing: 20) {
            StatusIconView(bikesMounted: entry.bikesMounted, size: .widgetMedium)

            StatusTextView(bikesMounted: entry.bikesMounted, fontSize: 18)

            Spacer()
        }
        .padding()
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
        .supportedFamilies([.systemSmall, .systemMedium])
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
