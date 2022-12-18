//
//  Created by Антон Лобанов on 18.11.2022.
//

import SwiftUI
import CoreData
import UserNotifications

struct HabitEditView: View {
    private enum Field {
        case title, category
    }

    var habit: Habit?

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var error: Error? {
        willSet { onMainThreadAsync(2) { self.error = nil } }
    }

    @State private var title = ""
    @State private var category = ""
    @State private var frequency = 1
    @State private var isReminderOn = false
    @State private var reminderDate = Date()
    @State private var reminderText = ""
    @State private var days = Set<String>()
    @State private var isTimePickerPresented = false
    @State private var notificationsStatus = false
    @FocusState private var focusedField: Field?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack(spacing: 24) {
                    titleFieldView

                    categoryFieldView
                }

                Divider()

                frequencyFieldView

                Divider()

                daysFieldView

                Divider()

                reminderView

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
        .overlay {
            if isTimePickerPresented {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .onTapGesture {
                            withAnimation {
                                isTimePickerPresented = false
                            }
                        }

                    DatePicker("", selection: $reminderDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                        .padding()
                }
                .ignoresSafeArea()
            }
        }
        .animation(.easeInOut, value: isReminderOn)
        .navigationTitle(habit == nil ? "New habit" : "Edit habit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: dismiss.callAsFunction) {
                    Text("Cancel")
                        .font(.system(.body, design: .monospaced))
                }
            }
            ToolbarItem {
                Button(action: done) {
                    Text(habit == nil ? "Add" : "Done")
                        .font(.system(.body, design: .monospaced))
                }
                .disabled(title.isEmpty || (isReminderOn ? reminderText.isEmpty : false))
            }
        }
        .onChange(of: title) {
            if $0.count > 16 {
                title = String($0.prefix(16))
            }
        }
        .onChange(of: category) {
            if $0.count > 16 {
                category = String($0.prefix(16))
            }
        }
        .onChange(of: frequency) {
            frequency = max(1, min(5, $0))
        }
        .onDisappear {
            NotificationCenter.default.post(name: .init("changes"), object: nil)
        }
        .onAppear {
            requestNotificationStatus()
            focusedField = .title
            title = habit?.title ?? ""
            category = habit?.category ?? ""
            frequency = Int(habit?.frequency ?? 0)
            days = Set(habit?.days ?? [])
            isReminderOn = habit?.isRemainderOn ?? false
            reminderDate = habit?.reminderDate ?? .now
            reminderText = habit?.reminderText ?? ""
        }
    }
}

