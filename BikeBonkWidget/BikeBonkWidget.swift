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

    private var backgroundGradient: LinearGradient {
        entry.bikesMounted ? Theme.Warning.gradient : Theme.Safe.gradient
    }

    var body: some View {
        Button(intent: ToggleBikesIntent()) {
            ZStack {
                backgroundGradient

                switch family {
                case .systemSmall:
                    smallWidgetContent
                case .systemMedium:
                    mediumWidgetContent
                default:
                    smallWidgetContent
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var smallWidgetContent: some View {
        VStack(spacing: 8) {
            iconView
                .font(.system(size: 44, weight: .medium))

            Text(entry.bikesMounted ? "bikes_status_mounted" : "bikes_status_not_mounted")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding()
    }

    private var mediumWidgetContent: some View {
        HStack(spacing: 20) {
            iconView
                .font(.system(size: 64, weight: .medium))

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.bikesMounted ? "bikes_status_mounted" : "bikes_status_not_mounted")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Text("bikes_toggle_label")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    private var iconView: some View {
        if entry.bikesMounted {
            Image(systemName: "bicycle")
                .foregroundColor(.white)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: 8, y: -4)
                }
        } else {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
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
                    entry.bikesMounted ? Theme.Warning.gradient : Theme.Safe.gradient
                }
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
