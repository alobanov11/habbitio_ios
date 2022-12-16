//
//  Created by Антон Лобанов on 18.11.2022.
//

import SwiftUI
import WidgetKit

struct HabbitListView: View {
    private enum SheetRoute: Identifiable, Hashable {
        var id: Int { hashValue }

        case newHabbit
        case editHabbit(Habbit)
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
                addButton
            }
            else {
                ScrollView {
                    VStack {
                        gridView
                            .padding(24)

                        addButton
                            .padding(.vertical, 24)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
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
                case .newHabbit:
                    HabbitEditView(habbit: nil)
                case let .editHabbit(habbit):
                    HabbitEditView(habbit: habbit)
                }
            }
        }
        .onBackground {
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onForeground(obtainRecords)
        .onAppear(perform: obtainRecords)
        .onReceive(changes) { _ in obtainRecords() }
    }
}

private extension HabbitListView {
    var gridView: some View {
        LazyVGrid(
            columns: Array(0..<itemsInRow).map { _ in
                GridItem(.flexible(), spacing: itemsInRow > 2 ? 14 : 28)
            },
            spacing: itemsInRow > 2 ? 14 : 28
        ) {
            ForEach(records) { record in
                HabbitItemView(record: record, isEditing: isEditing, itemsInRow: itemsInRow)
                    .scaleEffect(animatedObject == record.id ? 0.9 : 1)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6))
                    .onTapGesture {
                        selectRecord(record)
                    }
            }
        }
    }

    var addButton: some View {
        Button(action: { sheetRoute = .newHabbit }) {
            Label("Add Habbit", systemImage: "plus.circle")
                .font(.system(.headline, design: .monospaced))
                .padding()
        }
        .background(Capsule().stroke(lineWidth: 2))
    }
}

private extension HabbitListView {
    func obtainRecords() {
        do {
            let fetchRequest = Habbit.fetchRequest()

            let sort = NSSortDescriptor(key: #keyPath(Habbit.createdDate), ascending: true)
            fetchRequest.sortDescriptors = [sort]

            let habbits = try self.viewContext.fetch(fetchRequest)
            let maxFrequency = habbits.map { Int($0.frequency) }.reduce(0, +)

            self.records = habbits.map { habbit -> Record in
                let record: Record

                if let currentRecord = habbit.records?.lastObject as? Record,
                   let date = currentRecord.date,
                   Calendar.current.isDateInToday(date)
                {
                    record = currentRecord
                }
                else {
                    record = Record(context: self.viewContext)
                    record.date = Date()
                    record.habbit = habbit
                    record.count = 0
                }

                record.total = maxFrequency

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

        if self.isEditing, let habbit = record.habbit {
            self.sheetRoute = .editHabbit(habbit)
        }
        else {
            self.incrementRecordCounter(record)
        }
    }

    func incrementRecordCounter(_ record: Record) {
        do {
            let value = record.count + 1
            let maxValue = record.habbit?.frequency ?? 0
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

struct HabbitItemView: View {
    @ObservedObject var record: Record

    var isEditing: Bool
    var itemsInRow: Int

    var body: some View {
        VStack {
            HStack {
                Text(record.habbit?.title ?? "Empty title")
                    .font(.system(.callout, design: .monospaced))
                    .minimumScaleFactor(0.1)

                Spacer()
            }

            Spacer()

            HStack(alignment: .firstTextBaseline) {
                Text("\(record.count)")
                    .font(.system(size: 72, weight: .black, design: .monospaced))
                    .minimumScaleFactor(0.1)

                Text("/ \(record.habbit?.frequency ?? 0)")
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
                .stroke(style: StrokeStyle(lineWidth: 4, dash: isEditing ? [5] : []))
        )
    }
}

struct HabbitListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HabbitListView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
