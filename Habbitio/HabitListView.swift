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

    private var itemsInRow: Int {
        switch records.count {
        case ...6: return 2
        default: return 3
        }
    }

    @Environment(\.managedObjectContext) private var viewContext

    @State private var records: [Record] = []
    @State private var animatedObject: ObjectIdentifier?
    @State private var error = false
    @State private var isEditing = false
    @State private var sheetRoute: SheetRoute?

    private let changes = NotificationCenter.default.publisher(for: .init("changes"))

    var body: some View {
        ZStack {
            if records.isEmpty {
                buttonControls
            }
            else {
                ScrollView {
                    VStack {
                        gridView
                            .padding(24)

                        buttonControls
                            .padding(.vertical, 24)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditing.toggle() }) {
                    if isEditing {
                        Text("Done")
                    }
                    else {
                        Text("Edit")
                    }
                }
                .disabled(records.isEmpty)
            }
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
        .onAppear(perform: obtainRecords)

    }
}

private extension HabitListView {
    var gridView: some View {
        LazyVGrid(
            columns: Array(0..<itemsInRow).map { _ in
                GridItem(.flexible(), spacing: itemsInRow > 2 ? 16 : 28)
            },
            spacing: itemsInRow > 2 ? 16 : 28
        ) {
            ForEach(records) { record in
                HabitItemView(record: record, isEditing: isEditing, itemsInRow: itemsInRow)
                    .scaleEffect(animatedObject == record.id ? 0.9 : 1)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6))
                    .onTapGesture {
                        selectRecord(record)
                    }
            }
        }
    }

    var buttonControls: some View {
        VStack(spacing: 16) {
            Button(action: { sheetRoute = .newHabit }) {
                Label("Add Habit", systemImage: "plus.circle")
                    .font(.system(.headline, design: .monospaced))
                    .padding(12)
            }
            .background(Capsule().stroke(lineWidth: 2))

            NavigationLink(destination: ArchiveView()) {
                Text("Archive")
                    .foregroundColor(Color("Color"))
                    .font(.system(.callout, design: .monospaced))
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
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

            report.total = habits.map { $0.frequency }.reduce(0, +)

            self.records = habits.map { habit -> Record in
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
                    record.count = 0
                }

                return record
            }

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

        if self.isEditing, let habit = record.habit {
            self.sheetRoute = .editHabit(habit)
        }
        else {
            self.incrementRecordCounter(record)
        }
    }

    func incrementRecordCounter(_ record: Record) {
        do {
            let value = record.count + 1
            let maxValue = record.habit?.frequency ?? 0
            record.count = min(value, maxValue)

            if value > maxValue {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }

            try self.viewContext.save()
        }
        catch {
            print(error)
            self.error = true
        }
    }
}

struct HabitItemView: View {
    @ObservedObject var record: Record

    var isEditing: Bool
    var itemsInRow: Int

    var body: some View {
        VStack {
            HStack {
                Text(record.habit?.title ?? "Empty title")
                    .font(.system(.callout, design: .monospaced))
                    .minimumScaleFactor(0.1)

                Spacer()
            }

            Spacer()

            HStack(alignment: .firstTextBaseline) {
                Text("\(record.count)")
                    .font(.system(size: 72, weight: .black, design: .monospaced))
                    .minimumScaleFactor(0.1)

                Text("/ \(record.habit?.frequency ?? 0)")
                    .font(.system(.body, design: .monospaced))
                    .minimumScaleFactor(0.1)
            }

            Spacer()
        }
        .padding(itemsInRow > 2 ? 16 : 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(style: StrokeStyle(lineWidth: itemsInRow > 2 ? 2 : 4, dash: isEditing ? [5] : []))
        )
    }
}

struct HabitListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HabitListView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
