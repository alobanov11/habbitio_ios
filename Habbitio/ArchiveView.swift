import SwiftData
import SwiftUI

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<Habit> { $0.isArchived == true },
        sort: \.createdDate
    )
    private var habits: [Habit]

    @State private var error: Error?

    var body: some View {
        Group {
            if habits.isEmpty {
                Text("Archive is empty")
                    .font(.system(.body, design: .monospaced))
            } else {
                List {
                    ForEach(habits) { habit in
                        Text(habit.title)
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

extension ArchiveView {
    fileprivate func undo(_ habit: Habit) {
        habit.isArchived = false

        do {
            try modelContext.save()
            NotificationCenter.default.post(name: .init("changes"), object: nil)
        } catch {
            print(error)
            self.error = error
        }
    }

    fileprivate func delete(_ habit: Habit) {
        modelContext.delete(habit)

        do {
            try modelContext.save()
            NotificationCenter.default.post(name: .init("changes"), object: nil)
        } catch {
            print(error)
            self.error = error
        }
    }
}

struct ArchivePreview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ArchiveView()
        }
        .modelContainer(DataManager.preview.modelContainer)
    }
}
