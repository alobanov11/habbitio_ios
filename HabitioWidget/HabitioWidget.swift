//
//  Created by Антон Лобанов on 21.11.2022.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    let persistence: Persistence

    func placeholder(in _: Context) -> Entry { .preview }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        if context.isPreview {
            completion(self.placeholder(in: context))
        }
        else {
            completion(.init(date: Date(), activity: self.fetchActivity()))
        }
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        completion(Timeline(
            entries: [.init(date: Date(), activity: self.fetchActivity())],
            policy: .after(Date().addingTimeInterval(300))
        ))
    }

    private func fetchActivity() -> [Double] {
        let maxDays = 49
        let fetchRequest = Habbit.fetchRequest()
        let habbits = try? self.persistence.container.viewContext.fetch(fetchRequest)
        let maxFrequency = habbits?.map { Int($0.frequency) }.reduce(0, +) ?? 0

        var activity: [Date: Int] = [:]

        for i in 0 ..< maxDays {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            let startDate = Calendar.current.startOfDay(for: date)
            activity[startDate] = 0
        }

        for habbit in habbits ?? [] {
            for record in habbit.records?.suffix(maxDays).compactMap({ $0 as? Record }) ?? [] {
                let startDate = Calendar.current.startOfDay(for: record.date!)
                if let value = activity[startDate] {
                    activity[startDate] = value + Int(record.count)
                }
            }
        }

        let result = activity
            .map { ($0.key, $0.value) }
            .sorted { $0.0 < $1.0 }
            .map { maxFrequency != 0 ? Double($0.1) / Double(maxFrequency) : 0 }

        return result
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let activity: [Double]
}

struct HabitioWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
            ForEach(0 ..< 49) { value in
                let activity = entry.activity[value]
                RoundedRectangle(cornerRadius: 2)
                    .fill(activity == 0 ? Color.gray.opacity(0.2) : Color.green.opacity(activity))
                    .aspectRatio(1.0, contentMode: .fit)
            }
        }
        .padding()
    }
}

struct HabitioWidget: Widget {
    let kind: String = "HabitioWidget"
    let persistence = Persistence.shared

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(persistence: persistence)) { entry in
            HabitioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habbitio widget")
        .description("Widget shows 49 days of your habits activity")
        .supportedFamilies([.systemSmall])
    }
}

struct HabitioWidget_Previews: PreviewProvider {
    static var previews: some View {
        HabitioWidgetEntryView(entry: .preview)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension Entry {
    static var preview: Entry {
        .init(date: Date(), activity: (0 ..< 49).map { _ in Double.random(in: 0 ... 1) })
    }
}
