//
//  Created by Антон Лобанов on 18.11.2022.
//

import SwiftUI
import WidgetKit

struct HabitListView: View {
    private enum SheetRoute: Identifiable, Hashable {
        var id: Int { hashValue }

        case newHabit
        case editHabit(Habit)
    }

    private var currentWeekday: String {
        Calendar.current.shortWeekdaySymbols[
            Calendar.current.component(.weekday, from: .now) - 1
        ]
    }

    @Environment(\.managedObjectContext) private var viewContext

    @State private var records: [Record] = []
    @State private var animatedObject: ObjectIdentifier?
    @State private var error = false
    @State private var sheetRoute: SheetRoute?

    private let changes = NotificationCenter.default.publisher(for: .init("changes"))

    var body: some View {
        ZStack {
            if records.isEmpty {
                Text("Add your first habit")
                    .font(.system(.body, design: .monospaced))
            }
            else {
                ScrollView {
                    gridView
                        .padding(24)
                        .padding(.bottom, 96)
                }
            }

            buttonControls
                .padding(.vertical, 24)
        }
        .sheet(item: $sheetRoute) { route in
            NavigationView {
                switch route {
                case .newHabit:
                    HabitEditView(habit: nil)
                case let .editHabit(habit):
                    HabitEditView(habit: habit)
                }
            }
        }
        .onReceive(changes) { _ in
            obtainRecords()
        }
        .onBackground {
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onForeground(obtainRecords)
        .onAppear {
            requestNotificationStatus()
            obtainRecords()
        }
    }
}

private extension HabitListView {
    var gridView: some View {
        VStack(spacing: 24) {
            let sections = records
                .reduce(into: [String: [Record]]()) { $0[$1.habit?.category ?? "", default: []].append($1) }
                .map { ($0.key, $0.value) }
                .sorted { $0.0 > $1.0 }

            ForEach(sections, id: \.0) { (title, records) in
                VStack {
                    HStack {
                        Text(title)
                            .font(.system(.headline, design: .monospaced))

                        Spacer()
                    }
                    .hidden(title.isEmpty)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                        ],
                        spacing: 16
                    ) {
                        ForEach(records) { record in
                            HabitItemView(record: record)
                                .opacity(record.isEnabled == false ? 0.5 : record.done ? 0.5 : 1)
                                .scaleEffect(animatedObject == record.id ? 0.9 : 1)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6))
                                .onTapGesture {
                                    selectRecord(record)
                                }
                                .onLongPressGesture {
                                    doneRecord(record)
                                }
                        }
                    }
                }
            }
        }
    }

    var buttonControls: some View {
        HStack {
            Spacer()

            NavigationLink(destination: ArchiveView()) {
                Text("Archive")
                    .font(.system(.callout, design: .monospaced))
            }

            Spacer()

            Button(action: { sheetRoute = .newHabit }) {
                Text("Add habit")
                    .foregroundColor(Color("Color"))
                    .font(.system(.callout, design: .monospaced))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
            }
            .background(Capsule().fill(Color.accentColor))

            Spacer()

            NavigationLink(destination: StatsView()) {
                Text("Stats")
                    .font(.system(.callout, design: .monospaced))
            }

            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

private extension HabitListView {
    func obtainRecords() {
        self.viewContext.reset()

        do {
            let habitFetchRequest = Habit.fetchRequest()
            let habitSort = NSSortDescriptor(key: #keyPath(Habit.createdDate), ascending: true)
            let habitPredicate = NSPredicate(format: "isArchived == %@", NSNumber(value: false))

            habitFetchRequest.sortDescriptors = [habitSort]
            habitFetchRequest.predicate = habitPredicate

            let reportFetchRequest = Report.fetchRequest()
            let reportSort = NSSortDescriptor(key: #keyPath(Report.date), ascending: true)

            reportFetchRequest.sortDescriptors = [reportSort]

            let habits = try self.viewContext.fetch(habitFetchRequest)
            let reports = try self.viewContext.fetch(reportFetchRequest)

            let report: Report

            if let lastReport = reports.last,
               let date = lastReport.date,
               Calendar.current.isDateInToday(date)
            {
                report = lastReport
            }
            else {
                report = Report(context: self.viewContext)
                report.date = Date()
            }

            let records = habits.map { habit -> Record in
                let record: Record

                if let currentRecord = habit.records?.lastObject as? Record,
                   let date = currentRecord.date,
                   Calendar.current.isDateInToday(date)
                {
                    record = currentRecord
                }
                else {
                    record = Record(context: self.viewContext)
                    record.date = Date()
                    record.habit = habit
                    record.report = report
                }

                record.isEnabled = (habit.days ?? []).contains(currentWeekday)

                return record
            }

            self.records = records

            if self.viewContext.hasChanges {
                try self.viewContext.save()
            }
        }
        catch {
            print(error)
            self.error = true
        }
    }

    func selectRecord(_ record: Record) {
        self.animatedObject = record.id

        onMainThreadAsync(0.2) { self.animatedObject = nil }

        if let habit = record.habit {
            self.sheetRoute = .editHabit(habit)
        }
    }

    func doneRecord(_ record: Record) {
        self.animatedObject = record.id

        onMainThreadAsync(0.2) { self.animatedObject = nil }

        do {
            record.done.toggle()
            try self.viewContext.save()
        }
        catch {
            print(error)
            self.error = true
        }
    }

    func requestNotificationStatus() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { _, _ in }
    }
}

struct HabitItemView: View {
    @ObservedObject var record: Record

    var body: some View {
        VStack {
            Spacer()

            Text(record.habit?.title ?? "Empty title")
                .multilineTextAlignment(.center)
                .font(.system(.footnote, design: .monospaced))
                .fontWeight(.bold)
                .minimumScaleFactor(0.1)

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: []))
                .fill(record.done ? Color.green : Color.accentColor)
        )
    }
}

struct HabitListPreview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HabitListView()
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
