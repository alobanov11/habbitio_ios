//
//  Created by Антон Лобанов on 18.11.2022.
//

import SwiftUI
import WidgetKit

struct HabbitListView: View {
    @EnvironmentObject private var persistence: Persistence
    @State private var records: [Record] = []
    @State private var animatedObject: ObjectIdentifier?
    @State private var error = false
    @State private var isEditing = false
    @State private var isPresented = false
    @State private var selectedHabbit: Habbit?

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
        .sheet(isPresented: $isPresented) {
            NavigationView {
                HabbitEditView(habbit: selectedHabbit)
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
            columns: [
                .init(.flexible(), spacing: 28),
                .init(.flexible()),
            ],
            spacing: 28
        ) {
            ForEach(records) { record in
                HabbitItemView(record: record, isEditing: isEditing)
                    .scaleEffect(animatedObject == record.id ? 0.9 : 1)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6))
                    .onTapGesture {
                        selectRecord(record)
                    }
            }
        }
    }

    var addButton: some View {
        Button(action: addHabbit) {
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

            let habbits = try self.persistence.container.viewContext.fetch(fetchRequest)

            self.records = habbits.map { habbit -> Record in
                if let record = habbit.records?.lastObject as? Record,
                   let date = record.date,
                   Calendar.current.isDateInToday(date)
                {
                    return record
                }

                let record = Record(context: self.persistence.container.viewContext)
                record.date = Date()
                record.habbit = habbit
                record.count = 0

                return record
            }

            if self.persistence.container.viewContext.hasChanges {
                try self.persistence.container.viewContext.save()
            }
        }
        catch {
            print(error)
            self.error = true
        }
    }

    func addHabbit() {
        self.selectedHabbit = nil
        self.isPresented = true
    }

    func selectRecord(_ record: Record) {
        self.animatedObject = record.id

        onMainThreadAsync(0.2) { self.animatedObject = nil }

        if self.isEditing {
            self.selectedHabbit = record.habbit
            self.isPresented = true
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

            try self.persistence.container.viewContext.save()
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

    var body: some View {
        VStack {
            HStack {
                Text(record.habbit?.title ?? "Empty title")
                    .font(.system(.callout, design: .monospaced))

                Spacer()
            }

            Spacer()

            HStack(alignment: .firstTextBaseline) {
                Text("\(record.count)")
                    .font(.system(size: 72, weight: .black, design: .monospaced))

                Text("/ \(record.habbit?.frequency ?? 0)")
                    .font(.system(.body, design: .monospaced))
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .frame(height: (.screenHeight / 4) - 50)
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
                .environmentObject(Persistence.preview)
        }
    }
}
