//
//  NaviSyncWidget.swift
//  NaviSyncWidget
//
//  Home Screen Widget for NaviSync
//

import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let meetingTitle: String
    let locationName: String
    let participantCount: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), meetingTitle: "Joint Coffee", locationName: "Uptown City Center", participantCount: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), meetingTitle: "Joint Coffee", locationName: "Uptown City Center", participantCount: 3)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = SimpleEntry(date: Date(), meetingTitle: "Joint Coffee", locationName: "Uptown City Center", participantCount: 3)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct NaviSyncWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.red)
                Text("NaviSync")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(entry.meetingTitle)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
            
            Text(entry.locationName)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text("\(entry.participantCount) participants")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct NaviSyncWidget: Widget {
    let kind: String = "NaviSyncWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NaviSyncWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("NaviSync Meeting")
        .description("View active and upcoming joint meeting details.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#if DEBUG
#Preview(as: .systemSmall) {
    NaviSyncWidget()
} timeline: {
    SimpleEntry(date: Date(), meetingTitle: "Joint Coffee", locationName: "Uptown City Center", participantCount: 3)
}
#endif
