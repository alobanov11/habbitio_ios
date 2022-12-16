//
//  Created by Антон Лобанов on 18.11.2022.
//

import SwiftUI
import CoreData

struct HabitEditView: View {
    var habit: Habit?

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var error: Error? {
        willSet { onMainThreadAsync(2) { self.error = nil } }
    }

    @State private var title = ""
    @State private var frequency = 1
    @FocusState private var focused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                titleFieldView

                Divider()

                frequencyFieldView

                if let error = error {
                    Text(error.localizedDescription)
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundColor(.red)
                }

                if habit != nil {
                    Button(action: delete) {
                        Label("Delete Habit", systemImage: "trash.fill")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 24)
                }
            }
            .padding()
            .padding(.vertical)
        }
        .navigationTitle(habit == nil ? "New habit" : "Edit habit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: dismiss.callAsFunction) {
                    Text("Cancel")
                }
            }
            ToolbarItem {
                Button(action: done) {
                    Text(habit == nil ? "Add" : "Done")
                }
                .disabled(title.isEmpty)
            }
        }
        .onChange(of: title) {
            if $0.count > 16 {
                title = String($0.prefix(16))
            }
        }
        .onChange(of: frequency) {
            frequency = max(1, min(5, $0))
        }
        .onDisappear {
            NotificationCenter.default.post(name: .init("changes"), object: nil)
        }
        .onAppear {
            focused = true
            title = habit?.title ?? ""
            frequency = Int(habit?.frequency ?? 0)
        }
    }
}

private extension HabitEditView {
    var titleFieldView: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(lineWidth: 2)
            .frame(height: 48)
            .overlay {
                TextField("Title", text: $title)
                    .font(.system(.body, design: .monospaced))
                    .focused($focused)
                    .offset(x: 12)
            }
    }

    var frequencyFieldView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Frequency")
                    .font(.system(.body, design: .monospaced))

                Text("Times a day")
                    .foregroundColor(.gray)
                    .font(.system(.footnote, design: .monospaced))
            }

            Spacer()

            HStack(spacing: 16) {
                Button(action: { frequency -= 1 }) {
                    Image(systemName: "minus")
                        .tint(.white)
                        .frame(width: 36, height: 36)
                }
                .background(Color.gray.colorInvert().clipShape(Circle()))
                .disabled(frequency == 1)

                Text("\(frequency)")
                    .font(.system(.title2, design: .monospaced))

                Button(action: { frequency += 1 }) {
                    Image(systemName: "plus")
                        .tint(.white)
                        .frame(width: 36, height: 36)
                }
                .disabled(frequency == 5)
                .background(Color.gray.colorInvert().clipShape(Circle()))
            }
        }
    }
}

private extension HabitEditView {
    func done() {
        let habit = self.habit ?? Habit(context: self.viewContext)
        habit.title = self.title
        habit.frequency = Int16(self.frequency)
        habit.createdDate = habit.createdDate ?? Date()

        do {
            try self.viewContext.save()
            NotificationCenter.default.post(name: .init("changes"), object: nil)
            self.dismiss()
        }
        catch {
            self.error = UnknownError(error: error)
        }
    }

    func delete() {
        guard let habit = self.habit else { return }

        habit.isArchived = true

        do {
            try self.viewContext.save()
            NotificationCenter.default.post(name: .init("changes"), object: nil)
            self.dismiss()
        }
        catch {
            self.error = UnknownError(error: error)
        }
    }
}

struct HabitEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HabitEditView()
        }
    }
}
