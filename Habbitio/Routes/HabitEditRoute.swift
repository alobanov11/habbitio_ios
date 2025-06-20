import SwiftUI
import Contracts

struct HabitEditRoute: View {

	struct UseCase {

		var deleteHabit: (Habit) async throws -> Void
		var archiveHabit: (Habit) async throws -> Void
		var unarchiveHabit: (Habit) async throws -> Void
		var saveHabit: (Habit) async throws -> Void
		var requestNotificationStatus: () async throws -> Bool
	}

	struct Props: Equatable {

		var name = ""
		var category = ""
		var days: [String] = []
		var reminder = false
		var reminderTime = Date()
		var reminderText = ""
	}

	@Environment(\.context.habitEdit)
	var useCase

	@Environment(\.dismiss)
	var dismiss

	@State
	var props = Props()

	@State
	var isValid = false

	@State
	var habit: Habit?

	@State
	var toastError: Error?

	@State
	var toastSuccess: String?

	@State
	var showDeleteConfirmation = false

	@State
	var showTimePicker = false

	@State
	var notificationsStatus = false

	var body: some View {
		ZStack {
			Color.backgroundPrimary
				.ignoresSafeArea()

			VStack(spacing: 16) {
				NavigationBar {
					HStack(spacing: 4) {
						Spacer()
						if let habit, habit.isArchived {
							Button {
								Task {
									do {
										try await useCase.unarchiveHabit(habit)
										withAnimation {
											self.habit?.isArchived = false
											toastSuccess = String(localized: "HABIT_EDIT_SUCCESS_UNARCHIVED")
										}
									} catch {
										withAnimation {
											toastError = error
										}
									}
								}
							} label: {
								Image(systemName: "archivebox")
									.font(.system(size: 18, design: .rounded))
									.foregroundColor(.textContrast)
									.frame(width: 48, height: 48)
									.background(Color.backgroundAccentAlternative)
									.clipShape(Circle())
							}
						}
						if habit != nil {
							Button {
								showDeleteConfirmation.toggle()
							} label: {
								Image(systemName: "trash")
									.font(.system(size: 18, design: .rounded))
									.foregroundColor(.textContrast)
									.frame(width: 48, height: 48)
									.background(Color.backgroundNegative)
									.clipShape(Circle())
							}
						}
					}
				}

				ScrollView {
					VStack(spacing: 16) {
						VStack(spacing: 12) {
							Text(habit == nil ? String(localized: "HABIT_EDIT_NEW_TITLE") : String(localized: "HABIT_EDIT_EDIT_TITLE"))
								.largeTitle(.textPrimary)
								.maxWidth(.leading)

							Text(
								habit == nil
									? String(localized: "HABIT_EDIT_NEW_SUBTITLE")
									: String(localized: "HABIT_EDIT_EDIT_SUBTITLE")
							)
							.body(.textSecondary)
							.maxWidth(.leading)
						}
						.padding(.horizontal, 24)
						.padding(.bottom, 12)

						HStack(spacing: 8) {
							InputTextView(
								text: $props.name,
								placeholder: String(localized: "COMMON_NAME")
							)

							InputTextView(
								text: $props.category,
								placeholder: String(localized: "COMMON_CATEGORY")
							)
						}
						.padding(.horizontal, 16)

						InputListView(title: String(localized: "COMMON_DAYS")) {
							InputChipsView(
								items: Calendar.current.shortWeekdaySymbols,
								selected: $props.days
							)
						}

						if props.reminder, notificationsStatus {
							HStack(spacing: 8) {
								InputCheckboxButton(
									title: String(localized: "COMMON_REMINDER"),
									selected: $props.reminder
								)

								InputSelectView(
									text: props.reminderTime.formatted(date: .omitted, time: .shortened),
									placeholder: String(localized: "COMMON_TIME")
								) {
									withAnimation {
										showTimePicker.toggle()
									}
								}
							}
							.padding(.horizontal, 16)
						}

						if props.reminder, notificationsStatus {
							InputTextView(
								text: $props.reminderText,
								placeholder: String(localized: "COMMON_TEXT"),
								lineLimit: 3
							)
							.padding(.horizontal, 16)
						} else {
							InputCheckboxButton(
								title: String(localized: "COMMON_REMINDER"),
								selected: $props.reminder
							)
							.padding(.horizontal, 16)
						}
					}
					.padding(.bottom, 100)
				}
			}
		}
		.overlay(alignment: .bottom) {
			PrimaryButton(title: habit == nil ? String(localized: "COMMON_CREATE") : String(localized: "COMMON_SAVE")) {
				let habit = Habit(
					title: props.name,
					category: props.category.isEmpty ? nil : props.category,
					days: props.days,
					isArchived: habit?.isArchived ?? false,
					isRemainderOn: props.reminder,
					reminderDate: props.reminder ? props.reminderTime : nil,
					reminderText: props.reminder ? props.reminderText : nil
				)
				do {
					let isNewHabit = self.habit == nil
					try await useCase.saveHabit(habit)
					withAnimation {
						self.habit = habit
					} completion: {
						withAnimation {
							toastSuccess = isNewHabit ? String(localized: "HABIT_EDIT_SUCCESS_CREATED") : String(localized: "HABIT_EDIT_SUCCESS_UPDATED")
						}
					}
				} catch {
					withAnimation {
						toastError = error
					}
				}
			}
			.safeAreaPadding(.bottom)
			.disabled(!isValid)
			.opacity(isValid ? 1 : 0.5)
			.padding(.horizontal, 24)
		}
		.onTapGesture {
			UIApplication.shared.endEditing()
		}
		.overlay {
			if showTimePicker {
				ZStack {
					Color.backgroundPrimary
						.opacity(0.9)
						.ignoresSafeArea()
						.onTapGesture {
							withAnimation {
								showTimePicker = false
							}
						}

					DatePicker(
						"",
						selection: $props.reminderTime,
						displayedComponents: [.hourAndMinute]
					)
					.datePickerStyle(WheelDatePickerStyle())
					.padding(24)
				}
			}
		}
		.unwrap(habit) { view, habit in
			view.alert(
				String(localized: "HABIT_EDIT_ALERT_TITLE"),
				isPresented: $showDeleteConfirmation,
				actions: {
					Button(String(localized: "COMMON_ARCHIVE")) {
						Task {
							do {
								try await useCase.archiveHabit(habit)
								withAnimation {
									self.habit?.isArchived = true
									toastSuccess = String(localized: "HABIT_EDIT_SUCCESS_ARCHIVED")
								}
							} catch {
								withAnimation {
									toastError = error
								}
							}
						}
					}
					Button(String(localized: "COMMON_DELETE"), role: .destructive) {
						Task {
							do {
									try await useCase.deleteHabit(habit)
								dismiss()
							} catch {
								withAnimation {
									toastError = error
								}
							}
						}
					}
					Button(String(localized: "COMMON_CANCEL"), role: .cancel) {}
				},
				message: {
					Text(String(localized: "HABIT_EDIT_ALERT_MESSAGE"))
				}
			)
		}
		.toast(error: $toastError, success: $toastSuccess, paddingBottom: 52 + 16)
		.navigationBarHidden(true)
		.onChange(of: props) { _, _ in
			isValid = (
				!props.name.isEmpty &&
				!props.days.isEmpty &&
				(props.reminder ? !props.reminderText.isEmpty : true)
			)
		}
		.onChange(of: props.reminder) { old, new in
			guard new, !old else { return }
			Task { @MainActor in
				do {
					notificationsStatus = try await useCase.requestNotificationStatus()
					if !notificationsStatus {
						toastError = String(localized: "HABIT_EDIT_NOTIFICATION_ERROR")
						props.reminder = false
					}
				} catch {
					toastError = error
				}
			}
		}
		.onAppear {
			guard let habit else { return }
			props.name = habit.title
			props.category = habit.category ?? ""
			props.days = habit.days
			props.reminder = habit.isRemainderOn
			props.reminderTime = habit.reminderDate ?? Date()
			props.reminderText = habit.reminderText ?? "Don't forget to work on your habit!"
		}
	}
}