private extension HabitEditView {
    var titleFieldView: some View {
        VStack(alignment: .leading) {
            Text("Name")
                .font(.system(.callout, design: .monospaced))
                .fontWeight(.bold)

            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 2)
                .frame(height: 48)
                .overlay {
                    TextField("", text: $title)
                        .font(.system(.body, design: .monospaced))
                        .focused($focusedField, equals: .title)
                        .offset(x: 12)
                }
        }
    }

    var categoryFieldView: some View {
        VStack(alignment: .leading) {
            Text("Category")
                .font(.system(.callout, design: .monospaced))
                .fontWeight(.bold)

            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 2)
                .frame(height: 48)
                .overlay {
                    TextField("", text: $category)
                        .font(.system(.body, design: .monospaced))
                        .focused($focusedField, equals: .category)
                        .offset(x: 12)
                }
        }
    }

    var frequencyFieldView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Frequency")
                    .font(.system(.callout, design: .monospaced))
                    .fontWeight(.bold)

                Text("Times a day")
                    .foregroundColor(.gray)
                    .font(.system(.footnote, design: .monospaced))
            }

            Spacer()

            HStack(spacing: 16) {
                Button(action: { frequency -= 1 }) {
                    Image(systemName: "minus")
                        .tint(Color("Color"))
                        .frame(width: 36, height: 36)
                }
                .background(Color.accentColor.clipShape(Circle()))
                .disabled(frequency == 1)

                Text("\(frequency)")
                    .font(.system(.body, design: .monospaced))

                Button(action: { frequency += 1 }) {
                    Image(systemName: "plus")
                        .tint(Color("Color"))
                        .frame(width: 36, height: 36)
                }
                .disabled(frequency == 5)
                .background(Color.accentColor.clipShape(Circle()))
            }
        }
    }

    var daysFieldView: some View {
        VStack(alignment: .leading) {
            Text("Days")
                .font(.system(.callout, design: .monospaced))
                .fontWeight(.bold)

            HStack(spacing: 10) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .foregroundColor(days.contains(day) ? Color("Color") : Color.accentColor)
                        .font(.system(.footnote, design: .monospaced))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if days.contains(day) {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.accentColor)
                            }
                            else {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(lineWidth: 2)
                                    .fill(Color.accentColor)
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                if days.contains(day) {
                                    days.remove(day)
                                }
                                else {
                                    days.insert(day)
                                }
                            }
                        }
                }
            }
        }
    }

    var reminderView: some View {
        VStack(spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Remainder")
                        .font(.system(.callout, design: .monospaced))
                        .fontWeight(.bold)

                    Text("Just notification")
                        .foregroundColor(.gray)
                        .font(.system(.footnote, design: .monospaced))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Toggle("", isOn: $isReminderOn)
                    .labelsHidden()
            }

            HStack(spacing: 24) {
                Label {
                    Text(reminderDate.formatted(date: .omitted, time: .shortened))
                        .foregroundColor(Color("Color"))
                        .font(.system(.footnote, design: .monospaced))
                        .fontWeight(.bold)
                } icon: {
                    Image(systemName: "clock")
                        .foregroundColor(Color("Color"))
                }
                .padding(.horizontal)
                .frame(height: 36)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .onTapGesture {
                    withAnimation {
                        focusedField = nil
                        isTimePickerPresented = true
                    }
                }

                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 2)
                    .frame(height: 36)
                    .overlay {
                        TextField("Remainder text", text: $reminderText)
                            .font(.system(.footnote, design: .monospaced))
                            .offset(x: 12)
                    }
            }
            .opacity(isReminderOn ? 1 : 0)
            .frame(height: isReminderOn ? nil : 0)
        }
        .opacity(notificationsStatus ? 1 : 0)
        .frame(height: notificationsStatus ? nil : 0)
    }
}

private extension HabitEditView {
    func done() {
        let habit = self.habit ?? Habit(context: self.viewContext)
        habit.title = self.title
        habit.category = self.category
        habit.frequency = Int16(self.frequency)
        habit.days = Array(self.days)
        habit.reminderDate = self.reminderDate
        habit.reminderText = self.reminderText
        habit.isRemainderOn = self.isReminderOn
        habit.createdDate = habit.createdDate ?? Date()

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: habit.notifications ?? [])

        if self.isReminderOn {
            let content = UNMutableNotificationContent()
            content.title = self.title
            content.subtitle = self.reminderText
            content.sound = .default

            var notifications: [String] = []
            let calendar = Calendar.current
            let weekdaySymbols = calendar.shortWeekdaySymbols

            for indexOfDay in 0..<weekdaySymbols.count {
                if self.days.contains(weekdaySymbols[indexOfDay]) == false {
                    continue
                }

                let id = UUID().uuidString
                let hour = calendar.component(.hour, from: self.reminderDate)
                let minute = calendar.component(.minute, from: self.reminderDate)

                var components = DateComponents()
                components.hour = hour
                components.minute = minute
                components.weekday = indexOfDay + 1

                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request)

                notifications.append(id)
            }

            habit.notifications = notifications
        }

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
        habit.isRemainderOn = false
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: habit.notifications ?? [])

        do {
            try self.viewContext.save()
            NotificationCenter.default.post(name: .init("changes"), object: nil)
            self.dismiss()
        }
        catch {
            self.error = UnknownError(error: error)
        }
    }

    func requestNotificationStatus() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { status, _ in
            onMainThread {
                self.notificationsStatus = status
            }
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
