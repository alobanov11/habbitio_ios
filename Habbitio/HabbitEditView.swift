//
//  Created by Антон Лобанов on 18.11.2022.
//

import SwiftUI

struct HabbitEditView: View {
    var habbit: Habbit?

    @EnvironmentObject private var persistence: Persistence
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var frequency = 1
    @State private var error = false
    @FocusState private var focused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                titleFieldView

                Divider()

                frequencyFieldView

                if habbit != nil {
                    Button(action: delete) {
                        Label("Delete Habbit", systemImage: "trash.fill")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 24)
                }
            }
            .padding()
            .padding(.vertical)
        }
        .navigationTitle(habbit == nil ? "New habbit" : "Edit habbit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: dismiss.callAsFunction) {
                    Text("Cancel")
                }
            }
            ToolbarItem {
                Button(action: done) {
                    Text(habbit == nil ? "Add" : "Done")
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
        .onAppear {
            focused = true
            title = habbit?.title ?? ""
            frequency = Int(habbit?.frequency ?? 0)
        }
    }
}

private extension HabbitEditView {
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
                }
                .frame(width: 36, height: 36)
                .background(Color.gray.colorInvert().clipShape(Circle()))
                .disabled(frequency == 1)

                Text("\(frequency)")
                    .font(.system(.title2, design: .monospaced))

                Button(action: { frequency += 1 }) {
                    Image(systemName: "plus")
                        .tint(.white)
                }
                .disabled(frequency == 5)
                .frame(width: 36, height: 36)
                .background(Color.gray.colorInvert().clipShape(Circle()))
            }
        }
    }
}

private extension HabbitEditView {
    func done() {
        let habbit = self.habbit ?? Habbit(context: self.persistence.container.viewContext)
        habbit.title = self.title
        habbit.frequency = Int16(self.frequency)
        habbit.createdDate = habbit.createdDate ?? Date()

        do {
            try self.persistence.container.viewContext.save()
            NotificationCenter.default.post(name: .init("changes"), object: nil)
            self.dismiss()
        }
        catch {
            print(error)
            self.error = true
        }
    }

    func delete() {
        guard let habbit = self.habbit else { return }
        self.persistence.container.viewContext.delete(habbit)

        do {
            try self.persistence.container.viewContext.save()
            NotificationCenter.default.post(name: .init("changes"), object: nil)
            self.dismiss()
        }
        catch {
            print(error)
            self.error = true
        }
    }
}

struct HabbitEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HabbitEditView()
        }
    }
}
