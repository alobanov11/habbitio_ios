//
//  Created by Антон Лобанов on 16.12.2022.
//

import SwiftUI

struct ArchiveView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.createdDate)],
        predicate: NSPredicate(format: "isArchived == %@", NSNumber(value: true)),
        animation: .default
    )
    private var habits: FetchedResults<Habit>

    @State private var error: Error?

    var body: some View {
        Group {
            if habits.isEmpty {
                Text("Archive is empty")
                    .font(.system(.body, design: .monospaced))
            }
            else {
                List {
                    ForEach(habits) { habit in
                        Text(habit.title ?? "")
                            .swipeActions(allowsFullSwipe: false) {
                                Button {
                                    undo(habit)
                                } label: {
                                    Label("Restore", systemImage: "arrow.uturn.backward")
                                }
                                .tint(.indigo)

                                Button(role: .destructive) {
                                    delete(habit)
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                    }
                }
            }
        }
        .toolbar {
            EditButton()
                .disabled(habits.isEmpty)
        }
        .navigationBarTitle("Archive")
    }
}

private extension ArchiveView {
    func undo(_ habit: Habit) {
        habit.isArchived = false

        do {
            try self.viewContext.save()
            NotificationCenter.default.post(name: .init("changes"), object: nil)
        }
        catch {
            print(error)
            self.error = error
        }
    }

    func delete(_ habit: Habit) {
        self.viewContext.delete(habit)

        do {
            try self.viewContext.save()
            NotificationCenter.default.post(name: .init("changes"), object: nil)
        }
        catch {
            print(error)
            self.error = error
        }
    }
}

struct ArchivePreview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ArchiveView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