extension HabitEditRoute.UseCase {

	init(store: IStore, habitNotificationService: IHabitNotificationService) {
		let notificationCenter = UNUserNotificationCenter.current()
		deleteHabit = { habit in
			notificationCenter.removePendingNotificationRequests(
				withIdentifiers: habit.notifications
			)
			try await store.deleteHabit(habit)
		}
		archiveHabit = { habit in
			var habit = habit
			habit.isArchived = true
			notificationCenter.removePendingNotificationRequests(
				withIdentifiers: habit.notifications
			)
			try await store.saveHabit(habit)
		}
		unarchiveHabit = { habit in
			var habit = habit
			habit.isArchived = false
			habit.notifications = try await habitNotificationService.scheduleNotifications(for: habit)
			try await store.saveHabit(habit)
		}
		saveHabit = { habit in
			var habit = habit
			habit.notifications = try await habitNotificationService.scheduleNotifications(for: habit)
			try await store.saveHabit(habit)
		}
		requestNotificationStatus = {
			try await notificationCenter.requestAuthorization(options: [.sound, .alert, .badge])
		}
	}

	init() {
		deleteHabit = { _ in  }
		archiveHabit = { _ in throw "Something went wrong" }
		unarchiveHabit = { _ in }
		saveHabit = { _ in }
		requestNotificationStatus = { true }
	}
}


#Preview {

	let habit = Habit(
		title: "Water Intake",
		category: "Health",
		days: Array(Calendar.current.shortWeekdaySymbols[0..<2]),
		isArchived: false,
		isRemainderOn: false,
		reminderDate: nil,
		reminderText: nil
	)

	NavigationStack {
		HabitEditRoute(
			habit: habit
		)
	}
}
