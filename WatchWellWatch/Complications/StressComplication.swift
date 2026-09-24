import SwiftUI
import WidgetKit

struct StressEntry: TimelineEntry {
    let date: Date
    let stressIndex: Double?
}

struct StressProvider: TimelineProvider {
    func placeholder(in context: Context) -> StressEntry {
        StressEntry(date: .now, stressIndex: 42)
    }

    func getSnapshot(in context: Context, completion: @escaping (StressEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StressEntry>) -> Void) {
        // TODO: read the latest snapshot from a shared App Group container.
        let entry = StressEntry(date: .now, stressIndex: nil)
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(30 * 60))))
    }
}

struct StressComplicationView: View {
    let entry: StressEntry

    var body: some View {
        Gauge(value: entry.stressIndex ?? 0, in: 0...100) {
            Text("STR")
        } currentValueLabel: {
            Text(entry.stressIndex.map { String(Int($0)) } ?? "—")
        }
        .gaugeStyle(.accessoryCircular)
    }
}

@main
struct StressComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "StressComplication", provider: StressProvider()) { entry in
            StressComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Stress")
        .description("Your current stress index.")
        .supportedFamilies([.accessoryCircular])
    }
}
