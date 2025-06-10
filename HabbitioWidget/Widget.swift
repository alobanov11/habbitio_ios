import SwiftData
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    let modelContext: ModelContext

    func placeholder(in _: Context) -> Entry { .preview }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        if context.isPreview {
            completion(self.placeholder(in: context))
        } else {
            completion(.init(date: Date(), activity: self.fetchActivity()))
        }
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        completion(
            Timeline(
                entries: [.init(date: Date(), activity: self.fetchActivity())],
                policy: .after(Date().addingTimeInterval(300))
            ))
    }

    private func fetchActivity() -> [Double] {
        let maxDays = 49

        let fetchDescriptor = FetchDescriptor<Report>(
            sortBy: [SortDescriptor(\.date)]
        )

        let reports = try? modelContext.fetch(fetchDescriptor)

        var activity: [Date: Double] = [:]

        for i in 0..<maxDays {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            let startDate = Calendar.current.startOfDay(for: date)
            activity[startDate] = 0
        }

        for report in reports?.suffix(maxDays) ?? [] {
            let startDate = Calendar.current.startOfDay(for: report.date)

            if activity[startDate] != nil {
                activity[startDate] = report.rate
            }
        }

        let result =
        activity
            .map { ($0.key, $0.value) }
            .sorted { $0.0 < $1.0 }
            .map { $0.1 }

        return result
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let activity: [Double]
}

struct HabbitioWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
            ForEach(0..<49) { value in
                let activity = entry.activity[value]
                RoundedRectangle(cornerRadius: 2)
                    .fill(activity == 0 ? Color.gray.opacity(0.2) : Color.green.opacity(activity))
                    .aspectRatio(1.0, contentMode: .fit)
            }
        }
        .padding()
    }
}

struct HabbitioWidget: Widget {
    let kind: String = "HabbitioWidget"
    let dataManager = DataManager.shared

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(modelContext: dataManager.modelContext)) {
            entry in
            HabbitioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habbitio widget")
        .description("Widget shows 49 days of your habits activity")
        .supportedFamilies([.systemSmall])
    }
}

struct HabbitioWidget_Previews: PreviewProvider {
    static var previews: some View {
        HabbitioWidgetEntryView(entry: .preview)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension Entry {
    static var preview: Entry {
        .init(date: Date(), activity: (0..<49).map { _ in Double.random(in: 0...1) })
    }
}
